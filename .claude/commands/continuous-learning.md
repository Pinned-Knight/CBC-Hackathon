---
description: Instinct-based continuous learning — captures decisions made during a session, extracts reusable patterns, and updates persistent memory so future sessions build on past experience. Activate at session end or after major decisions.
allowed-tools: Read, Write, Bash, mcp__memory__*, mcp__filesystem__*
---

# Continuous Learning

## Purpose
Every agent session produces implicit knowledge — what worked, what failed, which patterns were chosen and why. This skill captures that knowledge and persists it so future sessions start smarter.

## When to Activate
- At the end of any agent session
- After a significant architectural decision
- After a bug is fixed (learn the pattern)
- After a performance optimization is applied
- After a security issue is discovered and fixed

## Learning Extraction Process

### Step 1 — Scan the Session
Read `build-log.md` and identify:
- Decisions made (tech stack choices, architecture choices)
- Errors encountered and how they were resolved
- Patterns applied (which skills were most useful)
- Anything that was tried and didn't work

### Step 2 — Classify Learning Type
```
PATTERN:    A reusable solution to a recurring problem
ANTI-PATTERN: Something that was tried and failed — don't repeat
DECISION:   A one-time architectural choice and why it was made
TOOL-TIP:   A non-obvious way to use a tool effectively
```

### Step 3 — Confidence Scoring
Rate each insight:
```
HIGH (0.9+):   Directly observed, reproducible, clearly beneficial
MEDIUM (0.7):  Likely correct, needs more data to confirm
LOW (0.5):     Hypothesis — worth noting but not yet proven
```
Only persist HIGH and MEDIUM confidence learnings.

### Step 4 — Store in Memory
```
memory.store({
  type: "PATTERN",
  title: "Zod validation before service layer prevents 40% of runtime errors",
  context: "Observed across 3 feature implementations — consistent result",
  confidence: 0.9,
  applies_to: ["backend-engineer", "api-design"],
  learned_from: "session-{id}"
})
```

### Step 5 — Update Project Context
Append to `.claude/contexts/project-context.md`:
```markdown
## Learned Patterns
- [timestamp] PATTERN: [title] (confidence: HIGH)
- [timestamp] ANTI-PATTERN: [title] — avoid because [reason]
```

## Format for Stored Learnings
```markdown
### [type]: [title]
**Confidence:** HIGH / MEDIUM
**Applies to:** [agent or skill names]
**Context:** [when this applies]
**Learning:** [the actual insight]
**Evidence:** [what you observed that led to this]
```

## Anti-Pattern Examples to Always Capture
- "Used X library but Y was better for this use case because..."
- "Tried to do X in one migration but it required downtime — use expand-contract next time"
- "Assumed deployment target was Vercel but Railway was needed for background workers"

## Rules
- Never store PII or secrets in memory
- Confidence must be justified — don't inflate
- Review stored patterns monthly and remove outdated ones
- Pass learned patterns to the orchestrator at next session start
