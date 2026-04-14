# CBC Hackathon — Agentic Development Challenge

## Summary

Build a **minimal blueprint repository** that, when executed with a single high-level prompt, causes Claude to autonomously generate a complete working application through multi-agent collaboration.

**You submit the factory, not the product.**

---

## Submission Requirements

Your repository must contain **exactly two things**:

1. `.claude/` folder — skill configs, agent definitions, sub-agent roles, MCP tool settings, structured workflow instructions
2. `claude.md` — master configuration file that Claude reads to orchestrate the entire system

**Any other files = immediate disqualification.**

---

## The Flow

```
Your Initial Prompt
        ↓
Orchestrator Agent reads claude.md → activates sub-agents
        ↓
Sub-agents plan, generate, and assemble the application
        ↓
Complete application — generated autonomously
```

---

## Evaluation Criteria (25% each)

| Criterion | What They Look For |
|---|---|
| **Prompt Interpretation** | Accurately maps prompt to a coherent plan |
| **Agent Coordination** | Clear role separation, handoffs, conflict resolution |
| **Architecture Quality** | Scalability, modularity, thoughtfulness |
| **Automation Depth** | Genuinely automated vs hardcoded/pre-built |

---

## Hard Rules

- Only `.claude/` folder and `claude.md` in the repo — nothing else
- No pre-written frontend or backend code anywhere
- Every output must emerge from agent execution — nothing hardcoded
- Unique submission — own prompt, own repo
- MCP integrations strongly encouraged and rewarded

---

## Tips for a Strong Submission

- Design agents with **clear, distinct roles**: orchestrator, planner, code generator, reviewer, etc.
- Use skill files in `.claude/` to give each agent a focused, non-overlapping capability
- Chain agents thoughtfully — output of one is a well-formed input for the next
- Integrate at least **one MCP tool** (filesystem, GitHub, browser, or custom)
- Write a **clear, specific initial prompt** — vague prompts produce vague systems
- Test end-to-end before submitting

---

## Submission Checklist

- [ ] Repo contains only `.claude/` folder and `claude.md` — nothing else
- [ ] No pre-written frontend or backend code anywhere
- [ ] Initial prompt is clearly written and submitted via the form
- [ ] GitHub repository is public and accessible
- [ ] System can generate a complete application when the prompt is executed
- [ ] All four declaration checkboxes in the submission form are ticked

---

*Claude Builders Club • BITS Pilani*
