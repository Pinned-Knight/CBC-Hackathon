# Database Architecture

**Agent:** database-engineer
**Phase:** 2
**Date:** 2026-04-14

---

## Schema Design

### habits table
```sql
CREATE TABLE IF NOT EXISTS habits (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL CHECK(length(name) >= 1 AND length(name) <= 100),
  color      TEXT    NOT NULL CHECK(length(color) = 7 AND color LIKE '#%'),
  created_at TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);
```

### completions table
```sql
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
```

---

## TypeScript Interfaces

```typescript
interface Habit {
  id: number;
  name: string;
  color: string;
  created_at: string;
}

interface Completion {
  id: number;
  habit_id: number;
  date: string;
}

interface HabitWithStatus extends Habit {
  is_completed_today: boolean;
}

interface StreakDay {
  date: string;       // YYYY-MM-DD
  is_completed: boolean;
  label: string;      // Mon, Tue, ..., Today
}

interface TodayStats {
  total: number;
  completed: number;
  percentage: number;
}
```

---

## Query Functions

### getHabitsWithTodayStatus(db, today: string): HabitWithStatus[]
```sql
SELECT
  h.*,
  CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END AS is_completed_today
FROM habits h
LEFT JOIN completions c ON c.habit_id = h.id AND c.date = ?
ORDER BY h.created_at ASC
```

### getStreakDays(db, habitId: number, dates: string[]): StreakDay[]
```sql
SELECT date FROM completions
WHERE habit_id = ? AND date IN (?, ?, ?, ?, ?, ?, ?)
```
(Build StreakDay[] by checking returned dates against input array)

### toggleCompletion(db, habitId: number, date: string): boolean
```sql
-- If exists: DELETE FROM completions WHERE habit_id = ? AND date = ?
-- If not exists: INSERT INTO completions (habit_id, date) VALUES (?, ?)
-- Returns: new completed state (true = just completed, false = just removed)
```

### getTodayStats(db, today: string): TodayStats
```sql
SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END) AS completed
FROM habits h
LEFT JOIN completions c ON c.habit_id = h.id AND c.date = ?
```

### createHabit(db, name: string, color: string): Habit
```sql
INSERT INTO habits (name, color) VALUES (?, ?)
```

### deleteHabit(db, id: number): void
```sql
DELETE FROM habits WHERE id = ?
-- Cascade deletes completions via FK
```

---

## Database Singleton Pattern

```typescript
// src/lib/db.ts
import Database from 'better-sqlite3'
import path from 'path'

const DB_PATH = path.join(process.cwd(), 'data', 'habits.db')

let db: Database.Database | null = null

export function getDb(): Database.Database {
  if (!db) {
    db = new Database(DB_PATH)
    db.pragma('journal_mode = WAL')
    db.pragma('foreign_keys = ON')
    initSchema(db)
  }
  return db
}
```

---

## Notes
- WAL mode for better concurrent read performance
- Foreign keys ON to enable cascade deletes
- Data directory: `{project_root}/data/habits.db`
- Date format: always YYYY-MM-DD (ISO 8601 date only)
