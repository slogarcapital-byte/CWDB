---
type: component-spec
component-name: hero-split
status: spec
created: 2026-04-19
supersedes: .section--hero (hero-section-subpage)
---

# hero-split

## Purpose

The homepage hero. Replaces the retired full-bleed gradient `.section--hero` with a split-column layout that pairs a confident speed-led headline with a 2-field micro-form on the left and a real deck photo on the right. The 2-field ask is intentionally low-stakes (zip + phone, no address, no budget) — it is the first of two touches in a two-touch commitment funnel.

## Layout

```
┌──────────────────────────────────┬──────────────────────────┐
│                                  │                          │
│  GET A QUOTE WITHIN              │                          │
│  48 HOURS.                       │   [PHOTO: real cedar     │
│                                  │    deck, Wausau build,   │
│  Vetted builders in Wausau,      │    golden-hour wide]     │
│  Schofield, Weston, Mosinee,     │                          │
│  and Merrill. Enter your zip     │                          │
│  and we'll match you in hours.   │                          │
│                                  │                          │
│  Zip code [_____]                │                          │
│  Phone    [_____________]        │                          │
│                                  │                          │
│  [ START MY QUOTE → ]            │                          │
│                                  │                          │
│  ✓ Licensed  ✓ Insured  ✓ Free   │                          │
│                                  │                          │
└──────────────────────────────────┴──────────────────────────┘
[builders-strip lives immediately below, still on slate bg]
```

At `<960px`, the grid stacks — photo below the content column, natural flow.

## Spec

**Container:**
- CSS grid: `grid-template-columns: 58% 42%`
- Minimum height: 92vh desktop (leaves footer of builders-strip visible above the fold)
- No max-width wrapper — the split runs edge-to-edge
- `padding-top: 72px` to clear the fixed header

**Left column:**
- Background: `var(--slate)`
- Padding: `96px 80px` desktop / `56px 24px` mobile
- Max content width: 560px within the column
- Text color: white / rgba(255,255,255,0.75) for subtext

**Headline (H1):**
- Font: Staatliches 400
- Size: 72px desktop / 42px mobile
- Line-height: 0.95
- Letter-spacing: 0.5px
- Color: white
- Uppercase

**Subtext:**
- Font: Public Sans 400
- Size: 18px
- Line-height: 1.55
- Color: `rgba(255,255,255,0.75)`
- Max-width: 480px

**Micro-form (2 fields + CTA):**
- Gap between fields: 16px
- Input styling inherits from design-system Quote Form spec (height 48px, Public Sans 400 16px, border 1px solid #ddd, `border-radius: 4px`, focus ring `--sky`)
- Inputs on a white background for contrast against `--slate`
- Both required; zip pattern = 5 digits; phone format = (XXX) XXX-XXXX

**CTA:**
- `.btn--primary` (inherits)
- `margin-top: 24px`
- Label: "Start My Quote →"
- On submit: navigate to `/get-a-quote?zip={{zip}}&phone={{phone}}`

**Trust row:**
- Plain text with `✓` glyphs, no icons, no badges
- Font: Public Sans 500, 13px, uppercase, letter-spacing: 1px
- Text color: `rgba(255,255,255,0.75)`
- Checkmark (`✓`) color: `var(--sky)` — each glyph wrapped in `<span class="tick">` for color isolation. Brightens the hero, signals trust/verification.
- Margin-top: 24px
- Items: `<span class="tick">✓</span> Licensed · <span class="tick">✓</span> Insured · <span class="tick">✓</span> Free`

**Right column:**
- Real photo — full-height, `object-fit: cover`
- **No gradient overlay** unless photo-text contrast genuinely fails QA (it shouldn't — no text sits on the photo)
- Alt text: describes the actual build ("Cedar deck overlooking wooded backyard in Wausau, Wisconsin")

## States

**Default:** as specified above.

**Hover (CTA):** `background → var(--orange-hover)`. No scale transform, no shadow glow.

**Focus (inputs):** `border-color: var(--sky); box-shadow: 0 0 0 3px rgba(131,178,207,0.18)` (per design-system).

**Validation error:** `border-color: var(--error)`; inline 13px Public Sans error text below the input in `var(--error)`.

**Submit pending:** CTA text → "Submitting…", button disabled, no spinner glyph.

**Empty / photo missing:** `--slate` fills the right column. Do not show a broken-image icon or skeleton loader.

**Mobile:** two-column grid collapses to single-column. Photo moves below the form area, 320px tall, `object-fit: cover`.

## Webflow implementation notes

- Build as a net new component `hero-split` — do not copy from the retired `hero-section-subpage`.
- Section wrapper is a plain `<section>` (no `.section--dark` — the component controls its own slate background on the left column).
- The 2-field form uses a Webflow native form block, not a custom HTML embed. Form Success redirect is set to `/get-a-quote` with query params appended via a hidden field or Webflow's native redirect behavior.
- If Webflow's native form block cannot append URL params on submit, pause and ask the user before adding a small custom JS snippet to Page Settings → Before `</body>`.
- Photo is a Webflow image element, not a background-image — gives us alt-text and Webflow's responsive image pipeline.
- No decoration inside this component: no border-radius on inputs beyond 4px, no shadow on the CTA, no icon wrappers, no cedar-strip divider between this and the builders-strip.

## Related files

- `/website/design-system.md` — typography, color, form styles
- `/website/pages/homepage/content.md` — copy source
- `/website/components/builders-strip.md` — component that sits directly below
- `/website/components/multi-step-form.md` — the form on `/get-a-quote` that consumes the URL params set here
