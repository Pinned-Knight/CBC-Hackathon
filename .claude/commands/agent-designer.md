---
description: Multi-agent system architecture — designing agent roles, communication patterns, orchestration strategies, tool schemas, guardrails, and evaluation frameworks. Activate when designing or reviewing a multi-agent system.
allowed-tools: Read, Write, Edit, Grep
---

# Agent Designer (POWERFUL Tier)

## Architecture Pattern Selection

### Single Agent
- **Use when**: Simple, focused task with clear boundaries
- **Pros**: Minimal complexity, easy debugging, predictable
- **Cons**: Limited parallelism, single point of failure

### Supervisor Pattern
- **Use when**: Hierarchical task decomposition, centralized control needed
- **Architecture**: One supervisor coordinates multiple specialist agents
- **Pros**: Clear command structure, centralized decision-making
- **Cons**: Supervisor bottleneck, complex coordination logic

### Swarm Pattern
- **Use when**: Distributed problem solving, high parallelism needed
- **Architecture**: Multiple autonomous agents, peer-to-peer collaboration
- **Pros**: Fault tolerant, emergent intelligence, high throughput
- **Cons**: Complex coordination, potential conflicts, harder to predict

### Pipeline Pattern
- **Use when**: Sequential processing with specialized stages
- **Architecture**: Agents arranged in processing stages with typed handoffs
- **Pros**: Clear data flow, specialized optimization per stage
- **Cons**: Sequential bottlenecks, rigid processing order

## Agent Role Definition

For each agent, define:
```
Identity: Name, purpose statement, core competencies
Responsibilities: Primary tasks, decision boundaries, success criteria
Capabilities: Required tools, knowledge domains, processing limits
Interfaces: Input format, output format, communication protocol
Constraints: Security boundaries, resource limits, operational guidelines
```

## Common Agent Archetypes

| Archetype | Role |
|---|---|
| **Coordinator** | Orchestrates workflows, allocates resources, handles escalations |
| **Specialist** | Deep expertise in one domain (code, data, research) |
| **Interface** | Handles external interactions (users, APIs, systems) |
| **Monitor** | Observability, alerting, compliance, audit trails |

## Tool Design Principles

### Schema Design
```typescript
// Strong typing, clear descriptions, consistent error format
interface ToolInput {
  required_field: string    // always document what this does
  optional_field?: number   // mark optional explicitly
}
interface ToolOutput {
  success: boolean
  data?: any
  error?: { code: string; message: string }
}
```

### Error Handling Patterns
- Graceful degradation: partial functionality when dependencies fail
- Retry with exponential backoff: `delay = Math.min(1000 * 2^attempt, 30000)`
- Circuit breaker: after N failures, fail fast for M minutes
- Structured error responses: always include `code` and `message`

### Idempotency
- Design write operations to be safely retryable
- Use idempotency keys for critical operations
- Track operation state to detect and handle retries

## Communication Patterns

### Handoff Contract
Every agent-to-agent handoff must define:
```
From: [agent-name]
To: [agent-name]
Payload format: [TypeScript interface]
Success condition: [what "done" means]
Failure condition: [what triggers retry or escalation]
```

### Context Sizing
- Keep handoff payloads **explicit and bounded** — no full conversation history
- Pass only what the receiving agent needs
- Validate intermediate outputs before combining results

## Guardrails

### Input Validation
- Schema enforcement on all agent inputs
- Content filtering for harmful requests
- Rate limiting on tool calls
- Authentication on inter-agent communication

### Human-in-the-Loop Triggers
- Confidence below threshold → escalate to human
- Irreversible actions → require approval
- Cost above budget → pause and report
- Ambiguous intent → clarify before acting

## Evaluation Framework

| Metric | Measurement |
|---|---|
| Task completion rate | % of tasks fully completed |
| Quality score | Output accuracy vs ground truth |
| Latency | End-to-end time per task |
| Cost | Token usage and API costs per task |
| Error rate | % of tasks requiring retry or escalation |

## Rules
- Avoid over-engineering simple tasks — single agent when possible
- Always define timeout and retry policies
- Never allow unbounded context growth in long-running agents
- Test with constrained token budgets before scaling
- Document every inter-agent interface as a contract
