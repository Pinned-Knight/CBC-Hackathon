---
description: Next.js 14+ App Router best practices — server vs client components, data fetching, caching, routing, and performance. Activate when building Next.js applications.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Next.js Best Practices (App Router)

## Server vs Client Components
- Default to Server Components — they reduce bundle size and run on the server
- Add `'use client'` only when you need: browser APIs, event listeners, hooks (`useState`, `useEffect`)
- Push `'use client'` as far down the tree as possible — keep parents as server components
- Never import server-only code into client components (database clients, secrets)

## Data Fetching
- Fetch data directly in Server Components — no need for `useEffect` + `useState`
- Use `async/await` in Server Components: `const data = await fetchData()`
- Parallel fetch with `Promise.all` to avoid request waterfalls
- Use `cache()` to deduplicate identical requests within a render

## Caching Strategy
```typescript
// Static (build time) — for content that rarely changes
fetch(url, { cache: 'force-cache' })

// Dynamic (per request) — for personalized content
fetch(url, { cache: 'no-store' })

// Revalidate on interval
fetch(url, { next: { revalidate: 3600 } }) // 1 hour

// Revalidate on demand
revalidatePath('/products')
revalidateTag('products')
```

## Routing & Layouts
- Use nested layouts for shared UI (nav, sidebar)
- Use `loading.tsx` for automatic Suspense boundaries
- Use `error.tsx` for error boundaries per route segment
- Use `not-found.tsx` for 404 handling
- Dynamic routes: `[id]` for single params, `[...slug]` for catch-all

## Server Actions
- Use Server Actions for form submissions and data mutations — no API route needed
- Mark with `'use server'` directive
- Validate inputs server-side with Zod before any database operation
- Return typed responses: `{ success: boolean; data?: T; error?: string }`

## Route Handlers (API Routes)
- Use for webhooks, OAuth callbacks, and external API integration
- File: `app/api/[route]/route.ts`
- Always return typed `NextResponse` objects
- Add rate limiting middleware for public endpoints

## Performance
- Use `next/image` for all images — automatic optimization and lazy loading
- Use `next/font` for web fonts — eliminates FOUT, self-hosted
- Use `next/link` for all internal navigation — prefetching built-in
- Enable `turbopack` in development for faster builds
- Analyze bundle with `@next/bundle-analyzer` before shipping

## Middleware
- Use `middleware.ts` for auth checks, redirects, and A/B testing
- Keep middleware lightweight — it runs on every request
- Use `matcher` config to limit which routes trigger middleware
