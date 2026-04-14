---
description: Live documentation lookup via Context7 MCP — fetches current library and framework docs instead of relying on training data. Activate for any framework-specific questions, API references, or code examples.
allowed-tools: Read, Write, mcp__fetch__*, mcp__brave-search__*
---

# Documentation Lookup (Context7)

## When to Activate
- Setup or configuration questions for any library/framework
- API reference questions ("what does X method accept?")
- Requests for code examples with specific frameworks
- User mentions: React, Next.js, Prisma, Supabase, Drizzle, Stripe, Tailwind, Playwright, Vitest, etc.

## 3-Step Process

### Step 1 — Resolve Library
Use Context7 `resolve-library-id` with the library name and the specific question.
- Choose the match that best fits: name accuracy, benchmark score, reputation, and version relevance
- Prefer version-specific IDs when the user mentions a specific version (e.g., "Next.js 14", "React 18")

### Step 2 — Fetch Documentation
Use Context7 `query-docs` with:
- The resolved library ID
- A specific, focused query (not the full user question)

**Limits**: Maximum 3 combined calls (resolve + query) per question.

### Step 3 — Answer with Current Docs
- Provide the answer using the fetched documentation
- Include relevant code examples from the docs
- Cite the documentation version if available
- Redact any sensitive data before sending queries to Context7

## Fallback (Context7 unavailable)
Use `brave-search` with site-specific queries:
```
"how to use useFormState site:react.dev"
"nextjs server actions site:nextjs.org/docs"
"prisma findMany include site:prisma.io/docs"
```

Then fetch the official docs page directly.

## Libraries to Always Look Up (never rely on training data)
These APIs change frequently:
- Next.js App Router (major changes in 13, 14, 15)
- React Server Components
- Prisma / Drizzle ORM schema syntax
- Stripe API (versioned, changes frequently)
- Supabase client methods
- Tailwind v3 vs v4 differences
- Playwright API

## Rules
- Always resolve library ID before querying — never call query-docs without a valid ID
- Maximum 3 calls per question
- Prefer official sources over community blogs
- Flag when documentation is for a different version than requested
