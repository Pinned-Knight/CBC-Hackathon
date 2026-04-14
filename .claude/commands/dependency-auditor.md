---
description: Comprehensive dependency audit — vulnerability scanning, license compliance, outdated detection, bloat analysis, and upgrade path planning across all languages. Activate before releases, during security reviews, or as part of CI.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Dependency Auditor (POWERFUL Tier)

## Vulnerability Scanning

### JavaScript/TypeScript
```bash
npm audit --audit-level=moderate
# Fix automatically where possible:
npm audit fix
# For breaking fixes (major version bumps):
npm audit fix --force  # review diff carefully after this
```

### Check CVE Patterns
```bash
# Snyk (more comprehensive than npm audit)
npx snyk test
npx snyk monitor  # continuous monitoring

# Check for known malicious packages
npx is-website-vulnerable https://yourapp.com
```

## License Compliance
```bash
npx license-checker --summary
npx license-checker --onlyAllow "MIT;ISC;BSD-2-Clause;BSD-3-Clause;Apache-2.0;CC0-1.0"
```

License classification:
| Type | Examples | Commercial Use |
|---|---|---|
| Permissive | MIT, ISC, BSD, Apache-2.0 | ✅ Safe |
| Weak copyleft | LGPL, MPL | ⚠️ Review required |
| Strong copyleft | GPL, AGPL | ❌ Requires source disclosure |
| Proprietary | Custom | ❌ Requires explicit permission |

## Outdated Dependency Detection
```bash
# Show all outdated packages
npm outdated

# Interactive upgrade tool
npx npm-check-updates

# Update all patch versions (safest)
npx npm-check-updates -u --target patch && npm install

# Check maintenance status — flag abandoned packages
npx npm-check  # shows last publish date
```

Flag packages as abandoned if:
- Last publish > 2 years ago
- Open issues > 100 with no recent responses
- Explicit deprecation warning on npm

## Dependency Bloat Analysis
```bash
# Find unused dependencies
npx depcheck

# Analyze what's included in your bundle
npx webpack-bundle-analyzer  # or @next/bundle-analyzer
npx source-map-explorer dist/bundle.js
```

Common bloat patterns:
- `lodash` instead of `lodash-es` (not tree-shakeable)
- `moment` instead of `date-fns` (moment is 67kb, non-tree-shakeable)
- Full icon library import instead of individual icons
- Utility packages replaceable with native JS

## Upgrade Path Planning
```
Semver risk levels:
patch (1.0.x): Low risk — bug fixes only, safe to auto-update
minor (1.x.0): Medium risk — new features, backwards compatible
major (x.0.0): High risk — breaking changes, review changelog
```

```bash
# Safe batch upgrade process:
# 1. Update patch versions
npx npm-check-updates -u --target patch
npm install && npm test

# 2. Update minor versions
npx npm-check-updates -u --target minor
npm install && npm test

# 3. Update major versions one at a time — check changelog first
npm install package@latest
# Read breaking changes → update code → run tests
```

## Supply Chain Security
```bash
# Verify package integrity
npm install --ignore-scripts  # prevents malicious install scripts (use for CI)

# Check for typosquatting (common attacks)
# Verify exact package name before installing
npm info <package-name> | grep -E "name|author|homepage"
```

## Lockfile Analysis
```bash
# Ensure lockfile is committed and up to date
git diff package-lock.json  # should only change on intentional updates

# Verify lockfile consistency (CI check)
npm ci  # fails if package-lock.json doesn't match package.json
```

## Audit Report Output
```markdown
## Dependency Audit Report — [date]

### Vulnerabilities
- Critical: 0
- High: 0
- Moderate: 2 (documented below)

### License Issues
- All dependencies: permissive ✅

### Outdated Packages
- [list of packages >1 major version behind]

### Abandoned Packages
- [packages with no commits in 2+ years]

### Recommended Actions
1. Update [package] from v2.x to v3.x — breaking changes: [summary]
2. Replace [abandoned-package] with [maintained-alternative]
```
