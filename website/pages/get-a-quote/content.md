---
type: page
page-url: /get-a-quote
tags:
  - type/page
  - dept/website
aliases: []
created: 2026-03-29
updated: 2026-04-19
status: active
page: Get a Quote
url: /get-a-quote
seo_title: "Get a Free Deck Quote | Central Wisconsin Deck Builders"
meta_description: "Get a deck quote within 48 hours. 3-step form, vetted local builders, no cost. Serving Wausau, Schofield, Weston, Mosinee, Merrill."
og_image: /assets/images/og-get-a-quote.jpg
canonical: https://cwdeckbuilders.com/get-a-quote
---

# Get a Quote — cwdeckbuilders.com/get-a-quote

**Revamped 2026-04-19** per design brief `/_plans/web-dev-agent-let-s-work-stateless-scroll.md`. Replaces single-page form with 3-step wizard and hero-to-form pre-fill handoff.

---

## Page Layout

Two-column grid (existing `.quote-layout` still applies):
- **Left column:** 3-step wizard (`multi-step-form` component)
- **Right column:** trust card + "What Happens Next?" card, sticky at `top: 100px`

On mobile (<960px), wizard stacks above right-column content.

---

## Hero Section

Uses a compact `hero-section-quote` variant (existing component — keep as-is for now, typography auto-refreshes with new `--font-body` / `--font-heading`).

**Headline:**
Get your deck quote within 48 hours.

**Subtext:**
3 quick steps. No phone calls. A vetted local builder will reach out within 48 hours to schedule a site visit.

---

## Multi-Step Form — `multi-step-form`

**Progress indicator** (top of form area): 3 horizontal dashes.
- Active dash: `--orange`, 3px tall, full width of its column
- Inactive dash: `--grey`, 3px tall, 50% opacity

Dash fills in as the user advances. Also serves as visual affordance for the "Step N of 3" pattern.

### Step 1 of 3 — Where is the deck going?

**Fields (both required):**
- **Zip code** — 5 digits, numeric input, pre-fills from URL param `?zip=XXXXX` if present
- **Phone number** — tel input, format (XXX) XXX-XXXX, pre-fills from URL param `?phone=XXXXXXXXXX` if present

**CTA:**
Next →

No Back link on step 1.

---

### Step 2 of 3 — Tell us about the project.

**Fields (all required):**
- **Project type** — select
  - New deck build
  - Deck replacement
  - Deck repair
  - Deck addition / expansion
  - Pergola
  - Screen porch
  - Not sure yet
- **Property address** — text, "Street address, City, WI ZIP"
- **Do you own this property?** — select (Yes / No)

**CTAs:**
← Back · Next →

---

### Step 3 of 3 — When and how much?

**Fields (all required):**
- **Budget range** — select
  - Under $5,000
  - $5,000 – $10,000
  - $10,000 – $20,000
  - $20,000 – $40,000
  - $40,000+
  - Not sure
- **Timeline** — select
  - As soon as possible
  - Within 1–3 months
  - 3–6 months
  - Just planning ahead
- **Project details** — textarea (optional), placeholder: "Deck size, materials, special features, anything else we should know."

**CTAs:**
← Back · Submit →

---

## URL-Parameter Pre-Fill Behavior

When a user arrives from the homepage hero micro-form, the URL is:
```
/get-a-quote?zip=54401&phone=7155551234
```

On page load, JS:
1. Parses `?zip=` and `?phone=` from `window.location.search`
2. If present, fills the zip and phone inputs on step 1
3. Skips the user directly to step 2 IF both fields are valid (zip = 5 digits, phone = 10 digits). Otherwise stays on step 1 with fields pre-populated.

Full JS spec lives in `/website/components/multi-step-form.md`.

---

## Submission Flow

On final Submit (end of step 3):
1. Webflow native form action fires the existing Make webhook URL (`hook 2183206`)
2. GTM `lead_submitted` event pushes to dataLayer → GA4 Lead event, Meta Lead, Nextdoor Lead, Google Ads Conversion all fire
3. Redirect to `/thank-you`

**Note on Make scenario (2026-04-19):** The Make scenario `CWDB Lead Routing — v1` (4792854) remains parked. The webhook still captures and stores the lead, but contractor notification is manual by Jim's SMS until reactivation triggers fire. See `/agents/agent-memory/cwdb-ceo-operator/pivot-2026-04-19.md`.

---

## Right Column — Sticky

Same 2-card stack as before (mini testimonial removed with testimonials in general).

### Trust Card — `.trust-card`
Plain-text trust list on white background. No sky icons, no pills.

- Licensed & insured builders
- Free quote, no obligation
- Fast 48-hour response
- Local Central Wisconsin team

### What Happens Next — `.next-card`
Dark Timber Slate card with 3 timeline items. Keep existing component; typography auto-refreshes.

**Step 1 — We review your project** (Within a few hours)
Our team reviews your project details so we can match you with the right builder.

**Step 2 — You get matched** (Within 48 hours)
A vetted local contractor in your area reaches out directly.

**Step 3 — You decide** (On your schedule)
Review the quote, ask questions, move forward only when you're ready.

---

## Bottom Reassurance

Below the form/right-column grid, full-width off-white band with a single line:

Still have questions? Check our [FAQ](/faq) or email us at [info@cwdeckbuilders.com](mailto:info@cwdeckbuilders.com).
