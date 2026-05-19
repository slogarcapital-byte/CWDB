---
type: memory
agent-id: lead-qualification
name: scoring-rules
description: Lead scoring rules summary — point values, thresholds, disqualification triggers
tags:
  - type/memory
  - agent/lead-qualification
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Scoring Rules

**Why:** Ensures only qualified homeowner leads reach contractors. Protects contractor trust.

**How to apply:** Apply to every form submission. Score ≥60 → qualified → route to contractors.

## Full Spec
`/operations/leads/scoring-rules.json`

## Rules
1. **Homeowner** (30 pts, REQUIRED) — "Do you own this property?" must be "Yes, I own this home". DQ if renter.
2. **Service Territory** (20 pts, REQUIRED) — Property address ZIP must be in: 54401, 54403, 54476, 54474, 54452. DQ if outside.
3. **Valid Phone** (10 pts, REQUIRED) — Must be valid US phone format. DQ if invalid.
4. **Budget ≥$5K** (20 pts) — "What is your estimated budget?" must not be "Under $5,000". Low-budget leads flagged but not DQ'd.
5. **Near-term Timeline** (20 pts) — "When are you looking to start?" in ["As soon as possible", "Within 1–3 months"].

## Pass Threshold: 60 points
Maximum: 100 points

## Auto-DQ Conditions
- Renter
- Outside territory
- Invalid phone
- Duplicate (same phone within 30 days)
