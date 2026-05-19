---
type: component-spec
component-name: builders-strip
status: spec
created: 2026-04-19
---

# builders-strip

## Purpose

A compact horizontal proof strip that sits immediately under the hero (still on the slate background, with a subtle tonal shift to visually separate it from the hero). It puts real contractor faces above the fold — directly addressing the audit finding that the current site has no trust signals above the fold. Two contractors max in the initial launch (Ben Barton, John Garcia). Adds a third row dynamically when contractor #3 signs.

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│  YOUR LOCAL BUILDERS:                                        │
│  (●) Ben Barton    Wausau, WI     Barton Builders LLC       │
│  (●) John Garcia   Merrill, WI    John Garcia Construction  │
│                                       Meet the team →        │
└─────────────────────────────────────────────────────────────┘
```

Horizontal flex container. On desktop: label, then contractor rows, then the right-aligned "Meet the team →" link. On mobile: label stacks, rows stack, link moves below on its own line.

## Spec

**Section:**
- Background: `var(--slate)` with a 40% opacity black overlay on top (creates a tonal shift from the hero-split's left column — the component reads as "under the hero" rather than "part of the hero")
  - Effective color: `#1e2020`
- Padding: `48px 0` desktop / `32px 0` mobile
- Container: standard `.container`

**Label:**
- Font: Public Sans 600, 12px, uppercase, letter-spacing 2.5px
- Color: `var(--orange)`
- Text: "YOUR LOCAL BUILDERS:"
- Margin-bottom: 16px

**Contractors wrapper:**
- Display: flex, flex-direction: column, gap: 12px
- Mobile: same, full-width each row

**Contractor row:**
- Display: flex, align-items: center, gap: 16px
- Mobile: gap: 12px

**Headshot:**
- Width / height: 56px
- `border-radius: 50%` (only exception to the site's flat-corners stance — circular avatars are not decorative accents, they're a standard human-face convention)
- `object-fit: cover`
- Sources:
  - Ben Barton → `/branding/headshots/ben-barton-headshot.jpg`
  - John Garcia → `/branding/headshots/john-headshot.png`
- Alt text: "Portrait of Ben Barton, Barton Builders LLC"

**Empty state (no headshot / file missing):**
- Circle with `var(--orange)` background
- Initials in white: Staatliches 400, 22px (e.g., `BB`, `JG`)
- Same 56px size

**Name:**
- Font: Public Sans 600, 16px
- Color: `#ffffff`

**Company + city (secondary line):**
- Font: Public Sans 400, 13px
- Color: `rgba(255,255,255,0.65)`
- Format: `[City, ST] · [Company name]` on a single line, or stacked below the name on mobile

**"Meet the team →" link:**
- Font: Public Sans 600, 14px, uppercase, letter-spacing 1px
- Color: `var(--sky)` — text link convention: orange is reserved for CTA buttons only
- Hover: underline fades in under the text, color stays `var(--sky)`
- Right-aligned on desktop (`margin-left: auto` on the link inside the flex wrapper, OR right-align via a secondary row)
- Mobile: full-width row below the contractors, left-aligned

## States

**Default:** as specified.

**Hover (contractor rows):** none — these are informational, not clickable. The link is the only interactive element.

**Hover (link):** color shift `--orange` → `--orange-hover`.

**Missing headshot:** initials-badge fallback (see spec above). This fallback is also the correct render for any future contractor who signs before submitting a photo.

**Third contractor signs:** add a third row in the same flex container. No layout changes needed — the flex naturally expands. If the strip grows beyond 4 rows, flag to Jim for a layout rethink (likely a CMS-bound grid variant).

## Webflow implementation notes

- Build as a net new component `builders-strip`.
- Hard-code the two contractor rows initially. If/when a third contractor signs, bind this component to the Our Builders CMS collection (`69cff079df8b05e8d3935fdf`) for easier management — Webflow CMS repeat inside the component wrapper.
- Upload both headshots to the Webflow Asset Manager if they aren't already there (they were uploaded per 2026-04-17 manual photo swap).
- Circular images: Webflow image element with combo-class `.headshot-circle` applying `border-radius: 50%` + `object-fit: cover`.
- No hover transforms anywhere in this component.

## Related files

- `/website/design-system.md` — Color + typography tokens
- `/website/pages/homepage/content.md` — contractor copy source
- `/website/pages/our-builders/content.md` — target of the "Meet the team →" link
- `/branding/headshots/ben-barton-headshot.jpg` — Ben Barton portrait
- `/branding/headshots/john-headshot.png` — John Garcia portrait
- Webflow CMS collection: Our Builders (`69cff079df8b05e8d3935fdf`)
