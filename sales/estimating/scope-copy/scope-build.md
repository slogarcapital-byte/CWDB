# Scope template — Frame Rebuild + Full Tear-Out

Used by `sales/estimates/deck_calculator.py` for project types:
- `Frame + Deck Rebuild (Keep Footings)`
- `Full Tear-Out + New Build`

Variables (filled by calculator with `str.format`):
- `{project_phrase}` — "frame and deck rebuild" or "complete tear-out and new build"
- `{deck_sf}`, `{length}`, `{depth}` — dimensions
- `{decking_phrase}` — "Trex Select composite", "Pressure-Treated Pine", etc.
- `{railing_phrase}` — "Trex Signature aluminum", "cedar wood", "glass panel", etc.
- `{framing_phrase}` — "kiln-dried pressure-treated lumber" or "Fortress Evolution steel"
- `{railing_lf}`, `{fascia_lf}`, `{stair_runs}`, `{stair_treads}`
- `{footing_phrase}` — full block of footing scope (empty for Frame Rebuild)
- `{footing_inclusion_phrase}` — same for "included" section
- `{stair_phrase}` — "{stair_runs} stair run{plural} of {stair_treads} treads" or "" if no stairs
- `{duration_range}` — "5-7" / "7-10" working days

---

## OVERVIEW
{project_phrase} at the project address. The job covers approximately <b>{deck_sf} sq ft of new deck floor</b> ({length} ft x {depth} ft) with <b>{railing_lf} linear feet</b> of railing system{stair_overview_phrase}. The new deck features <b>{decking_phrase}</b> decking, <b>{railing_phrase}</b> railings, and <b>{framing_phrase}</b> framing built to current Wisconsin residential code. Work includes complete site protection, code-compliant structure, and final homeowner walkthrough.

## SCOPE
- Site survey, layout, and homeowner walkthrough of staked footprint before any demo
- Move and protect homeowner furniture, grill, plants, and adjacent landscaping
- Cover and protect siding, windows, doors, and any nearby paved surfaces
- Demolish and remove the existing deck structure (boards, railings, stairs{demo_extras})
- Haul all demo debris to the on-site dumpster; full disposal at completion
{footing_phrase}- Frame the new deck per WI residential code: {framing_phrase}, ledger lag-bolted and flashed to house rim, code-compliant joist spacing on 16 in centers
- Install {decking_phrase} decking boards with hidden fasteners (composite) or 3-inch stainless deck screws (wood), maintaining manufacturer-specified gap spacing
- Install matching {decking_phrase} fascia on exposed rim ({fascia_lf} LF)
- Install {railing_phrase} railing system ({railing_lf} LF) with code-compliant baluster spacing and structural post anchoring{stair_scope_line}
- Final touch-ups, complete cleanup, and removal of all debris and dumpster
- Final homeowner walkthrough and punch-list resolution

## SCOPE_NOTE
The scope above assumes standard residential site access (driveway accessible to delivery truck and dumpster), no underground utilities within the deck footprint, and existing house siding/framing in sound condition at the ledger location. Any discoveries during demo (rot at ledger, inadequate footings, undisclosed utilities) will be discussed before continuing work, and any change order will be priced separately and added in writing.

## INCLUDED
- All materials: {framing_phrase} framing, {decking_phrase} decking, {railing_phrase} railings, hardware (joist hangers, hurricane ties, lag bolts, fasteners), code-compliant flashing
{footing_inclusion_phrase}- All labor for demo, framing, decking, railing, and stairs
- Permit and engineering allowance (homeowner is named as homeowner on permit)
- On-site dumpster for the duration of work
- Final job-site cleanup and haul-off of all debris
- <b>10-year limited workmanship warranty</b> on framing and structural connections
- Manufacturer warranties pass through on decking ({decking_phrase}) and railing ({railing_phrase})

## NOT_INCLUDED
- Landscape restoration beyond the immediate deck footprint (sod replacement, planting bed restoration, irrigation repair)
- Electrical, plumbing, gas, or hot tub utility hookups (separate trade required)
- Pergolas, screens, outdoor kitchens, or other built-ins unless added to scope in writing
- Structural modifications to the house itself (door replacement, header changes, siding alterations beyond the ledger flashing detail)
- Site grading, drainage modifications, or retaining wall work
- Any work required to remediate discoveries (rot, hidden utilities, code violations at ledger attachment) — quoted separately if found
- Painting or staining of new decking (Trex composite does not need staining; wood decking can be quoted as an add-on for first-year finish)
- Snow removal during winter installs

## SCHEDULE
duration: {duration_range} working days
weather: Work will be rescheduled if rain forecast exceeds 60% during exterior framing days. Winter installs may extend the duration by 2-4 days due to weather windows. Concrete pours require ambient temperatures above 40 F for 48 hours after placement.
start_phrase: Within {start_window_weeks} weeks of signed acceptance and deposit

## DEPOSIT_PCT
30

## WARRANTY_YEARS
10
