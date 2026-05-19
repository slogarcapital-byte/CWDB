---
type: component-spec
component-name: cta-final
status: spec
created: 2026-04-19
---

# cta-final

## Purpose

The end-of-scroll conversion section. A single-purpose band that gives a user who has scrolled the full homepage (seen the hero, the builders, the process, the gallery, the coverage, the FAQ) one last clean path to the quote form. No trust badges, no secondary links, no FAQ teaser — trust was established earlier in the scroll; this section exists solely to convert.

Reuse this component on other conversion-adjacent pages (city pages, blog articles, About page) as the second-to-last section before the footer.

## Layout

```
┌─────────────────────────────────────────────────┐
│                                                 │
│                                                 │
│    START YOUR DECK QUOTE.                       │
│    24-HOUR RESPONSE FROM A LOCAL BUILDER.       │
│                                                 │
│    [ START MY QUOTE → ]                         │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

Full-width band. Centered content. Generous vertical breathing room — this is the "arrival" moment at the end of the scroll.

## Spec

**Section:**
- Background: `var(--slate)` (full-width, edge-to-edge)
- Padding: `128px 0` desktop / `80px 0` mobile
- Container: standard `.container`, content centered via `text-align: center` and `align-items: center` on the flex wrapper

**Inner wrapper:**
- Display: flex, flex-direction: column, align-items: center, gap: 32px
- Max-width: 720px, centered via `margin: 0 auto`

**Headline:**
- Font: Staatliches 400
- Size: 56px desktop / 36px mobile
- Color: `#ffffff`
- Line-height: 1.05
- Letter-spacing: 0.5px
- Uppercase
- Text (homepage default): "Start your deck quote. 48-hour response from a local builder."
  - Can be overridden per page via a Webflow component property

**Primary CTA:**
- `.btn--primary` (inherits from design-system)
- Label: "Start My Quote →"
- Link: `/get-a-quote`

**Nothing else.**
- No trust badges
- No secondary link
- No micro-copy below the button
- No decorative lines
- No graphic element behind the text

## States

**Default:** as specified.

**Hover (CTA):** inherits `.btn--primary` hover (background → `var(--orange-hover)`).

**Focus (CTA):** 2px orange outline at 3px offset.

**Empty / disabled:** this component never renders empty — the headline and CTA are both required properties. If headline is missing during build, fall back to the homepage default copy above.

**Page variations:**
- City pages: headline override → "Start your deck quote. 48-hour response from a local [Wausau / Schofield / Weston / Mosinee / Merrill] builder."
- Blog articles: headline override → "Ready for a deck quote? We'll match you with a local builder within 48 hours."
- About page: headline override → "Ready to work with a local builder? Get your deck quote within 48 hours."

## Webflow implementation notes

- Build as a net new component `cta-final`.
- Headline is a component property (editable per page).
- CTA label and href are also component properties — default to "Start My Quote →" and `/get-a-quote`.
- Use Webflow's Component Properties panel to expose `headline` and `cta_label` as editable text fields.
- No CMS binding — this is a static component that gets reused with property overrides.
- No background image, no gradient overlay, no decorative element. The slate is the design.
- Vertical padding must stay generous (128px desktop) — compressing this to match the default section padding breaks the "arrival" feeling and makes the CTA read as another section instead of the end of the page.

## Related files

- `/website/design-system.md` — color + typography + button tokens
- `/website/pages/homepage/content.md` — default copy source
- `/website/components/multi-step-form.md` — the page this CTA leads to
