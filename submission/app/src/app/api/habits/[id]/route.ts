import { NextResponse } from 'next/server'

import { getDb, deleteHabit, habitExists } from '@/lib/db'

interface RouteParams {
  params: { id: string }
}

export async function DELETE(
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

    deleteHabit(db, id)
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error(`[DELETE /api/habits/${id}] failed:`, error)
    return NextResponse.json({ error: 'Failed to delete habit' }, { status: 500 })
  }
}
