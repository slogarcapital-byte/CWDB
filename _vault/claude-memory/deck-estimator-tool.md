---
name: deck-estimator-tool
description: "CWDB internal deck quote tool built 2026-05-28; Phase 1 (Excel) done, Phase 2 (Python+PDF) pending Jim's verification"
metadata: 
  node_type: memory
  type: project
  originSessionId: 58e91269-8e63-441d-b6b6-e44887d0aaa4
---

# Deck Estimator v1 (Phase 1 shipped 2026-05-28)

CWDB internal deck-quote tool. Built from John Garcia's spreadsheet (`C:\Users\jslog\Downloads\Deck_Estimating_Tool.xlsx`) as the inheritance source, extended with project-type and multi-material support.

**Why:** Jim is quoting jobs personally and needed a fast, fair estimator that handles the full project spectrum (stain → full tear-out) and multiple decking/railing materials (PT, cedar, composite, aluminum, cable, glass) — John's tool only handled Trex composite + aluminum tear-out-and-rebuild jobs.

**How to apply:** Workbook lives at `sales/estimating/CWDB_Deck_Estimator_v1.xlsx`. Regenerate from `build_estimator_workbook.py` after editing `pricing-db.json`. Pricing research with Menards Wausau SKU references in `pricing-research-2026-05.md` (next quarterly review 2026-08-28). Engine math mirrored in pure Python at `verify_engine.py` for parity checks.

## Files
- `sales/estimating/CWDB_Deck_Estimator_v1.xlsx` — user-facing workbook (7 sheets)
- `sales/estimating/build_estimator_workbook.py` — generator script (openpyxl)
- `sales/estimating/pricing-db.json` — single source of truth for prices, matrix, multipliers
- `sales/estimating/pricing-research-2026-05.md` — Menards Wausau SKUs + industry estimates
- `sales/estimating/verify_engine.py` — pure-Python mirror of Excel engine; will become Phase 2 calculator core
- Plan: `C:\Users\jslog\.claude\plans\c-users-jslog-downloads-deck-estimating-federated-acorn.md`

## Engine notes (non-obvious)
- **Waste applied to decking only** (not framing). This diverges from John's model where waste applied to combined framing+decking. Result: ~2% lower total on full-build quotes vs John's. Intentional - framing dimensions are precise, no waste; only decking has cut-off waste.
- **Project Type Behavior matrix** is the brain — sheet "Project Type Behavior" rows 4-8 cols B-I encode Y/N/OPT/Light/Inspect flags that drive INDEX/MATCH lookups in engine formulas. Add a project type = add a row to the matrix + a row to demo_rates_per_sf + a row to allowances_by_project_type.
- **OPT semantics:** engine includes the line item if the scope detail input is non-zero. User must zero out scope detail (e.g., RailingLF) for items not in scope on OPT-flagged project types.
- **Allowances auto-default per project type** via INDEX/MATCH formula in B58/B59/B60. User overrides by typing a value (which replaces the formula).
- **Bug fixes from John's tool:** E28-E31 (sell price + low/high range + per-SF) referenced wrong source cells in John's. CWDB v1 fixes by computing from explicit SUBTOTAL. Adder lookups switched from hard-coded string MATCH to keyed lookups via the `adders[].key` field.

## Open verification items
- Menards SKU 1110669 (AC2 5/4x6x16 PT decking) - fallback price; verify in-person at Menards Wausau
- Menards SKU 1072752 (Cedar 2x4x8 S4S) - fallback price; verify in-person

## Phase 2 (deferred pending Jim's verification of Phase 1)
- `sales/estimates/deck_calculator.py` - port verify_engine.py to a full Python calculator
- Output JSON schema-compatible with existing `sales/estimates/generate_estimate_pdf.py`
- See plan file for full Phase 2 spec

## v1.1 (2026-05-28 same-day) — Materials List + bug fixes
- **Materials List sheet added**: ~30 line items across Decking / Framing / Footings / Railing / Stairs / Stain / Other. Quantities computed from Quote Input dimensions + project-type matrix + material selections. Unit costs from new `materials_unit_costs` array in pricing-db.json (rows 130-157 of Pricing DB sheet, editable). Conditional formatting greys 0-qty rows. Freeze pane at row 8 keeps project info echo visible while scrolling.
- **Bug fixed: comma in project type name broke dropdown**. "Resurface (New Boards, Keep Frame)" split on the comma in Excel's inline list parser. Renamed to "Resurface (Boards Only)" AND switched Project Type dropdown to a range reference (`'Project Type Behavior'!$A$4:$A$8`) so future comma-containing values won't break.
- **Bug fixed: wood vs steel framing exclusivity**. Materials List rows 17-23 (KDAT joists/beam/ledger/posts/hangers/ties/lag screws) used to fire alongside the Steel framing line when user selected Steel. Now those rows check both matrix.frame=Y AND framing_mat="KDAT Pressure-Treated".
- **Bug fixed: deck screw box count**. Was using `DeckSF*1.6/5` (treating 1.6 lb/SF as the rate, ~30x overcount). Corrected to `DeckSF/100` based on industry rate of ~1 5-lb box per 100 SF.
- **Bug fixed: CEILING.MATH → CEILING(x, 1)**. `CEILING.MATH` is Excel 2013+ only AND some Excel installs treat it as unknown (returning #NAME?). Switched all 24 occurrences to legacy `CEILING(x, 1)` which works in Excel 2007+. Lesson: `formulas` Python package supporting a function does not guarantee real Excel will. Real-Excel verification required, not just headless test runner.
- **`test_workbook.py` is the regression test**. 10 scenarios across all 5 project types still produce identical prices vs pre-v1.1 — no engine regressions.
- New file: `sales/estimating/test_workbook.py` uses the `formulas` Python package to evaluate the workbook's actual Excel formulas headlessly (not a Python mirror).

## Phase 1 SIGNED OFF by Jim 2026-05-28 — "she's a thing of beauty"

## Phase 2 SHIPPED 2026-05-28 — Python calculator + scope templates + PDF pipeline

**Files:**
- `sales/estimates/deck_calculator.py` — pure-Python port of the workbook engine; reads pricing-db.json (shared source of truth with Phase 1 workbook); interactive prompts OR --inputs JSON file; outputs estimate JSON; optional --pdf flag invokes generate_estimate_pdf.py
- `sales/estimating/scope-copy/scope-build.md` — scope template for Frame Rebuild + Full Tear-Out
- `sales/estimating/scope-copy/scope-resurface.md` — scope template for Resurface
- `sales/estimating/scope-copy/scope-stain.md` — scope template for Stain Only + Stain + Repairs
- `sales/estimates/_data/test-inputs-*.json` — three reference input fixtures (tearout / stain / resurface)
- `sales/estimates/2026-05-28-henderson-deck-build.pdf` (etc.) — three demo PDFs from the test runs

**Engine parity verified:** Python calculator output matches Excel workbook to the dollar on identical inputs. Both read pricing-db.json so prices stay in sync — edit once, both update.

**JSON schema** matches existing _data/*.json (Overbeck reference). Fields: estimate_number, date_issued, valid_days, client, project (overview/scope/scope_note), line_items (sum to sell price), included, not_included, schedule, payment.

**Line item allocation:** for build-type projects, 5-7 customer-friendly buckets (Demo, Construction, Railing, Stairs, Upgrades, Permits). For stain-type, 4 buckets matching the Overbeck pattern (Prep, Materials, Application, Cleanup). Each line item is sell-side dollars, sum reconciled to exact sell price with rounding spread on last line.

**Scope templates** use `str.format_map` with a defensive `_DefaultDict` that returns empty string for missing placeholders (so unused fields in a project type don't error). Loaded once per project type from the markdown file.

**Workflow:**
1. Jim sketches quote in Excel workbook (live with customer at kitchen table)
2. Once locked in, runs `python deck_calculator.py --interactive --pdf`
3. Calculator writes JSON to `_data/<date>-<client>-<project>.json` and produces PDF in `sales/estimates/`
4. Jim attaches PDF to email or DocuSign for client acceptance
