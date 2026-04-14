#!/bin/bash
# ============================================================
# HOOK: SessionStart
# Runs once when a Claude Code session begins.
# Restores context, loads memory, sets the active phase,
# and announces the agent factory is live.
# ============================================================

set -euo pipefail

SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_LOG="${BUILD_LOG:-build-log.md}"
PHASE="${CLAUDE_PHASE:-dev}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  AGENT FACTORY — SESSION START"
echo "  Session : $SESSION_ID"
echo "  Phase   : $PHASE"
echo "  Time    : $TIMESTAMP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Ensure build log exists ────────────────────────────
if [ ! -f "$BUILD_LOG" ]; then
  cat > "$BUILD_LOG" <<EOF
# Build Log

Started: $TIMESTAMP
Session: $SESSION_ID
Phase:   $PHASE

## Agent Activity
EOF
  echo "[SESSION-START] Created build-log.md"
fi

# ── 2. Append session entry to build log ─────────────────
echo "" >> "$BUILD_LOG"
echo "### Session $SESSION_ID — $TIMESTAMP" >> "$BUILD_LOG"
echo "Phase: \`$PHASE\`" >> "$BUILD_LOG"

# ── 3. Load memory context if it exists ──────────────────
MEMORY_FILE=".claude/contexts/project-context.md"
if [ -f "$MEMORY_FILE" ]; then
  echo "[SESSION-START] Loaded project context from $MEMORY_FILE"
else
  echo "[SESSION-START] No existing project context found — fresh session"
fi

# ── 4. Detect current git branch (if in a git repo) ──────
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  echo "[SESSION-START] Git branch: $BRANCH"
  echo "Branch: \`$BRANCH\`" >> "$BUILD_LOG"
fi

# ── 5. Print active MCP profile ──────────────────────────
MCP_PROFILE="${MCP_PROFILE:-fullstack}"
echo "[SESSION-START] MCP profile: $MCP_PROFILE"
echo "[SESSION-START] Worktrees enabled: ${WORKTREE_ENABLED:-false}"
echo "[SESSION-START] Strict testing: ${STRICT_TESTING:-false}"

echo ""
echo "[SESSION-START] Factory is live. Awaiting initial prompt."
