/**
 * Shared TypeScript interfaces for the habit tracker application.
 * These types are used across the database layer, API routes, and UI components.
 */

export interface Habit {
  id: number
  name: string
  color: string
  created_at: string
}

export interface Completion {
  id: number
  habit_id: number
  date: string
}

export interface HabitWithStatus extends Habit {
  is_completed_today: boolean
}

export interface StreakDay {
  date: string
  is_completed: boolean
  label: string
}

export interface TodayStats {
  total: number
  completed: number
  percentage: number
}

export interface ApiError {
  error: string
  details?: unknown
}
