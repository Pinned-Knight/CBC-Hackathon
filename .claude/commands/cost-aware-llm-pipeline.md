---
description: Token cost tracking and optimization for multi-agent pipelines — monitors token usage per agent, flags expensive operations, and recommends cost-reduction strategies. Activate when planning or auditing a multi-agent workflow.
allowed-tools: Read, Write, Bash, Glob, mcp__memory__*, mcp__filesystem__*
---

# Cost-Aware LLM Pipeline

## Purpose
Multi-agent systems can burn tokens quickly. This skill tracks cost per agent, identifies expensive patterns, and enforces budgets so a single run doesn't become prohibitively expensive.

## Token Cost Reference (approximate, verify current pricing)
| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|---|---|---|
| claude-opus-4-6 | $15 | $75 |
| claude-sonnet-4-6 | $3 | $15 |
| claude-haiku-4-5 | $0.80 | $4 |

## Agent Cost Profiles

### Heavy Agents (use claude-opus-4-6 only when needed)
- `orchestrator` — high complexity reasoning → Opus
- `product-strategist` — creative synthesis → Opus
- `agent-designer` — system architecture → Opus

### Medium Agents (claude-sonnet-4-6)
- `frontend-architect` — structured code generation → Sonnet
- `backend-engineer` — structured code generation → Sonnet
- `database-engineer` — structured code generation → Sonnet
- `security-agent` — pattern matching + reasoning → Sonnet
- `code-reviewer` — analysis → Sonnet

### Light Agents (claude-haiku-4-5)
- `build-error-resolver` — focused, narrow task → Haiku
- `docs-agent` — templated output → Haiku
- `refactor-cleaner` — mechanical transformations → Haiku
- `qa-agent` (test execution) → Haiku for test running

## Budget Enforcement

### Per-Agent Token Budgets
```typescript
const agentBudgets = {
  orchestrator:          50_000,  // tokens
  'product-strategist':  30_000,
  'research-analyst':    40_000,
  'frontend-architect':  80_000,
  'backend-engineer':    80_000,
  'database-engineer':   40_000,
  'qa-agent':            60_000,
  'security-agent':      30_000,
  'docs-agent':          20_000,
  'growth-agent':        20_000,
}
// Total budget: ~450k tokens ≈ $2-5 per full app generation
```

### Context Size Reduction Strategies
1. **Pass summaries, not full files** — use `strategic-compact` before handoffs
2. **Use targeted reads** — agents should read only the sections they need
3. **Cache tool outputs** — don't re-run the same shell command twice
4. **Prune conversation history** — use `strategic-compact` after Phase 2
5. **Parallel agents** — same cost, less wall time

## Cost Tracking
After each agent completes, log to `build-log.md`:
```markdown
- agent: frontend-architect | model: sonnet | ~tokens: 45,000 | ~cost: $0.07
```

## Red Flags (investigate if seen)
- Any single agent call > 100k tokens → likely passing too much context
- Same file being read 5+ times → cache the content
- Orchestrator > 80k tokens → time to compact
- Total run > 1M tokens → review what's being passed between agents

## Optimization Checklist
- [ ] Each agent receives only what it needs (not full history)
- [ ] Heavy model used only for reasoning-heavy agents
- [ ] Phase boundaries use strategic-compact
- [ ] Repeated tool outputs are cached
- [ ] Agent outputs are summaries, not full file dumps
