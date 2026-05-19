---
name: Bid Acceptance Verification Architecture
description: Recommended system for verifying contractor-reported accepted bids — dual-confirmation + audit rights + contractual teeth
type: reference
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-04-04
updated: 2026-04-16
status: active
---

## The Problem
CWDB's revenue model ($1,000 per accepted bid) depends entirely on contractors self-reporting when a homeowner accepts their bid. Contractors have a financial incentive to underreport. A pure honor system is unenforceable.

## Recommended Verification System: Dual-Confirmation with Audit Rights

### Layer 1 — Homeowner Follow-Up Confirmation (Primary Control)
- After delivering a lead, CWDB sends the homeowner an automated follow-up sequence via email/SMS (through [[Make]] automation):
  - Day 7: "Have you received quotes from our builders yet?"
  - Day 14: "Have you selected a contractor for your deck project?"
  - Day 30: "Has your project started? We'd love to hear how it's going."
- If homeowner confirms they hired a CWDB-referred contractor, that triggers a billing event.
- This gives CWDB an independent data source it controls — not reliant on contractor reporting.
- TCPA consent for these follow-ups must be baked into the [[Webflow]] quote request form.

### Layer 2 — Contractor Reporting Obligation (Contractual)
- Contractor agreement requires written notification to CWDB within 5 business days of a bid being accepted.
- Contractor must provide: homeowner name, project address, accepted bid amount, and estimated start date.
- Failure to report is a material breach.

### Layer 3 — Audit Rights Clause (Deterrent)
- Contractor agreement grants CWDB the right to audit contractor records related to CWDB-sourced leads.
- Scope: project records, invoices, and correspondence with homeowners originally sourced through CWDB.
- Frequency: no more than once per calendar quarter, with 10 business days' notice.
- This clause exists primarily as a deterrent — unlikely to be exercised often, but its presence discourages underreporting.

### Layer 4 — Contractual Consequences (Teeth)
- If audit or homeowner confirmation reveals unreported accepted bids:
  - Contractor owes the $1,000 fee plus a late reporting penalty (recommend $250 per incident).
  - CWDB may suspend or terminate lead delivery.
  - Repeated violations (2+ in 12 months) = automatic termination for cause + all outstanding fees immediately due.
- Liquidated damages clause for intentional concealment: 2x the standard fee ($2,000 per concealed bid).

### Layer 5 — Lead Withholding Leverage (Practical)
- CWDB controls the lead flow. If a contractor stops reporting, CWDB simply stops sending leads.
- This is the most powerful practical enforcement tool — no court needed.
- Contractor agreement should explicitly state that CWDB may pause or redirect lead delivery at its sole discretion.

## Implementation Priority for Phase 1
1. **Immediate:** Include Layers 2, 3, 4, 5 in the Contractor Lead Purchase Agreement
2. **Before first ad spend:** Build Layer 1 homeowner follow-up sequence in Make
3. **Form update:** Add TCPA consent language covering post-submission follow-ups to the Webflow quote form

## Wisconsin Law Notes
- Audit rights clauses are enforceable in Wisconsin commercial contracts between businesses (B2B).
- Liquidated damages must be reasonable and not punitive — 2x fee for intentional concealment should survive scrutiny as a reasonable estimate of damages (lost revenue + investigation costs).
- Lead withholding is permissible — CWDB has no obligation to continue delivering leads absent a minimum commitment clause running the other direction.
