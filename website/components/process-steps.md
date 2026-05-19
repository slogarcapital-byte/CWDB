---
type: component-spec
component-name: process-steps-v2
status: spec
created: 2026-04-19
supersedes: .process-section
---

# process-steps-v2

## Purpose

The homepage "how it works" section. Replaces the retired `.process-section` (48px orange circle badges with Barlow numbers + cedar gradient connector). The redesign swaps decoration for scale: three giant Staatliches numerals carry the hierarchy, and the connector between steps becomes a single flat grey line that reads as utilitarian diagramming rather than decorative.

## Layout

```
┌─────────────────┬─────────────────┬─────────────────┐
│                 │                 │                 │
│      01         │      02         │      03         │
│                 │                 │                 │
│  TELL US ABOUT  │  GET MATCHED    │  GET YOUR       │
│  YOUR DECK      │  LOCAL          │  QUOTE          │
│                 │                 │                 │
│  Zip, phone,    │  We hand-match  │  Builder reaches│
│  project basics.│  based on city  │  out within 48h │
│  60 seconds.    │  and project.   │  to schedule.   │
└─────────────────┴─────────────────┴─────────────────┘
```

Horizontal connector is a 1px line running across the row at the vertical center of the numerals, passing behind them (numerals sit on top, above the line). On mobile, steps stack vertically — connector becomes a short 1px vertical segment between each pair, or omitted entirely on single-column.

## Spec

**Section:**
- Background: `var(--slate)` (dark section — contrasts with hero left slate via vertical rhythm)
- Padding: `96px 0` desktop / `64px 0` mobile
- Container: standard `.container` (max 1200px)

**Section label (optional):**
- Font: Public Sans 600, 12px, uppercase, letter-spacing 3px
- Color: `var(--orange)`
- Text: "HOW IT WORKS"
- Margin-bottom: 12px

**Section heading:**
- Font: Staatliches 400, 48px desktop / 32px mobile
- Color: white
- Text: "Three steps. One quote."
- Margin-bottom: 64px

**Steps row:**
- Display: grid, `grid-template-columns: repeat(3, 1fr)`, gap 48px
- Mobile: single column, gap 48px
- Position: relative (for connector)

**Connector (desktop only):**
- Position: absolute
- Top: calculated to sit at the 50% vertical point of the numerals (≈ 60px from the top of the steps row)
- Left: ~16%, Right: ~16% (starts after step 1's numeral, ends before step 3's numeral)
- Height: 1px
- Background: `var(--sky)` at 50% opacity (`rgba(131,178,207,0.5)`) — sky brightens the dark section; grey read as muted
- Z-index: 0 (sits behind numerals)

**Step column:**
- Display: flex, flex-direction: column, align-items: flex-start
- Text-align: left (not centered — centered step cards are an AI-template tell)
- Position: relative, z-index: 1 (numerals sit above connector)

**Step numeral:**
- Font: Staatliches 400
- Size: 120px desktop / 72px mobile
- Color: `var(--orange)`
- Line-height: 1
- Letter-spacing: 0
- Margin-bottom: 16px
- Content: literal "01", "02", "03"

**Step title:**
- Font: Staatliches 400, 24px, uppercase
- Color: white
- Letter-spacing: 0.5px
- Line-height: 1.1
- Margin-bottom: 12px

**Step body:**
- Font: Public Sans 400, 15px
- Line-height: 1.55
- Color: `rgba(255,255,255,0.75)`
- Max-width: 280px (keeps lines short)

## States

**Default:** as specified.

**Hover (optional):** none. Process steps are static — they don't need hover interactivity since they aren't clickable.

**Mobile:** 3 columns → 1 column. Connector optional — the planned default is to omit the connector on mobile (single-column stacks read clearly without it).

**Empty / missing copy:** do not render the component at all. No placeholder copy.

**Light variant (if used on a light section elsewhere):** swap white → `var(--slate)` for title, `rgba(255,255,255,0.75)` → `var(--grey)` for body, `rgba(131,178,207,0.5)` → `rgba(131,178,207,0.6)` for the connector line (sky stays — slightly more saturated on light bg to remain visible). Section label and numeral colors stay the same.

## Webflow implementation notes

- Build as a net new component `process-steps-v2`. Do not copy from the deprecated `.process-section` — different structural grid.
- Each step is its own nested component slot OR just a repeating div inside the parent — either works; prefer nested "process-step" sub-component if Jim plans to reuse the step cell elsewhere.
- The connector line is a pure CSS pseudo-element (`::before`) on the steps-row container, not a separate Webflow element. Achieves a single-draw line without Webflow fighting the grid layout.
- Numerals are actual text ("01"), not SVG or decorative images — keeps them accessible and selectable.
- Verify at Lighthouse: no layout shift when Staatliches swaps in (CSS `font-display: swap` is already set in the Google Fonts link).
- No hover states, no scroll-triggered stagger animation. (Animation is explicitly out of scope for this revamp — per brief: "keep it fast-loading and accessible.")

## Related files

- `/website/design-system.md` — typography section, numeral row added to font stack table
- `/website/pages/homepage/content.md` — step copy source
- `/website/components/hero-split.md` — the component above this in the spine
