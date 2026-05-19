---
type: decision
decision-date: 2026-03-29
decided-by: "[[Jim Slogar]]"
context: Zapier pricing too high for a pre-revenue startup
alternatives-considered:
  - Zapier (original plan)
  - n8n (self-hosted)
outcome: Make (formerly Integromat)
supersedes: Zapier
tags:
  - type/decision
  - decision/tech-stack
created: 2026-03-29
updated: 2026-04-16
status: active
---

# Decision: Zapier Dropped for Make

## Context
Original automation platform was Zapier. Make offers a better free tier and lower costs for the volume we need.

## Decision
**Make (formerly Integromat).** Cheaper, better free tier, sufficient for lead routing automation.

## Impact
- All automation references changed from Zapier to Make
- Webhook spec: `/operations/make/webhooks.json`
- [[Lead Routing Agent]] uses Make for lead delivery

## Related
- [[Make]]
- [[Lead Routing Agent]]
