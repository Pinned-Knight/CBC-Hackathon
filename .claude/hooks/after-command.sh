#!/bin/bash
# ============================================================
# HOOK: PostToolUse — Bash
# Runs after a shell command completes.
# Captures exit codes, detects errors, triggers recovery,
# and updates build log with command outcome.
# ============================================================

set -euo pipefail

COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-}"
EXIT_CODE="${CLAUDE_TOOL_EXIT_CODE:-0}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_LOG="${BUILD_LOG:-build-log.md}"

# ── 1. Report exit code ───────────────────────────────────
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "[AFTER-CMD] ✅ Command succeeded (exit 0)"
else
  echo "[AFTER-CMD] ❌ Command failed (exit $EXIT_CODE)"
  echo "[AFTER-CMD] Failed command: $(echo "$COMMAND" | head -c 150)"

  # Log failure to build log
  if [ -f "$BUILD_LOG" ]; then
    echo "  ❌ FAILED (exit $EXIT_CODE): \`$(echo "$COMMAND" | head -c 100)\` — $TIMESTAMP" >> "$BUILD_LOG"
  fi

  # ── 2. Known error patterns → recovery hints ──────────
  OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

  if echo "$OUTPUT" | grep -q "Cannot find module"; then
    echo "[AFTER-CMD] 💡 Recovery: Missing module — run: npm install"
  fi

  if echo "$OUTPUT" | grep -q "EADDRINUSE"; then
    echo "[AFTER-CMD] 💡 Recovery: Port in use — run: kill \$(lsof -t -i:3000)"
  fi

  if echo "$OUTPUT" | grep -q "ECONNREFUSED"; then
    echo "[AFTER-CMD] 💡 Recovery: Connection refused — check if database/Redis is running"
  fi

  if echo "$OUTPUT" | grep -qE "TypeScript.*error|TS[0-9]+"; then
    echo "[AFTER-CMD] 💡 Recovery: TypeScript errors — run: npx tsc --noEmit for full report"
  fi

  if echo "$OUTPUT" | grep -q "migration"; then
    echo "[AFTER-CMD] 💡 Recovery: Migration issue — run: npx prisma migrate dev or npm run db:migrate"
  fi

  exit "$EXIT_CODE"
fi

# ── 3. Detect successful test run — log coverage ─────────
if echo "$COMMAND" | grep -qE "vitest|jest|pytest"; then
  echo "[AFTER-CMD] Test suite completed — check qa-report.md for coverage"
fi

# ── 4. Detect successful build ───────────────────────────
if echo "$COMMAND" | grep -qE "npm run build|next build|tsc"; then
  echo "[AFTER-CMD] Build succeeded — artifact ready"
  if [ -f "$BUILD_LOG" ]; then
    echo "  🏗️  Build succeeded — $TIMESTAMP" >> "$BUILD_LOG"
  fi
fi

exit 0
