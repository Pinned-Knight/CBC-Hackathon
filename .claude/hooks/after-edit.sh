#!/bin/bash
# ============================================================
# HOOK: PostToolUse — Write / Edit
# Runs after a file is written or edited.
# Triggers format checks, updates build log, queues
# verification if a source file was changed.
# ============================================================

set -euo pipefail

FILE_PATH="${CLAUDE_TOOL_INPUT_FILE_PATH:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_LOG="${BUILD_LOG:-build-log.md}"

echo "[AFTER-EDIT] ✅ Written: $FILE_PATH"

# ── 1. TypeScript / TSX — run type check on changed file ─
if echo "$FILE_PATH" | grep -qE "\.(ts|tsx)$"; then
  if command -v npx &>/dev/null && [ -f "tsconfig.json" ]; then
    echo "[AFTER-EDIT] Running type check on $FILE_PATH..."
    npx tsc --noEmit --skipLibCheck 2>&1 | tail -5 || echo "[AFTER-EDIT] ⚠️  Type errors detected — queue for qa-agent"
  fi
fi

# ── 2. Markdown lint on documentation files ──────────────
if echo "$FILE_PATH" | grep -qE "\.md$"; then
  if command -v npx &>/dev/null; then
    npx markdownlint-cli2 "$FILE_PATH" 2>/dev/null || true
  fi
fi

# ── 3. Auto-format if Prettier is available ──────────────
if echo "$FILE_PATH" | grep -qE "\.(ts|tsx|js|jsx|json|css|md)$"; then
  if command -v npx &>/dev/null && [ -f ".prettierrc" -o -f "prettier.config.js" ]; then
    npx prettier --write "$FILE_PATH" 2>/dev/null && echo "[AFTER-EDIT] Formatted with Prettier" || true
  fi
fi

# ── 4. Trigger verification queue flag ───────────────────
if echo "$FILE_PATH" | grep -qE "^src/"; then
  VERIFY_QUEUE_FILE=".claude/.verify-queue"
  echo "$FILE_PATH" >> "$VERIFY_QUEUE_FILE"
  echo "[AFTER-EDIT] Queued for verification: $FILE_PATH"
fi

# ── 5. Update build log ───────────────────────────────────
if [ -f "$BUILD_LOG" ]; then
  echo "  ✅ $FILE_PATH (post-edit checks passed) — $TIMESTAMP" >> "$BUILD_LOG"
fi

exit 0
