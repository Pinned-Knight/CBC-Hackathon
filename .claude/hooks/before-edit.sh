#!/bin/bash
# ============================================================
# HOOK: PreToolUse — Write / Edit
# Runs before any file is written or edited.
# Logs the change, enforces rules, and guards forbidden paths.
# ============================================================

set -euo pipefail

FILE_PATH="${CLAUDE_TOOL_INPUT_FILE_PATH:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_LOG="${BUILD_LOG:-build-log.md}"

# ── 1. Guard forbidden paths ──────────────────────────────
FORBIDDEN_PATTERNS=(
  ".env$"
  "secrets"
  "credentials"
  "private-key"
  ".pem$"
)

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qiE "$pattern"; then
    echo "[BEFORE-EDIT] ❌ BLOCKED: Attempt to write to sensitive path: $FILE_PATH"
    echo "[BEFORE-EDIT] Secrets and credentials must never be written by agents."
    exit 1
  fi
done

# ── 2. Warn on direct test file modification ──────────────
if echo "$FILE_PATH" | grep -qE "\.(test|spec)\.(ts|tsx|js|jsx|py)$"; then
  echo "[BEFORE-EDIT] ⚠️  Modifying test file: $FILE_PATH"
  echo "[BEFORE-EDIT] Ensure test changes reflect real requirement changes, not just making tests pass."
fi

# ── 3. Log the edit ───────────────────────────────────────
echo "[BEFORE-EDIT] Writing: $FILE_PATH at $TIMESTAMP"

if [ -f "$BUILD_LOG" ]; then
  echo "- \`$FILE_PATH\` written at $TIMESTAMP" >> "$BUILD_LOG"
fi

# ── 4. Check if file already exists (overwrite warning) ───
if [ -f "$FILE_PATH" ]; then
  LINES=$(wc -l < "$FILE_PATH" 2>/dev/null || echo 0)
  echo "[BEFORE-EDIT] Overwriting existing file ($LINES lines)"
fi

exit 0
