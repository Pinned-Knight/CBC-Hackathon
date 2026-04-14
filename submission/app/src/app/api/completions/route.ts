import { NextResponse } from 'next/server'
import { z } from 'zod'

import { getDb, toggleCompletion, habitExists } from '@/lib/db'

const ToggleCompletionSchema = z.object({
  habit_id: z.number().int().positive('habit_id must be a positive integer'),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be in YYYY-MM-DD format'),
})

export async function POST(request: Request): Promise<NextResponse> {
  try {
    const body: unknown = await request.json()
    const result = ToggleCompletionSchema.safeParse(body)

    if (!result.success) {
      return NextResponse.json(
        { error: 'Validation failed', details: result.error.flatten().fieldErrors },
        { status: 400 }
      )
    }

    const db = getDb()
    const { habit_id, date } = result.data

    if (!habitExists(db, habit_id)) {
      return NextResponse.json({ error: 'Habit not found' }, { status: 404 })
    }

    const completed = toggleCompletion(db, habit_id, date)
    return NextResponse.json({ completed })
  } catch (error) {
    console.error('[POST /api/completions] failed:', error)
    return NextResponse.json({ error: 'Failed to toggle completion' }, { status: 500 })
  }
}
