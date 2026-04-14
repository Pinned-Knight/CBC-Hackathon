---
description: Automated runtime security scan — runs static analysis, secret detection, and dependency vulnerability checks as a fast automated pass. Lighter than the full security-agent audit; runs after every code generation phase.
allowed-tools: Read, Write, Bash, Glob, Grep, mcp__filesystem__*
---

# Security Scan (Automated)

This is the fast, automated security scan. It runs after every code generation phase as a first-pass safety net. The full `security-agent` audit runs in Phase 5.

## Run Order
Execute all checks sequentially. Stop and report immediately on critical findings.

## Check 1 — Secret Detection
```bash
# Scan for hardcoded secrets using pattern matching
grep -rn --include="*.ts" --include="*.tsx" --include="*.js" --include="*.env" \
  -E "(api_key|apikey|secret|password|token|credential|private_key)\s*=\s*['\"][a-zA-Z0-9]{16,}" \
  src/ .

# Check for common secret patterns
grep -rn --include="*.ts" --include="*.js" \
  -E "(sk-[a-zA-Z0-9]{32,}|ghp_[a-zA-Z0-9]{36,}|pk_live_|sk_live_)" \
  .
```
**Critical:** Any match = STOP and report to orchestrator immediately.

## Check 2 — Dependency Vulnerabilities
```bash
npm audit --audit-level=high --json | jq '.metadata.vulnerabilities'
```
**Critical:** Any `high` or `critical` count > 0 = flag for security-agent.

## Check 3 — Dangerous Patterns
```bash
# SQL injection risks — string concatenation in queries
grep -rn "query.*\+.*req\." src/ || true
grep -rn "execute.*\`.*\${" src/ || true

# eval / exec usage
grep -rn -E "\beval\(|\bexec\(|new Function\(" src/ || true

# Prototype pollution
grep -rn "__proto__\|constructor\[" src/ || true
```

## Check 4 — Auth Bypass Risks
```bash
# Check for routes without auth middleware
grep -rn "router\.\(get\|post\|put\|delete\|patch\)" src/api/ | \
  grep -v "authMiddleware\|requireAuth\|withAuth\|auth()" || true

# Check for disabled auth
grep -rn -i "bypass.*auth\|skip.*auth\|no.*auth" src/ || true
```

## Check 5 — Environment Variable Safety
```bash
# Ensure .env is gitignored
grep -q "^\.env" .gitignore || echo "WARNING: .env not in .gitignore"

# Ensure no real secrets in .env.example
grep -E "[A-Za-z0-9]{32,}" .env.example 2>/dev/null | \
  grep -v "your-\|replace-\|example-\|placeholder" && \
  echo "WARNING: Possible real secret in .env.example" || true
```

## Output Format
```markdown
## Security Scan — [timestamp]

### ✅ Passed / ❌ Failed

| Check | Status | Findings |
|---|---|---|
| Secret detection | ✅/❌ | [count or "clean"] |
| Dependencies | ✅/❌ | [vuln counts] |
| Dangerous patterns | ✅/❌ | [pattern matches] |
| Auth coverage | ✅/❌ | [unprotected routes] |
| Env safety | ✅/❌ | [issues] |

### Findings (if any)
[list each finding with file:line]

### Verdict
CLEAN — proceed to next phase
FLAGGED — [N] issues require security-agent review
CRITICAL — STOP — [describe blocker]
```
