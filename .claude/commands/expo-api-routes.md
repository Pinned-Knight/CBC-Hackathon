---
description: Expo API Routes — building backend API endpoints directly within an Expo app using Expo Router server features. Activate when adding backend functionality to an Expo project.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Expo API Routes

Expo Router supports server-side API routes that run on a Node.js server alongside your app — eliminating the need for a separate backend for simple use cases.

## Setup
```bash
# Requires Expo SDK 50+ with server output
# In app.json:
{
  "expo": {
    "web": { "output": "server" }
  }
}
```

## File Convention
API routes live in `app/` with `+api` suffix:
```
app/
  api/
    users+api.ts       — handles /api/users
    users/[id]+api.ts  — handles /api/users/:id
    auth/login+api.ts  — handles /api/auth/login
```

## Route Handler Structure
```typescript
// app/api/users+api.ts
import { ExpoRequest, ExpoResponse } from 'expo-router/server'

export async function GET(request: ExpoRequest): Promise<ExpoResponse> {
  const users = await db.user.findMany()
  return ExpoResponse.json(users)
}

export async function POST(request: ExpoRequest): Promise<ExpoResponse> {
  const body = await request.json()
  const result = schema.safeParse(body)
  if (!result.success) {
    return ExpoResponse.json({ error: result.error.flatten() }, { status: 422 })
  }
  const user = await db.user.create({ data: result.data })
  return ExpoResponse.json(user, { status: 201 })
}
```

## Dynamic Routes
```typescript
// app/api/users/[id]+api.ts
export async function GET(request: ExpoRequest, { id }: { id: string }) {
  const user = await db.user.findUnique({ where: { id } })
  if (!user) return ExpoResponse.json({ error: 'Not found' }, { status: 404 })
  return ExpoResponse.json(user)
}
```

## Middleware Pattern
```typescript
// lib/api-middleware.ts
export function withAuth(handler: Function) {
  return async (request: ExpoRequest, params: any) => {
    const token = request.headers.get('Authorization')?.replace('Bearer ', '')
    if (!token) return ExpoResponse.json({ error: 'Unauthorized' }, { status: 401 })
    const user = await verifyToken(token)
    return handler(request, params, { user })
  }
}
```

## Calling from the App
```typescript
// Use relative URLs in your app
const response = await fetch('/api/users', {
  headers: { Authorization: `Bearer ${token}` }
})
const users = await response.json()
```

## When to Use vs Separate Backend
- **Use Expo API Routes**: simple CRUD, auth callbacks, webhooks, BFF patterns
- **Use separate backend**: complex business logic, background jobs, heavy DB operations, microservices

## Rules
- Always validate request bodies with Zod
- Return consistent error shapes: `{ error: string, details?: any }`
- Use environment variables for secrets — never hardcode
- API routes only run when deployed with server output — not in static/SPA mode
