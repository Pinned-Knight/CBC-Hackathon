---
description: Six-phase quality verification loop — build, type check, lint, test coverage, security scan, and diff review. Run after completing a feature, before creating a PR, or after significant refactoring.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Verification Loop

Run this loop after completing a feature or significant change. Repeat until all 6 phases pass.

## Phase 1 — Build Verification
```bash
npm run build
```
**Pass criteria**: Exit code 0, no build errors.
**On failure**: Fix compilation errors before proceeding. Do not advance.

## Phase 2 — Type Check
```bash
npx tsc --noEmit
```
**Pass criteria**: Zero TypeScript errors.
**On failure**: Fix type errors. Common fixes:
- Add missing type annotations
- Fix `undefined` not handled cases
- Update interface definitions

## Phase 3 — Lint
```bash
npx eslint . --max-warnings 0
# or
npx biome check .
```
**Pass criteria**: Zero warnings, zero errors.
**On failure**: Run `npx eslint . --fix` for auto-fixable issues, manually fix the rest.

## Phase 4 — Test Suite
```bash
npm run test -- --coverage --reporter=verbose
```
**Pass criteria**:
- Zero failing tests
- Overall coverage ≥ 80%
- All new code paths covered

**On failure**: 
- Failing tests → fix the underlying code or update the test if requirements changed
- Low coverage → write missing tests before proceeding

## Phase 5 — Security Scan
```bash
npm audit --audit-level=high
```
Also check manually:
- No hardcoded secrets or API keys in changed files
- No debug `console.log` or `debugger` statements in production code
- No `TODO: auth check` or similar skipped security

**Pass criteria**: Zero high/critical vulnerabilities, no secrets in diff.
**On failure**: `npm audit fix` for auto-fixable, manually review the rest.

## Phase 6 — Diff Review
```bash
git diff HEAD~1
# or from branch point:
git diff main...HEAD
```
Check for:
- Unintended file changes
- Missing error handling in new code paths
- Missing loading/empty states in UI changes
- Edge cases not covered by tests
- Overly broad changes (scope creep)

**Pass criteria**: All changes are intentional, edge cases handled.

## Verification Report
After all 6 phases pass, record:
```
Verification Report — [date]
Phase 1 Build:    PASS
Phase 2 Types:    PASS
Phase 3 Lint:     PASS
Phase 4 Tests:    PASS (coverage: 87%, tests: 142 passed)
Phase 5 Security: PASS (0 vulnerabilities)
Phase 6 Diff:     PASS

PR Ready: YES
```

## Continuous Loop Schedule
For extended development sessions:
- Run after every completed feature
- Run every 15 minutes during active development
- Always run before creating or updating a PR

## Rules
- Never skip a phase — a partial pass is a fail
- Fix phase 1 before checking phase 2 (phases are sequential)
- A single `any` type suppression that hides a real error = type check fail
- Unused imports and `console.log` are lint errors — clean them up
