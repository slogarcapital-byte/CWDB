# fact_bids Verification List for Jim (audit-2026-07-05#27)

- **Date:** 2026-07-22
- **Rule:** nothing here has been written to `fact_bids`. Each row below is a
  suspected correction awaiting Jim's check. Tick the box, note the real value,
  and the correction gets applied in a follow-up migration (or fixed at the
  HubSpot source so the daily pull re-stamps it).
- **Source snapshot:** `fact_bids` as of 2026-07-22 (16 rows). Contractor IDs:
  1 = Ben Barton (Barton Builders), 2 = John Garcia.

## 1. Placeholder bid amount

| bid_id | Lead (homeowner) | bid_amount | Status | contractor_id | Suspicion |
|---|---|---|---|---|---|
| 1 | Chrys Hanus (lead 2) | $1,000.00 | declined (Lost) | 1 (Barton) | Amount equals the $1,000 referral fee exactly. Almost certainly a placeholder typed into the HubSpot deal amount, not a real quote. A real deck bid would be thousands. |

- [ ] **bid 1 (Hanus):** confirm the real quoted amount (or confirm no quote was
  ever produced). Suspected correction: set `bid_amount_cents` to the actual
  quote, or NULL if none existed. Real amount: ____________

## 2. Rows with NULL contractor_id (13 of 16 rows)

Context: after the 2026-06-10 fulfillment pivot, Jim produces all estimates, so
NULL contractor_id is EXPECTED on Jim-estimated (cwdb-lane) bids. The question
per row is whether NULL is the pivot convention working as intended, or missing
attribution from the pre-pivot era.

### Pre-pivot rows (sent 2026-05-05, before the pivot): attribution suspect

| bid_id | Lead (homeowner) | bid_amount | Status | Suspicion |
|---|---|---|---|---|
| 2 | Brian Gundersen (lead 3) | NULL | declined | Sent 5/5, pre-pivot. Amount also NULL. Who quoted this, Barton or Garcia? Same-day sibling deals carry contractor 1 or 2. |
| 66 | Purnatoya Nayak (lead 97) | $4,900 | declined | Sent 5/5, pre-pivot, manual lead. Memory notes a Nayak deal in fact_bids; was a contractor attached? |

- [ ] **bid 2 (Gundersen):** contractor was ______ (Barton / Garcia / none) and
  amount was ____________ (or confirm no quote).
- [ ] **bid 66 (Nayak):** contractor was ______ (Barton / Garcia / none / Jim).

### The accepted-and-paid row: confirm the convention

| bid_id | Lead (homeowner) | bid_amount | Status | Suspicion |
|---|---|---|---|---|
| 4 | Debbie Overbeck (lead 6) | $2,800 | paid, CWDB-2026-043 | contractor_id NULL. This was cwdb-lane SELF-PERFORM, so no contractor is arguably correct. But `referral_fee_cents` still reads $1,000 on this row, and no contractor fee ever applied here. |

- [ ] **bid 4 (Overbeck):** confirm NULL contractor_id is the intended encoding
  for cwdb-lane self-perform jobs, and whether `referral_fee_cents` should be
  zeroed on self-perform rows so fee reporting can never phantom-count it.

### Post-pivot rows (2026-06-19 onward, Jim's estimates): NULL likely correct

| bid_id | Lead (homeowner) | bid_amount | Status | Note |
|---|---|---|---|---|
| 71 | Joe Sjoberg (lead 103) | $13,443 | declined | Estimate era 6/3; Jim-quoted, NULL expected |
| 123 | Thomas Quinn (lead 75) | $8,960 | sent | Jim-quoted (Quinn HIC staged), NULL expected |
| 124 | David Johnson (lead 49) | $14,000 | declined | Jim-quoted, NULL expected |
| 125 | Darlene Wroblewski (lead 104) | NULL | declined | Bid marked sent 6/19 but amount NULL, see section 3 |
| 126 | Mike Kampstra (lead 50) | $14,400 | declined | Jim-quoted, NULL expected |
| 127 | James Reist (lead 147) | $30,380 | declined | Jim-quoted, NULL expected |
| 210 | Sherry Neely (lead 306) | NULL | declined | Amount NULL, see section 3 |
| 213 | Valeria Hanson (lead 307) | NULL | sent | Amount NULL, see section 3 |
| 214 | Dena Petersen (lead 308) | NULL | pending | Not yet sent; NULLs expected |
| 259 | Jodi Nelson-Claeys (lead 351) | NULL | pending | Not yet sent; NULLs expected |

- [ ] **bids 71, 123, 124, 126, 127:** confirm these were all Jim-estimated
  (no contractor referral owed), so NULL contractor_id stands as-is.

## 3. Bids marked sent/declined but with NULL amount

| bid_id | Lead (homeowner) | Status | Suspicion |
|---|---|---|---|
| 125 | Darlene Wroblewski | declined | bid_sent_at 6/19 but no amount. Was an estimate actually delivered, or was the deal stage advanced without one? |
| 210 | Sherry Neely | declined | Same pattern (also TCPA-gated lead). |
| 213 | Valeria Hanson | sent | Status says a bid is out with no recorded amount. |

- [ ] **bid 125 (Wroblewski):** amount ____________ or reclassify (no bid sent).
- [ ] **bid 210 (Neely):** amount ____________ or reclassify (no bid sent).
- [ ] **bid 213 (Hanson):** amount ____________ or reclassify (no bid sent).

## 4. Related hygiene flag (dim_contractor, not fact_bids)

| contractor_id | Name | Suspicion |
|---|---|---|
| 73 | Debbie Overbeck | A HOMEOWNER ingested into `dim_contractor` (HubSpot lifecycle `customer` after her job closed made the pull classify her as a contractor). Risk: she could appear in `v_contractor_scorecard`. |

- [ ] **dim_contractor 73 (Overbeck):** confirm she should be removed or
  deactivated (`is_active = false`), and the ingestion filter tightened so
  homeowner-customers do not enter the contractor dimension.

## Next step once boxes are ticked

Corrections go in either: (a) the HubSpot deal record, letting the daily pull
re-stamp `fact_bids` (preferred, keeps source and warehouse aligned), or (b) a
one-off warehouse migration if HubSpot no longer holds the truth. Note
`accepted_at` is earliest-wins by design (HubSpot closedate re-stamps), so
amount fixes will not disturb acceptance history.
