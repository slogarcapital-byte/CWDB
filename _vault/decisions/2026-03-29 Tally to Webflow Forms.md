---
type: decision
decision-date: 2026-03-29
decided-by: "[[Jim Slogar]]"
context: Tally form was built but added unnecessary complexity to the stack
alternatives-considered:
  - Keep Tally (Form ID 81GbEO)
  - Typeform
  - Custom HTML form
outcome: Webflow native forms
supersedes: Tally form 81GbEO
tags:
  - type/decision
  - decision/tech-stack
created: 2026-03-29
updated: 2026-04-16
status: active
---

# Decision: Tally Replaced by Webflow Native Forms

## Context
Tally form (ID: 81GbEO) was built on 2026-03-28, but adding a third-party form tool to a [[Webflow]] site added unnecessary stack complexity.

## Options Considered
1. **Keep Tally** — already built, but requires embed, post-submit redirect needs Pro plan
2. **Typeform** — powerful but expensive, same embed issues
3. **Webflow native forms** — built into the platform, better design control, simpler stack

## Decision
**Webflow native forms.** Simpler stack, better design control, no third-party dependency.

## Impact
- Tally form 81GbEO superseded — do not use
- All form references updated to Webflow native
- Form spec: `/operations/leads/quote-form-fields.json`
- 9-field quote form with TCPA consent language

## Related
- [[Webflow]]
- [[Web Dev Agent]]
- [[Lead Qualification Agent]]
