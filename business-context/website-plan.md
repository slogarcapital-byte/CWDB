---
type: reference
tags:
  - type/reference
  - dept/website
  - phase/1-validation
created: 2026-03-29
updated: 2026-04-16
status: active
---

# CWDB Full Website Plan — Replacing Phase 1 Step 3B

## Context

Phase 1 step 3B originally called for a single Webflow landing page with an embedded Tally form. The scope has expanded to a **complete website** for [[Central Wisconsin Deck Builders LLC|Central Wisconsin Deck Builders]] that serves as both a high-converting lead generation machine AND a local authority site for organic SEO growth. This replaces the single-page approach with a multi-page, conversion-optimized, mobile-first website built in [[Webflow]].

**Key tech stack change:** Webflow native forms replace Tally (confirmed 2026-03-29). The existing Tally form (ID: 81GbEO) is superseded.

---

## Build Decomposition

The 21-page website is broken into 7 independent sub-projects, each with its own spec → plan → build cycle:

| Sub-project | Pages / Work |
|---|---|
| **A. Foundation** | Design variables, global styles, header + footer components |
| **B. Core conversion pages** | Homepage, /get-a-quote, /thank-you |
| **C. City pages** | /wausau, /schofield, /weston, /mosinee, /merrill |
| **D. Supporting pages** | /about, /faq, /gallery, /our-builders, /cost-calculator |
| **E. Blog** | CMS collection setup, blog index, 4 article pages |
| **F. Legal pages** | /privacy, /terms |
| **G. SEO & analytics** | Page metadata, JSON-LD schema, tracking setup |

Sub-projects flow sequentially — Foundation must be complete before any page work begins. Each page sub-project (B–F) can be executed independently once the foundation is in place.

---

## Requirements Summary (from interview)

| Requirement | Decision |
|---|---|
| **Site purpose** | Lead gen + local authority (organic SEO + paid traffic) |
| **Brand positioning** | Transparent network of deck builders ("We connect you with vetted local contractors") |
| **Brand feel** | Team/network — professional, human, not founder-led or corporate |
| **Visual direction** | Dark & bold (Timber Slate dominant), Wisconsin Sky Blue woven in to avoid Home Depot/Halloween feel |
| **Navigation** | Minimal — Our Builders \| Resources \| About + orange "Get a Quote" mega CTA + phone in header |
| **Homepage hero** | Full-bleed dark hero with faded deck photo background, bold white headline, orange CTA |
| **Form tool** | [[Webflow]] native form (not Tally), all 9 fields retained |
| **Form placement** | Embedded on homepage + city pages, CTA buttons linking to /get-a-quote on other pages |
| **Phone number** | Prominent in header, click-to-call on mobile |
| **City pages** | All 5 cities at launch, fully unique content per city |
| **Contractors page** | Partner profiles: photo, bio, service area, years in business, licensing |
| **Gallery** | Stock deck photos initially, replace with real projects later |
| **Blog** | 4 articles at launch: cost guide, materials comparison, permits, seasonal timing |
| **FAQ page** | Common homeowner questions |
| **About page** | Team/network story, mission, why CWDB exists |
| **Interactive elements** | Deck cost calculator + process timeline visualization |
| **Thank-you page** | Confirmation + next steps timeline + push to blog content |
| **Footer** | Clean minimal: logo, phone, email, key links, copyright |
| **Social media** | Facebook + Instagram + Nextdoor (links in footer) |
| **Social proof** | Trust badges at launch + placeholder sections for homeowner testimonials |
| **SEO** | Full from day one: meta tags, LocalBusiness schema, Open Graph, XML sitemap |
| **Analytics** | Full stack: GA4, GTM, Meta Pixel, Nextdoor pixel, Google Ads conversion, Hotjar/Clarity heatmaps |
| **Mobile** | Mobile-first design, sticky CTA bar, click-to-call always visible |
| **Timeline** | Quality first — get the plan right, then build |

---

## Design System

### Color Palette

| Role | Name | Hex | Usage |
|---|---|---|---|
| Primary Accent | Crafted Orange | `#e54c00` | CTAs, highlights, hover states, active elements |
| Dark Base | Timber Slate | `#323434` | Backgrounds (hero, footer, dark sections), primary text on light |
| Secondary Text | Builders Grey | `#646760` | Subheadings, borders, secondary copy, captions |
| Sky Accent | Wisconsin Sky Blue | `#83b2cf` | Secondary accents, icons, decorative elements, section dividers |
| Light Background | White/Off-White | `#ffffff` / `#f8f8f6` | Body content sections, form backgrounds, cards |

**Key design rule:** Alternate between dark (Timber Slate) and light (white) sections. Use Wisconsin Sky Blue as the third color to break up orange/charcoal and give outdoor Wisconsin feel. Orange is ONLY for CTAs and key highlights — never a background fill.

### Typography (Webflow Google Fonts)

| Role | Font | Weight | Style |
|---|---|---|---|
| Headlines (H1-H3) | Barlow Condensed | Bold (700) | Uppercase, tight tracking |
| Body / Paragraphs | Inter | Regular (400) / Medium (500) | Normal case, 1.6 line height |
| Labels / Tags / Buttons | Inter | Semi-Bold (600) | Uppercase, wide tracking, small size |

### Imagery Direction

- **Hero backgrounds:** Dark-toned deck photography (faded/overlaid with Timber Slate gradient for text readability)
- **Gallery:** Well-lit outdoor deck photos in Wisconsin-like settings (cedar, pine surroundings, lake country)
- **Process/trust sections:** Clean iconography in Wisconsin Sky Blue + Crafted Orange
- **No generic stock:** Photos must feel regional — wood grain, Northwoods settings, real-looking projects

### Component Patterns

- **CTA Buttons:** Crafted Orange background, white text, rounded corners (4-6px), hover → darken 10%
- **Secondary Buttons:** Transparent with Crafted Orange border, orange text, hover → fill orange
- **Cards:** White background, subtle shadow, Builders Grey border-bottom accent
- **Section Dividers:** Wisconsin Sky Blue thin line or subtle angled/diagonal section breaks
- **Trust Badges:** Icon (Sky Blue) + text (Timber Slate) in horizontal row

---

## Site Architecture

### Sitemap

```
cwdeckbuilders.com/
├── /                          Homepage
├── /get-a-quote               Dedicated quote form page
├── /our-builders              Contractor profiles
├── /gallery                   Project photo gallery
├── /about                     About CWDB — the network story
├── /faq                       Frequently asked questions
├── /cost-calculator           Interactive deck cost estimator
├── /thank-you                 Post-form confirmation page
│
├── /wausau                    City page — Wausau
├── /schofield                 City page — Schofield
├── /weston                    City page — Weston
├── /mosinee                   City page — Mosinee
├── /merrill                   City page — Merrill
│
├── /blog                      Blog index
├── /blog/deck-cost-wisconsin  Article — cost guide
├── /blog/composite-vs-wood    Article — materials comparison
├── /blog/deck-permits-wausau  Article — permits & regulations
├── /blog/best-time-build-deck Article — seasonal timing
│
├── /privacy                   Privacy policy
└── /terms                     Terms of service
```

**Total pages at launch: 21**

---

## Page-by-Page Specifications

### 1. Homepage (`/`)

**Purpose:** Primary entry point. Establish brand, build trust, convert visitors to leads.

**Hero Section (above the fold):**
```
┌──────────────────────────────────────────────────────┐
│  [LOGO]     Our Builders | Resources | About  [PHONE]│
│             ──────────────────────────────── [CTA btn]│
│                                                       │
│  (full-bleed dark photo: beautiful deck, faded overlay)│
│                                                       │
│  GET YOUR FREE DECK QUOTE                             │
│  IN CENTRAL WISCONSIN                                 │
│                                                       │
│  Local pros respond within hours — not days.          │
│                                                       │
│  [ GET MY FREE QUOTE ]  ← Crafted Orange button       │
│                                                       │
│  ✓ Free  ✓ No obligation  ✓ Licensed & insured        │
└──────────────────────────────────────────────────────┘
```

**Below the fold sections (in order):**

1. **Value Props (3 columns)** — Light background
   - "Local Contractors" (icon: map pin)
   - "Fast Quotes" (icon: clock)
   - "Licensed & Insured" (icon: shield)

2. **How It Works — Process Timeline** — Timber Slate background
   - Step 1: "Tell us about your project" (form icon)
   - Step 2: "Get matched with a local builder" (handshake icon)
   - Step 3: "Receive your free quote" (document icon)
   - Animated/visual horizontal timeline with Wisconsin Sky Blue connector lines

3. **Service Cities** — Light background
   - 5 cards linking to city pages: [[Wausau]], [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]]
   - Each card: city name + "Get a quote in [City]" link

4. **Gallery Preview** — Light background
   - 4-6 deck project photos in a grid
   - "View All Projects →" link to /gallery

5. **Trust Badges + Testimonial Placeholders** — Light background
   - Trust badges: Licensed & Insured, Free Quotes, Locally Owned, 5 Cities Served
   - Testimonial section: "What Homeowners Say" with placeholder cards (ready for real testimonials)

6. **Cost Calculator Teaser** — Wisconsin Sky Blue accent background
   - "Wondering what a deck costs in Central Wisconsin?"
   - "Try our free deck cost calculator →" link

7. **Embedded Quote Form** — Timber Slate background
   - Full 9-field Webflow form
   - Headline: "Ready to Get Started?"
   - Subtext: "Fill out the form and a local builder will reach out within 24 hours."

8. **Blog Preview** — Light background
   - 3 latest blog article cards
   - "Read More on the Blog →"

**Primary CTA:** "Get My Free Quote" → scrolls to form or links to /get-a-quote
**Secondary CTA:** "View Our Builders" → /our-builders

---

### 2. Get a Quote (`/get-a-quote`)

**Purpose:** Dedicated form page for CTAs across the site. Clean, distraction-free.

**Content:**
- Headline: "Get Your Free Deck Quote"
- Subtext: "Tell us about your project. A trusted local builder will reach out within 24 hours."
- Full 9-field Webflow form (center-aligned, max-width ~600px)
- Trust badges below form
- "What happens next?" mini process timeline (3 steps)

**Form Fields (Webflow native):**
1. Full name (text, required)
2. Phone number (tel, required)
3. Email address (email, required)
4. Property address (text, required)
5. Do you own this property? (select: Yes / No, required)
6. Project type (select: New build / Replacement / Repair / Addition / Not sure, required)
7. Budget range (select: Under $5K / $5K–$10K / $10K–$20K / $20K–$40K / $40K+, required)
8. Timeline (select: ASAP / 1–3 months / 3–6 months / Just planning, required)
9. Additional notes (textarea, optional)

**Submit button:** "Get My Free Quote" — Crafted Orange

> **LEGAL BLOCKER — TCPA Consent Checkbox (go-live dependency)**
> A required checkbox must appear between the last form field and the submit button. Exact language TBD by legal counsel. Placeholder:
> *"By submitting this form, you consent to being contacted by Central Wisconsin Deck Builders and our contractor partners by phone, text, or email regarding your project request. Message and data rates may apply."*
> This applies to BOTH the /get-a-quote form AND the inline quote form on all city pages. Neither form goes live until this checkbox is in place.

---

### 3. City Pages (`/wausau`, `/schofield`, `/weston`, `/mosinee`, `/merrill`)

**Purpose:** SEO landing pages for city-specific searches + ad campaign destinations. Each fully unique.

**Structure (per city):**
1. **Hero** — Dark, city-specific headline: "Deck Builders in [City], Wisconsin"
2. **City intro** — Unique paragraph about the city, its neighborhoods, housing stock, outdoor living culture
3. **Value props** — Same 3 value props, localized copy
4. **Process timeline** — Same 3 steps
5. **Local gallery** — Deck photos (stock initially, labeled as "[City] area")
6. **Testimonial placeholder** — "[City] homeowner" placeholders
7. **Trust badges** — Same set
8. **Embedded quote form** — With city pre-selected or mentioned in headline
9. **Blog links** — Relevant articles (permits article linked from every city page)
10. **City-specific FAQ** — 3-5 questions unique to each city

**Unique content per city (to be written):**
- **Wausau** — Largest city, county seat, older housing stock with deck replacement demand
- **Schofield** — Smaller community, newer developments, family-oriented
- **Weston** — Growing suburb, newer homes, additions and upgrades
- **Mosinee** — River town, outdoor recreation culture, seasonal projects
- **Merrill** — Northern anchor, rural-suburban mix, practical/value-focused homeowners

**SEO targets per city:**
- "deck builders [city] WI"
- "deck contractor [city] Wisconsin"
- "deck quote [city]"
- "deck cost [city] WI"

---

### 4. Our Builders (`/our-builders`)

**Purpose:** Showcase partner contractors. Build trust through transparency. Grows over time.

**Content:**
- Headline: "Meet Our Trusted Builders"
- Intro: "Every contractor in our network is vetted, licensed, and insured."
- **Contractor profile cards** (1 at launch, grows):
  - Photo (headshot or team photo)
  - Business name
  - Bio (2-3 sentences)
  - Service area (which cities)
  - Years in business
  - License status / insurance confirmation
  - "Get a Quote with [Business Name]" CTA
- Bottom CTA: "Are you a contractor? Join our network." (link to contact or future contractor page)

---

### 5. Gallery (`/gallery`)

**Purpose:** Visual proof of quality. Builds desire. Stock photos at launch.

**Content:**
- Headline: "Deck Projects in Central Wisconsin"
- Filterable grid (by project type: new build, replacement, addition, etc.)
- Each image: caption with project type + city
- CTA below gallery: "Ready to start your project? Get a free quote."

---

### 6. About (`/about`)

**Purpose:** Tell the CWDB story. Build trust for skeptical visitors who need to verify legitimacy.

**Content:**
- Headline: "About Central Wisconsin Deck Builders"
- Mission statement: "We make it easy for Central Wisconsin homeowners to find trusted, local deck builders — fast."
- The story: Why CWDB exists (problem: homeowners wait weeks for callbacks. Solution: we vet the builders and connect you in hours.)
- "How We're Different" section:
  - We're local to Central Wisconsin
  - We vet every contractor in our network
  - You get connected fast — not weeks later
  - It's completely free for homeowners
- Team/network values: reliability, speed, local expertise
- Service area map or city list
- CTA: "Get Your Free Quote"

---

### 7. FAQ (`/faq`)

**Purpose:** Answer objections, reduce friction, capture long-tail SEO.

**Questions to include:**
1. How does Central Wisconsin Deck Builders work?
2. Is the quote really free?
3. How quickly will I hear back?
4. How do you choose the contractors in your network?
5. What areas do you serve?
6. What types of deck projects do you handle?
7. How much does a deck cost in Central Wisconsin?
8. Do I need a permit for my deck?
9. What materials are available (composite, wood, cedar)?
10. What if I'm just in the planning stage?
11. Can I choose which contractor I work with?
12. Is my information shared with anyone else?

---

### 8. Deck Cost Calculator (`/cost-calculator`)

**Purpose:** Interactive engagement tool. SEO magnet for "how much does a deck cost" searches. Pre-qualifies leads.

**Inputs:**
- Deck size (preset options: 10x12, 12x16, 14x20, 16x24, custom)
- Material (pressure-treated wood, cedar, composite, PVC)
- Features (railing, stairs, built-in seating, pergola/cover)
- City/location (dropdown of 5 cities)

**Output:**
- Estimated range: "$X,XXX – $XX,XXX"
- Disclaimer: "This is a rough estimate. Get an exact quote from a local builder."
- CTA: "Get Your Exact Quote — Free" → /get-a-quote

**Implementation:** Webflow custom code or embedded calculator (JS-based, runs client-side).

---

### 9. Blog (`/blog` + 4 articles)

**Purpose:** Organic traffic, authority building, internal linking to quote form.

**Article 1: "How Much Does a Deck Cost in Wisconsin? (2026 Guide)"** (`/blog/deck-cost-wisconsin`)
- Average costs by material, size, and project type
- Central Wisconsin-specific pricing factors
- Cost breakdown table
- Link to cost calculator
- CTA: Get a free custom quote

**Article 2: "Composite vs. Wood vs. Cedar: Best Deck Material for Wisconsin Weather"** (`/blog/composite-vs-wood`)
- Pros/cons of each material
- How Wisconsin's freeze-thaw cycles affect durability
- Cost comparison
- CTA: Not sure which material? Let a local builder help.

**Article 3: "Do You Need a Permit to Build a Deck in Wausau, WI?"** (`/blog/deck-permits-wausau`)
- Wausau/Marathon County permit requirements
- When a permit is needed vs. not
- How to apply
- CTA: Our builders handle permits — get a quote.

**Article 4: "When Is the Best Time to Build a Deck in Central Wisconsin?"** (`/blog/best-time-build-deck`)
- Seasonal pros/cons (spring, summer, fall)
- Wisconsin frost dates and construction windows
- How to plan ahead
- CTA: Start planning now — get a free quote.

**Blog article template:**
- Hero image (dark overlay, article title)
- Estimated read time
- Table of contents (for longer articles)
- Body content with H2/H3 subheadings
- Inline CTAs every 2-3 sections
- Related articles sidebar or bottom section
- Author: "Central Wisconsin Deck Builders Team"

---

### 10. Privacy Policy (`/privacy`)

**Purpose:** Legal requirement before collecting homeowner PII. Must be live before any forms or ads go live.

> **LEGAL BLOCKER — go-live dependency.** This page must be published and linked in the footer before the website launches or any ads run. PII collection (name, address, phone) without a published privacy policy exposes CWDB to FTC and Wisconsin consumer protection liability.

**Content:** Drafted by legal counsel. Web-dev owns page structure only.

**Structure:**
- `hero-section-subpage` component (same as About, FAQ, etc.)
- Single-column rich text body (no sidebar, no form)
- Sections covering: data collected, how it's used, who it's shared with, homeowner rights, contact info
- Last updated date in header

**Footer link:** The footer "Privacy" link (already present in the footer component) must point to `/privacy`.

---

### 11. Thank-You Page (`/thank-you`)

**Purpose:** Confirm submission, set expectations, keep engagement.

**Content:**
1. **Confirmation:** "Thanks! Your quote request has been received."
2. **Next Steps Timeline:**
   - Step 1: "We're reviewing your project details now."
   - Step 2: "A licensed builder in your area will reach out within 24 hours."
   - Step 3: "You'll receive a free, no-obligation deck quote."
3. **While You Wait — Recommended Reading:**
   - Link to cost guide article
   - Link to materials comparison article
   - Link to permits article
4. **Contact info:** "Questions? Call us at [PHONE] or email [EMAIL]."

---

## Navigation & Global Elements

### Header (sticky on scroll)
```
[LOGO]     Our Builders | Resources ▼ | About     [ GET A QUOTE ]  (715) XXX-XXXX
```

**Resources dropdown (simple):**
- Blog
- FAQ
- Cost Calculator
- Deck Permits Guide

### Mobile Header
```
[LOGO]     [☰ hamburger]     [PHONE icon]
```
- Sticky bottom bar on mobile: "Get a Free Quote" full-width orange button + phone icon

### Footer
```
[LOGO]                                    [PHONE] | [EMAIL]
Central Wisconsin Deck Builders
Fast Quotes. Trusted Builders.

Wausau | Schofield | Weston | Mosinee | Merrill | Get a Quote | Blog | FAQ | About

[Facebook] [Instagram] [Nextdoor]

© 2026 Central Wisconsin Deck Builders | Privacy | Terms
```

---

## SEO Strategy

### Per-Page SEO

Every page gets:
- Unique `<title>` tag (under 60 chars)
- Unique `<meta description>` (under 155 chars)
- Open Graph tags (og:title, og:description, og:image)
- Canonical URL
- H1 → H2 → H3 hierarchy

### Structured Data (JSON-LD)

- **Homepage:** LocalBusiness schema (name, address, phone, service area, opening hours)
- **City pages:** LocalBusiness + Service schema per city
- **Blog articles:** Article schema (headline, author, datePublished, image)
- **FAQ page:** FAQPage schema (renders FAQ rich snippets in Google)
- **Cost calculator:** HowTo or WebApplication schema

### XML Sitemap

Auto-generated by Webflow. Submit to Google Search Console.

---

## Analytics & Tracking Setup

| Tool | Purpose | Implementation |
|---|---|---|
| Google Analytics 4 | Traffic, user behavior, acquisition | GTM container |
| Google Tag Manager | Event tracking, pixel management | Webflow `<head>` embed |
| Meta Pixel | Facebook/Instagram ad conversion tracking | GTM tag |
| Nextdoor Pixel | Nextdoor ad conversion tracking | GTM tag |
| Google Ads Conversion | Google Ads ROAS tracking | GTM tag |
| Hotjar or MS Clarity | Heatmaps, session recordings, scroll depth | GTM tag or direct embed |

### Conversion Events to Track

- Form submission (primary conversion)
- CTA button clicks (by page and button location)
- Phone number clicks (click-to-call)
- Cost calculator usage
- Blog article reads (scroll depth > 50%)
- City page visits (from ads vs. organic)
- Time on site / pages per session

---

## Build Sequence

### Phase A: Design System + Global Components ✅ COMPLETE (2026-04-02)
1. ✅ Set up Webflow project with brand colors, fonts, and global styles
2. ✅ Build header component (desktop + mobile + sticky behavior)
3. ✅ Build footer component
4. ✅ Build CTA button styles (primary + secondary)
5. ✅ Build quote form component (9 fields, Webflow native)
6. ✅ Build trust badge row component
7. ✅ Build process timeline component (3 steps)
8. Set up form submission → email notification (Webflow → [[Make]] webhook)

### Phase B: Core Pages (IN PROGRESS)
1. ✅ Homepage (all sections) — COMPLETE (2026-04-02)
   - All homepage sections built and converted to reusable Webflow components
   - Components available for use across city pages, supporting pages, and future development
2. Get a Quote page
3. Thank-you page
4. Test full form submission flow end-to-end

### Phase C: City Pages
1. Wausau (primary — most ad traffic will land here)
2. Schofield
3. Weston
4. Mosinee
5. Merrill

### Phase D: Trust & Authority Pages
1. Our Builders (contractor profiles)
2. About page
3. Gallery
4. FAQ page

### Phase E: Interactive + Content
1. Deck cost calculator (custom code embed)
2. Blog index page
3. Blog article template
4. 4 launch articles (content to be written)

### LEGAL BLOCKERS — Must be complete before go-live
- [ ] **BLOCKER:** Privacy Policy page (`/privacy`) published and footer link confirmed — required before ads run or forms collect PII. Content from legal counsel.
- [ ] **BLOCKER:** TCPA consent checkbox added to `/get-a-quote` form AND inline city page form — required before any form goes live.

### Phase F: SEO + Analytics
1. Meta tags and OG tags on all pages
2. Structured data (JSON-LD) on all page types
3. GTM container setup
4. GA4 + Meta Pixel + Nextdoor Pixel + Google Ads conversion
5. Hotjar/Clarity setup
6. XML sitemap submission to Google Search Console
7. Connect domain: cwdeckbuilders.com → Webflow

### Phase G: Mobile Optimization + QA
1. Test every page on mobile (iPhone, Android)
2. Sticky mobile CTA bar
3. Click-to-call testing
4. Form validation testing
5. Page speed optimization (image compression, lazy loading)
6. Cross-browser testing (Chrome, Safari, Firefox, Edge)

---

## Verification Plan

1. **Form flow:** Submit test quote → verify email notification fires → verify thank-you page redirect
2. **Mobile:** Test all pages on real mobile device — sticky CTA, click-to-call, form usability
3. **SEO:** Run each page through Google's Rich Results Test for structured data validation
4. **Analytics:** Verify GA4 real-time shows page views, verify conversion events fire in GTM debug mode
5. **Performance:** Run Lighthouse audit — target 90+ performance, 100 accessibility, 100 SEO
6. **Links:** Click every nav link, CTA button, footer link, internal link across all 21 pages
7. **Content:** Proofread all copy for brand voice consistency (direct, confident, local, no-fluff)

---

## Files to Create/Modify

| File | Action | Purpose |
|---|---|---|
| `website/site-architecture.md` | Create | Full sitemap and page specs reference |
| `website/design-system.md` | Create | Colors, fonts, components, patterns for Webflow build |
| `website/pages/` (per page) | Create | Content and copy for each of the 21 pages |
| `website/templates/base.html` | Update | Replace old single-page template with new multi-page structure |
| `website/pages/wausau-deck/index.html` | Update | Replace with new city page spec |
| `business-context/phase-1-plan.md` | Update | Replace 3B section with new website scope |
| `CLAUDE.md` | Update | Note tech stack change (Webflow forms replace Tally) |
| `operations/leads/` | Review | May need updates since Tally is no longer the form tool |

---

## Key Decisions Captured (2026-03-29)

1. **Webflow native forms replace Tally** — simpler stack, better design control
2. **21-page website replaces single landing page** — investment in authority + SEO + conversion
3. **Fully unique city pages** — not templated, each city gets hand-crafted content
4. **Dark & bold visual** with Wisconsin Sky Blue as third color to prevent Home Depot feel
5. **Mobile-first** with sticky CTA bar and click-to-call
6. **Full analytics from day one** — GA4, GTM, all ad pixels, heatmaps
7. **Deck cost calculator** as interactive engagement/SEO tool
8. **4 blog articles at launch** targeting high-value organic keywords
