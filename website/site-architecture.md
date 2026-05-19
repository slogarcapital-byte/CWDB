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

# CWDB Site Architecture — cwdeckbuilders.com

Reference document for the full site structure, navigation, SEO strategy, and analytics setup.

**Last updated 2026-04-19:** Homepage section spine rewritten to proof-first funnel per design brief `/_plans/web-dev-agent-let-s-work-stateless-scroll.md`. Services grid removed from homepage (services content still appears on interior pages). City-card grid replaced by `coverage-map` band. New components added: `hero-split`, `process-steps-v2`, `gallery-featured`, `builders-strip`, `coverage-map`, `cta-final`, `multi-step-form`.

---

## Homepage Section Spine (Proof-First)

The homepage scroll order as of 2026-04-19:

```
1. header
2. hero-split                  ← 2-field micro-form (zip + phone) in left column, photo right
3. builders-strip              ← compact contractor proof strip immediately under hero
4. process-steps-v2            ← 3 massive Staatliches numerals + flat connector
5. gallery-featured            ← 3 featured builds, 16:10 photos, zero decoration
6. coverage-map                ← custom WI SVG + Staatliches city list, replaces city-card grid
7. faq-section-home            ← 5 top FAQs from the FAQs CMS collection
8. cta-final                   ← full-width slate band, single headline + orange CTA
9. footer
```

**Removed from homepage 2026-04-19:** services grid (Custom Decks / Pergolas / Screened Porches / Renovations card row), cost-calculator teaser section, testimonials section (already removed 2026-04-15 per FTC compliance), separate "embedded form" section (replaced by hero-split micro-form + CTA-final conversion path). Blog preview is also deprioritized — moved off the homepage.

**Interior pages still carry services content:** City pages, About, and FAQ continue to describe services (custom decks, pergolas, screened porches, renovations) but as flat body-text lists, not a card grid. The full services taxonomy survives — it just stops being the homepage visual anchor.

---

## Sitemap (21 Pages)

```
cwdeckbuilders.com/
├── /                          Homepage (primary landing + conversion)
├── /get-a-quote               Dedicated quote form page
├── /our-builders              Contractor profiles
├── /gallery                   Project photo gallery
├── /about                     About CWDB network story
├── /faq                       Frequently asked questions
├── /cost-calculator           Interactive deck cost estimator
├── /thank-you                 Post-form confirmation (noindex)
│
├── /wausau                    City — Wausau
├── /schofield                 City — Schofield
├── /weston                    City — Weston
├── /mosinee                   City — Mosinee
├── /merrill                   City — Merrill
│
├── /blog                      Blog index
├── /blog/deck-cost-wisconsin  Cost guide article
├── /blog/composite-vs-wood    Materials comparison article
├── /blog/deck-permits-wausau  Permits & regulations article
├── /blog/best-time-build-deck Seasonal timing article
│
├── /privacy                   Privacy policy (noindex)
└── /terms                     Terms of service (noindex)
```

---

## Navigation Structure

### Desktop Header (sticky)

```
[LOGO]     Our Builders | Resources ▼ | About     [GET A QUOTE]  (715) XXX-XXXX
```

**Resources Dropdown:**
- Blog → /blog
- FAQ → /faq
- Cost Calculator → /cost-calculator
- Deck Permits Guide → /blog/deck-permits-wausau

### Mobile Header

```
[LOGO]     [☎ phone icon]     [☰ hamburger]
```

### Sticky Mobile Bottom Bar

```
[ GET A FREE QUOTE          ☎ ]
```

Full-width orange bar, fixed to bottom on all mobile pages.

### Footer Links

Row 1: Wausau | Schofield | Weston | Mosinee | Merrill
Row 2: Get a Quote | Our Builders | Blog | FAQ | Cost Calculator | About
Row 3: Privacy | Terms
Row 4: Facebook | Instagram | Nextdoor

---

## Internal Linking Strategy

Every page links to `/get-a-quote` via at least one CTA button.

| From Page | Links To |
|---|---|
| Homepage | /get-a-quote, /our-builders, /gallery, /cost-calculator, /blog, all 5 city pages |
| City pages | /get-a-quote (embedded form + CTA), /blog/deck-permits-wausau, /gallery |
| Our Builders | /get-a-quote (per contractor CTA) |
| Gallery | /get-a-quote |
| About | /get-a-quote, /our-builders |
| FAQ | /get-a-quote, /cost-calculator, /blog articles |
| Cost Calculator | /get-a-quote (post-calculation CTA) |
| Blog articles | /get-a-quote (inline + bottom CTAs), /cost-calculator, other articles |
| Thank-you | /blog articles (keep engagement) |

---

## Page Priority & SEO Targets

| Page | Priority | Primary Keywords |
|---|---|---|
| / | Highest | deck builders central wisconsin, deck quote wisconsin |
| /wausau | High | deck builders wausau wi, deck contractor wausau |
| /schofield | High | deck builders schofield wi |
| /weston | High | deck builders weston wi |
| /mosinee | High | deck builders mosinee wi |
| /merrill | High | deck builders merrill wi |
| /blog/deck-cost-wisconsin | High | how much does a deck cost wisconsin |
| /blog/composite-vs-wood | Medium | composite vs wood deck wisconsin |
| /blog/deck-permits-wausau | Medium | deck permit wausau wi |
| /blog/best-time-build-deck | Medium | best time to build deck wisconsin |
| /cost-calculator | Medium | deck cost calculator wisconsin |
| /faq | Medium | deck builders faq, deck questions |
| /our-builders | Medium | local deck contractors central wi |
| /gallery | Low | deck projects central wisconsin |
| /about | Low | about central wisconsin deck builders |
| /get-a-quote | Low (ad landing) | free deck quote |
| /thank-you | None (noindex) | — |
| /privacy | None (noindex) | — |
| /terms | None (noindex) | — |

---

## SEO Per-Page Requirements

Every indexable page gets:

1. **Title tag** — under 60 characters, primary keyword + brand
2. **Meta description** — under 155 characters, includes CTA language
3. **Canonical URL** — self-referencing
4. **Open Graph tags** — og:title, og:description, og:image, og:url
5. **H1 → H2 → H3 hierarchy** — one H1 per page
6. **Alt text** on all images

### Structured Data (JSON-LD)

| Page Type | Schema |
|---|---|
| Homepage | LocalBusiness + WebSite |
| City pages | LocalBusiness + Service (per city) |
| Blog articles | Article (headline, author, datePublished, image) |
| FAQ | FAQPage (renders rich snippets in Google) |
| Cost calculator | WebApplication |
| Our Builders | Organization + Person (per contractor) |

### LocalBusiness Schema (Homepage + City Pages)

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Central Wisconsin Deck Builders",
  "url": "https://cwdeckbuilders.com",
  "telephone": "+1-715-XXX-XXXX",
  "description": "Free deck quotes from trusted local contractors in Central Wisconsin.",
  "areaServed": [
    {"@type": "City", "name": "Wausau", "containedInPlace": {"@type": "State", "name": "Wisconsin"}},
    {"@type": "City", "name": "Schofield", "containedInPlace": {"@type": "State", "name": "Wisconsin"}},
    {"@type": "City", "name": "Weston", "containedInPlace": {"@type": "State", "name": "Wisconsin"}},
    {"@type": "City", "name": "Mosinee", "containedInPlace": {"@type": "State", "name": "Wisconsin"}},
    {"@type": "City", "name": "Merrill", "containedInPlace": {"@type": "State", "name": "Wisconsin"}}
  ],
  "priceRange": "Free quotes",
  "serviceType": "Deck Building",
  "image": "https://cwdeckbuilders.com/images/og-image.jpg"
}
```

---

## Analytics & Tracking Setup

### Tools

| Tool | Purpose | Install Method |
|---|---|---|
| Google Tag Manager (GTM) | Tag management container | Webflow `<head>` + `<body>` embed |
| Google Analytics 4 (GA4) | Traffic & behavior | GTM tag |
| Meta Pixel | Facebook/Instagram conversion tracking | GTM tag |
| Nextdoor Pixel | Nextdoor ad conversion tracking | GTM tag |
| Google Ads Conversion | Google Ads ROAS tracking | GTM tag |
| Microsoft Clarity | Heatmaps, session recordings, scroll depth | GTM tag |

### GTM Container Setup

All tags fire through GTM. No direct script embeds except GTM itself.

### Conversion Events

| Event | Trigger | Platforms |
|---|---|---|
| `form_submit` | Webflow form submission | GA4, Google Ads, Meta, Nextdoor |
| `cta_click` | Any CTA button click | GA4 |
| `phone_click` | Click-to-call tap | GA4, Google Ads |
| `calculator_use` | Cost calculator "Calculate" click | GA4 |
| `blog_read` | Scroll depth > 50% on blog articles | GA4 |
| `page_view` | Standard page view | GA4 (automatic) |

### GA4 Custom Dimensions

- `page_type`: homepage, city, blog, form, calculator, info
- `city`: wausau, schofield, weston, mosinee, merrill (on city pages)
- `traffic_source`: google_ads, facebook, nextdoor, organic, direct

---

## Form Submission Flow

```
Visitor fills form on any page
        ↓
Webflow native form captures data
        ↓
Webflow webhook fires to Make
        ↓
Make scenario:
  1. Receive webhook payload
  2. Score lead (scoring-rules.json)
  3. If qualified:
     a. Send contractor email with lead details
     b. Send contractor SMS alert
     c. Create HubSpot deal
  4. If disqualified:
     a. Log reason
     b. Notify admin
        ↓
Visitor redirected to /thank-you
```

### Webflow Form → Make Webhook

Webflow form action submits to a Make webhook URL. Fields map 1:1 with the 9 form fields defined in the design system.

---

## Domain & Hosting

- **Domain:** cwdeckbuilders.com (registered on GoDaddy)
- **DNS:** Point to Webflow via CNAME or A record
- **SSL:** Automatic via Webflow
- **CDN:** Webflow's built-in CDN (Fastly/Cloudflare)
- **Hosting:** [[Webflow]] Starter plan (~$14/mo)

---

## Build Sequence

| Phase | Pages | Priority |
|---|---|---|
| A | Design system + global components (header, footer, form, trust badges) | Foundation |
| B | Homepage, /get-a-quote, /thank-you | Core conversion |
| C | /wausau, /schofield, /weston, /mosinee, /merrill | City SEO |
| D | /our-builders, /about, /gallery, /faq | Trust & authority |
| E | /cost-calculator, /blog + 4 articles | Interactive + content |
| F | SEO tags, structured data, GTM, all pixels | Measurement |
| G | Mobile QA, sticky CTA, click-to-call, speed audit | Polish |
