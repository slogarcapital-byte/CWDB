---
name: sow-job-number-system
description: Two-tier homeowner contract system (interim staining work order live now; full Home Improvement Contract gated) plus the CWDB-YYYY-NNN job-number registry in Supabase dim_jobs
metadata: 
  node_type: memory
  type: project
  originSessionId: 88ff7b49-6200-4ec7-be73-12fecefe8b2f
---

# SOW / Job Number system (shipped 2026-06-10)

**Verdict (contractor-sales + legal agents, 2026-06-09):** a homeowner-signed
contract at deposit is REQUIRED by Wis. Admin. Code ATCP 110.05 because CWDB
issues quotes in its own name and takes deposits (CWDB is a home-improvement
"seller" and prime contractor on direct jobs). Violations risk 2x damages plus
attorney fees (Wis. Stat. 100.20(5)).

**Two-tier standard (Jim's decision):**
- **Interim, ACTIVE NOW:** staining-only jobs (no permit, DSPS gate does not
  apply). Template `docs/legal/templates/staining-work-order-interim.md`,
  rendered by `sales/estimates/generate_work_order_pdf.py` from the estimate
  JSON. Includes conspicuous 3-day cancel block (Wis. Stat. 423.201-.203 +
  16 CFR 429), two Notice of Cancellation copies, 779.02(2) Notice to Owner,
  deposit held until the cancel window closes, no "insured" claim.
- **Long-term, GATED on GL insurance + DSPS Dwelling Contractor cert:** full
  contract from `docs/legal/templates/home-improvement-contract-template.md`,
  rendered by `sales/estimates/generate_sow_pdf.py` (quote merged into the
  body, estimate PDF appended as Exhibit A via pypdf).

**Pipeline:** estimate JSON in `sales/estimates/_data/` is the single schema.
Excel-only quotes backfill via `sales/estimates/excel_to_estimate_json.py`
(reads the Quote Input sheet through the QI map and re-runs the engine; note
it reproduces ENGINE pricing, manual discounts are not stored in the workbook,
e.g. Overbeck stain engine price $4,058 was hand-discounted to $2,800).
DocuSign send: `sales/estimates/generate_and_send_sow.py` (anchor tabs,
homeowner routing 1, Jim routing 2; token ~8h expiry).

**Job numbers:** Supabase migration 008 (`dim_jobs` + `allocate_job_number()`
+ `fact_bids.job_number`). Format CWDB-YYYY-NNN, issued at contract formation,
never reused; change orders reference JOB/CO-N. **Re-based 2026-06-26 onto the
QBO invoice series (migration 012):** job numbers now mirror QBO invoice numbers
so one running number ties job + signed contract + QBO invoice. Overbeck =
**CWDB-2026-043** (was -001, matches deposit invoice INV-2026-043); Thomas Quinn
deck build = **CWDB-2026-044**; `allocate_job_number()` continues at 045 and is
floored at 043 for 2026. Overbeck's local signed work-order PDF + INV-2026-001
file keep their old labels for audit (re-base recorded in `dim_jobs.notes`).
Mirror property
`cwdb_job_number` on HubSpot deals is PENDING: the private app token lacks
`crm.schemas.deals.write` (Jim adds the scope, then re-POST
/crm/v3/properties/deals).

**Operational ritual every signing:** generate the work order ON the signing
date (cancellation deadline is computed from it; Saturdays count, Sundays and
federal holidays do not), hand BOTH cancellation copies to the buyer, all
titleholders sign, hold the deposit until the deadline passes, refund within
10 days on cancel, retain signed docs 6+ years filed by job number.

Related: [[v-clean-leads-test-exclusion-gap]]
