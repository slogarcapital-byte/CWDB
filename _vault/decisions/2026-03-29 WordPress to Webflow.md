---
type: decision
decision-date: 2026-03-29
decided-by: "[[Jim Slogar]]"
context: WordPress added hosting and maintenance complexity unnecessary for a lead gen site
alternatives-considered:
  - WordPress (original plan)
  - Custom HTML/CSS
outcome: Webflow only
supersedes: WordPress
tags:
  - type/decision
  - decision/tech-stack
created: 2026-03-29
updated: 2026-04-16
status: active
---

# Decision: WordPress Dropped for Webflow Only

## Context
Original tech stack included both WordPress and [[Webflow]]. WordPress adds hosting, plugin, and maintenance overhead.

## Decision
**Webflow only.** Simpler stack, visual builder, built-in CMS, no hosting management.

## Impact
- All website work done in [[Webflow]]
- No WordPress hosting or plugins to manage
- [[Web Dev Agent]] uses Webflow MCP for all site changes

## Related
- [[Webflow]]
- [[Web Dev Agent]]
