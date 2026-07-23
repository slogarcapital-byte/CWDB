---
name: estimator-v2-explicit-labor
description: "Estimator v2 explicit-labor pricing model - Jim's locked pricing decisions, the cutover gate, and what must not break"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1f168056-cd2e-4988-b560-b4185eade2e5
---

# Estimator v2: Simple-Labor Pricing Model (LIVE - cutover 2026-07-11)

**Status: ACTIVE.** Committed 2591b04, pushed to test-branch (deploy branch) AND main 2026-07-11; Streamlit Cloud redeployed. Rollback = flip `pricing-db-v2.json` status to "draft" + push.

Replaces v1's area-based sell rates (labor hidden in 2.5-2.9x material spreads, margin double-stacked). v1 deep-dive findings + full plan: `~/.claude/plans/cwdb-ceo-operator-agent-do-a-drifting-bunny.md`.

## Jim's locked pricing decisions (2026-07-09 + simplification 2026-07-11, durable - do not re-raise)
- **Loaded labor rate $125/man-hour** (owner/premium positioning; Wausau market loaded is ~$36)
- **3-man crew** (Jim, Ben, John): crew-day = 24 man-hours = $3,000/day
- **SIMPLE CREW-DAYS labor model (2026-07-11)**: days = (base_days + days_per_100 x area/100 + 0.25-day extras) x site multipliers + **1.0 contingency day (every job)**, rounded to nearest 0.5 day. NO per-task hour rates - the labor JSON is a days table Jim reads like a calendar (`labor.crew_days_by_project_type` + `extra_days`)
- **Labor prints on the estimate as literal math**: "N crew-days x 3-person crew x 8 hrs @ $125/hr" and is NEVER margin-inflated
- **Margin applies to MATERIALS ONLY (2026-07-11)**: `price = materials_cost/(1-margin) x market_load + labor(at face) + allowances(at face)`. Default margin 30%. Labor profit lives in the $125 rate itself. Jim accepted the total drop this causes (~15% effective margin over true cost)
- **All client-facing figures round to the nearest $50** (`round_client`; DB `round_client_figures_to`)
- Rungs: Breakeven / 15% floor / Market / 30% target (all $50-rounded)
- PDF: materials scope lines + ONE labor line (day math) + allowances line; Materials & Labor Summary block reproducible on a napkin
- **Diamond Piers $150/footing** true material cost; count = max(4, ceil(sf/32))
- **Everyday shelf prices only - NEVER assume the Menards 11% rebate**
- **Excel workbook eliminated from the send flow**: email attaches the Materials & Hardware List PDF (piece-level takeoff w/ SKUs) instead
- CWDB self-performs all jobs (no builder-lane pricing branch; lane plumbing stays for disclosures)
- Site multipliers scale LABOR DAYS, never material dollars; market_load multiplies the materials-margin component only

## Reference deck (320 sf elevated tear-out, TT PRO Reserve) - approved numbers
Piers $2,150 + deck materials $10,350 + rail $2,550 + stairs $700 + labor $12,000 (4 days x 3 x 8 x $125) + allowances $4,200 = **$31,950**. Materials summary $15,750 / labor $12,000 / site $4,200.

## Cutover gate (NOT yet flipped)
`sales/estimating/pricing-db-v2.json` `status: "draft"` -> app still prices v1. Flip to `"active"` + reboot Streamlit Cloud to cut over; flip back to roll back. v1 `pricing-db.json` frozen as audit record. Before flipping: run `python sales/estimating/verify_engine.py` (v1-vs-v2 calibration table + confidence audit) with Jim.

## Calibration flags (from verify harness 2026-07-09)
- Builds drop 19-37% vs v1; **stain jobs +153-155%** (contingency day dominates small jobs) and **fence +113%** - review with Jim before cutover
- Overbeck actual ran ~1.8x book stain hours; production rates are all `confidence: "estimate"` (tunable per task in the DB)
- Unpriced pending dealer sheet (Builders FirstSource Wausau / Wausau Supply): TimberTech Terrain+, Harvest+ per-board, Reliance vinyl rail
- market-rates.json composite $34/sf benchmark is below v2 materials+allowances on premium TT jobs - replace before trusting the market rung

## Do not break
- ATCP 110 disclosure / Notice of Cancellation / lane logic in generate_estimate_pdf.py (untouched by v2)
- Line items are now `[label, amount, materials, labor]` (legacy 2-element still supported); consumers must index, not tuple-unpack
- Sum-to-chosen-price invariant; allowances ride at face in v2 line items
- Tests: `python -m pytest sales/estimating/test_engine_v2.py` (15 tests: golden v1 numbers, v2 invariants, legacy PDF render regression)
- `apply_psf_cap.py` is legacy (v1 era only); `compute_cost_floor` v1-only
