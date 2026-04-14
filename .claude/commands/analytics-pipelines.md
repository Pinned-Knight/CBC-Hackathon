---
description: Analytics pipeline patterns — event tracking, data ingestion, aggregation, warehouse integration, and reporting setup. Activate when building analytics or data pipelines.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Analytics Pipelines

## Event Tracking Architecture
```
User Action → Client SDK → Ingestion API → Message Queue → Pipeline → Data Warehouse → Dashboards
```

## Event Schema Design
```typescript
// Consistent event structure for all tracking
interface AnalyticsEvent {
  event: string          // 'page_viewed', 'button_clicked', 'purchase_completed'
  userId?: string        // null for anonymous
  anonymousId: string    // persistent device ID
  properties: Record<string, unknown>
  timestamp: string      // ISO 8601
  context: {
    page: { url: string; path: string; title: string }
    userAgent: string
    ip?: string          // hash before storing
  }
}
```

## Client-Side Tracking
```typescript
// Use Segment, PostHog, or custom — consistent interface
class Analytics {
  track(event: string, properties: Record<string, unknown>) {
    if (typeof window === 'undefined') return // SSR guard
    window.analytics?.track(event, {
      ...properties,
      timestamp: new Date().toISOString(),
    })
  }

  identify(userId: string, traits: Record<string, unknown>) {
    window.analytics?.identify(userId, traits)
  }

  page(name: string, properties?: Record<string, unknown>) {
    window.analytics?.page(name, properties)
  }
}

export const analytics = new Analytics()
```

## Server-Side Ingestion API
```typescript
// app/api/analytics/track/route.ts
export async function POST(req: Request) {
  const body = await req.json()
  const event = eventSchema.parse(body)

  // Hash IP before storing
  event.context.ip = hashIp(event.context.ip)

  // Queue for async processing (never block the response)
  await queue.add('analytics.event', event, { attempts: 3 })

  return new Response('OK', { status: 200 })
}
```

## Data Pipeline (BullMQ Worker)
```typescript
// workers/analytics.worker.ts
analyticsQueue.process(async (job) => {
  const event = job.data as AnalyticsEvent

  // Write to time-series table
  await db.execute(sql`
    INSERT INTO events (event, user_id, anonymous_id, properties, occurred_at)
    VALUES (${event.event}, ${event.userId}, ${event.anonymousId},
            ${JSON.stringify(event.properties)}, ${event.timestamp})
  `)

  // Forward to warehouse (async, non-blocking)
  await warehouseClient.insert(event)
})
```

## Aggregation Tables
```sql
-- Pre-aggregate for dashboard performance
CREATE TABLE daily_active_users AS
SELECT
  DATE(occurred_at) as date,
  COUNT(DISTINCT user_id) as dau
FROM events
WHERE user_id IS NOT NULL
GROUP BY DATE(occurred_at);

-- Refresh nightly via cron
-- Or use materialized views with incremental refresh
```

## PostHog Integration (Self-hosted / Cloud)
```typescript
import { PostHog } from 'posthog-node'
const posthog = new PostHog(process.env.POSTHOG_API_KEY!, {
  host: process.env.POSTHOG_HOST ?? 'https://app.posthog.com'
})

// Feature flags
const isEnabled = await posthog.isFeatureEnabled('new-dashboard', userId)

// Track server-side
posthog.capture({ distinctId: userId, event: 'subscription_created', properties: { plan } })

// Flush before shutdown
await posthog.shutdown()
```

## Key Metrics to Track
| Metric | Event |
|---|---|
| DAU/MAU | `session_started` |
| Activation | `key_action_completed` (app-specific) |
| Retention | `session_started` (D1, D7, D30 cohorts) |
| Revenue | `subscription_created`, `payment_succeeded` |
| Churn | `subscription_canceled` |
| Funnel | `signup_started` → `signup_completed` → `onboarding_completed` |

## Rules
- Track events server-side for critical business events (payments, signups) — client-side can be blocked
- Never track PII in event properties — use user IDs only
- Hash IPs before storing
- Use a consistent naming convention: `noun_past_tense` (page_viewed, button_clicked)
- Always include userId and anonymousId for identity resolution
