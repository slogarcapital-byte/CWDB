---
type: page-revamp
page: Shared components, template, design system
targets: website/templates/base.html, website/components/*.md, website/design-system.md, website/pages/wausau-deck/index.html
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Shared Components, Template & Design System

These strings are reused across many pages. Fixing them here prevents the old claims from being re-seeded when a component or the base template is reused. None of these are the live Webflow page directly, but they are the copy source-of-truth the live components were built from, so they must match the revamp.

---

## `website/templates/base.html` (reference template)

### REPLACE: hero badge (line 432)
OLD:
&#10003; Licensed &amp; insured
NEW:
&#10003; Insured

### REPLACE: hero CTA (line 428)
OLD:
Get My Free Quote
NEW:
Get My Free Estimate

### REPLACE: value prop "Fast Quotes" body (line 449)
OLD:
A licensed builder will reach out within 48 hours of your request.
NEW:
We reach out to book your free walk-through, usually within one business day.

### REPLACE: value prop card 3 heading + body (lines 453-454)
OLD:
<h3>Licensed &amp; Insured</h3>
<p>Every contractor is vetted, licensed, and fully insured.</p>
NEW:
<h3>Fully Insured</h3>
<p>Our local crew carries $1M/$2M general liability insurance.</p>

### REPLACE: process step 2 title + body (lines 472-473)
OLD:
<div class="process__title">Get Matched With a Local Builder</div>
<p class="process__text">We connect you with a vetted contractor in your area.</p>
NEW:
<div class="process__title">We Come Out for a Free Walk-Through</div>
<p class="process__text">Our insured local crew measures and talks through your project.</p>

### REPLACE: process step 3 title + body (lines 477-478)
OLD:
<div class="process__title">Receive Your Free Quote</div>
<p class="process__text">Your builder reaches out within 48 hours with a quote.</p>
NEW:
<div class="process__title">Get Your Estimate</div>
<p class="process__text">We follow up with a clear, itemized estimate and a build date.</p>

### REPLACE: trust badge (line 535)
OLD:
<span class="trust-badge__text">Licensed &amp; Insured</span>
NEW:
<span class="trust-badge__text">Fully Insured</span>

### REMOVE: the entire testimonial placeholder section (lines 547-562)
REMOVE the "What Homeowners Say" heading and all three placeholder cards:
```
<h2 ...>What Homeowners Say</h2>
<div class="card-grid" ...>
  <div class="card"><p ...>"Placeholder — real testimonial coming soon."</p><p ...>— Homeowner, Wausau</p></div>
  <div class="card"><p ...>"Placeholder — real testimonial coming soon."</p><p ...>— Homeowner, Weston</p></div>
  <div class="card"><p ...>"Placeholder — real testimonial coming soon."</p><p ...>— Homeowner, Schofield</p></div>
</div>
```
The trust-badges row above it (Fully Insured / Free Quotes / Locally Owned / 5 Cities Served) stays. Do not seed placeholder review cards; they invite fabricated content and read as fake even when labeled "placeholder."

### REPLACE: embedded form subhead (line 582)
OLD:
Fill out the form and a local builder will reach out within 48 hours.
NEW:
Fill out the form and we'll reach out to book your free walk-through, usually within one business day.

---

## `website/components/hero-split.md`

### REPLACE: headline reference (line 21)
OLD:
48 HOURS.
NEW:
BUILT BY A LOCAL CREW.

### REPLACE: trust items (lines 33 and 88)
OLD:
✓ Licensed  ✓ Insured  ✓ Free
NEW:
✓ Insured  ✓ Local crew  ✓ Free walk-through

OLD (line 88 format):
Items: `<span class="tick">✓</span> Licensed · <span class="tick">✓</span> Insured · <span class="tick">✓</span> Free`
NEW:
Items: `<span class="tick">✓</span> Insured · <span class="tick">✓</span> Local crew · <span class="tick">✓</span> Free walk-through`

---

## `website/components/cta-final.md`

### REPLACE: visual reference (line 23)
OLD:
24-HOUR RESPONSE FROM A LOCAL BUILDER.
NEW:
BUILT BY A LOCAL CREW.

### REPLACE: homepage default (line 51)
OLD:
Text (homepage default): "Start your deck quote. 48-hour response from a local builder."
NEW:
Text (homepage default): "Ready to build? Get a free estimate from a local crew, usually within one business day."

### REPLACE: city-page override (line 77)
OLD:
City pages: headline override → "Start your deck quote. 48-hour response from a local [Wausau / Schofield / Weston / Mosinee / Merrill] builder."
NEW:
City pages: headline override → "Ready to build in [Wausau / Schofield / Weston / Mosinee / Merrill]? Get a free estimate from a local crew."

### REPLACE: blog override (line 78)
OLD:
Blog articles: headline override → "Ready for a deck quote? We'll match you with a local builder within 48 hours."
NEW:
Blog articles: headline override → "Ready to build? Get a free estimate from a local crew, usually within one business day."

### REPLACE: about override (line 79)
OLD:
About page: headline override → "Ready to work with a local builder? Get your deck quote within 48 hours."
NEW:
About page: headline override → "Ready to build with a local crew? Get your free estimate, usually within one business day."

---

## `website/components/process-steps.md`

### REPLACE: step 3 reference (line 26)
OLD:
out within 48h
NEW:
free walk-through

(Adjust the surrounding ASCII step labels so step 2 reads "we come out" and step 3 reads "get your estimate," matching the homepage process rewrite in `home.md`.)

---

## `website/design-system.md`

### REPLACE: badge sample (line 311)
OLD:
Badge:        "✓ Free · ✓ No Obligation · ✓ Licensed & Insured"
NEW:
Badge:        "✓ Free · ✓ No Obligation · ✓ Insured"

### REPLACE: hero-variant badges (line 412)
OLD:
Badges (hero variant): `✓ Licensed  ✓ Insured  ✓ Free`
NEW:
Badges (hero variant): `✓ Insured  ✓ Local crew  ✓ Free`

### REPLACE: full-variant badges (line 413)
OLD:
Badges (full variant): Licensed Contractors | Insured & Bonded | Free Quotes — No Obligation | Local Wisconsin Builders
NEW:
Badges (full variant): Insured Local Crew | Free Estimates, No Obligation | Central Wisconsin Only | Built to Code

Note: "Insured & Bonded" specifically must go. "Bonded" is not true, and the em dash in the old string violates the project's no-em-dash rule anyway.

---

## FLAG: `website/pages/wausau-deck/index.html` (legacy standalone page)

This older standalone file still carries every old claim: "Hear back within 24 hours" (line 39), "Licensed & Insured Contractors" (line 55), "within 24 hours" (line 63), and two `[TESTIMONIAL 1]` / `[TESTIMONIAL 2]` placeholders with `[NAME], Wausau` / `[NAME], Schofield` (lines 47-49).

Web-dev: confirm whether this page is still routed. If it is a dead/legacy file superseded by `/wausau` (the CMS city page), delete it. If it is live anywhere, apply the same fixes as `city-wausau.md`: drop "Licensed," change "24 hours" to "usually within one business day," remove the testimonial placeholders, and switch matching language to "we build."

---

## FLAG: homepage mockups (design references, not live)

`website/pages/homepage/design-mockup.html` and `mobile-mockup.html` contain fabricated testimonials ("We got three quotes within a day...", "Our contractor showed up on time...") and "Licensed / Insured & Bonded" badges. These are static design mockups, not the live site. They do not need copy edits for compliance, but if they are ever used as a visual reference for a rebuild, note that their copy is pre-revamp and must not be copied forward. Lowest priority.
