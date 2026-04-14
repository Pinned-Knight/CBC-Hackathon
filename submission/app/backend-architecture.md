# Backend Architecture

**Agent:** backend-engineer
**Phase:** 2
**Date:** 2026-04-14

---

## API Route Design

All routes follow REST conventions. Responses use JSON.
Error format: `{ error: string, details?: unknown }`

### Route Map

| Method | Path | Handler | DB Function |
|---|---|---|---|
| GET | /api/habits | listHabits | getHabitsWithTodayStatus |
| POST | /api/habits | createHabit | createHabit |
| DELETE | /api/habits/[id] | deleteHabit | deleteHabit |
| GET | /api/habits/[id]/streak | getStreak | getStreakDays |
| POST | /api/completions | toggleCompletion | toggleCompletion |
| GET | /api/completions/today | getTodayStats | getTodayStats |

---

## Request/Response Types

### GET /api/habits
Response: `HabitWithStatus[]`

### POST /api/habits
Request body (Zod-validated):
```typescript
const CreateHabitSchema = z.object({
  name: z.string().min(1).max(100),
  color: z.string().regex(/^#[0-9a-fA-F]{6}$/)
})
```
Response: `Habit` (201)
Error: 400 on validation failure, 500 on DB error

### DELETE /api/habits/[id]
Response: `{ success: true }` (200)
Error: 404 if habit not found, 400 if id is not a number

### GET /api/habits/[id]/streak
Query: none (uses today's date, computes last 7 days server-side)
Response: `StreakDay[]` (7 items)

### POST /api/completions
Request body (Zod-validated):
```typescript
const ToggleCompletionSchema = z.object({
  habit_id: z.number().int().positive(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/)
})
```
Response: `{ completed: boolean }` (200)
Error: 400 on validation, 404 if habit not found

### GET /api/completions/today
Response: `TodayStats` — `{ total: number, completed: number, percentage: number }`

---

## Error Handling Pattern

```typescript
try {
  // DB operation
} catch (error) {
  console.error('[API] operation failed:', error)
  return NextResponse.json(
    { error: 'Internal server error' },
    { status: 500 }
  )
}
```

Never expose raw DB errors to client.

---

## Date Handling

Server always computes today's date as:
```typescript
const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD
```

Streak dates computed server-side using date arithmetic:
```typescript
const dates = Array.from({ length: 7 }, (_, i) => {
  const d = new Date()
  d.setDate(d.getDate() - (6 - i))
  return d.toISOString().split('T')[0]
})
```

---

## next.config.ts Requirements

```typescript
// Must externalize better-sqlite3 from webpack client bundle
const config: NextConfig = {
  serverExternalPackages: ['better-sqlite3'],
}
```

---

## Validation Layer

All POST/PUT routes validate with Zod `safeParse`.
Invalid requests return 400 with field-level errors.
```typescript
const result = Schema.safeParse(await request.json())
if (!result.success) {
  return NextResponse.json(
    { error: 'Validation failed', details: result.error.flatten().fieldErrors },
    { status: 400 }
  )
}
```
