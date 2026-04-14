# Commands Quick Reference

All slash commands available in this system. Use `/command-name` to invoke.

---

## Frontend

| Command | When to Use |
|---|---|
| `/react-best-practices` | Writing or reviewing React components |
| `/next-best-practices` | Building with Next.js App Router |
| `/shadcn-ui` | Implementing UI with shadcn/ui components |
| `/composition-patterns` | Designing reusable component APIs |
| `/web-design-guidelines` | Making UI layout and visual decisions |
| `/frontend-design` | Designing interactions, states, animations |
| `/webapp-testing` | Writing frontend component or hook tests |

## Mobile

| Command | When to Use |
|---|---|
| `/expo-ui` | Building native UI with Expo |
| `/expo-api-routes` | Adding backend routes to an Expo app |
| `/react-native-best-practices` | React Native architecture and performance |

## Backend

| Command | When to Use |
|---|---|
| `/api-design` | Designing REST API endpoints |
| `/backend-patterns` | Structuring service/repository layers |
| `/authentication-patterns` | Implementing auth (JWT, NextAuth, RBAC) |
| `/stripe-best-practices` | Integrating Stripe payments |

## Data

| Command | When to Use |
|---|---|
| `/postgres-best-practices` | PostgreSQL schema, queries, RLS |
| `/database-designer` | Designing DB schema from requirements |
| `/migration-architect` | Planning zero-downtime migrations |
| `/analytics-pipelines` | Building event tracking and data pipelines |

## Testing & QA

| Command | When to Use |
|---|---|
| `/tdd-workflow` | Writing code test-first (RED-GREEN-REFACTOR) |
| `/verification-loop` | Running the 6-phase quality gate |
| `/e2e-testing` | Writing Playwright end-to-end tests |
| `/performance-optimization` | Diagnosing and fixing performance issues |
| `/dependency-auditor` | Auditing deps for vulnerabilities and bloat |

## Research & Product

| Command | When to Use |
|---|---|
| `/deep-research` | Multi-source research on any topic |
| `/documentation-lookup` | Fetching live library/framework docs |
| `/market-research` | Competitive analysis, market sizing |
| `/agent-designer` | Designing multi-agent system architecture |
| `/workflow-designer` | Building multi-agent workflow pipelines |

## Automation & Meta

| Command | When to Use |
|---|---|
| `/continuous-learning` | Capturing and persisting session learnings |
| `/strategic-compact` | Compressing context before agent handoffs |
| `/cost-aware-llm-pipeline` | Tracking and optimizing token costs |
| `/security-scan` | Fast automated security scan (every phase) |
| `/eval-harness` | Scoring generated app quality (0-100) |

---

## Agents (invoked by orchestrator via `Agent` tool)

| Agent | Phase | Role |
|---|---|---|
| `orchestrator` | All | Master controller |
| `planner` | 1 | PRD → execution plan |
| `product-strategist` | 1 | Prompt → PRD |
| `research-analyst` | 1 | Research via MCP |
| `frontend-architect` | 2-3 | UI code generation |
| `backend-engineer` | 2-3 | API code generation |
| `database-engineer` | 2-3 | Schema + migration |
| `mcp-integration-engineer` | 4 | Wire all services |
| `code-reviewer` | 3→4 | Review generated code |
| `refactor-cleaner` | 3→4 | Clean up code |
| `build-error-resolver` | Any | Fix build failures |
| `qa-agent` | 5 | Tests + coverage |
| `security-agent` | 5 | Audit + hardening |
| `devops-agent` | 6 | CI/CD + deployment |
| `docs-agent` | 6 | Documentation |
| `growth-agent` | 6 | Launch + marketing |

---

## MCP Profiles (set via `MCP_PROFILE` env var)

| Profile | Tools | Use In |
|---|---|---|
| `fullstack` | FS, GitHub, Postgres, Redis, Puppeteer | Default |
| `research` | Brave Search, Fetch, Memory, Exa | Phase 1 |
| `frontend` | Puppeteer, Figma, Storybook | Phase 2-3 UI |
| `devops` | AWS, Docker, GitHub, Terraform, Sentry | Phase 6 |
| `security` | Snyk, Ghidra | Phase 5 |
| `observability` | Sentry, Postgres, Memory | Phase 5 |
| `design` | Figma, Blender | Design work |
| `mobile` | Android ADB, Xcode | Mobile apps |
| `data-science` | Jupyter, SQLite, Postgres | Data work |
| `workflow-automation` | n8n, Pipedream | Phase 4 |
