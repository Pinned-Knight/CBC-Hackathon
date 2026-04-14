import Database from 'better-sqlite3'
import fs from 'fs'
import path from 'path'

import type { Habit, HabitWithStatus, StreakDay, TodayStats } from './types'

const DB_DIR = path.join(process.cwd(), 'data')
const DB_PATH = path.join(DB_DIR, 'habits.db')

let dbInstance: Database.Database | null = null

function initSchema(db: Database.Database): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS habits (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      name       TEXT    NOT NULL CHECK(length(name) >= 1 AND length(name) <= 100),
      color      TEXT    NOT NULL CHECK(length(color) = 7 AND color LIKE '#%'),
      created_at TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
    );

    CREATE TABLE IF NOT EXISTS completions (
      id       INTEGER PRIMARY KEY AUTOINCREMENT,
      habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
      date     TEXT    NOT NULL CHECK(date LIKE '____-__-__'),
      UNIQUE(habit_id, date)
    );

    CREATE INDEX IF NOT EXISTS idx_completions_habit_date
      ON completions(habit_id, date);

    CREATE INDEX IF NOT EXISTS idx_completions_date
      ON completions(date);
  `)
}

/**
 * Returns the singleton database connection, initializing it on first call.
 * Ensures the data directory exists before opening the database file.
 */
export function getDb(): Database.Database {
  if (!dbInstance) {
    if (!fs.existsSync(DB_DIR)) {
      fs.mkdirSync(DB_DIR, { recursive: true })
    }
    dbInstance = new Database(DB_PATH)
    dbInstance.pragma('journal_mode = WAL')
    dbInstance.pragma('foreign_keys = ON')
    initSchema(dbInstance)
  }
  return dbInstance
}

/**
 * Returns all habits with a boolean indicating if each was completed on the given date.
 */
export function getHabitsWithTodayStatus(
  db: Database.Database,
  today: string
): HabitWithStatus[] {
  const stmt = db.prepare<[string], { id: number; name: string; color: string; created_at: string; is_completed_today: number }>(`
    SELECT
      h.id,
      h.name,
      h.color,
      h.created_at,
      CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END AS is_completed_today
    FROM habits h
    LEFT JOIN completions c ON c.habit_id = h.id AND c.date = ?
    ORDER BY h.created_at ASC
  `)
  const rows = stmt.all(today)
  return rows.map((row) => ({
    ...row,
    is_completed_today: row.is_completed_today === 1,
  }))
}

/**
 * Returns streak data for the last 7 days for a given habit.
 * Days are ordered oldest-first (index 0 = 6 days ago, index 6 = today).
 */
export function getStreakDays(
  db: Database.Database,
  habitId: number,
  dates: string[]
): StreakDay[] {
  if (dates.length === 0) return []

  const placeholders = dates.map(() => '?').join(', ')
  const stmt = db.prepare<unknown[], { date: string }>(
    `SELECT date FROM completions WHERE habit_id = ? AND date IN (${placeholders})`
  )
  const completedRows = stmt.all(habitId, ...dates)
  const completedSet = new Set(completedRows.map((r) => r.date))

  const DAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

  return dates.map((date, index) => {
    const isToday = index === dates.length - 1
    const dayOfWeek = new Date(date + 'T12:00:00').getDay()
    const label = isToday ? 'Today' : (DAY_LABELS[dayOfWeek] ?? date)
    return {
      date,
      is_completed: completedSet.has(date),
      label,
    }
  })
}

/**
 * Toggles completion for a habit on a given date.
 * Inserts if not present, deletes if already present.
 * Returns the new completion state (true = now completed).
 */
export function toggleCompletion(
  db: Database.Database,
  habitId: number,
  date: string
): boolean {
  const checkStmt = db.prepare<[number, string], { id: number }>(
    'SELECT id FROM completions WHERE habit_id = ? AND date = ?'
  )
  const existing = checkStmt.get(habitId, date)

  if (existing) {
    db.prepare('DELETE FROM completions WHERE habit_id = ? AND date = ?').run(
      habitId,
      date
    )
    return false
  } else {
    db.prepare(
      'INSERT INTO completions (habit_id, date) VALUES (?, ?)'
    ).run(habitId, date)
    return true
  }
}

/**
 * Returns overall completion stats for today.
 */
export function getTodayStats(
  db: Database.Database,
  today: string
): TodayStats {
  const stmt = db.prepare<[string], { total: number; completed: number }>(`
    SELECT
      COUNT(*) AS total,
      SUM(CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END) AS completed
    FROM habits h
    LEFT JOIN completions c ON c.habit_id = h.id AND c.date = ?
  `)
  const row = stmt.get(today)
  const total = row?.total ?? 0
  const completed = row?.completed ?? 0
  const percentage = total === 0 ? 0 : Math.round((completed / total) * 100)
  return { total, completed, percentage }
}

/**
 * Creates a new habit and returns the created record.
 */
export function createHabit(
  db: Database.Database,
  name: string,
  color: string
): Habit {
  const stmt = db.prepare<[string, string], { id: number; name: string; color: string; created_at: string }>(
    'INSERT INTO habits (name, color) VALUES (?, ?) RETURNING id, name, color, created_at'
  )
  const habit = stmt.get(name, color)
  if (!habit) {
    throw new Error('Failed to create habit — no row returned')
  }
  return habit
}

/**
 * Deletes a habit by ID. Returns true if a row was deleted, false if not found.
 */
export function deleteHabit(db: Database.Database, id: number): boolean {
  const result = db.prepare('DELETE FROM habits WHERE id = ?').run(id)
  return result.changes > 0
}

/**
 * Checks if a habit with the given ID exists.
 */
export function habitExists(db: Database.Database, id: number): boolean {
  const row = db
    .prepare<[number], { id: number }>('SELECT id FROM habits WHERE id = ?')
    .get(id)
  return row !== undefined
}
