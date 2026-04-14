---
description: Evaluation framework for agent output quality — scores generated code, architecture, and documentation against defined criteria. Produces a quantified quality report. Activate after full application generation to get an objective quality score.
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Eval Harness

## Purpose
Objectively score the quality of the generated application across five dimensions. Produces a numeric score (0-100) that can be compared across runs.

## Scoring Dimensions

### 1. Completeness (0-25 points)
Does the output contain everything that was requested?

```
Score each:
- All MVP features from PRD implemented:      0-10 pts (2pts per feature, max 5 features)
- All API endpoints from contract exist:      0-5 pts
- All DB tables from schema exist:            0-5 pts
- All frontend routes from plan exist:        0-5 pts
```

**Check:**
```bash
# Count implemented vs planned endpoints
grep -c "export async function" src/api/**/*.ts 2>/dev/null
# Count DB models vs planned tables
grep -c "createTable\|model\." migrations/*.sql 2>/dev/null
```

### 2. Code Quality (0-25 points)
```
- TypeScript: zero `any` types:               0-5 pts
- Test coverage ≥ 80%:                        0-8 pts (1pt per % above 72%)
- Zero lint errors:                           0-5 pts
- Build succeeds:                             0-7 pts (binary)
```

**Check:**
```bash
npx tsc --noEmit 2>&1 | grep -c "error TS" || echo 0  # should be 0
npm test -- --coverage --reporter=json 2>/dev/null | jq '.coverageMap | .. | .pct? // empty' | awk '{sum+=$1;n++} END{print sum/n}'
```

### 3. Security (0-25 points)
```
- Zero hardcoded secrets:                     0-10 pts (binary)
- npm audit: zero high/critical:              0-8 pts (binary)
- All routes authenticated where needed:      0-7 pts
```

### 4. Architecture Quality (0-15 points)
```
- Service/Repository separation maintained:   0-5 pts
- No business logic in route handlers:        0-5 pts
- Component/feature folder structure correct: 0-5 pts
```

**Check:**
```bash
# Flag business logic in routes (should be minimal)
grep -n "await db\." src/api/**/*.ts 2>/dev/null | wc -l  # should be ~0
```

### 5. Documentation (0-10 points)
```
- README exists and has quick-start:          0-4 pts
- API reference exists:                       0-3 pts
- .env.example is complete:                   0-3 pts
```

## Scoring Script
```bash
#!/bin/bash
echo "=== EVAL HARNESS ==="
SCORE=0

# Completeness
BUILD_RESULT=$(npm run build 2>&1 && echo "PASS" || echo "FAIL")
[ "$BUILD_RESULT" = "PASS" ] && SCORE=$((SCORE + 7)) && echo "✅ Build: +7"

# TypeScript
TS_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo 999)
[ "$TS_ERRORS" -eq 0 ] && SCORE=$((SCORE + 5)) && echo "✅ TypeScript: +5" || echo "❌ TypeScript errors: $TS_ERRORS"

# Security
SECRET_HITS=$(grep -rn "apikey\|api_key" src/ | grep -v "process.env" | wc -l)
[ "$SECRET_HITS" -eq 0 ] && SCORE=$((SCORE + 10)) && echo "✅ No secrets: +10" || echo "❌ Possible secrets: $SECRET_HITS"

# Docs
[ -f "README.md" ] && SCORE=$((SCORE + 4)) && echo "✅ README: +4"
[ -f ".env.example" ] && SCORE=$((SCORE + 3)) && echo "✅ .env.example: +3"

echo "=== TOTAL SCORE: $SCORE / 100 ==="
```

## Output: `eval-report.md`
```markdown
## Evaluation Report — [timestamp]

| Dimension | Score | Max | Notes |
|---|---|---|---|
| Completeness | X | 25 | |
| Code Quality | X | 25 | |
| Security | X | 25 | |
| Architecture | X | 15 | |
| Documentation | X | 10 | |
| **TOTAL** | **X** | **100** | |

### Grade
90-100: Excellent — production ready
75-89:  Good — minor fixes needed
60-74:  Acceptable — review flagged issues
< 60:   Needs work — review eval report with orchestrator
```
