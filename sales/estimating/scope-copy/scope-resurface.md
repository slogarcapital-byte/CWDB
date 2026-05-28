# Scope template — Resurface (Boards Only)

Used by `sales/estimates/deck_calculator.py` for project type:
- `Resurface (Boards Only)`

Variables filled by calculator:
- `{deck_sf}`, `{length}`, `{depth}` — dimensions
- `{decking_phrase}` — new decking material (Trex Select, Cedar, etc.)
- `{railing_phrase}` — new railing material (or "existing railing system retained" if RailingLF = 0)
- `{railing_lf}`, `{fascia_lf}`, `{stair_runs}`, `{stair_treads}`
- `{rail_scope_phrase}` — "Install new {railing_phrase} railing..." or "Retain and refresh existing railing system"
- `{stair_phrase}` — for overview if stairs included
- `{board_repair_count}`, `{joist_repair_lf}` — repair scope if any
- `{repair_phrase}` — list of repair line items, or empty

---

## OVERVIEW
Resurface project at the project address. Existing deck structure (frame, footings) is retained; deck boards, fascia, and{rail_overview_phrase} are removed and replaced. The job covers approximately <b>{deck_sf} sq ft of deck floor</b> ({length} ft x {depth} ft) with new <b>{decking_phrase}</b> decking{rail_phrase_for_overview}{stair_overview_phrase}. Frame inspection allowance is included; any necessary joist or beam repair will be quoted at the rates shown in the line items.

## SCOPE
- Move and protect homeowner furniture, grill, plants, and adjacent landscaping
- Cover and protect siding, windows, and any nearby paved surfaces
- Remove existing deck boards, fascia, and stair tread surfaces
- Haul all old deck boards to the on-site dumpster
- Inspect existing frame (joists, beams, ledger, posts, footings) for soundness; flag any structural concerns for change-order review
{repair_phrase}- Install new {decking_phrase} decking with hidden fasteners (composite) or 3-inch stainless deck screws (wood), maintaining manufacturer-specified gap spacing
- Install new matching fascia on exposed rim ({fascia_lf} LF){rail_scope_line}{stair_scope_line}
- Final touch-ups, complete cleanup, and removal of all debris

## SCOPE_NOTE
The scope above assumes the existing frame is sound. Frame inspection during board removal may uncover joist rot, inadequate hardware, or beam sag that requires repair before new boards can be installed safely. Any such work will be discussed before continuing and any change order will be priced separately. Original footings are reused as-is and assumed to be in sound condition.

## INCLUDED
- All materials: {decking_phrase} decking, matching fascia, hidden fasteners (composite) or 3-inch stainless deck screws (wood){rail_included_phrase}
- All labor for board removal, frame inspection, new deck installation{rail_labor_phrase}
- Frame inspection allowance (visual + selective probing for rot, hardware adequacy)
- On-site dumpster for the duration of work
- Final job-site cleanup and haul-off
- <b>5-year limited workmanship warranty</b> on the new decking surface installation
- Manufacturer warranty passes through on {decking_phrase} decking

## NOT_INCLUDED
- Structural frame replacement (joists, beams, ledger, posts, footings) — frame is inspected; any required structural work is quoted separately
- Landscape restoration beyond the immediate deck footprint
- Electrical, plumbing, or hot tub utility relocations
- Replacement of stair stringers if found unsound (will be quoted separately)
- New footings or post replacement
- Painting or staining of new decking
- Any work required to remediate code violations discovered during inspection

## SCHEDULE
duration: 3-5 working days
weather: Work will be rescheduled if rain forecast exceeds 60% during board install. Composite decking can be installed in cooler weather; wood decking requires temperatures above 40 F for accurate gap spacing.
start_phrase: Within 2-3 weeks of signed acceptance and deposit

## DEPOSIT_PCT
30

## WARRANTY_YEARS
5
