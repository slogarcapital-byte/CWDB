---
type: agent
agent-id: revenue-optimization
department: finance
domain:
  - pricing
  - roi-analysis
  - market-optimization
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/revenue-optimization/
tags:
  - type/agent
  - agent/revenue-optimization
  - dept/finance
aliases:
  - revenue-optimization
  - Agent 7
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Revenue Optimization Agent

Analyzes lead conversion rates, optimizes pricing models, and adjusts ad spend allocation.

## Responsibilities
- Analyze cost per lead and revenue per accepted bid
- Optimize pricing models
- Identify profitable markets
- Adjust ad spend allocation across [[Google Ads]], [[Meta Ads]], [[Nextdoor]], [[TikTok]]

## Key Files
- **Prompt:** `.claude/agents/revenue-optimization.md`
- **Memory:** `.claude/agent-memory/revenue-optimization/MEMORY.md`

## Target Metrics
| Metric | Target |
|--------|--------|
| Cost per lead | <$60 |
| Revenue per accepted bid | $1,000 |
| Cost per accepted bid | <$400 |
| ROI | 2x+ |

## Current State
No live data yet — pre-launch.

## Prompt (live)
![[claude/agents/revenue-optimization]]

## Agent Memory (live)
![[claude/agent-memory/revenue-optimization/MEMORY]]
