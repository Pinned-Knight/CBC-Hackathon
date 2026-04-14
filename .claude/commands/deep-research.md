---
description: Deep multi-source research workflow using firecrawl and exa MCP tools. Activate when users ask to research, deep dive, investigate, or explore the current state of any topic.
allowed-tools: Read, Write, mcp__brave-search__*, mcp__fetch__*, mcp__memory__*, mcp__filesystem__*
---

# Deep Research Workflow

## When to Activate
User says: "research", "deep dive", "investigate", "explore", "current state of", "find information about", "look into"

## Core Standards
- Every material claim requires source attribution
- Cross-reference unverified single-source assertions
- Prioritize recent sources (last 12 months)
- Flag gaps, estimates, and opinions clearly
- Separate facts from inferences
- State "insufficient data" when appropriate — never hallucinate

## 6-Step Research Process

### Step 1 — Clarify Goals
Before searching, understand what the user needs:
- Learning/understanding? → synthesis + explanation
- Decision-making? → comparison + recommendation
- Writing content? → facts + citations
- Competitive analysis? → structured comparison

### Step 2 — Plan Sub-Questions
Break the topic into 3-5 focused research angles:
```
Topic: "Best auth library for Next.js in 2024"
Sub-questions:
1. What auth libraries exist for Next.js?
2. How do they compare on features (OAuth, MFA, session management)?
3. What are their maintenance status and community health?
4. What are real-world developer experiences and pain points?
5. What do official docs recommend?
```

### Step 3 — Multi-Source Search
Run 2-3 keyword variations per sub-question:
```
brave-search: "nextjs auth library 2024 comparison"
brave-search: "nextjs authentication nextauth clerk supabase"
brave-search: "nextjs auth best practices site:reddit.com OR site:dev.to"
```
Target: 15-30 unique sources across academic, official, news, and reputable sources.

### Step 4 — Deep-Read Key Sources
Scrape 3-5 most promising URLs for full context:
```
fetch: [official docs URL]
fetch: [in-depth comparison article URL]
fetch: [recent benchmarks or community discussion URL]
```

### Step 5 — Synthesize Report
Structure findings:
```markdown
## Executive Summary
[2-3 sentence overview of findings]

## Key Findings
[Themed sections, each with evidence and sources]

## Comparison (if applicable)
[Table or structured comparison]

## Takeaways & Recommendations
[Actionable conclusions]

## Risks & Caveats
[What might be wrong, outdated, or uncertain]

## Sources
[Numbered list of all sources cited]
```

### Step 6 — Deliver
- Short topics (< 500 words): inline response
- Long topics: save to `research-report.md` via filesystem MCP, then summarize

## Quality Checklist
- [ ] All numbers sourced or labeled as estimates
- [ ] Stale data (> 2 years) flagged explicitly
- [ ] Recommendations are evidence-based
- [ ] Counterarguments and risks included
- [ ] Output enables decision-making
- [ ] Sources list complete
