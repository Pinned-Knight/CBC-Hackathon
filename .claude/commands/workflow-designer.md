---
description: Multi-agent workflow design — sequential, parallel, router, orchestrator, and evaluator patterns with handoff contracts and failure recovery. Activate when designing agent workflows or multi-step automation pipelines.
allowed-tools: Read, Write, Edit, Grep
---

# Workflow Designer (POWERFUL Tier)

## When to Use Multi-Agent Workflows
A single prompt is insufficient when:
- Task complexity exceeds a single agent's context
- Tasks can be parallelized for speed
- Different stages require different specialized capabilities
- Quality gates are needed between stages
- Human approval is required at certain steps

## Workflow Patterns

### Sequential Workflow
Each agent runs after the previous completes. Use when stages have strict dependencies.
```
Input → [Agent A] → output_A → [Agent B] → output_B → [Agent C] → Final Output
```
```typescript
async function runSequential(input: Input) {
  const plannerOutput = await plannerAgent.run(input)
  const builderOutput = await builderAgent.run(plannerOutput)
  const reviewerOutput = await reviewerAgent.run(builderOutput)
  return reviewerOutput
}
```

### Parallel Workflow
Multiple agents run simultaneously on independent tasks. Use to reduce total time.
```
Input → ┌─ [Agent A] ─┐
        ├─ [Agent B] ─┤ → merge → Final Output
        └─ [Agent C] ─┘
```
```typescript
async function runParallel(input: Input) {
  const [frontendResult, backendResult, dbResult] = await Promise.all([
    frontendAgent.run(input),
    backendAgent.run(input),
    dbAgent.run(input),
  ])
  return mergeOutputs(frontendResult, backendResult, dbResult)
}
```

### Router Workflow
An orchestrator inspects input and routes to the appropriate specialist.
```
Input → [Router] → intent detection → [Specialist A | B | C]
```
```typescript
async function routeRequest(input: Input) {
  const intent = await routerAgent.classify(input)
  switch (intent) {
    case 'billing': return billingAgent.run(input)
    case 'technical': return techAgent.run(input)
    default: return generalAgent.run(input)  // fallback
  }
}
```

### Orchestrator Pattern
Central planner manages multiple specialists, aggregates results.
```
[Orchestrator] → dispatches tasks → [Specialist x N]
                ← collects outputs ←
                → aggregates → Final Output
```

### Evaluator-Generator Loop
Quality gate: generator produces output, evaluator scores it, loop until threshold met.
```
[Generator] → output → [Evaluator] → score < threshold → back to Generator
                                    → score ≥ threshold → done
```
```typescript
async function generateWithEval(prompt: string, maxAttempts = 3) {
  for (let i = 0; i < maxAttempts; i++) {
    const output = await generatorAgent.run(prompt)
    const score = await evaluatorAgent.score(output)
    if (score.pass) return output
    prompt = `${prompt}\n\nPrevious attempt failed: ${score.feedback}. Try again.`
  }
  throw new Error('Max attempts reached without passing evaluation')
}
```

## Handoff Contract Template
Every agent-to-agent handoff must be explicit:
```typescript
interface HandoffPayload {
  from: string          // agent name
  to: string            // next agent name
  phase: string         // which workflow phase
  data: {
    // only what the next agent needs — nothing extra
  }
  metadata: {
    attemptNumber: number
    startedAt: string
    parentWorkflowId: string
  }
}
```

## Failure Recovery Policies
```typescript
const retryPolicy = {
  maxAttempts: 3,
  backoffMs: [1000, 3000, 9000],   // exponential backoff
  retryOn: ['TIMEOUT', 'RATE_LIMIT', 'TRANSIENT_ERROR'],
  noRetryOn: ['VALIDATION_ERROR', 'AUTH_ERROR', 'NOT_FOUND'],
}

const fallbackPolicy = {
  onMaxRetriesExceeded: 'skip-and-log',  // or 'escalate-to-human' | 'abort-workflow'
  requiredAgents: ['qa-agent', 'security-agent'],  // must succeed or abort
  optionalAgents: ['growth-agent', 'docs-agent'],  // skip on failure, continue workflow
}
```

## Cautions
- **Avoid over-engineering**: use a single agent for simple tasks
- **Timeout every agent**: no agent should run indefinitely
- **Keep payloads bounded**: don't pass full conversation history between agents
- **Validate intermediate outputs**: check agent output schema before passing downstream
- **Budget before scaling**: test with token budgets before production

## Rules
- Define handoff contracts before implementing any workflow
- Every agent in a workflow must have a timeout
- Required agents (security, qa) must succeed — optional agents (docs, growth) can be skipped
- Log every agent invocation, input hash, and output hash to the build log
