import { NextResponse } from 'next/server'

import { getDb, getStreakDays, habitExists } from '@/lib/db'
import { getLastNDays } from '@/lib/utils'

interface RouteParams {
  params: { id: string }
}

export async function GET(
  _request: Request,
  { params }: RouteParams
): Promise<NextResponse> {
  const id = parseInt(params.id, 10)

  if (isNaN(id) || id <= 0) {
    return NextResponse.json({ error: 'Invalid habit ID' }, { status: 400 })
  }

  try {
    const db = getDb()

    if (!habitExists(db, id)) {
      return NextResponse.json({ error: 'Habit not found' }, { status: 404 })
    }

    const dates = getLastNDays(7)
    const streakDays = getStreakDays(db, id, dates)
    return NextResponse.json(streakDays)
  } catch (error) {
    console.error(`[GET /api/habits/${id}/streak] failed:`, error)
    return NextResponse.json({ error: 'Failed to fetch streak data' }, { status: 500 })
  }
}
