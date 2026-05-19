---
name: Component Inventory
description: All confirmed Webflow components, naming rules, and the 3-tier build methodology
type: project
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-04-16
status: active
---

# Component Inventory — CWDB Webflow

Last updated: 2026-04-07

## Confirmed Components

| Component Name | Description | Used On |
|---|---|---|
| `header` | Glassmorphism fixed nav with logo, links, phone, orange CTA | All pages |
| `footer` | 4-column dark footer | All pages |
| `hero-section-subpage` | Interior page hero — default for all interior pages | Most interior pages |
| `hero-section-confirmation` | Thank-you page hero with check icon | /thank-you |
| `hero-section-quote` | Short focused hero with badge row | /get-a-quote |
| `cedar-strip` | 6px decorative wood-grain divider strip | Various pages |
| `form-section-quote` | 2-column form + trust/timeline right column | /get-a-quote |
| `cta-section-reassurance` | Off-white bottom bar with FAQ/contact links | /get-a-quote |
| `mobile-cta-bar` | Fixed orange mobile CTA bar | /get-a-quote |
| `process-section-vertical` | Vertical timeline of steps | /thank-you |
| `links-section-blog` | "While you wait" blog link cards | /thank-you |
| `contact-section-minimal` | Simple centered contact methods section | /thank-you |
| `faq-section-full` | Full 12-item FAQ accordion, CMS-bound to FAQs collection | /faq |
| `builders-grid` | Contractor profile card grid, CMS-bound to Our Builders | /our-builders |
| `gallery-grid-lightbox` | 3-col photo grid with native Webflow lightbox, CMS-bound | /gallery |
| `cta-section-contractor` | Dark CTA bar with contractor join copy + mailto link | /our-builders |
| `calculator-section` | Custom code embed for deck cost calculator JS | /cost-calculator |
| `material-table-section` | Static material cost comparison table | /cost-calculator |
| `blog-index-grid` | 2-col CMS-bound article card grid | /blog |
| `article-hero-section` | Dark hero with category + read time + CMS title | Blog article template |
| `article-body-section` | Centered rich text body column | Blog article template |

**Homepage components** — names to be verified in Webflow designer (Phase B components not fully documented)

## Naming Rules
- Format: `[base]-[descriptor]` — all lowercase, hyphen-separated, no camelCase, no underscores, no page URLs
- Canonical example: `hero-section-subpage`
- Mobile variants: add `-mobile` suffix only when Webflow breakpoints genuinely can't handle layout difference
- Page headers: always use a `hero-` component — never start a page with a raw section
- Footer: always uses `footer` component — never inline

## 3-Tier Build Hierarchy (always follow in order)

**Tier 1 — Edit property values**
Change text, headings, CTAs, images. Always try first. If properties cover the difference, stop here.

**Tier 2 — Copy closest component, rename, edit styling variables**
Use when property editing cannot express the design difference. Copying preserves all other instances of the original. Rename using `[base]-[descriptor]` schema.

**Tier 3 — Build net new component from scratch**
Last resort only. No existing component is close enough. Add new component name to this inventory immediately.

## HTML Reference File Convention
Every section in local HTML files must be wrapped:
```html
<!-- WEBFLOW COMPONENT: [component-name] -->
<section class="[component-name]"> ... </section>
<!-- /WEBFLOW COMPONENT: [component-name] -->
```
