---
type: memory
agent-id: legal-compliance-counsel
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-06-10
updated: 2026-06-10
status: active
---

# Two-Tier Homeowner Contract System (decided 2026-06-10)

## Decision
Jim ruled: CWDB takes deposits NOW for staining-only jobs (no permit, so the
DSPS Dwelling Contractor gate does not block), using a SHORT interim contract.
The full Home Improvement Contract is the long-term standard, invoked only
after GL insurance binds and the DSPS Certification + Qualifier are filed.

## The two instruments
1. **Interim (active):** `docs/legal/templates/staining-work-order-interim.md`,
   rendered by `sales/estimates/generate_work_order_pdf.py` from the estimate
   JSON. ATCP 110.05(2)-complete, conspicuous 3-day cancel block, two Notice
   of Cancellation copies, 779.02(2) Notice to Owner, deposit held until the
   cancel window closes, NO "licensed/insured" representation anywhere.
   Scope firewall: cosmetic surface finishing only; any structural touch
   means stop and switch to the full contract.
2. **Long-term (gated):** `docs/legal/templates/home-improvement-contract-template.md`,
   rendered by `sales/estimates/generate_sow_pdf.py` (quote merged into the
   body, estimate PDF appended as Exhibit A, Section 11 represents GL
   insurance, so do not use before insurance binds).

## Durable legal facts (verified 2026-06-10)
- **Cancellation right citation:** the 3-business-day right comes from Wis.
  Stat. 423.201 to 423.203 (Wisconsin Consumer Act) plus FTC Cooling-Off Rule
  16 CFR Part 429. ATCP 110.025 governs LIEN WAIVERS, not cancellation; never
  cite it for the cancel right. (A prior review claimed the contract template
  mis-cited 110.025; on file inspection the template cited generic "ATCP 110",
  and the precise ch. 423 citations were ADDED to sections 9.2 and 10.4 on
  2026-06-10.)
- **Business-day rule for the deadline:** Saturdays count; Sundays and federal
  holidays do not (16 CFR 429). The generators compute this.
- **1099 direction anomaly:** lead-purchase agreement section 10.3 says CWDB
  issues a 1099-NEC to the contractor, which is backwards for the
  pay-per-accepted-bid cash flow (contractor pays CWDB). In the build channel,
  CWDB paying Ben/John as subs DOES make CWDB the 1099 issuer. Keep the two
  directions straight; fix queued with accounting/legal.
- **Retention:** signed contract + notices + change orders + lien waivers kept
  at least 6 years (Wis. Stat. 893.43), filed by Job Number.

## Job Number registry
Supabase `dim_jobs` (migration 008) issues CWDB-YYYY-NNN at contract
formation via `allocate_job_number()`; mirrored to HubSpot deal property
`cwdb_job_number` (creation pending a private-app scope fix). CWDB-2026-001 is
reserved for the Overbeck staining job ($2,800, $840 deposit).

## Open gates before any BUILD contract
- GL insurance bound (also a real risk for staining; flagged to Jim)
- DSPS Dwelling Contractor Certification (entity) + Qualifier (Jim)
- One-time WI attorney review of both rendered templates before first signature
- Carryover blockers: [[advertising-claims]], [[ai-testimonials-issue]],
  [[privacy-policy-status]]
