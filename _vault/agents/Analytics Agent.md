---
type: agent
agent-id: analytics
department: finance
domain:
  - ga4
  - gtm
  - funnel-analysis
  - conversion-tracking
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/analytics/
tags:
  - type/agent
  - agent/analytics
  - dept/finance
aliases:
  - analytics
  - Agent 9
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Analytics Agent

Monitors landing page traffic, ad platform performance, and lead funnel drop-off points.

## Responsibilities
- Monitor landing page traffic and conversion rates
- Analyze ad platform performance by channel
- Track lead funnel drop-off points
- Identify top-performing creatives and keywords

## Key Funnel
Ad Impression → Click → Page Visit → Form Submit → Qualified Lead → Contractor Delivery

## Key Files
- **Prompt:** `.claude/agents/analytics.md`
- **Memory:** `.claude/agent-memory/analytics/MEMORY.md`
- **Reports:** `/finance/reports/performance/`

## Current State
No tracking set up yet. GA4, GTM, Meta Pixel, Nextdoor Pixel, Google Ads conversion, MS Clarity all pending (Phase F).

## Prompt (live)
![[claude/agents/analytics]]

## Agent Memory (live)
![[claude/agent-memory/analytics/MEMORY]]
