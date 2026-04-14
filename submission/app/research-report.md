# Research Report — Habit Tracker Tech Stack

**Agent:** research-analyst
**Phase:** 1
**Date:** 2026-04-14

---

## 1. Next.js 14 App Router — Key Findings

- App Router uses React Server Components (RSC) by default; client interactivity
  requires `'use client'` directive
- API routes live in `app/api/[route]/route.ts` using `NextRequest`/`NextResponse`
- Server Actions can replace some API routes but API routes are more explicit for
  this use case
- `better-sqlite3` must only be imported in server-side code (API routes, server
  components) — never in client components

## 2. better-sqlite3 — Key Findings

- Synchronous API (blocking) — acceptable for single-user local app
- Must be imported only in Node.js server context (not browser)
- Database file path: use `process.cwd()` + relative path or absolute path
- Needs native compilation: `npm install better-sqlite3` + `@types/better-sqlite3`
- In Next.js, must be excluded from client bundle via `next.config.js` externals
- Pattern: singleton database module to avoid multiple connections

## 3. shadcn/ui — Key Findings

- Not a traditional npm package — components are copied into `src/components/ui/`
- Init: `npx shadcn@latest init` (selects style, base color, CSS variables)
- Components added via: `npx shadcn@latest add button card input label badge`
- Uses Tailwind CSS v3 under the hood
- Requires `tailwind.config.ts` and `globals.css` with CSS variable definitions
- Key components for this app: Button, Card, Input, Label, Badge, Progress

## 4. SQLite Schema Best Practices

- Use TEXT for dates in YYYY-MM-DD format for easy string comparison
- Use UNIQUE constraints to prevent duplicate completions
- Use INTEGER PRIMARY KEY for auto-increment (SQLite alias for rowid)
- Foreign keys must be enabled per-connection: `PRAGMA foreign_keys = ON`
- Use transactions for multi-step writes

## 5. TypeScript Strict Mode Considerations

- `better-sqlite3` types: `Database`, `Statement` from `@types/better-sqlite3`
- API route handlers: `NextRequest` → typed body parsing via `await request.json()`
- Zod for runtime validation at API boundaries
- All database query results should be typed with explicit interfaces

## 6. Color Palette Recommendation

10 preset colors for habit colors (Tailwind-inspired):
```
#ef4444 (red-500)
#f97316 (orange-500)
#eab308 (yellow-500)
#22c55e (green-500)
#14b8a6 (teal-500)
#3b82f6 (blue-500)
#8b5cf6 (violet-500)
#ec4899 (pink-500)
#6366f1 (indigo-500)
#64748b (slate-500)
```

## 7. Streak Calendar UI Pattern

- Render 7 day columns: D-6, D-5, D-4, D-3, D-2, D-1, Today
- Each cell: small square (28x28px) with rounded corners
- Filled = habit color at full opacity; empty = gray-100 border
- Day label below: Mon, Tue, etc. or "Today"
- Use `date-fns` for reliable date arithmetic (format, subDays, isToday)

## 8. Recommended Project Structure

```
app/
  src/
    app/
      page.tsx          # Main page (server component)
      layout.tsx        # Root layout
      globals.css       # Tailwind + shadcn CSS vars
      api/
        habits/
          route.ts      # GET, POST
          [id]/
            route.ts    # DELETE
            streak/
              route.ts  # GET streak data
        completions/
          route.ts      # POST toggle
          today/
            route.ts    # GET today stats
    components/
      ui/               # shadcn/ui components
      habit-card.tsx
      habit-list.tsx
      add-habit-form.tsx
      completion-header.tsx
      streak-calendar.tsx
    lib/
      db.ts             # Database singleton + queries
      types.ts          # Shared TypeScript interfaces
      utils.ts          # Date helpers, cn() utility
```
