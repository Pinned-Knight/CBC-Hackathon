import { NextResponse } from 'next/server'

import { getDb, getTodayStats } from '@/lib/db'
import { getTodayDate } from '@/lib/utils'

export async function GET(): Promise<NextResponse> {
  try {
    const db = getDb()
    const today = getTodayDate()
    const stats = getTodayStats(db, today)
    return NextResponse.json(stats)
  } catch (error) {
    console.error('[GET /api/completions/today] failed:', error)
    return NextResponse.json(
      { error: 'Failed to fetch today stats' },
      { status: 500 }
    )
  }
}
