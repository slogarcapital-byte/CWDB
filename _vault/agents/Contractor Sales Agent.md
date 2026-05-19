---
type: agent
agent-id: contractor-sales
department: sales
domain:
  - contractor-outreach
  - onboarding
  - pricing
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/contractor-sales/
tags:
  - type/agent
  - agent/contractor-sales
  - dept/sales
aliases:
  - contractor-sales
  - Agent 6
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Contractor Sales Agent

Identifies, pitches, and onboards deck contractor partners. Negotiates territory pricing.

## Responsibilities
- Generate contractor outreach scripts
- Handle contractor onboarding
- Negotiate pricing ($1,000/accepted bid)
- Manage contractor relationships

## Key Files
- **Prompt:** `.claude/agents/contractor-sales.md`
- **Memory:** `.claude/agent-memory/contractor-sales/MEMORY.md`
- **Call Script:** `/sales/outreach/call-script.md`
- **Email Template:** `/sales/outreach/email-template.md`
- **Contractor Profile:** `/sales/onboarding/contractor-profile.json`

## Current Roster
- [[Ben Barton]] — agreement sent 2026-04-07
- [[John Garcia]] — agreement sent 2026-04-07
- Target: 10-20 contractors total

## Prompt (live)
![[claude/agents/contractor-sales]]

## Agent Memory (live)
![[claude/agent-memory/contractor-sales/MEMORY]]
