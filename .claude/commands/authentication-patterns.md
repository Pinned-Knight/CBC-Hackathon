---
description: Authentication and authorization implementation patterns — JWT, sessions, OAuth, RBAC, and security hardening. Activate when implementing auth in any application.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Authentication Patterns

## Auth Provider Decision
| Option | Use When |
|---|---|
| NextAuth.js (Auth.js) | Next.js app, need OAuth + credentials, self-hosted |
| Clerk | Fast setup, need pre-built UI, managed service |
| Supabase Auth | Already using Supabase, need row-level security |
| Custom JWT | Full control, non-Next.js, microservices |

## JWT Implementation (Custom)
```typescript
// Token generation
import jwt from 'jsonwebtoken'

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET!
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!

export function generateTokens(userId: string) {
  const accessToken = jwt.sign({ sub: userId, type: 'access' }, ACCESS_SECRET, { expiresIn: '15m' })
  const refreshToken = jwt.sign({ sub: userId, type: 'refresh' }, REFRESH_SECRET, { expiresIn: '7d' })
  return { accessToken, refreshToken }
}

export function verifyAccessToken(token: string): { sub: string } {
  return jwt.verify(token, ACCESS_SECRET) as { sub: string }
}
```

```typescript
// Auth middleware
export async function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (!token) return res.status(401).json({ error: { code: 'UNAUTHENTICATED' } })
  try {
    const payload = verifyAccessToken(token)
    req.user = await userRepo.findById(payload.sub)
    next()
  } catch {
    res.status(401).json({ error: { code: 'TOKEN_INVALID' } })
  }
}
```

## NextAuth.js Setup
```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth'
import GitHub from 'next-auth/providers/github'
import Credentials from 'next-auth/providers/credentials'

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    GitHub({ clientId: process.env.GITHUB_ID!, clientSecret: process.env.GITHUB_SECRET! }),
    Credentials({
      async authorize(credentials) {
        const result = loginSchema.safeParse(credentials)
        if (!result.success) return null
        const user = await userRepo.findByEmail(result.data.email)
        if (!user) return null
        const valid = await bcrypt.compare(result.data.password, user.password)
        return valid ? user : null
      }
    })
  ],
  callbacks: {
    jwt({ token, user }) {
      if (user) token.role = user.role
      return token
    },
    session({ session, token }) {
      session.user.role = token.role as string
      return session
    }
  }
})
```

## Role-Based Access Control (RBAC)
```typescript
// Define roles and permissions
const permissions = {
  admin:  ['users:read', 'users:write', 'users:delete', 'billing:manage'],
  member: ['users:read', 'profile:write'],
  viewer: ['users:read'],
} as const

type Permission = typeof permissions[keyof typeof permissions][number]
type Role = keyof typeof permissions

// Permission check middleware
export function requirePermission(permission: Permission) {
  return (req: Request, res: Response, next: NextFunction) => {
    const userPermissions = permissions[req.user.role as Role] ?? []
    if (!userPermissions.includes(permission)) {
      return res.status(403).json({ error: { code: 'FORBIDDEN' } })
    }
    next()
  }
}

// Usage
router.delete('/users/:id', authMiddleware, requirePermission('users:delete'), deleteUser)
```

## Password Security
```typescript
// Always hash with bcrypt (min 12 rounds) or Argon2
const hashed = await bcrypt.hash(plaintext, 12)
const valid = await bcrypt.compare(plaintext, hashed)

// Password strength requirements
const passwordSchema = z.string()
  .min(8, 'At least 8 characters')
  .regex(/[A-Z]/, 'At least one uppercase letter')
  .regex(/[0-9]/, 'At least one number')
```

## Refresh Token Rotation
- Store refresh tokens in database (allows revocation)
- Issue new refresh token on every use (rotation)
- Invalidate old refresh token immediately after use
- On reuse detection → revoke all tokens for user (security breach indicator)

## Security Rules
- Never store tokens in localStorage — use httpOnly cookies for web
- Short access token lifetime (15 min), longer refresh (7 days)
- Rate limit login endpoint: max 5 attempts per 15 minutes per IP
- Lock account after 10 failed attempts, require email unlock
- Always log auth events (login, logout, token refresh, failed attempts)
