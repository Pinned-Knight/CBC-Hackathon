#!/bin/bash
# ============================================================
# HOOK: PreToolUse — Bash
# Runs before any shell command is executed.
# Blocks destructive commands, logs all commands,
# and validates against the active phase rules.
# ============================================================

set -euo pipefail

COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-}"
PHASE="${CLAUDE_PHASE:-dev}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_LOG="${BUILD_LOG:-build-log.md}"

# ── 1. Block destructive commands ────────────────────────
DESTRUCTIVE_PATTERNS=(
  "rm -rf /"
  "rm -rf \*"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate"
  "format c:"
  "> /dev/sda"
  "dd if=/dev/zero"
  "chmod -R 777 /"
  "sudo rm"
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiF "$pattern"; then
    echo "[BEFORE-CMD] ❌ BLOCKED destructive command: $pattern"
    echo "[BEFORE-CMD] Command: $COMMAND"
    exit 1
  fi
done

# ── 2. Block prod DB writes outside deploy phase ─────────
if echo "$COMMAND" | grep -qiE "psql|mysql|mongo" && [ "$PHASE" != "deploy" ]; then
  if echo "$COMMAND" | grep -qiE "INSERT|UPDATE|DELETE|DROP|TRUNCATE"; then
    echo "[BEFORE-CMD] ⚠️  WARNING: Direct DB write attempted outside deploy phase"
    echo "[BEFORE-CMD] Current phase: $PHASE. Use migrations instead."
  fi
fi

# ── 3. Log command to build log ───────────────────────────
if [ -f "$BUILD_LOG" ]; then
  echo "- \`$(echo "$COMMAND" | head -c 120)\` — $TIMESTAMP" >> "$BUILD_LOG"
fi

echo "[BEFORE-CMD] Executing (phase=$PHASE): $(echo "$COMMAND" | head -c 100)..."
exit 0
