---
name: fulfillment-model-pivot-2026-06-10
description: "Jim owns all lead follow-up/walk-throughs/estimates; phased hybrid Option A (builder contracts) now, Option B (CWDB primes + subs) post-license; disclosure rules"
metadata: 
  node_type: memory
  type: project
  originSessionId: a0e0b14f-d836-4245-b2bd-ce398dee1da0
---

# Fulfillment Model Pivot (2026-06-10)

**Why:** Ben Barton and John Garcia are busy with their own jobs and cannot meet CWDB's 48-hour quote promise. Jim now owns ALL lead follow-up, walk-through booking, walk-throughs, and estimate issuance (Streamlit estimator + `sales/estimates/generate_estimate_pdf.py`). Jim is also pursuing his DSPS Dwelling Contractor cert (Qualifier 12-hour course) + GL insurance, and self-performs stain/resurface jobs (no permit needed) under CWDB now.

**Legal structure (legal-compliance-counsel opinion, 2026-06-10):**

- **Phase 0 (pre-license, NOW): hand-off at the estimate.** Estimate JSON `fulfillment.lane` controls the paper:
  - `cwdb` lane: cosmetic stain/resurface only. CWDB signs the interim staining work order, takes the deposit. Boundaries: no joists/beams/ledger/footings/dimensions/structural rails. If a stain walk-through reveals rot or structural issues, STOP and route to a licensed builder.
  - `builder` lane: any build/repair/structural work. CWDB issues the estimate WITH the "Who Performs Your Work" disclosure naming the builder (ATCP 110.02 cure for bait-and-switch); the builder signs the homeowner, takes the deposit, pulls the permit. CWDB collects $1,000 per accepted bid under existing agreements. CWDB must NEVER sign as prime or take a build deposit pre-cert (unlicensed contracting, and subbing out does not cure it).
  - Name the builder DURING the walk-through, never first at signature. One signature surface per job.
- **Phase 1 (post cert + GL bind): Option B unlocks per-job.** CWDB primes the Home Improvement Contract (trust-fund deposits, ch. 779 Notice to Owner, 423.201-203 + 16 CFR 429 cancellation), subs to Ben/John under the subcontractor agreement + amendment (1099 direction: CWDB issues 1099 on sub-pay channel only, never on lead-fee channel). A and B run side by side, chosen per job.

**Key artifacts:** side letter making CWDB-authored estimate acceptance = "Accepted Bid" (`docs/legal/templates/side-letter-accepted-bid-definition.md`, draft); estimate generator lane disclosure (shipped 2026-06-10); invoice series INV-YYYY-NNN (`finance/invoices/generate_invoice_pdf.py`).

**Open items:** board directive WB-018 (GL bind for DSPS cert, DSPS filings, Wausau permit line, WI attorney review) and WB-017 (scrub "licensed and insured" sitewide pre-license). Sales-tax items CLOSED by owner decision 2026-06-10: no WI sales tax on any CWDB revenue. Staining-job insurance gap risk-accepted by Jim 2026-06-10.

Related: [[sow-job-number-system]], [[phone-leads-count]]
