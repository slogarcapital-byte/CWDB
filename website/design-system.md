---
type: reference
tags:
  - type/reference
  - dept/website
aliases: []
created: 2026-03-29
updated: 2026-04-19
status: active
---

# CWDB Design System — [[Webflow]] Build Reference

This document defines every visual rule for building cwdeckbuilders.com in Webflow. Follow it exactly to maintain consistency across all 21 pages.

**Last updated 2026-04-19:** Site revamp per design brief `/_plans/web-dev-agent-let-s-work-stateless-scroll.md`. Typography fully swapped (Barlow Condensed → Staatliches, Inter → Public Sans). Removed banned decoration patterns (border-left / border-bottom accent stripes, cedar-strip divider, tinted icon-wrapper squares, --sky-tint / --cedar-light section backgrounds). Added 7 new component specs for proof-first homepage spine. Deprecated components marked inline — not deleted — to preserve audit trail.

---

## Color Palette

| Role | Name | Token | Hex | RGB | Usage |
|---|---|---|---|---|---|
| Primary Accent | Crafted Orange | `--orange` | `#e54c00` | 229, 76, 0 | CTAs, highlights, section labels, step circles |
| Primary Accent Hover | Orange Dark | `--orange-hover` | `#cc4300` | 204, 67, 0 | Button hover state (10% darker) |
| Primary Accent Active | Orange Pressed | `--orange-active` | `#b33a00` | 179, 58, 0 | Button active/pressed state |
| Dark Base | Timber Slate | `--slate` | `#323434` | 50, 52, 52 | Hero/footer backgrounds, primary text on light |
| Secondary Text | Builders Grey | `--grey` | `#646760` | 100, 103, 96 | Subheadings, borders, captions, secondary copy |
| Sky Accent | Wisconsin Sky Blue | `--sky` | `#83b2cf` | 131, 178, 207 | Signal-accent color (2026-04-19 revamp): text links on light backgrounds, trust-row checkmarks, 1px connector/separator lines, inactive progress dashes, coverage-map pins, input focus ring. Never used as card accent stripe, section border, or icon-wrapper fill. |
| Wood Accent | Aged Cedar | `--cedar` | `#8B5A2B` | 139, 90, 43 | Reserved for future illustrative use. No longer used for card borders, process connectors, or the cedar-strip divider (2026-04-19) |
| Light BG | Off-White | `--off-white` | `#f8f8f6` | 248, 248, 246 | Alternating content sections |
| White | White | `--white` | `#ffffff` | 255, 255, 255 | Cards, form backgrounds, primary content |
| Error | Red | `--error` | `#d32f2f` | 211, 47, 47 | Form validation errors |
| Success | Green | `--success` | `#2e7d32` | 46, 125, 50 | Form success states, confirmation checkmarks |

### Color Rules

1. **Alternate sections** between Timber Slate (dark), White, and Off-White only — no accent-tinted section backgrounds
2. **Crafted Orange** is for primary CTA buttons and section-label eyebrows only — never as a section background fill, never as a text-link color. This keeps orange as a dedicated action signal.
3. **Wisconsin Sky Blue** is the signal-accent color (clarified 2026-04-19): text links on light backgrounds, trust-row checkmarks, 1px connector/separator lines, inactive progress dashes, coverage-map pins, input focus ring. Always as color on a defined element — never as a card accent stripe, section border, or icon-wrapper fill.
4. **Aged Cedar** is reserved for future illustrative use (e.g., real-wood imagery). Do not use as a border, divider, or connector color (removed 2026-04-19)
5. Hero sections use Timber Slate with a real photo — no gradient overlay unless the photo itself needs it for text readability
6. Text on dark backgrounds: White (`#ffffff`)
7. Text on light backgrounds: Timber Slate (`#323434`)
8. Secondary text on light: Builders Grey (`#646760`)
9. **Text link convention (2026-04-19):** hyperlink text uses `--sky` on any background — on light backgrounds it reads clearly, on dark backgrounds it remains visible. Button CTAs always use orange regardless of background. Focus rings stay orange for keyboard-visibility.

### CSS Custom Properties (Webflow Variables Panel)

```css
:root {
  --orange:       #e54c00;
  --orange-hover: #cc4300;
  --orange-active: #b33a00;
  --slate:        #323434;
  --grey:         #646760;
  --sky:          #83b2cf;
  --cedar:        #8B5A2B;
  --off-white:    #f8f8f6;
  --white:        #ffffff;
  --error:        #d32f2f;
  --success:      #2e7d32;
  --font-heading: 'Staatliches', sans-serif;
  --font-body:    'Public Sans', sans-serif;
  --max-width:    1200px;
  --content-width: 720px;
}
```

**Retired tokens (2026-04-19):** `--sky-tint` and `--cedar-light` are removed. Section backgrounds are limited to `--slate`, `--white`, and `--off-white`.

---

## Typography

All fonts loaded via Google Fonts in Webflow. Add both fonts to the project: **Staatliches** (400 — single-weight face) and **Public Sans** (400, 500, 600).

**Why these fonts (2026-04-19 swap):**
- **Staatliches** — narrow, civic-industrial signage face. Reads as "municipal permit office + Northwoods trade." Not on the AI-reflex-reject list.
- **Public Sans** — US Web Design System font. Civic-credible, refined, American-utility. Explicitly off the Inter / Geist / generic-sans reflex list.

### Font Stack

| Role | Font | Weight | Size (Desktop) | Size (Mobile) | Style |
|---|---|---|---|---|---|
| H1 (display) | Staatliches | 400 | 72px | 42px | Uppercase, letter-spacing: 0.5px, line-height: 0.95 |
| H2 | Staatliches | 400 | 48px | 32px | Uppercase, letter-spacing: 0.5px, line-height: 1.05 |
| H3 | Staatliches | 400 | 32px | 24px | Uppercase, letter-spacing: 0.5px, line-height: 1.1 |
| H4 | Public Sans | Semi-Bold (600) | 20px | 17px | Normal case, line-height: 1.3 |
| Body | Public Sans | Regular (400) | 16px | 16px | Line-height: 1.55 |
| Body Large | Public Sans | Regular (400) | 18px | 16px | Line-height: 1.55 — hero subtext |
| Small / Caption | Public Sans | Regular (400) | 14px | 13px | Line-height: 1.4 |
| Button Text | Public Sans | Semi-Bold (600) | 15px | 15px | Uppercase, letter-spacing: 1.5px |
| Nav Links | Public Sans | Medium (500) | 14px | 14px | Normal case |
| Section Label | Public Sans | Semi-Bold (600) | 12px | 12px | Uppercase, letter-spacing: 3px, color: var(--orange) |
| Form Label | Public Sans | Medium (500) | 14px | 14px | Normal case, color: var(--slate) |
| Form Group Divider | Public Sans | Semi-Bold (600) | 11px | 11px | Uppercase, letter-spacing: 2px, color: var(--orange) |
| Process Numeral | Staatliches | 400 | 120px | 72px | Color: var(--orange), line-height: 1 |

### Typography Rules

1. Headlines (H1–H3): always **Staatliches, uppercase** (Staatliches ships only at weight 400 — do not specify 700)
2. Body text: always **Public Sans, normal case**
3. Line height for body: **1.55** (the switch from Inter's 1.6 is intentional — Public Sans has a shorter x-height)
4. Maximum content width: **1200px** (centered container)
5. Paragraph max-width: **720px** (for readability on wide screens)
6. Section labels always appear above headings in Crafted Orange, 12px, uppercase
7. **Fallback pairings** (Jim's call at approval): Anton + Public Sans (heavier display) · Oswald + Libre Franklin (safer / closer to current feel). Current recommendation: Staatliches + Public Sans.

---

## Spacing Scale

Use a consistent 8px base grid:

| Token | Value | Usage |
|---|---|---|
| xs | 8px | Tight gaps, icon margins |
| sm | 16px | Between related elements |
| md | 24px | Default component padding |
| lg | 32px | Between section content blocks |
| xl | 48px | Section padding (mobile) |
| 2xl | 64px | Section padding (tablet) |
| 3xl | 96px | Section padding (desktop) |
| 4xl | 128px | Hero section vertical padding |

---

## Responsive Breakpoints

| Breakpoint | Width | Notes |
|---|---|---|
| Desktop | 1024px+ | Full layout, multi-column grids |
| Tablet | 768px–1023px | 2-column grids, reduced padding |
| Mobile | max-width: 767px | Single column, hamburger nav |
| Small Mobile | max-width: 480px | Tightest spacing, stacked trust badges |

---

## Components

### CTA Buttons — `.btn`

**Primary Button — `.btn--primary`**
```
Background:    var(--orange) → #e54c00
Text:          #ffffff
Font:          Public Sans Semi-Bold 600, 15px, uppercase, letter-spacing: 1.5px
Padding:       16px 40px
Border-radius: 4px     ← reduced from 6px (2026-04-19) for flatter, less templated feel
Box-shadow:    none    ← glowing shadow removed (2026-04-19); anti-generic pass
Hover:         background → var(--orange-hover)
Active:        background → var(--orange-active)
Transition:    background 150ms ease
```

**Secondary Button — `.btn--secondary`**
```
Background:    transparent
Border:        2px solid var(--orange)
Text:          var(--orange)
Font:          Public Sans Semi-Bold 600, 15px, uppercase, letter-spacing: 1.5px
Padding:       14px 38px
Border-radius: 4px
Hover:         Background → var(--orange), Text → #ffffff
```

**Small Variant — `.btn--sm`**
```
Padding:       10px 24px
Font-size:     13px
```

**Full Width — `.btn--full`**
```
Width:         100%
Display:       block
Text-align:    center
```

**Webflow:** Create a Button Symbol with combo class modifiers (`.btn--primary`, `.btn--secondary`, `.btn--sm`, `.btn--full`).

---

### Navigation Header — `.header`

**Glassmorphism (at page top):**
```
Position:       fixed; top: 0; left: 0; right: 0
Height:         72px
Z-index:        1000
Background:     rgba(50, 52, 52, 0.65)
Backdrop-filter: blur(14px)
-webkit-backdrop-filter: blur(14px)
Border-bottom:  1px solid rgba(255, 255, 255, 0.07)
Transition:     background 300ms ease
```

**Scrolled state — `.header.scrolled`** (JS adds class on scroll > 60px):
```
Background:     rgba(50, 52, 52, 0.97)
Border-bottom:  1px solid rgba(255, 255, 255, 0.05)
```

**Logo — `.header__logo`:**
```
Display:        flex; align-items: center; gap: 10px
Logo image:     height: 36px (use 1.1-primary-logo-high-res.png)
Fallback text:  "CWDB" — Staatliches 400, 22px, uppercase, letter-spacing: 2px, white
Subtext:        "Central Wisconsin Deck Builders" — Public Sans 500, 9px, color: rgba(255,255,255,0.6), letter-spacing: 1.5px
```

**Nav links — `.header__nav`:**
```
Gap:            32px
Links:          14px, Public Sans 500, color: rgba(255,255,255,0.85)
Hover:          color: rgba(255,255,255,1.0)     ← changed from var(--sky) 2026-04-19
```

**Resources Dropdown:**
```
Position:       absolute; top: calc(100% + 12px); left: 50%; transform: translateX(-50%)
Background:     var(--slate)
Border-radius:  8px
Padding:        8px 0
Min-width:      180px
Box-shadow:     0 8px 32px rgba(0,0,0,0.3)
Border:         1px solid rgba(255,255,255,0.1)
Items:          Blog | FAQ | Cost Calculator | Deck Permits Guide
```

**Phone link — `.header__phone`:**
```
Font-size:      14px; Public Sans 500; color: rgba(255,255,255,0.85)
Hover:          color: rgba(255,255,255,1.0)
Gap:            6px (icon + number)
```

**Quote CTA button (header):**
```
Same .btn--primary, padding: 10px 24px (sm variant)
```

**Mobile hamburger — `.hamburger`:**
```
Display:        none (hidden at desktop)
Visible:        max-width: 767px
Icon:           3 lines, 20px, white, 2px stroke
```

**Mobile menu overlay — `.m-menu-overlay`:**
```
Position:       fixed; inset: 0
Background:     var(--slate)
Z-index:        9999
Nav links:      Staatliches 400, 32px, uppercase, white, centered
Close button:   top-right, 40px, rgba(255,255,255,0.6)
```

**Scroll JS (required — add to page settings → Custom Code):**
```javascript
document.addEventListener('scroll', function() {
  var header = document.querySelector('.header');
  if (window.scrollY > 60) {
    header.classList.add('scrolled');
  } else {
    header.classList.remove('scrolled');
  }
}, { passive: true });
```

**Webflow:** Use a Navbar Symbol. Apply glassmorphism via custom CSS embed. The `.scrolled` class toggle requires a JS embed in page settings.

---

### Hero Section — `.section--hero` [DEPRECATED — superseded by `hero-split` as of 2026-04-19]

**Retired 2026-04-19.** The full-bleed gradient-overlay hero is replaced by the `hero-split` component. See `/website/components/hero-split.md`. Original spec preserved below for audit trail only.

```
Min-height:     100vh
Display:        flex; align-items: center
Padding-top:    72px (account for fixed header height)
Color:          white
Overflow:       hidden

Background (simulates dark deck photo overlay):
  linear-gradient(180deg, rgba(50,52,52,0.55) 0%, rgba(30,26,20,0.85) 60%, rgba(26,22,18,0.95) 100%)
  overlaid on:
  linear-gradient(135deg, #1e2820 0%, #2e2a20 35%, #1c1e20 70%, #16181c 100%)

Subtle wood plank texture (::before pseudo-element):
  repeating-linear-gradient(
    180deg,
    transparent 0px, transparent 34px,
    rgba(0,0,0,0.06) 34px, rgba(0,0,0,0.06) 36px
  )
  Opacity: 0.4

Vignette (::after pseudo-element):
  radial-gradient(ellipse at center, transparent 40%, rgba(0,0,0,0.4) 100%)
```

**Hero content layout:**
```
Max-width:      640px
H1:             64px Barlow Condensed 700, uppercase, letter-spacing: 1.5px
Subtext:        18px Inter 400, rgba(255,255,255,0.85), max-width: 520px
CTA row:        flex, gap: 16px, margin-top: 40px
Trust badges:   flex row, gap: 24px, margin-top: 32px
  Badge:        "✓ Free · ✓ No Obligation · ✓ Licensed & Insured"
  Font:         13px Inter 500, rgba(255,255,255,0.75)
```

---

### Cedar Divider Strip — `.cedar-strip` [DEPRECATED — removed 2026-04-19]

**Retired 2026-04-19.** The cedar-strip divider is explicitly flagged as decoration without information value per the `/impeccable` anti-pattern list. Removed site-wide. Do not reintroduce. Component spec preserved below for audit trail only.

```
Height:         6px
Background:     repeating-linear-gradient(
                  90deg,
                  var(--cedar) 0, var(--cedar) 20px,
                  rgba(139,90,43,0.3) 20px, rgba(139,90,43,0.3) 24px
                )
Width:          100%
```

---

### Services Grid — `.services-grid` [DEPRECATED — removed from homepage 2026-04-19]

**Retired 2026-04-19.** The homepage services grid is replaced in the proof-first spine by `gallery-featured` (real project photos do the work the service cards used to do). Services copy still appears on interior pages (city pages, About) but as a flat list, not a bordered/iconed card grid. Original spec preserved below for audit trail only.

Plan violations flagged: `border-bottom: 3px solid var(--sky)` accent stripe, 56×56 tinted icon-wrapper squares — both on the `/impeccable` anti-pattern list.

```
Layout:         grid; grid-template-columns: repeat(4, 1fr); gap: 24px
Mobile:         grid-template-columns: repeat(2, 1fr)
```

**Service Card — `.service-card` [DEPRECATED]:**
```
Background:     white
Border-radius:  10px
Padding:        28px 24px
Border-bottom:  3px solid var(--sky)     ← BANNED decoration
Box-shadow:     0 2px 12px rgba(0,0,0,0.07)
Text-align:     center
Hover:          translateY(-4px); shadow → 0 8px 24px rgba(0,0,0,0.12)
Transition:     all 200ms ease

Icon wrapper:   56px × 56px; background: rgba(131,178,207,0.12);   ← BANNED decoration
                border-radius: 12px; margin: 0 auto 16px
Icon:           28px; color: var(--sky)
Title:          H4 / Inter Semi-Bold 600, 17px, var(--slate), margin-bottom: 8px
Body:           14px Inter 400, var(--grey), line-height: 1.5
```

Services formerly listed here: Custom Decks | Pergolas | Screened Porches | Renovations. These are still offered; they are just not the homepage visual anchor anymore.

---

### Value Props Grid — `.value-grid`

3-column grid (on white or off-white background):
```
Layout:         grid; grid-template-columns: repeat(3, 1fr); gap: 32px
Mobile:         single column
```

**Value Prop Card:**
```
Icon:           40px; color: var(--slate)     ← changed from --sky (2026-04-19)
Title:          Staatliches 400, 24px, uppercase; var(--slate)
                ← Component override: 24px (not full H3 32px)
Body:           16px Public Sans 400; var(--grey); line-height: 1.55
```

---

### Process Timeline — `.process-section` [DEPRECATED — superseded by `process-steps-v2` as of 2026-04-19]

**Retired 2026-04-19.** The 48px orange-circle-with-number + cedar-gradient-connector pattern is replaced by `process-steps-v2` — massive Staatliches numerals (120px / 72px) and a plain 1px `--grey` connector. See `/website/components/process-steps.md`. Original spec preserved below for audit trail only.

Plan violations flagged: orange circle badges (templated), cedar gradient connector (banned decoration), Inter body font.

```
Step number circle:  48px circle, orange bg, Barlow Condensed number
Step connector:      2px linear-gradient cedar → transparent (BANNED)
Step title:          Inter Semi-Bold 600, 17px
Step body:           Inter 400, 15px
```

---

### Trust Badges Row — `.trust-row`

Plain-text trust row. No icons, no tinted pill backgrounds, no card treatment — just checkmark glyphs + text.

```
Layout:         flex row; justify-content: center; gap: 24px; flex-wrap: wrap
Mobile:         gap: 16px; can wrap

Badge item:     inline text with ✓ prefix glyph
Font:           Public Sans 500, 13px; uppercase; letter-spacing: 1px
Color:          var(--grey) on light, rgba(255,255,255,0.75) on dark
```

Badges (hero variant): `✓ Licensed  ✓ Insured  ✓ Free`
Badges (full variant): Licensed Contractors | Insured & Bonded | Free Quotes — No Obligation | Local Wisconsin Builders

---

### Testimonial Cards — `.testimonial-card` [DEPRECATED — removed 2026-04-19]

**Retired 2026-04-19.** Testimonial cards are already removed from the site per the FTC 16 CFR 255 / Aug 2024 Fake Reviews Rule decision (2026-04-15). Additionally, the `border-left: 3px solid var(--cedar)` pattern is explicitly flagged by `/impeccable` as the single most overused AI design touch. Original spec preserved below for audit trail only. If real testimonials are ever added, bind to a CMS collection and use a flat plain-card treatment — no border-left accent.

```
Background:     white
Border-radius:  10px
Padding:        28px
Border-left:    3px solid var(--cedar)    ← BANNED decoration
Box-shadow:     0 2px 12px rgba(0,0,0,0.07)

Quote text:     16px Inter 400, var(--slate), line-height: 1.6; italic
Author:         Inter Semi-Bold 600, 15px, var(--slate)
Location badge: Inter 500, 12px uppercase; var(--cedar) text on var(--cedar-light) pill  ← BANNED
Stars:          5× ★ in var(--orange), 14px
```

---

### Quote Page Layout — `.quote-layout`

Two-column grid used on `/get-a-quote`:

```
Display:        grid
Grid-template-columns: 1fr 400px
Gap:            56px
Padding:        72px 0 96px
Align-items:    start

Mobile (max-width: 960px): single column
```

**Left column:** The quote form (see Form section below). **Note 2026-04-19:** on `/get-a-quote`, the single-page form is being replaced by a 3-step wizard (`multi-step-form`). The two-column page layout still applies — the wizard takes the left column, the right column stays the same.

**Right column — `.right-col`:**
```
Position:       sticky; top: 100px
Display:        flex; flex-direction: column; gap: 28px
```

Right column contains:
1. Trust card (`.trust-card`) — white bg, 4 trust items as plain text (no sky icons as of 2026-04-19)
2. "What Happens Next?" card (`.next-card`) — dark Timber Slate bg
3. Mini testimonial (`.mini-testimonial`) [DEPRECATED — removed with testimonials]

---

### Quote Form — `.quote-form`

```
Display:        grid; grid-template-columns: 1fr 1fr; gap: 20px 24px
Mobile:         single column grid

Input/Select/Textarea:
  Width:        100%
  Height:       48px (inputs/selects)
  Min-height:   100px (textarea)
  Border:       1px solid #ddd
  Border-radius: 4px     ← reduced from 6px (2026-04-19)
  Padding:      0 16px (inputs); 12px 16px (textarea)
  Font:         Public Sans 400, 16px, var(--slate)
  Background:   white
  Focus:        border-color: var(--sky);
                box-shadow: 0 0 0 3px rgba(131, 178, 207, 0.18)
                ← --sky retained here as focus-only accent
  Transition:   border-color 150ms ease, box-shadow 150ms ease

Label:
  Font:         Public Sans 500, 14px, var(--slate)
  Margin-bottom: 6px

Error state:    border-color: var(--error); color: var(--error)
```

**Form Group Divider Label — `.form-group-label`:**
```
Grid-column:    span 2
Font:           Public Sans 600, 11px; text-transform: uppercase; letter-spacing: 2px
Color:          var(--orange)
Border-bottom:  1px solid var(--off-white)
Padding-bottom: 8px; margin-top: 8px
```

Form fields (9 total): First Name | Last Name | Email | Phone | City/Zip | Project Type (select) | Budget (select) | Timeline (select) | Project Details (textarea, full-width)

---

### "What Happens Next?" Card — `.next-card`

Used in the quote page right column and thank-you page.

```
Background:     var(--slate)
Border-radius:  8px     ← reduced from 12px (2026-04-19)
Padding:        28px 24px
Color:          white

Heading:        H3 / Staatliches 400, uppercase, white
Connector between steps:
  Width:        1px; height: 20px; background: rgba(255,255,255,0.2); margin: 4px 0 4px 19px
  ← simplified from cedar-tinted 2px bar (2026-04-19)
```

**Timeframe Badge — `.next-step__time`:**
```
Display:        inline-block
Font:           Public Sans 600, 10px, uppercase, letter-spacing: 1.5px
Color:          var(--orange)
Background:     rgba(229, 76, 0, 0.12)
Border:         1px solid rgba(229, 76, 0, 0.25)
Padding:        2px 8px
Border-radius:  12px
Margin-bottom:  6px
```

**Step title:** Public Sans Semi-Bold 600, 15px, white, margin-bottom: 4px
**Step body:** Public Sans 400, 14px, rgba(255,255,255,0.70), line-height: 1.55

---

### City Cards — `.city-card` [DEPRECATED — superseded by `coverage-map` as of 2026-04-19]

**Retired 2026-04-19.** The 5-city card grid is replaced by the `coverage-map` band: a 2-column layout with a custom-drawn Wisconsin SVG on the left and a Staatliches city list on the right. See `/website/components/coverage-map.md`. Original spec preserved below for audit trail only.

Plan violation flagged: `border-bottom: 3px solid var(--cedar)` accent stripe — banned decoration.

```
Background:     white; Border-radius: 10px; Padding: 24px
Border-bottom:  3px solid var(--cedar)    ← BANNED decoration
Box-shadow:     0 2px 8px rgba(0,0,0,0.07)
City name:      H3 Barlow Condensed 700
Description:    Inter 400, 14px
```

---

### Blog Cards — `.blog-card`

```
Background:     white
Border-radius:  4px     ← reduced from 10px (2026-04-19)
Overflow:       hidden
Box-shadow:     none    ← removed (2026-04-19); no drop shadows on cards
Border-top:     none
Hover:          photo scales 1.02 within overflow-hidden container; no translate on card
Transition:     transform 200ms ease

Image area:     height: 200px; real CMS image; no gradient placeholder
Content:        padding: 24px 0
Category badge: Public Sans Semi-Bold 600, 12px, uppercase, letter-spacing: 2px, color: var(--grey)
                No pill background (2026-04-19); plain text only
Title:          H4 / Public Sans Semi-Bold 600, 18px, var(--slate), line-height: 1.4
Body:           15px Public Sans 400, var(--grey), 2-line clamp
Read more link: "Read more →"; var(--orange); 14px Public Sans 600
```

Grid: 2-column desktop (not 3), 1-column mobile. Plan change 2026-04-19: wider cards, larger photos, less monotony.

---

### 4-Column Footer — `.footer`

```
Background:     var(--slate)
Padding:        64px 0 0
Color:          white

Footer grid — .footer__grid:
  Display:      grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 48px
  Mobile:       2-column grid, then single column below 480px
```

**Column 1 — Brand:**
```
Logo image:     height: 32px (1.1 or 1.2 logo variant)
Tagline:        "Fast Quotes. Trusted Builders." — 14px Public Sans 400, rgba(255,255,255,0.65)
Social icons:   flex row; gap: 12px; margin-top: 24px
```

**Columns 2–4 — Links:**
```
Heading:        Staatliches 400, 16px, uppercase, letter-spacing: 1px, white, margin-bottom: 16px
Links:          Public Sans 400, 14px, rgba(255,255,255,0.65), hover → white; line-height: 2.2
```

Col 2 — Quick Links: Home | Get a Quote | Our Builders | Gallery | About | FAQ | Blog
Col 3 — Service Areas: Wausau | Schofield | Weston | Mosinee | Merrill
Col 4 — Contact: info@cwdeckbuilders.com | (phone TBD) | Hours TBD

**Social Icon Buttons — `.social-btn`:**
```
Width/Height:   40px; border-radius: 50%
Border:         1px solid rgba(131, 178, 207, 0.3)
Background:     rgba(131, 178, 207, 0.08)
Display:        flex; align-items: center; justify-content: center
Hover:          background → rgba(131, 178, 207, 0.2); border-color → var(--sky)
Icon:           20px SVG; color: var(--sky)
```

Platforms: Facebook | Instagram | Nextdoor

**Footer bottom bar:**
```
Margin-top:     48px
Border-top:     1px solid rgba(255,255,255,0.1)
Padding:        20px 0
Layout:         flex; justify-content: space-between; align-items: center
Copyright:      © 2026 Central Wisconsin Deck Builders — 13px Public Sans 400, rgba(255,255,255,0.5)
Links:          Privacy Policy | Terms of Service — 13px Public Sans 400, rgba(255,255,255,0.5), hover → white
```

---

### Sticky Mobile CTA Bar — `.mobile-cta-bar`

```
Position:       sticky (inside phone scroll container) or fixed bottom (real Webflow build)
Bottom:         0; z-index: 999
Background:     var(--orange)
Height:         56px
Display:        flex; align-items: center; justify-content: center
Layout:         two columns: text link + phone call link

Text:           "Start My Quote →"; Public Sans 600, 15px, uppercase, letter-spacing: 1px, white
Phone link:     phone icon + number; white; Public Sans 500, 14px
Divider:        1px solid rgba(255,255,255,0.3)

Visible:        max-width: 767px only
```

---

### Confirmation / Thank-You Components

**Success Checkmark — `.confirm-check`:**
```
Width/Height:   60px; border-radius: 50%
Background:     var(--orange)
Color:          white
Font-size:      28px (checkmark character ✓)
Display:        flex; align-items: center; justify-content: center
Margin:         0 auto 28px
Box-shadow:     0 4px 20px rgba(229, 76, 0, 0.35)
```

**"While You Wait" Blog Link Cards — `.wait-card` [DEPRECATED — 2026-04-19]**

**Retired 2026-04-19.** The `border-left: 3px solid var(--sky)` pattern is explicitly banned. Replacement treatment: plain `.blog-card` style (see above), or a flat link list with Public Sans 500 text + orange arrow — no bordered card. Original spec preserved below for audit trail only.

```
Background:     var(--off-white)
Border-left:    3px solid var(--sky)    ← BANNED decoration
Padding:        18px 20px
Title:          Inter Semi-Bold 600, 15px
```

---

## Section Patterns

Every page follows an alternating dark / white / off-white rhythm. Accent-tinted backgrounds (`.section--accent`, `.section--cedar`) are **retired 2026-04-19** — do not reintroduce.

| Class | Background | Text | Use For |
|---|---|---|---|
| `.section--dark` | `var(--slate)` = `#323434` | white | Hero (split), process, final CTA, embedded form, footer |
| `.section--light` | `#ffffff` | `var(--slate)` | Gallery, blog index, interior page content |
| `.section--alt` | `var(--off-white)` = `#f8f8f6` | `var(--slate)` | Alternating sections for visual break |

**Rhythm rule:** Sections alternate dark/light/off-white. Vertical padding is intentionally uneven — hero full viewport, process tall, gallery taller (photos run tall), builders-strip compact, coverage-map wide-short, FAQ tight, final CTA tall. Do not apply uniform 96px padding everywhere.

**Section structure:**
```html
<section class="section section--[variant]">
  <div class="container">
    <span class="section__label">Label Text</span>
    <h2 class="section__heading">Section Heading</h2>
    <p class="section__sub">Optional subtitle or description.</p>
    <!-- content -->
  </div>
</section>
```

**Section label — `.section__label`:** 12px Public Sans 600, uppercase, letter-spacing: 3px, color: var(--orange), margin-bottom: 12px
**Section heading — `.section__heading`:** H2 Staatliches 400, uppercase, margin-bottom: 16px
**Section subtitle — `.section__sub`:** 18px Public Sans 400, color: var(--grey) (or rgba(255,255,255,0.7) on dark), max-width: 600px, centered, margin: 0 auto 48px

Vertical padding per section: default `96px` desktop / `64px` tablet / `48px` mobile. Override per-component (hero 100vh, final CTA 128px, builders-strip 48px — see individual component specs).

---

## Imagery Guidelines

- **Hero backgrounds:** Dark-toned deck photography, overlaid with gradient (see Hero spec) for text readability
- **Gallery photos:** Well-lit outdoor deck photos — Wisconsin settings: cedar, pine, lake country aesthetic
- **Icons:** Simple line icons, 2px stroke, `var(--sky)` or `var(--orange)` — use inline SVG with `stroke="currentColor"`
- **No generic stock:** Photos must feel regional — wood grain, Northwoods
- **Image format:** WebP with JPG fallback for Webflow
- **Lazy loading:** Enable on all below-fold images in Webflow
- **Blog card images:** 180px tall; use real photos when available, gradient placeholder in mockups

---

## Animations

Keep animations subtle and performant (Webflow Interactions panel):

- **Scroll reveal:** Fade-up (opacity 0→1, translateY 20px→0, 400ms ease-out) on sections entering viewport
- **Buttons:** scale(1.02) on hover, 200ms ease
- **Cards:** translateY(-2px to -4px) + shadow increase on hover, 200ms ease
- **Process timeline steps:** Animate in sequentially (stagger 150ms) on scroll
- **Header transition:** background 300ms ease (JS-driven)
- **No parallax** — keep it fast-loading and accessible

---

## Webflow Implementation Notes

### Fonts
- Add **Staatliches** via Webflow Designer → Project Settings → Fonts → Google Fonts (weight: 400 — single-weight face)
- Add **Public Sans** via same flow (weights: 400, 500, 600)
- After the full site rebuild passes QA, remove the old Barlow Condensed and Inter font entries from Project Settings

### CSS Variables
- Add all tokens from the `:root` block (Color Palette section) to Webflow's **CSS Variables** panel (Project Settings → CSS Variables)

### Glassmorphism Header
- Use a **Navbar Symbol** in Webflow
- Apply glassmorphism background via **Embed** element with `<style>` tag scoped to `.header`
- The `.scrolled` class toggle requires a **JS embed** in Page Settings → Before `</body>` tag

### Sticky Right Column
- On the quote page, use Webflow's **Position: Sticky** option in the Style panel for the right column
- Set `top: 100px` to clear the fixed header

### Mobile Sticky CTA Bar
- Use a **fixed position** div at the bottom of the page
- Set display: `none` on desktop, `flex` on mobile via breakpoint

### Form
- Use **Webflow native forms** — configure the form action to submit to Make webhook URL
- Style form fields using the class system above
- Add hidden field for page source: `?source=get-a-quote`

### Images
- Use Webflow's built-in **Asset Manager** for all images
- Apply WebP with JPG fallback via Webflow's Responsive Images feature
- Hero section: use a div with `background-image` set to the hero photo + gradient overlay div on top

### SVG Icons
- Upload SVG files to Webflow Asset Manager, OR embed inline via HTML embed elements
- Use `currentColor` on SVG strokes to inherit CSS color values

---

## New Components (2026-04-19 revamp)

Full specs live in `/website/components/*.md` — one file per component. Short summaries below.

### `hero-split`
Split-hero replacing the retired `.section--hero`. Two-column CSS grid (58% / 42%), stacks <960px. Left column: `--slate` background, Staatliches 72px headline, Public Sans subtext, 2-field micro-form (zip + phone), primary CTA, plain trust row. Right column: full-height real photo, no gradient overlay. See `/website/components/hero-split.md`.

### `process-steps-v2`
Redesigned `.process-section` (that component is deprecated). Drops the 48px orange circles and cedar gradient connector. Uses massive Staatliches numerals (120px desktop / 72px mobile) in `--orange`, plus a plain 1px `--grey` horizontal connector at 50% vertical position. 3 columns desktop, vertical stack mobile. See `/website/components/process-steps.md`.

### `gallery-featured`
New homepage component. 3 featured builds in a 3-column row (1 col mobile), 16:10 photos, **no rounded corners, no shadow, no border**. Caption stack: project-type label (Staatliches 14px uppercase `--orange`) → specs line (Public Sans 15px `--slate`) → builder line (Public Sans 13px `--grey`). Whole card links to `/gallery`. See `/website/components/gallery-featured.md`.

### `builders-strip`
Compact horizontal proof strip that sits immediately under the hero (or after the gallery as a secondary placement). 56px circular headshots for Ben Barton + John Garcia (sourced from `/branding/headshots/`), name + company + city, "Meet the team →" link to `/our-builders`. Empty-state fallback: initial badges in `--orange` circles. See `/website/components/builders-strip.md`.

### `coverage-map`
Replaces the retired 5-city card grid. 2-column layout: custom-drawn Wisconsin SVG (Marathon + Lincoln county outlines, slate strokes, orange pins at the 5 cities, ~320×280 viewBox) on the left, Staatliches 32px uppercase city list on the right (hover → orange underline, each links to the city page). Stacks on mobile. See `/website/components/coverage-map.md`.

### `cta-final`
New end-of-scroll CTA section. Full-width `--slate` band, 128px vertical padding desktop, single white Staatliches headline (56px desktop / 36px mobile), single orange primary CTA centered. No trust badges — trust is established earlier in the scroll. See `/website/components/cta-final.md`.

### `multi-step-form`
New 3-step wizard on `/get-a-quote`. Progress indicator at top = 3 dashes (active `--orange`, inactive `--grey`). Step 1: zip + phone (pre-fills from URL params `?zip=X&phone=Y` when user arrives from hero micro-form). Step 2: project type + property address + ownership. Step 3: budget + timeline + project details. Back link on steps 2–3. Requires custom JS in Webflow Page Settings → Before `</body>`. Final submit fires the existing Make webhook. See `/website/components/multi-step-form.md`.

---

## Webflow Component Methodology

This section governs how every page on cwdeckbuilders.com is built in Webflow. The visual specs above define *what* components look like. This section defines *how* they are assembled, named, and managed across all 21 pages.

### Core Rules

**1. Every section is a Webflow component.**
No section on any page may exist as raw/loose HTML or an unlinked div. Every section — from the page header to the footer — must be a named Webflow component. This applies across all 21 pages.

**2. Use the 3-tier hierarchy before creating anything new.**

| Tier | Action | When to Use |
|---|---|---|
| 1 | **Edit property values** — change text, headings, CTAs, images like a content editor | Always start here. If properties cover the difference, stop. |
| 2 | **Copy the closest component, rename it, edit its styling variables** | When property editing cannot express the design difference. Copying preserves all other instances of the original. |
| 3 | **Build a net new component from scratch** | Last resort only. No existing component is close enough to copy from. |

**3. Page headers always use a `hero-` component.**
Every page opens with a component whose name starts with `hero-`. Use `hero-section-subpage` as the default for all interior pages. Only create a hero variation when the layout or content structure genuinely cannot be expressed through that component's properties or by copying and restyling it.

**4. Footers always use the `footer` component.**
All 21 pages share the single `footer` component. Never build footer markup inline on any page.

**5. Mobile variations use the `-mobile` suffix.**
When a component requires genuine structural restructuring at mobile breakpoints (not just responsive resizing, but a different layout), a mobile variation may be created (e.g., `process-section-mobile`). Always exhaust Webflow's built-in responsive breakpoint controls before taking this step.

---

### Component Naming Schema

Pattern: `[base]-[descriptor]`

| Part | Rule | Examples |
|---|---|---|
| base | Lowercase component category | `hero`, `process`, `services`, `footer`, `contact`, `cta`, `trust`, `blog`, `testimonial` |
| descriptor | Single adjective or page-type noun | `subpage`, `confirmation`, `city`, `vertical`, `minimal`, `featured` |
| separator | Hyphen only | `hero-section-subpage` — not `HeroSectionSubpage` or `hero_section_subpage` |

All names: lowercase, hyphen-separated, no underscores, no camelCase, no page URLs.

**Established reference name:** `hero-section-subpage` — this is the canonical example of correct naming. All new variation names must follow this exact pattern.

---

### When to Edit Properties vs. When to Create a Variation

| Scenario | Decision |
|---|---|
| Different headline or subtext copy | Edit property values |
| Different CTA label or button text | Edit property values |
| Different section label text | Edit property values |
| Different background color (dark/light toggle already exists) | Edit property values |
| Confirmation hero needs a checkmark icon + success layout | Copy `hero-section-subpage` → rename `hero-section-confirmation` → restyle |
| City page hero needs a dynamic city name slot | Copy `hero-section-subpage` → rename `hero-section-city` → restyle |
| Process section needs vertical stacked layout (not horizontal) | Copy → rename `process-section-vertical` → restyle |
| Contact section needs email + phone only, no form | Copy → rename `contact-section-minimal` → restyle |
| No existing component is structurally close | Build net new component from scratch |

**Decision rule:** Try properties first. If they fall short, copy + rename + restyle. Build new only when no existing component is a reasonable starting point.

---

### Component Inventory

Update this table whenever a new component or variation is confirmed in Webflow.

**Core Components (Phase A — 2026-04-02, unchanged):**

| Component Name | Description | Pages Used |
|---|---|---|
| `header` | Glassmorphism fixed nav, logo, links, hamburger, mobile overlay (typography refreshed 2026-04-19) | All pages |
| `footer` | 4-column dark footer, social icons, legal bottom bar (typography refreshed 2026-04-19) | All pages |
| `hero-section-subpage` [DEPRECATED — superseded by `hero-split` 2026-04-19] | Interior page hero: dark gradient, centered H1 + subtext | Interior pages until rebuild complete |

**Homepage Components — Revamp 2026-04-19 (new proof-first spine):**

| Component Name | Description | Pages Used |
|---|---|---|
| `hero-split` | Split hero, 2-field micro-form left, real photo right, no gradient overlay | Homepage, city pages (variant) |
| `builders-strip` | Compact horizontal contractor strip, 56px circle headshots, names + companies + cities | Homepage (under hero), potentially city pages |
| `process-steps-v2` | Redesigned 3-step process with massive Staatliches numerals, 1px grey connector | Homepage |
| `gallery-featured` | 3 featured builds, 16:10 photos, zero decoration, whole-card links to `/gallery` | Homepage |
| `coverage-map` | Custom-drawn WI SVG map + Staatliches city list | Homepage |
| `cta-final` | Full-width slate band, single Staatliches headline, single orange CTA | Homepage, all conversion-focused pages |
| `multi-step-form` | 3-step wizard on `/get-a-quote` with URL-param pre-fill and custom JS | `/get-a-quote` |

**Deprecated Components (retained for audit trail — do not use on new builds):**

| Component Name | Status | Replacement |
|---|---|---|
| `.section--hero` | DEPRECATED 2026-04-19 | `hero-split` |
| `.cedar-strip` | REMOVED 2026-04-19 | none — banned decoration |
| `.services-grid` / `.service-card` | DEPRECATED 2026-04-19 | removed from homepage; flat text list on interior pages |
| `.process-section` | DEPRECATED 2026-04-19 | `process-steps-v2` |
| `.testimonial-card` | DEPRECATED 2026-04-15 / 2026-04-19 | none — FTC compliance + banned border-left |
| `.city-card` | DEPRECATED 2026-04-19 | `coverage-map` |
| `.wait-card` | DEPRECATED 2026-04-19 | plain `.blog-card` or flat link list |
| `.section--accent` (sky-tint bg) | DEPRECATED 2026-04-19 | use `--slate` / `--white` / `--off-white` only |
| `.section--cedar` (cedar-light bg) | DEPRECATED 2026-04-19 | use `--slate` / `--white` / `--off-white` only |

**Still-valid variations (create when needed):**

| Component Name | Based On | Purpose |
|---|---|---|
| `hero-section-confirmation` | Copy of new `hero-split` (not the deprecated subpage hero) | Thank-you page: checkmark icon, success headline |
| `hero-section-city` | Copy of `hero-split` | City pages: dynamic city name slot |
| `contact-section-minimal` | Net new | Email + phone only, no form (thank-you, FAQ, about) |

---

### HTML Reference File Format

When writing HTML reference files in `/website/pages/`, wrap every section with Webflow component comment markers. This creates a 1-to-1 map between the HTML file and the Webflow component library.

```html
<!-- WEBFLOW COMPONENT: hero-section-subpage -->
<section class="hero-section-subpage">
  <!-- section content -->
</section>
<!-- /WEBFLOW COMPONENT: hero-section-subpage -->
```

Every section in every HTML reference file must have these markers. No section is left unidentified.

---

### Page Composition Pattern

Every page follows this structure:

```
[hero- component]       ← always first; always a hero- prefixed component
[content section 1]     ← named component from inventory
[content section 2]     ← named component from inventory
...
[cta-final]             ← end-of-scroll conversion section on conversion pages
[footer]                ← always last; always the footer component
```

The `cedar-strip` divider that used to sit between hero and first section is removed 2026-04-19 — do not reintroduce.

Content sections alternate between dark/light/off-white backgrounds per the Section Patterns table above. Background is controlled via the component's property values — not by creating new components for each background variant.
