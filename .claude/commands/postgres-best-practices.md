---
description: PostgreSQL best practices from Supabase — schema design, indexing, query optimization, RLS, and connection management. Activate when designing or querying a PostgreSQL database.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# PostgreSQL Best Practices (Supabase)

## Schema Design
```sql
-- Always include audit columns
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ  -- soft delete
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

## Data Types
| Data | Use |
|---|---|
| `UUID` | Primary keys |
| `TEXT` | Variable-length strings (not VARCHAR) |
| `TIMESTAMPTZ` | All timestamps (timezone-aware) |
| `BOOLEAN` | True/false |
| `NUMERIC(10,2)` | Money/currency |
| `JSONB` | Semi-structured data (indexed) |
| `ENUM` | Fixed value sets |

## Indexing Strategy
```sql
-- Index every foreign key
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Composite index for frequent filter+sort patterns
CREATE INDEX idx_posts_user_status_created ON posts(user_id, status, created_at DESC);

-- Partial index for filtered queries
CREATE INDEX idx_active_users ON users(email) WHERE deleted_at IS NULL;

-- GIN index for JSONB and full-text search
CREATE INDEX idx_products_metadata ON products USING GIN(metadata);
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', title || ' ' || body));
```

## Query Optimization
```sql
-- Use EXPLAIN ANALYZE to find slow queries
EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC LIMIT 20;

-- Avoid SELECT * — always specify columns
SELECT id, title, created_at FROM posts WHERE user_id = $1;

-- Use CTEs for readability, but inline for performance-critical queries
WITH active_users AS (
  SELECT id FROM users WHERE deleted_at IS NULL AND last_active > NOW() - INTERVAL '30 days'
)
SELECT COUNT(*) FROM active_users;

-- Batch inserts
INSERT INTO events (user_id, action, created_at)
SELECT unnest($1::uuid[]), unnest($2::text[]), NOW();
```

## Row Level Security (Supabase)
```sql
-- Enable RLS on every table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Users can only read their own posts
CREATE POLICY "users_read_own_posts" ON posts
FOR SELECT USING (auth.uid() = user_id);

-- Users can create posts for themselves
CREATE POLICY "users_create_own_posts" ON posts
FOR INSERT WITH CHECK (auth.uid() = user_id);
```

## Connection Management
```typescript
// Use connection pooling — never create new connections per request
// PgBouncer in Supabase handles this automatically
// In your ORM config, set pool size based on server RAM:
// pool_size = (RAM in GB × 25) - reserved_connections
const db = drizzle(connectionString, {
  logger: process.env.NODE_ENV === 'development',
})
```

## Migrations
```sql
-- Always write reversible migrations
-- UP
ALTER TABLE users ADD COLUMN bio TEXT;

-- DOWN
ALTER TABLE users DROP COLUMN bio;
```

## Rules
- Never use `SERIAL` — use `gen_random_uuid()` for UUIDs
- Always use `TIMESTAMPTZ`, never `TIMESTAMP` (timezone handling)
- Foreign keys must have corresponding indexes
- Test queries with `EXPLAIN ANALYZE` before shipping
- Use transactions for multi-table writes
- Soft delete with `deleted_at` over hard deletes for audit trails
