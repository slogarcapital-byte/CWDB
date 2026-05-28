# Scope template — Stain Only + Stain + Minor Repairs

Used by `sales/estimates/deck_calculator.py` for project types:
- `Stain Only`
- `Stain + Minor Repairs`

Variables filled by calculator:
- `{stain_sf}` — square feet to be stained
- `{stain_type}` — "Transparent", "Semi-Transparent", "Solid / Paint-and-Sealer"
- `{stain_coats}` — 1 or 2
- `{coats_word}` — "one" or "two"
- `{coats_phrase}` — "Single-coat" or "Two-coat"
- `{stain_color_phrase}` — defaults to "color to be selected by homeowner" or filled value
- `{deck_existing_material}` — "pressure-treated wood" / "cedar" / "composite" — usually "wood"
- `{rail_sf}`, `{stair_count}` — adders to scope
- `{repair_phrase}` — list of repair line items (board count, joist LF, hardware), or "" for Stain Only

---

## OVERVIEW
{coats_phrase} {stain_type_lc} stain on an existing single-level {deck_existing_material} deck at the project address. The job covers approximately <b>{stain_sf} sq ft of deck floor</b>{rail_stair_overview_phrase}. Work includes full surface preparation (power wash, sand rough spots, set raised fasteners, mask landscaping), application of {coats_word} coat{coats_plural} of {stain_product_phrase}{stain_color_phrase}, and complete job-site protection and cleanup.{repair_overview_phrase}

## SCOPE
- Move and protect homeowner furniture, grill, and personal items
- Cover and protect plants, landscaping, and adjacent siding
- Power-wash the entire deck surface, stairs, and railing system
- Light sanding of rough spots on floor boards, stair treads, and railing surfaces
- Set any raised or popped fasteners flush with the deck surface
{repair_phrase}- Apply {coats_word} coat{coats_plural} of {stain_product_phrase} to all visible wood surfaces: deck floor, stair treads and risers, top rails, bottom rails, balusters, and posts
- Final touch-ups, complete cleanup, and haul-off of all debris

## SCOPE_NOTE
Work covers all visible wood surfaces above the deck floor and on the staircase. Underside of deck framing, joists, support posts below the deck floor, and any structural members hidden from normal view are not included. {coat_note}

## INCLUDED
- All materials: {stain_product_phrase}, sandpaper, brushes, pads, rollers, drop cloths, masking
- All labor: approximately {duration_days} working days ({day_breakdown})
- Full job-site protection of furniture, plants, and siding
- Post-job cleanup and debris haul-off
- <b>1-year limited warranty</b> against premature finish failure caused by defects in workmanship (excludes acts of nature, normal wear, and pre-existing structural conditions)
{repair_warranty_phrase}

## NOT_INCLUDED
{full_replace_not_included}- Hardware replacement (screws, nails, joist hangers, fasteners) beyond setting existing raised fasteners and any specifically scoped repair items
- Structural repairs of any kind beyond minor scoped repairs
- Removal of carpet, outdoor mats, planters, or built-in features
- Refinishing of pergolas, gazebos, or attached fences unless explicitly added to scope in writing
- Site power supply (homeowner provides access to a working exterior 120V outlet)
- {second_coat_addon}

## SCHEDULE
duration: {duration_days} working days
weather: Application will be rescheduled if rain forecast exceeds 40% during the cure window. A minimum ambient temperature of 50 F day and night is required for proper finish cure. Cooler-weather applications may extend cure time by 24-48 hours per coat.
start_phrase: Within 1-2 weeks of signed acceptance and deposit

## DEPOSIT_PCT
30

## WARRANTY_YEARS
1
