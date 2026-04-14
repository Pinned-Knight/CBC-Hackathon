# Project Context

> Auto-managed file. Updated by session-stop.sh and continuous-learning skill.
> Agents read this at session start to restore state.

## Status
Fresh — no sessions run yet. This file will be populated after the first agent session.

## How Agents Use This File
1. `session-start.sh` reads this file and prints the last known state
2. `orchestrator` reads this to determine which phase to resume from
3. `continuous-learning` appends new learnings after each session
4. `session-stop.sh` overwrites this with the latest snapshot

## Template (populated after first run)

```
Session: [id]
Phase: [dev|review|research|deploy]
MCP Profile: [fullstack|research|devops|...]
Git Branch: [branch name]

## App Being Built
[one-sentence description]

## Tech Stack (confirmed)
- Frontend: [Next.js 14 / React / etc]
- Backend: [Node.js / Express / etc]
- Database: [PostgreSQL via Drizzle]
- Auth: [NextAuth.js / Clerk]
- Payments: [Stripe / N/A]
- Deployment: [Vercel + Railway / AWS ECS / etc]

## Phase Progress
- [x] Phase 1 — Planning (PRD.md written)
- [x] Phase 2 — Architecture (all 3 architecture docs written)
- [ ] Phase 3 — Code Generation (in progress)
- [ ] Phase 4 — Integration
- [ ] Phase 5 — Review & Hardening
- [ ] Phase 6 — Deploy & Launch

## Key Files
- PRD.md: product requirements
- PLAN.md: execution plan
- backend-architecture.md: API contract
- frontend-architecture.md: component tree
- database-architecture.md: schema design
- build-log.md: full agent activity log

## Learned Patterns
(populated by continuous-learning skill)

## Open Questions
(populated by planner when PRD has ambiguities)
```
