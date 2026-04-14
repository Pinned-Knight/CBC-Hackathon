#!/bin/bash
# ============================================================
# HOOK: SessionEnd
# Runs when a Claude Code session ends.
# Saves session summary, persists memory, logs final state.
# ============================================================

set -euo pipefail

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_LOG="${BUILD_LOG:-build-log.md}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  AGENT FACTORY — SESSION STOP"
echo "  Session : $SESSION_ID"
echo "  Time    : $TIMESTAMP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Append stop entry to build log ────────────────────
if [ -f "$BUILD_LOG" ]; then
  echo "" >> "$BUILD_LOG"
  echo "**Session ended:** $TIMESTAMP" >> "$BUILD_LOG"
  echo "---" >> "$BUILD_LOG"
fi

# ── 2. Snapshot generated file count ─────────────────────
if [ -d "src" ]; then
  FILE_COUNT=$(find src -type f | wc -l | tr -d ' ')
  echo "[SESSION-STOP] Generated files in src/: $FILE_COUNT"
  echo "Files generated: $FILE_COUNT" >> "$BUILD_LOG"
fi

# ── 3. Run final git status summary ──────────────────────
if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGED=$(git status --short | wc -l | tr -d ' ')
  echo "[SESSION-STOP] Uncommitted changes: $CHANGED files"

  # Auto-stage and summarize (do not commit — orchestrator decides)
  if [ "$CHANGED" -gt 0 ]; then
    echo "[SESSION-STOP] Tip: run git add -A && git commit -m 'chore: agent session $SESSION_ID' to save progress"
  fi
fi

# ── 4. Persist context for next session ──────────────────
CONTEXT_FILE=".claude/contexts/project-context.md"
mkdir -p .claude/contexts

cat > "$CONTEXT_FILE" <<EOF
# Project Context — Auto-saved at $TIMESTAMP

Session: $SESSION_ID
Phase: ${CLAUDE_PHASE:-dev}
MCP Profile: ${MCP_PROFILE:-fullstack}

## Last Known State
- Build log: $BUILD_LOG
- Git branch: $(git branch --show-current 2>/dev/null || echo "unknown")

## Carry Forward
- Resume from phase: ${CLAUDE_PHASE:-dev}
- All agents should re-read claude.md on startup
EOF

echo "[SESSION-STOP] Context saved to $CONTEXT_FILE"
echo "[SESSION-STOP] Session complete."
