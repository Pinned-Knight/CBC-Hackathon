import { NextResponse } from 'next/server'
import { z } from 'zod'

import { getDb, getHabitsWithTodayStatus, createHabit } from '@/lib/db'
import { getTodayDate } from '@/lib/utils'

const CreateHabitSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name must be 100 chars or fewer'),
  color: z.string().regex(/^#[0-9a-fA-F]{6}$/, 'Color must be a valid hex color'),
})

export async function GET(): Promise<NextResponse> {
  try {
    const db = getDb()
    const today = getTodayDate()
    const habits = getHabitsWithTodayStatus(db, today)
    return NextResponse.json(habits)
  } catch (error) {
    console.error('[GET /api/habits] failed:', error)
    return NextResponse.json({ error: 'Failed to fetch habits' }, { status: 500 })
  }
}

export async function POST(request: Request): Promise<NextResponse> {
  try {
    const body: unknown = await request.json()
    const result = CreateHabitSchema.safeParse(body)

    if (!result.success) {
      return NextResponse.json(
        { error: 'Validation failed', details: result.error.flatten().fieldErrors },
        { status: 400 }
      )
    }

    const db = getDb()
    const habit = createHabit(db, result.data.name, result.data.color)
    return NextResponse.json(habit, { status: 201 })
  } catch (error) {
    console.error('[POST /api/habits] failed:', error)
    return NextResponse.json({ error: 'Failed to create habit' }, { status: 500 })
  }
}
