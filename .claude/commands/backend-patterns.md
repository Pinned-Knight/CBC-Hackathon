---
description: Backend architecture patterns — service layer, repository pattern, error handling, caching, background jobs, and observability. Activate when structuring backend code.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Backend Patterns

## Layered Architecture
```
HTTP Request
    ↓
Middleware (auth, rate limit, logging)
    ↓
Controller (parse request, call service, return response)
    ↓
Service (business logic, orchestration)
    ↓
Repository (data access, database queries)
    ↓
Database
```

## Repository Pattern
```typescript
// repositories/user.repository.ts
export class UserRepository {
  async findById(id: string): Promise<User | null> {
    return db.user.findUnique({ where: { id } })
  }
  async findByEmail(email: string): Promise<User | null> {
    return db.user.findUnique({ where: { email } })
  }
  async create(data: CreateUserInput): Promise<User> {
    return db.user.create({ data })
  }
  async update(id: string, data: UpdateUserInput): Promise<User> {
    return db.user.update({ where: { id }, data })
  }
}
```

## Service Layer
```typescript
// services/user.service.ts
export class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService,
  ) {}

  async createUser(input: CreateUserInput): Promise<User> {
    const existing = await this.userRepo.findByEmail(input.email)
    if (existing) throw new ConflictError('Email already registered')

    const hashed = await bcrypt.hash(input.password, 12)
    const user = await this.userRepo.create({ ...input, password: hashed })
    await this.emailService.sendWelcome(user.email)
    return user
  }
}
```

## Database Patterns
```typescript
// Select only needed columns — never SELECT *
const users = await db.user.findMany({
  select: { id: true, name: true, email: true },
  where: { active: true },
})

// Batch to prevent N+1
const users = await db.user.findMany({ where: { id: { in: userIds } } })
const userMap = new Map(users.map(u => [u.id, u]))

// Transaction for multi-step operations
await db.$transaction(async (tx) => {
  const order = await tx.order.create({ data: orderData })
  await tx.inventory.update({ where: { id: itemId }, data: { quantity: { decrement: 1 } } })
  return order
})
```

## Caching (Redis)
```typescript
// Cache-aside pattern
async function getUserById(id: string): Promise<User> {
  const cacheKey = `user:${id}`
  const cached = await redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  const user = await userRepo.findById(id)
  if (!user) throw new NotFoundError('User not found')

  await redis.setex(cacheKey, 3600, JSON.stringify(user)) // 1 hour TTL
  return user
}

// Invalidate on update
async function updateUser(id: string, data: UpdateUserInput) {
  const user = await userRepo.update(id, data)
  await redis.del(`user:${id}`)
  return user
}
```

## Error Handling
```typescript
// Custom error classes
export class AppError extends Error {
  constructor(public message: string, public statusCode: number, public code: string) {
    super(message)
  }
}
export class NotFoundError extends AppError {
  constructor(msg = 'Resource not found') { super(msg, 404, 'NOT_FOUND') }
}
export class ConflictError extends AppError {
  constructor(msg: string) { super(msg, 409, 'CONFLICT') }
}
export class ValidationError extends AppError {
  constructor(public details: any[]) { super('Validation failed', 422, 'VALIDATION_ERROR') }
}

// Centralized error handler middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: { code: err.code, message: err.message } })
  }
  logger.error({ err, req }, 'Unhandled error')
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' } })
})
```

## Observability
```typescript
// Structured JSON logging with pino
import pino from 'pino'
const logger = pino({ level: process.env.LOG_LEVEL ?? 'info' })

// Log with context — never raw strings
logger.info({ userId, requestId, action: 'user.created' }, 'User created')
logger.error({ err, userId, action: 'payment.failed' }, 'Payment failed')
```

## Background Jobs
- Use BullMQ (Redis-backed) for job queues
- Define job types with TypeScript interfaces
- Implement retry logic with exponential backoff (max 3 retries)
- Monitor queue health in observability dashboard
