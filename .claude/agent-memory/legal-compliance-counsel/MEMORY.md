---
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-04-04
updated: 2026-06-24
status: active
---

# Legal & Compliance Counsel Memory — CWDB

## User Profile
- [[[Jim Slogar]] — Profile & Preferences](user-jim-slogar.md) — No attorney on retainer; AI serves as working counsel; prefers full docs + summary + walkthrough

## Owner & Entity
- [Entity & Ownership Status](entity-ownership.md) — LLC formed 2026-04-06; single-member WI LLC; James Slogar; EIN 41-5355234; Entity ID C138564
- [Construction Services Pivot](construction-services-pivot.md) — 2026-06-08: CWDB adds direct deck build/stain UNDER the existing LLC; full legal/insurance/structuring doc set drafted; Ben/John become subs; spin-out off-ramp noted. DSPS licensing facts verified + executable roadmap 2026-06-24 (`docs/legal/construction-setup/01-jim-qualifier-licensing-roadmap.md`)
- [SBG Construction Group](construction-group-merger.md) — 2026-06-17 (eve): merger plan REPLACED by SBG shared-services/captive-labor group. 3 SBG entities (Labor/Equipment/RealEstate, 1/3 each by INDIVIDUALS, equal cash) lease to the 3 LLCs which stay independent + keep own job profit. Phase A siloed -> Phase B true merger. 3 docs in business-context/construction-group/
- [Owner Decisions (binding)](owner-decisions.md) — 2026-06-10: NO WI sales tax on any CWDB revenue (overrides open DOR items); Overbeck stain job proceeds w/o GL bound (risk accepted). Do not re-argue.

## Contractor Relationships
- [Contractor Relationships](contractor-relationships.md) — 2 contractors: [[Ben Barton]] + [[John Garcia]]; agreements sent via DocuSign 2026-04-07; awaiting signed copies
- [Bid Verification Architecture](verification-architecture.md) — Dual-confirmation system: homeowner follow-up + audit rights + contractual penalties + lead withholding

## Compliance & Legal Issues
- [AI-Generated Testimonials — CRITICAL](ai-testimonials-issue.md) — HIGH RISK GO-LIVE BLOCKER: all site testimonials are AI-fabricated; violates FTC 16 CFR 255 + fake review rule
- [Privacy Policy Status](privacy-policy-status.md) — No policy exists; /privacy page is a LEGAL BLOCKER; legal counsel to draft
- [TCPA Consent Language](tcpa-consent-status.md) — FINALIZED 2026-04-07; compliant language deployed to field 10; no longer a blocker
- [PII Data Flow Audit](pii-data-flow-audit.md) — 2026-04-04 audit: no deletion workflow, contractor data handling uncontrolled, retention is indefinite
- [Advertising Claims Review](advertising-claims.md) — "Free quotes" approved (low risk); "Licensed/insured" approved with verification conditions (medium risk)
- [Cost Calculator Audit](cost-calculator-audit.md) — Code reviewed 2026-04-04; disclaimer needs strengthening; CTA "Exact Quote" should be softened; full written audit pending

## Contracts & Agreements
- [Two-Tier Homeowner Contract System](sow-two-tier-contract-system.md) — 2026-06-10: interim staining work order (active, deposits OK now) vs full Home Improvement Contract (gated on insurance + DSPS); cancellation right cites Wis. Stat. 423.201-.203 + 16 CFR 429 (ATCP 110.025 is lien waivers, never cite for cancellation); Job Numbers from Supabase dim_jobs; 6-year retention
- [Combined Estimate + Work Order Spec](../../docs/legal/templates/combined-estimate-work-order-spec.md) — 2026-06-10: ONE PDF for cwdb self-perform lane; signature on acceptance CONVERTS estimate into binding staining work order; ATCP 110.05(2) content embedded so signature-as-contract is compliant; builder lane stays estimate-only; impl via combined=true flag in generate_estimate_pdf.py
- [Agreements Status](agreements-status.md) — Agreement v1 sent via DocuSign 2026-04-07 to both contractors; awaiting signed copies; attorney review recommended
- [Contractor Lead Purchase Agreement v1](../../docs/legal/contractor-lead-purchase-agreement-v1.md) — Full agreement at /docs/legal/; $1K/accepted bid, 5-layer verification, audit rights, data handling, arbitration
