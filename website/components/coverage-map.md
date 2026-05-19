---
type: component-spec
component-name: coverage-map
status: spec
created: 2026-04-19
supersedes: .city-card grid
---

# coverage-map

## Purpose

Replaces the deprecated `.city-card` grid (5 bordered white cards with `border-bottom: 3px solid var(--cedar)` accent stripes — flagged by `/impeccable`). The coverage-map band communicates *regional specificity* visually through a custom-drawn map of Central Wisconsin, paired with a Staatliches uppercase city list that doubles as a navigation menu to the 5 city pages.

The map reads as a place. The card grid read as a generic "areas we serve" component.

## Layout

```
WE SERVE CENTRAL WISCONSIN

┌───────────────────────┬───────────────────────┐
│                       │                       │
│  [SVG MAP of          │   WAUSAU        →    │
│   Marathon + Lincoln  │   SCHOFIELD     →    │
│   counties w/         │   WESTON        →    │
│   5 sky-blue pins,    │   MOSINEE       →    │
│   slate strokes,      │   MERRILL       →    │
│   no fills]           │                       │
│                       │                       │
└───────────────────────┴───────────────────────┘
```

2-column grid desktop, stacks mobile. Map stays full-width above the list on mobile.

## Spec

**Section:**
- Background: `var(--off-white)` (creates a visual rest between gallery-featured `--white` and the next slate section)
- Padding: `96px 0` desktop / `64px 0` mobile
- Container: standard `.container`

**Section heading:**
- Font: Staatliches 400, 48px desktop / 32px mobile
- Color: `var(--slate)`
- Text: "We serve Central Wisconsin"
- Margin-bottom: 56px
- Optional section label above: Public Sans 600, 12px uppercase, letter-spacing 3px, `var(--orange)` — text "COVERAGE AREA"

**Grid:**
- `grid-template-columns: 1fr 1fr` desktop (equal halves), gap 64px
- Mobile: single column, gap 32px

**Left column — SVG map:**
- Aspect ratio: match SVG viewBox (≈ 320×280, so ~1.14:1)
- Max-width: 480px within the column, centered
- SVG inline (not background-image) so we can style strokes and interact with pins
- County outlines: Marathon County + Lincoln County
  - Stroke: `var(--slate)` at full opacity
  - Stroke-width: 1.5px
  - Fill: none
- Pins: 5 `<circle>` elements at the approximate coordinates for Wausau, Schofield, Weston, Mosinee, Merrill
  - Fill: `var(--sky)` — pins carry the Wisconsin outdoor feel; orange is reserved strictly for CTA buttons
  - Radius: 6px
  - No stroke, no glow
- Optional city name labels next to pins: Public Sans 500, 10px, `var(--slate)` — keep them only if they don't crowd; otherwise the city list on the right is the authoritative list

**Right column — city list:**
- Display: flex, flex-direction: column, gap: 16px
- Each list item:
  - Wrapping `<a>` → `/[city-slug]`
  - Display: flex, justify-content: space-between, align-items: center
  - Font: Staatliches 400, 32px desktop / 28px mobile, uppercase, letter-spacing 0.5px
  - Color: `var(--slate)`
  - Padding-block: 8px
  - Hover: text color stays `var(--slate)`, but a 2px underline in `var(--sky)` fades in under the text. Arrow character `→` shifts 4px right on hover.
  - Focus (keyboard): 2px `var(--orange)` outline at 3px offset on the anchor (focus rings stay orange for visibility)

**Fallback constellation (Phase 2 launch default — custom SVG deferred per Jim, 2026-04-19):**
Abstract dot-and-line constellation on `var(--off-white)` background. Five `var(--sky)` dots positioned approximately where the cities sit relative to each other, connected by 1px `var(--sky)` lines at 40% opacity. City names labeled above/below each dot in Public Sans 500, 11px uppercase, `var(--slate)`. This fallback ships with the homepage launch; the custom-drawn Marathon + Lincoln county SVG is a post-launch upgrade, not a blocker.

## States

**Default:** as specified.

**Hover (city item):** underline fades in, arrow shifts right. No text color change.

**Focus (keyboard):** 2px orange outline on the anchor.

**Map tap (mobile):** entire pin is a `<g>` wrapped in an `<a xlink:href="/[city]">` — tapping a pin navigates to that city's page.

**Map missing / SVG fails to load:** the right-column city list is still fully functional on its own. The component degrades gracefully — the map is supplementary visual context, not the only way to reach city pages.

## Webflow implementation notes

- Build as a net new component `coverage-map`.
- Webflow does not have a native SVG-drawing tool. Author the SVG externally (Figma, hand-coded, or SVG-optimized with SVGO), paste as a Webflow HTML embed inside the left column. This is one of the explicit exceptions to the "native elements only" rule — Webflow has no native element for custom-drawn SVGs.
- Optimize the SVG aggressively: remove Illustrator metadata, collapse unused defs, keep final file under 4KB.
- Right-column list: Webflow Link Block per city (not a CMS repeat — we only have 5 cities and they're the core of the business; binding to the Service Areas CMS collection is optional but adds an unnecessary dependency).
- Hover underline: use a `::after` pseudo-element on the Link Block via a Webflow Embed with scoped CSS, OR use Webflow's Interactions panel to animate a child div (simpler, stays in Designer).
- No decoration background behind the map — `--off-white` only.

## Related files

- `/website/design-system.md` — color + typography tokens
- `/website/pages/homepage/content.md` — coverage section copy source
- `/website/pages/wausau/`, `/schofield/`, `/weston/`, `/mosinee/`, `/merrill/` — link targets
- Webflow CMS collection: Service Areas (`69cf0c26f69f8fdddb60ccba`) — optional binding source
