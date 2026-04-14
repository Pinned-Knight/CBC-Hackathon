# Product Requirements Document — Personal Habit Tracker

**Agent:** product-strategist
**Phase:** 1
**Date:** 2026-04-14

---

## 1. Product Overview

A personal habit tracker web application that enables a single user to define habits,
track daily completions, and visualize streaks and completion rates over time.
The app is local-first, file-based (SQLite), and requires no authentication, payments,
or external API calls.

---

## 2. Target User

A single person who wants a lightweight, fast, self-hosted habit tracker running
locally in their browser with zero setup beyond `npm run dev`.

---

## 3. Core Features

### F-01: Habit Management
- User can add a habit with a name (required, 1–100 chars) and a color (required,
  from a preset palette of 10 colors)
- User can delete a habit (with confirmation)
- Habits persist across sessions via SQLite

### F-02: Daily Completion Toggle
- User can mark any habit as complete for today's date
- Toggle is idempotent — clicking again un-marks it
- Completion state shown visually (filled vs empty circle/checkbox)

### F-03: 7-Day Streak Calendar
- Each habit card shows the last 7 days as a mini calendar row
- Each day cell is filled (habit color) if completed, empty if not
- Today's cell is always visible and interactive

### F-04: Overall Daily Completion Percentage
- A header/dashboard bar shows: "Today: X of Y habits completed (Z%)"
- Updates in real-time as user toggles completions
- Shows "No habits yet" when list is empty

### F-05: Responsive UI with shadcn/ui
- Mobile-friendly layout (single-column on small screens, up to 2-col on desktop)
- Light mode by default (no dark mode required for MVP)
- Clean, minimal aesthetic using shadcn/ui components

---

## 4. Non-Requirements (Explicitly Out of Scope)

- No authentication or multi-user support
- No external APIs, analytics, or telemetry
- No payments or subscriptions
- No notifications or reminders
- No mobile app (web only)
- No dark mode (MVP)
- No data export (MVP)

---

## 5. Technical Stack

| Layer | Technology |
|---|---|
| Framework | Next.js 14+ (App Router) |
| Language | TypeScript 5+ (strict mode) |
| UI Library | shadcn/ui (Radix UI + Tailwind CSS) |
| Database | SQLite via better-sqlite3 |
| ORM | Raw SQL with typed wrapper functions |
| Styling | Tailwind CSS v3 |
| Package Manager | npm |
| Node Version | 18+ |

---

## 6. Data Model (High Level)

**habits** table:
- id (integer primary key autoincrement)
- name (text, not null)
- color (text, not null — hex color string)
- created_at (text, ISO datetime)

**completions** table:
- id (integer primary key autoincrement)
- habit_id (integer, foreign key -> habits.id)
- date (text, YYYY-MM-DD format)
- UNIQUE constraint on (habit_id, date)

---

## 7. API Routes (Next.js App Router)

| Method | Path | Description |
|---|---|---|
| GET | /api/habits | List all habits with today's completion status |
| POST | /api/habits | Create a new habit |
| DELETE | /api/habits/[id] | Delete a habit and its completions |
| GET | /api/habits/[id]/streak | Get 7-day streak data for a habit |
| POST | /api/completions | Toggle completion for a habit on a date |
| GET | /api/completions/today | Get today's overall completion percentage |

---

## 8. Acceptance Criteria

- AC-01: User can create a habit with name + color and it persists after page refresh
- AC-02: User can mark a habit complete for today; UI reflects change immediately
- AC-03: User can un-mark a habit; toggle is reversible
- AC-04: 7-day calendar shows correct fill for each day based on DB completions
- AC-05: Header shows correct X/Y and percentage, updating on toggle
- AC-06: User can delete a habit; it disappears with all its completions
- AC-07: App loads in < 2 seconds on localhost
- AC-08: No TypeScript errors (`tsc --noEmit` passes)
- AC-09: No runtime errors in browser console on normal usage

---

## 9. Page Structure

Single page app at `/` (root route):
- `<Header>` — app title + daily completion stats
- `<AddHabitForm>` — inline form or modal to add new habit
- `<HabitList>` — list of `<HabitCard>` components
- `<HabitCard>` — name, color dot, today's toggle, 7-day streak row, delete button
