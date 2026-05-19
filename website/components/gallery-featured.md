---
type: component-spec
component-name: gallery-featured
status: built
created: 2026-04-19
built: 2026-04-20
webflow-component-id: 182ba5d8-1b29-7e4d-30f1-99ff54130c65
homepage-instance-element-id: 4836d90b-9938-3bdb-d77d-b529ebad39ae
cms-items-used:
  - 69cff0a60dcd496698b5a991  # Cedar Deck with Pergola — Merrill, WI
  - 69cff0a60dcd496698b5a98b  # Composite Deck Build — Wausau, WI
  - 69cff0a60dcd496698b5a98d  # Multi-Level Deck — Weston, WI
binding: hardcoded  # v1 — 3 items, Jim not editing; bind to CMS with featured_on_homepage flag later
hover-descendant-css: inline site script (galleryfeaturedhover)  # Webflow style_tool cannot express .card:hover .photo
---

# gallery-featured

## Purpose

The homepage proof section. Three featured real builds do the visual work that the old services-grid-with-icons pretended to do. Photos are the whole point — zero decoration around them, no rounded corners, no shadow, no border, no hover glow. The information density is in the caption below each photo, not in chrome around the photo.

This is the component that most directly expresses the brief's direction: "every design decision runs through the Three Anti-Words test — Generic / Salesy / Cheap. Photos run tall, captions stay compact, layout runs full-width."

## Layout

```
RECENT CENTRAL WISCONSIN BUILDS

┌──────────────┬──────────────┬──────────────┐
│              │              │              │
│   [PHOTO]    │   [PHOTO]    │   [PHOTO]    │
│   16:10      │   16:10      │   16:10      │
│              │              │              │
├──────────────┼──────────────┼──────────────┤
│ CEDAR DECK   │ SCREEN PORCH │ PERGOLA      │
│ 12×16 · Weston │ 14×20 · Wausau │ 10×10 · Mosinee │
│ Built by     │ Built by     │ Built by     │
│ Barton       │ J. Garcia    │ Barton       │
└──────────────┴──────────────┴──────────────┘
```

3 columns desktop, 1 column mobile. Gap between cards: 24px desktop / 32px mobile.

## Spec

**Section:**
- Background: `var(--white)` or `var(--off-white)` (alternates based on what sits above — in the homepage spine, gallery follows process-steps (slate), so gallery is `--white`)
- Padding: `96px 0` desktop / `64px 0` mobile
- Container: standard `.container`

**Section heading:**
- Font: Staatliches 400, 48px desktop / 32px mobile
- Color: `var(--slate)`
- Text: "Recent Central Wisconsin builds"
- Margin-bottom: 56px

**Grid:**
- Display: grid
- `grid-template-columns: repeat(3, 1fr)` desktop
- `grid-template-columns: 1fr` mobile
- Gap: 24px desktop / 32px mobile

**Card:**
- No background, no padding, no border, **no border-radius, no shadow, no overflow-hidden on the photo** (photos are sharp-cornered and full-bleed within their grid cell)
- Entire card is wrapped in an `<a href="/gallery">` — whole-card clickable
- Hover state: photo opacity shifts from 1.0 → 0.92 over 150ms ease. No scale transform, no shadow emerge.

**Photo:**
- Aspect ratio: 16:10 (`aspect-ratio: 16/10`)
- `object-fit: cover`
- Alt text describes the actual build ("Cedar deck in Weston, Wisconsin — 12 by 16 feet, built by Barton Builders")

**Caption stack (below photo):**
- Padding-top: 20px (no horizontal padding — aligns with photo edge)
- Three stacked lines:
  1. **Project-type label:** Staatliches 400, 14px, uppercase, letter-spacing 1.5px, color `var(--orange)`
  2. **Specs line:** Public Sans 500, 15px, color `var(--slate)` — format `[dims] · [city]`
  3. **Builder line:** Public Sans 400, 13px, color `var(--grey)` — format `Built by [Barton / J. Garcia Construction]`

## States

**Default:** as specified.

**Hover:** photo opacity 1.0 → 0.92 transition. No transforms, no shadows.

**Focus (keyboard):** 2px `var(--orange)` outline at 3px offset on the card anchor.

**Empty (no builds yet):** Render a substitute section instead — full-width `--slate` band, 128px padding, single centered Staatliches headline "Recent builds posted soon." + a secondary CTA "Start My Quote →". No skeleton placeholder cards.

**Loading (CMS slow):** No skeleton shimmer. Preserve space via `aspect-ratio` so there's no layout shift when the image loads.

## Webflow implementation notes

- Build as a net new component `gallery-featured`.
- Hard-code 3 build cards initially with placeholder content (Jim selects the real 3 during Phase 2 step 7). When ready, bind to the existing Gallery Photos CMS collection (`69cff077a56c28009f3df538`) with a `featured_on_homepage = true` boolean added to that collection's schema.
- Caption fields map to CMS fields:
  - Project-type label → `project_type` (single-line text)
  - Specs line → `dimensions` + `city` concatenated via Webflow's text combine or a formatted rich-text field
  - Builder line → `builder_name` (reference or single-line text)
- Photo uses Webflow image element (not background-image) for alt-text + responsive pipeline.
- Whole-card link: wrap the entire CMS repeat item in a Link Block with `href` → `/gallery` (not the individual project's detail page — the gallery index already shows that project in context). Jim confirms at Phase 2 review.
- No hover transforms — the opacity shift is the only motion.

## Related files

- `/website/design-system.md` — typography, color tokens
- `/website/pages/homepage/content.md` — placeholder caption content until Jim selects real builds
- `/website/pages/gallery/content.md` — the full gallery page this links to
- Webflow CMS collection: Gallery Photos (`69cff077a56c28009f3df538`)
