# Task Plan — Habit Tracker App

**Agent:** planner
**Phase:** 1 -> 2
**Date:** 2026-04-14

---

## Phase Gate Checklist

- [x] PRD.md created (product-strategist)
- [x] research-report.md created (research-analyst)
- [x] PLAN.md created (planner) — Phase 2 may now start

---

## Atomic Task List

### DATABASE-ENGINEER Tasks (Phase 2-3)

| ID | Task | Output File |
|---|---|---|
| DB-01 | Design SQLite schema (habits + completions tables) | database-architecture.md |
| DB-02 | Create database singleton module with typed queries | src/lib/db.ts |
| DB-03 | Define TypeScript interfaces for DB entities | src/lib/types.ts |

### BACKEND-ENGINEER Tasks (Phase 2-3)

| ID | Task | Output File |
|---|---|---|
| BE-01 | Design API route structure and request/response types | backend-architecture.md |
| BE-02 | Implement GET /api/habits | src/app/api/habits/route.ts |
| BE-03 | Implement POST /api/habits (with Zod validation) | src/app/api/habits/route.ts |
| BE-04 | Implement DELETE /api/habits/[id] | src/app/api/habits/[id]/route.ts |
| BE-05 | Implement GET /api/habits/[id]/streak (7-day data) | src/app/api/habits/[id]/streak/route.ts |
| BE-06 | Implement POST /api/completions (toggle) | src/app/api/completions/route.ts |
| BE-07 | Implement GET /api/completions/today (stats) | src/app/api/completions/today/route.ts |

### FRONTEND-ARCHITECT Tasks (Phase 2-3)

| ID | Task | Output File |
|---|---|---|
| FE-01 | Design component hierarchy and data flow | frontend-architecture.md |
| FE-02 | Set up Next.js project config files | package.json, tsconfig.json, next.config.ts, tailwind.config.ts |
| FE-03 | Set up shadcn/ui components | src/components/ui/* |
| FE-04 | Create root layout and globals.css | src/app/layout.tsx, src/app/globals.css |
| FE-05 | Create main page (server component) | src/app/page.tsx |
| FE-06 | Create CompletionHeader component | src/components/completion-header.tsx |
| FE-07 | Create AddHabitForm component | src/components/add-habit-form.tsx |
| FE-08 | Create HabitList component | src/components/habit-list.tsx |
| FE-09 | Create HabitCard component | src/components/habit-card.tsx |
| FE-10 | Create StreakCalendar component | src/components/streak-calendar.tsx |
| FE-11 | Create utility functions | src/lib/utils.ts |

### MCP-INTEGRATION-ENGINEER Tasks (Phase 4)

| ID | Task | Output File |
|---|---|---|
| INT-01 | Wire next.config to externalize better-sqlite3 | next.config.ts |
| INT-02 | Create .env.example | .env.example |
| INT-03 | Verify all imports/exports are consistent | (review pass) |
| INT-04 | Create docker-compose.yml for optional containerization | docker-compose.yml |

### QA-AGENT Tasks (Phase 5)

| ID | Task | Output File |
|---|---|---|
| QA-01 | Write unit tests for db.ts query functions | src/lib/__tests__/db.test.ts |
| QA-02 | Write API route tests | src/__tests__/api/ |
| QA-03 | Write component tests for HabitCard | src/components/__tests__/ |
| QA-04 | Generate qa-report.md | qa-report.md |

### SECURITY-AGENT Tasks (Phase 5)

| ID | Task | Output File |
|---|---|---|
| SEC-01 | Audit API input validation (Zod schemas) | security-report.md |
| SEC-02 | Check for SQL injection vectors | security-report.md |
| SEC-03 | Review dependency versions | security-report.md |

### DEVOPS-AGENT Tasks (Phase 6)

| ID | Task | Output File |
|---|---|---|
| DEV-01 | Create GitHub Actions CI workflow | .github/workflows/ci.yml |
| DEV-02 | Create Dockerfile | Dockerfile |

### DOCS-AGENT Tasks (Phase 6)

| ID | Task | Output File |
|---|---|---|
| DOC-01 | Create README.md | README.md |

---

## Dependency Graph

```
DB-01 -> DB-02 -> DB-03
BE-01 -> BE-02..BE-07 (depend on DB-02, DB-03)
FE-01 -> FE-02..FE-11 (depend on BE-01, DB-03)
INT-01..INT-04 (depend on all Phase 3 outputs)
QA-01..QA-04 (depend on Phase 4 outputs)
SEC-01..SEC-03 (depend on Phase 4 outputs)
DEV-01..DEV-02 (depend on Phase 5 sign-off)
DOC-01 (depends on Phase 5 sign-off)
```
