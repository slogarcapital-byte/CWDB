---
type: page
page-url: /
tags:
  - type/page
  - dept/website
aliases: []
created: 2026-03-29
updated: 2026-04-19
status: active
page: Homepage
url: /
seo_title: "Deck Builders in Central Wisconsin | Free Quotes — CWDB"
meta_description: "Get a deck quote within 48 hours. Vetted builders in Wausau, Schofield, Weston, Mosinee, and Merrill. Enter your zip to get matched."
og_image: /assets/images/og-homepage.jpg
canonical: https://cwdeckbuilders.com/
---

# Homepage — cwdeckbuilders.com

**Revamped 2026-04-19** per design brief `/_plans/web-dev-agent-let-s-work-stateless-scroll.md`. Proof-first spine. Services grid removed. Testimonials remain removed (FTC compliance, 2026-04-15). Single source of truth for homepage copy.

---

## Section Order (Proof-First Spine)

1. Hero (split)
2. Builders strip
3. Process (3 steps)
4. Gallery (3 featured builds)
5. Coverage map
6. FAQ (5 top items, CMS-bound)
7. Final CTA
8. Footer

---

## 1. Hero — `hero-split`

**Layout:** Two-column CSS grid, 58% left / 42% right. Stacks below 960px.

**Left column (on `--slate` background):**

**Headline:**
Get a quote within 48 hours.

**Subtext:**
Vetted builders in Wausau, Schofield, Weston, Mosinee, and Merrill. Enter your zip and we'll match you in hours.

**Micro-form (2 required fields):**
- Zip code — 5 digits, numeric
- Phone — (XXX) XXX-XXXX

**Primary CTA:**
Start My Quote →

On submit: navigate to `/get-a-quote?zip={{zip}}&phone={{phone}}`. The multi-step form on that page pre-fills step 1 from URL params.

**Trust row (plain text, no icons):**
✓ Licensed · ✓ Insured · ✓ Free

**Right column:**
Real photo, full-height, no gradient overlay. Candidate photos per plan: a Wausau cedar-deck golden-hour shot OR the JGC-jobsite-blueprint action shot at `/branding/headshots/jgc-jobsite-blueprint-review.png`. Jim confirms during Phase 2 step 5.

---

## 2. Builders Strip — `builders-strip`

Sits immediately under the hero, still on `--slate` (with 40% opacity tint overlay per component spec). Horizontal compact strip, full-width container, 48px vertical padding.

**Label (uppercase, Public Sans 13px, orange):**
YOUR LOCAL BUILDERS:

**Row 1:**
(●) Ben Barton — Wausau, WI — Barton Builders LLC

**Row 2:**
(●) John Garcia — Merrill, WI — John Garcia Construction, LLC

**Right-aligned link:**
Meet the team →  ← `/our-builders`

**Headshots:** Circular 56px. Sourced from `/branding/headshots/ben-barton-headshot.jpg` and `/branding/headshots/john-headshot.png`. Empty-state fallback: initials badge (`BB`, `JG`) in `--orange` circles.

---

## 3. Process — `process-steps-v2`

Dark section on `--slate`. 3 columns desktop, vertical stack mobile.

**Section label:**
HOW IT WORKS

**Section heading:**
Three steps. One quote.

### Step 01 — Tell us about your deck
Zip, phone, project basics. Takes 60 seconds.

### Step 02 — Get matched with a local builder
We hand-match based on city and project type.

### Step 03 — Get your quote
Builder reaches out within 48 hours to schedule a site visit.

Numerals (`01` / `02` / `03`): Staatliches 120px desktop / 72px mobile, in `--orange`.
Connector between steps: single 1px `--grey` horizontal line at 50% vertical position. No cedar, no gradient.

---

## 4. Gallery — `gallery-featured`

Light section. 3-column row desktop, 1-column mobile. Photos at 16:10, no rounded corners, no shadow, no border.

**Section heading:**
Recent Central Wisconsin builds

**Three featured builds (Jim selects during Phase 2, step 7):**

**Build 1 — placeholder until Jim picks:**
- Project type: Cedar Deck
- Specs: 12×16 · Weston
- Built by: Barton

**Build 2 — placeholder until Jim picks:**
- Project type: Screen Porch
- Specs: 14×20 · Wausau
- Built by: J. Garcia Construction

**Build 3 — placeholder until Jim picks:**
- Project type: Pergola
- Specs: 10×10 · Mosinee
- Built by: Barton

**Caption template:**
`[PROJECT TYPE] · [dimensions] · [city] · Built by [Barton / J. Garcia Construction]`

Whole card clickable → `/gallery`.

**Empty state (if no photos yet):** Full-width `--slate` band with headline "Recent builds posted soon." + Start-Quote CTA. No skeleton / placeholder cards.

---

## 5. Coverage — `coverage-map`

Off-white section. 2-column layout desktop (map left, city list right), stacks mobile.

**Section heading:**
We serve Central Wisconsin

**Left column:**
Custom-drawn SVG map of Marathon + Lincoln counties. ViewBox approx 320×280. `--slate` strokes, no fills. 5 orange pins at Wausau / Schofield / Weston / Mosinee / Merrill.

**Right column (each item links to its city page):**
- WAUSAU →
- SCHOFIELD →
- WESTON →
- MOSINEE →
- MERRILL →

Each city: Staatliches 32px uppercase, hover → orange underline.

---

## 6. FAQ — `faq-section-home`

Light section. CMS-bound to the existing FAQs collection (12 items total — show top 5 on homepage, sorted by priority field).

**Section heading:**
Common questions

**CTA below accordion:**
See all FAQs →  ← `/faq`

---

## 7. Final CTA — `cta-final`

Full-width `--slate` band. 128px vertical padding desktop / 80px mobile. Centered content.

**Headline (white, Staatliches 56px desktop / 36px mobile):**
Start your deck quote. 48-hour response from a local builder.

**Primary CTA:**
Start My Quote →  ← `/get-a-quote`

No trust badges here — trust was established by the builders-strip, gallery, and coverage-map earlier in the scroll.

---

## 8. Footer

Uses existing `footer` component unchanged (typography auto-refreshes with new `--font-body` / `--font-heading` tokens). Content unchanged:

**Column 1 — Brand:**
Logo + "Fast Quotes. Trusted Builders." tagline + social icons.

**Column 2 — Quick Links:**
Home · Get a Quote · Our Builders · Gallery · About · FAQ · Blog

**Column 3 — Service Areas:**
Wausau · Schofield · Weston · Mosinee · Merrill

**Column 4 — Contact:**
info@cwdeckbuilders.com · (715) 544-7941 · Hours TBD

**Bottom bar:**
© 2026 Central Wisconsin Deck Builders. All rights reserved. [Privacy Policy](/privacy) · [Terms of Service](/terms)

---

## Copy Rules (enforce site-wide)

- Primary CTA always reads **"Start My Quote →"** — never "Get Your Free Quote", never "Request a Quote", never "Free Estimate"
- Subtext never uses "no cost, no pressure, no obligation" filler
- "48-hour response" is the concrete promise — not "fast" or "quick"
- Brand voice per `/business-context/brand-discovery/brand-voice-positioning.md` — Milwaukee Tool 4-5 zone: trade-credible, specific, regionally-rooted, not salesy
