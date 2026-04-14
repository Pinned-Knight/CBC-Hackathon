---
description: Context window compression — intelligently summarizes conversation history and large file contents to prevent token bloat, while preserving the information agents actually need. Activate when context is getting large or when spawning a new agent that needs project context.
allowed-tools: Read, Write, Bash, Glob, mcp__memory__*, mcp__filesystem__*
---

# Strategic Compact

## Purpose
Long agent sessions accumulate context — full file contents, repeated tool outputs, verbose logs. This skill compresses that context intelligently, keeping what matters and discarding what's already been acted on.

## When to Activate
- Before spawning a new sub-agent (pass compact context, not full history)
- When conversation history exceeds ~50k tokens
- When passing context between phases (Phase 2 → Phase 3)
- When a file referenced earlier has since been updated

## Compression Levels

### Level 1 — Summarize Tool Outputs (lightest)
Replace verbose tool call results with a one-line summary:
```
BEFORE:
[full output of npm test — 200 lines]

AFTER:
[Test result: 142 passed, 0 failed, coverage 87% — 2024-01-15T10:30:00Z]
```

### Level 2 — Compress File References (medium)
Replace full file contents with a structural summary:
```
BEFORE:
[full content of src/services/user.service.ts — 180 lines]

AFTER:
[user.service.ts: 180 lines — exports UserService with methods:
  createUser(input) → Promise<User>
  findById(id) → Promise<User|null>
  updateUser(id, input) → Promise<User>
  deleteUser(id) → Promise<void>
  Dependencies: UserRepository, EmailService, BcryptService]
```

### Level 3 — Phase Handoff Summary (heaviest, between phases)
At phase boundaries, produce a `phase-N-summary.md`:
```markdown
## Phase [N] Complete — [timestamp]

### What was built
- [list of files created]
- [key architectural decisions made]

### Current state
- Tech stack: [confirmed choices]
- Database: [schema status]
- API: [endpoints implemented]

### Open items for Phase [N+1]
- [list of things the next phase needs to do]
- [unresolved questions]

### Key files to read
- [file]: [one-line description of what's in it]
```

## Context Handoff Template
When spawning a new agent, pass this compact context:
```
You are the [agent-name]. Here is your context:

PROJECT: [one-sentence app description]
PHASE: [current phase]
YOUR INPUT: [specific file or data you're receiving]
YOUR OUTPUT: [specific file or data you must produce]
CONSTRAINTS: [3-5 most important rules for this agent]
PRIOR DECISIONS: [key architectural choices already locked in]
```

## Rules
- Never discard error messages — errors are always compact-forward
- Never discard decision rationale — WHY something was chosen is precious
- Always preserve file paths and line numbers in summaries
- When in doubt, summarize rather than delete
- The orchestrator's chain-of-thought is never compacted — only tool outputs and file contents
