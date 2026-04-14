# Frontend Architecture

**Agent:** frontend-architect
**Phase:** 2
**Date:** 2026-04-14

---

## Component Hierarchy

```
app/page.tsx (Server Component — initial data fetch)
└── HabitTracker (Client Component — state owner)
    ├── CompletionHeader
    │   └── Progress (shadcn)
    ├── AddHabitForm
    │   ├── Input (shadcn)
    │   ├── Label (shadcn)
    │   ├── Button (shadcn)
    │   └── ColorPicker (custom — color swatches)
    └── HabitList
        └── HabitCard (one per habit)
            ├── CompletionToggle (checkbox-style button)
            ├── StreakCalendar (7 day cells)
            └── DeleteButton (shadcn Button, ghost variant)
```

---

## Data Flow

1. `page.tsx` (server) fetches initial habits + today stats via direct db calls
   (or via fetch to own API — use fetch for simplicity to avoid server/client split issues)
2. `HabitTracker` (client) owns `habits` and `stats` state
3. User actions (toggle, add, delete) call API routes via `fetch`
4. On success, local state is updated optimistically or re-fetched
5. `CompletionHeader` receives `stats` prop and re-renders on change

---

## State Management

No external state library needed. Use React `useState` + `useCallback`.

```typescript
// HabitTracker state
const [habits, setHabits] = useState<HabitWithStatus[]>(initialHabits)
const [stats, setStats] = useState<TodayStats>(initialStats)
const [isAddingHabit, setIsAddingHabit] = useState(false)
```

Optimistic updates for toggle (instant UI feedback):
```typescript
// On toggle click: immediately flip local state, then confirm with API
setHabits(prev => prev.map(h =>
  h.id === habitId
    ? { ...h, is_completed_today: !h.is_completed_today }
    : h
))
```

---

## Component Specifications

### CompletionHeader
Props: `{ stats: TodayStats }`
- Shows: "X / Y habits completed today" + percentage badge
- shadcn Progress component for visual bar
- Updates when stats prop changes

### AddHabitForm
Props: `{ onAdd: (habit: Habit) => void }`
- Collapsible card (toggle visibility with "Add Habit" button)
- Input for habit name (controlled, max 100 chars)
- ColorPicker: 10 color swatches as clickable circles
- Submit button: disabled when name is empty
- On submit: POST /api/habits, call onAdd, reset form

### ColorPicker
Props: `{ value: string; onChange: (color: string) => void }`
- 10 preset color circles (see research-report.md palette)
- Selected color has ring outline
- No text input — purely visual selection

### HabitCard
Props: `{ habit: HabitWithStatus; onToggle: () => void; onDelete: () => void }`
- Color dot (6px circle in habit color) + habit name
- CompletionToggle: large checkbox button, checked state based on `is_completed_today`
- StreakCalendar component
- Delete button (trash icon, ghost variant, top-right corner)
- Uses shadcn Card component for layout

### StreakCalendar
Props: `{ habitId: number; habitColor: string }`
- Client component that fetches /api/habits/[id]/streak on mount
- Shows 7 day columns: oldest to newest (left to right)
- Each cell: 28x28px rounded square
  - Completed: background = habitColor
  - Empty: background = gray-100, border = gray-200
- Day label below each cell (Mon/Tue/etc, "Today" for last)
- Loading skeleton while fetching

### HabitList
Props: `{ habits: HabitWithStatus[]; onToggle: ...; onDelete: ... }`
- Renders list of HabitCard
- Empty state: centered message "No habits yet. Add your first habit above."

---

## shadcn/ui Components Needed

- `button` — add, delete, toggle
- `card` — HabitCard wrapper
- `input` — habit name field
- `label` — form label
- `badge` — percentage display
- `progress` — completion bar

---

## Styling Conventions

- Tailwind utility classes only (no custom CSS except globals.css variables)
- `cn()` utility from `src/lib/utils.ts` for conditional classes
- Color for habit: always via inline `style={{ backgroundColor: habit.color }}`
  (dynamic values can't be Tailwind classes)
- Responsive: `grid-cols-1 md:grid-cols-2` for habit list on wider screens

---

## File Structure

```
src/
  app/
    layout.tsx
    page.tsx
    globals.css
    api/
      habits/
        route.ts
        [id]/
          route.ts
          streak/
            route.ts
      completions/
        route.ts
        today/
          route.ts
  components/
    ui/              # shadcn components (auto-generated)
    habit-tracker.tsx
    completion-header.tsx
    add-habit-form.tsx
    color-picker.tsx
    habit-list.tsx
    habit-card.tsx
    streak-calendar.tsx
  lib/
    db.ts
    types.ts
    utils.ts
```
