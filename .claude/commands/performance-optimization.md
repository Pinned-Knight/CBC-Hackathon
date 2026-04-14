---
description: Application performance optimization — frontend bundle, Core Web Vitals, backend query optimization, caching strategy, and profiling. Activate when investigating or improving performance.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Performance Optimization

## Frontend — Core Web Vitals Targets
| Metric | Good | Needs Work | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5-4s | > 4s |
| FID / INP (Interaction to Next Paint) | < 200ms | 200-500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1-0.25 | > 0.25 |
| TTFB (Time to First Byte) | < 800ms | 800ms-1.8s | > 1.8s |

## Bundle Optimization
```bash
# Analyze bundle size
ANALYZE=true npm run build
# or
npx @next/bundle-analyzer
```

Common fixes:
```typescript
// Lazy load heavy components
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <Skeleton className="h-64" />,
  ssr: false,
})

// Tree shake large libraries — import specifically
import { debounce } from 'lodash-es'   // not: import _ from 'lodash'
import { format } from 'date-fns'       // not: import * as dateFns from 'date-fns'

// Replace heavy libraries with lighter alternatives
// moment.js (67kb) → date-fns (tree-shakeable)
// lodash (71kb) → lodash-es or native JS
```

## Image Optimization
```typescript
// Next.js Image component — automatic WebP, lazy loading, size optimization
import Image from 'next/image'
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // for above-the-fold images
  sizes="(max-width: 768px) 100vw, 50vw"
/>
```

## React Rendering Optimization
```typescript
// Memo components that receive stable props but re-render often
const ExpensiveList = React.memo(function ExpensiveList({ items }: Props) {
  return <>{items.map(item => <Item key={item.id} item={item} />)}</>
})

// Virtualize long lists (>50 items)
import { useVirtualizer } from '@tanstack/react-virtual'

// Debounce search inputs
const debouncedSearch = useMemo(() => debounce(handleSearch, 300), [])
```

## Backend Query Optimization
```sql
-- Run EXPLAIN ANALYZE on slow queries
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT ...;

-- Key patterns that cause slowdowns:
-- 1. Missing index on WHERE clause column
-- 2. SELECT * instead of specific columns
-- 3. N+1 queries in application code
-- 4. Missing pagination (unbounded result sets)
-- 5. JSON/JSONB without GIN index for key lookups
```

```typescript
// Fix N+1: batch load instead of per-item fetch
// Bad:
const posts = await db.post.findMany()
for (const post of posts) {
  post.author = await db.user.findUnique({ where: { id: post.userId } }) // N queries!
}

// Good:
const posts = await db.post.findMany({ include: { author: true } }) // 1 query with JOIN
```

## Caching Layers
```
Browser Cache → CDN Cache → Application Cache (Redis) → Database
```
```typescript
// Redis caching with stale-while-revalidate pattern
async function getCachedData<T>(key: string, fetcher: () => Promise<T>, ttl = 300): Promise<T> {
  const cached = await redis.get(key)
  if (cached) {
    // Revalidate in background if near expiry
    const ttlRemaining = await redis.ttl(key)
    if (ttlRemaining < ttl * 0.2) {
      fetcher().then(data => redis.setex(key, ttl, JSON.stringify(data)))
    }
    return JSON.parse(cached)
  }
  const data = await fetcher()
  await redis.setex(key, ttl, JSON.stringify(data))
  return data
}
```

## Profiling Tools
- **Frontend**: Chrome DevTools Performance tab, Lighthouse, WebPageTest
- **Backend**: `clinic.js` for Node.js, `pg_stat_statements` for PostgreSQL
- **Network**: `curl -o /dev/null -s -w "%{time_total}"` for endpoint timing

## Quick Wins Checklist
- [ ] Images use `next/image` with proper `sizes`
- [ ] Fonts use `next/font` (no render-blocking)
- [ ] No `console.log` in production (minor perf + security)
- [ ] API responses gzip compressed
- [ ] Static assets served with far-future cache headers
- [ ] Database queries have `LIMIT` clauses
- [ ] Heavy routes use streaming (`loading.tsx`)
