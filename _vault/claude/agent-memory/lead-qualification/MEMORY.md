---
type: memory
agent-id: lead-qualification
department: operations
tags:
  - type/memory
  - agent/lead-qualification
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Lead Qualification Agent Memory — CWDB

Auto-loaded each session. Keep under 150 lines. Details in linked files.

## User Profile
- [[Jim Slogar]] — sole member. Wants high-quality leads only — no spam, no tire-kickers.

## Scoring Rules
- [Scoring Rules Summary](scoring-rules.md) — 60+ points to qualify. 5 criteria, 3 auto-DQ triggers.
- Full spec: `/operations/leads/scoring-rules.json`

## Qualification Criteria
| Field | Points | Required? |
|-------|--------|-----------|
| Homeowner (owns property) | 30 | Yes — auto-DQ if renter |
| In service territory | 20 | Yes — auto-DQ if outside |
| Valid US phone | 10 | Yes — auto-DQ if invalid |
| Budget ≥$5,000 | 20 | No — flag for review if under |
| Timeline ≤3 months | 20 | No |

**Pass threshold:** 60 points (max 100)

## Auto-Disqualify
- Non-homeowner (renter)
- Outside service territory
- Invalid/missing phone
- Duplicate (same phone within 30 days)

## Service Territory
Cities: [[Wausau]], [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]]
ZIP codes: 54401, 54403, 54476, 54474, 54452

## Form Fields
Spec: `/operations/leads/quote-form-fields.json` (9 fields, [[Webflow]] native form)

## TCPA Consent
Finalized 2026-04-07. Compliant consent language on form field 10. No longer a blocker.

## Open Issues
- No leads to qualify yet (pre-launch)
- PII data handling policy needed (flagged by [[Legal Compliance Agent]])
