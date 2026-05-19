---
type: agent
agent-id: market-research
department: marketing
domain:
  - market-analysis
  - city-expansion
  - competitive-intelligence
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/market-research/
tags:
  - type/agent
  - agent/market-research
  - dept/marketing
aliases:
  - market-research
  - Agent 1
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Market Research Agent

Identifies high-demand contractor niches, analyzes local market demand, and recommends city expansions.

## Responsibilities
- Analyze local market demand in target cities
- Identify underserved cities for expansion
- Monitor [[Nextdoor]] neighborhood posts for demand signals
- Estimate lead value by niche

## Key Files
- **Prompt:** `.claude/agents/market-research.md`
- **Memory:** `.claude/agent-memory/market-research/MEMORY.md`

## Markets Covered
**Primary:** [[Wausau]], [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]]
**Expansion:** [[Eau Claire]], [[Appleton]], [[Green Bay]], [[Stevens Point]], [[Madison]], [[Minneapolis Suburbs]]

## Prompt (live)
![[claude/agents/market-research]]

## Agent Memory (live)
![[claude/agent-memory/market-research/MEMORY]]
