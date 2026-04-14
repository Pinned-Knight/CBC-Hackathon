# Tech Stack Defaults

> Injected by orchestrator when spawning architect agents.
> Agents read this to know the project's confirmed technology choices.
> Overridden by PRD.md if the user specified a different stack.

## Default Full-Stack Web App

### Frontend
| Concern | Choice | Why |
|---|---|---|
| Framework | Next.js 14 (App Router) | SSR, file-based routing, server components |
| Language | TypeScript (strict) | Type safety, better DX |
| UI Components | shadcn/ui + Radix UI | Accessible, unstyled primitives |
| Styling | Tailwind CSS | Utility-first, design tokens via CSS vars |
| State (server) | TanStack Query | Caching, background refetch, optimistic updates |
| State (global) | Zustand | Lightweight, no boilerplate |
| Forms | react-hook-form + Zod | Type-safe validation |
| Icons | lucide-react | Tree-shakeable, consistent |

### Backend
| Concern | Choice | Why |
|---|---|---|
| Runtime | Node.js 20+ | LTS, ESM support, top-of-ecosystem |
| API style | REST (Next.js Route Handlers) | Simple, well-understood, cacheable |
| Validation | Zod | Runtime + compile-time safety |
| Auth | NextAuth.js (Auth.js v5) | OAuth + credentials, Next.js native |
| HTTP client | native fetch | Built-in, no extra dep |
| Background jobs | BullMQ + Redis | Battle-tested, Redis-backed queues |
| Logging | Pino | Fastest Node.js logger, JSON output |

### Database
| Concern | Choice | Why |
|---|---|---|
| Database | PostgreSQL 16 | ACID, JSON support, mature ecosystem |
| ORM | Drizzle ORM | TypeScript-native, thin abstraction, fast |
| Migrations | Drizzle Kit | Integrated with Drizzle ORM |
| Cache | Redis 7 | Fast key-value, pub/sub, BullMQ |
| Connection pool | PgBouncer (via Supabase) | Handles connection limits at scale |

### Infrastructure
| Concern | Choice | Why |
|---|---|---|
| Frontend hosting | Vercel | Best Next.js DX, edge functions |
| Backend / workers | Railway | Simple containers, managed Postgres option |
| Containerization | Docker + docker-compose | Local dev parity |
| CI/CD | GitHub Actions | Free for public repos, well-integrated |
| Monitoring | Sentry | Error tracking, performance, session replay |
| Analytics | PostHog | Self-hostable, feature flags, funnels |

### Testing
| Concern | Choice | Why |
|---|---|---|
| Unit / Integration | Vitest | Vite-native, fast, ESM-first |
| Component | React Testing Library | User-behavior focused |
| E2E | Playwright | Cross-browser, powerful, good DX |
| API mocking | MSW (Mock Service Worker) | Network-level mocking |
| Test DB | pg-mem or real Postgres | Real DB for integration tests |

## Overrides
If PRD specifies a different stack, update this file at the start of Phase 1 so all agents use consistent choices.
