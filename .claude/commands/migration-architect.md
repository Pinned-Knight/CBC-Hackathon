---
description: Zero-downtime migration planning — expand-contract pattern, rollback strategies, compatibility validation, and phased migration approaches. Activate when planning database or service migrations.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Migration Architect (POWERFUL Tier)

## Core Philosophy
Zero-downtime migrations mean the database and application code must be **compatible at every point in time**. This requires deploying changes in multiple phases, never in a single big-bang release.

## Expand-Contract Pattern

### Phase 1 — Expand (backwards compatible)
Add the new structure without removing the old:
```sql
-- Add new column with default (non-breaking)
ALTER TABLE users ADD COLUMN display_name TEXT;
-- Update new column from old
UPDATE users SET display_name = name WHERE display_name IS NULL;
```
Deploy application code that writes to BOTH old and new columns.

### Phase 2 — Migrate
Backfill all existing rows. Do in batches to avoid locking:
```sql
-- Batch backfill to avoid table lock
DO $$
DECLARE batch_size INT := 1000; last_id UUID := '00000000-0000-0000-0000-000000000000';
BEGIN
  LOOP
    UPDATE users SET display_name = name
    WHERE id > last_id AND display_name IS NULL
    ORDER BY id LIMIT batch_size
    RETURNING id INTO last_id;
    EXIT WHEN NOT FOUND;
    PERFORM pg_sleep(0.1); -- rate limit
  END LOOP;
END $$;
```

### Phase 3 — Contract (remove old)
Once all reads/writes use the new column:
```sql
ALTER TABLE users DROP COLUMN name;
```

## Safe Schema Changes

### Always Safe (no downtime)
- `ADD COLUMN` with a default value (PostgreSQL 11+)
- `ADD COLUMN NULL`
- `CREATE INDEX CONCURRENTLY`
- `ADD CONSTRAINT` (not yet `NOT NULL` with no default)
- `CREATE TABLE`

### Requires Care (may lock)
- `ADD COLUMN NOT NULL` without default → add nullable first, backfill, then add constraint
- `ALTER COLUMN TYPE` → add new column, backfill, swap
- `DROP COLUMN` → ensure no code reads it first
- `ADD FOREIGN KEY` → validate in batches with `NOT VALID`, then `VALIDATE CONSTRAINT`

### Never Do in Production
- `DROP TABLE` without archiving first
- `TRUNCATE` without backup
- Adding index without `CONCURRENTLY`

## Rollback Strategy
Every migration must have a rollback script:
```sql
-- migrations/003_add_display_name.sql (UP)
ALTER TABLE users ADD COLUMN display_name TEXT;

-- migrations/003_add_display_name_rollback.sql (DOWN)
ALTER TABLE users DROP COLUMN display_name;
```

Document rollback decision criteria:
- Error rate > 1% after deploy → auto-rollback trigger
- Migration running > expected time × 2 → pause and assess
- Data integrity check fails → rollback immediately

## Feature Flags for Progressive Rollout
```typescript
// Use feature flags to control which code path runs
if (featureFlags.isEnabled('use-display-name', userId)) {
  return user.display_name
} else {
  return user.name // old column still in use
}
```

## Pre-Migration Checklist
- [ ] Backup taken and restore tested
- [ ] Migration tested on production data snapshot
- [ ] Estimated duration calculated (rows × avg time per row)
- [ ] Rollback script written and tested
- [ ] Monitoring alerts configured
- [ ] Stakeholders notified of maintenance window (if needed)
- [ ] Feature flag ready to control rollout

## Validation Checkpoints
```sql
-- After migration: verify row counts match
SELECT COUNT(*) FROM users WHERE display_name IS NULL; -- should be 0
SELECT COUNT(*) FROM users; -- should match pre-migration count

-- Verify indexes were created
SELECT indexname FROM pg_indexes WHERE tablename = 'users';
```
