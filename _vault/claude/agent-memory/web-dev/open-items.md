---
name: Open Items & Blockers
description: Active tasks, manual-only items, go-live blockers, and pending follow-ups for the CWDB website
type: project
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-04-16
status: active
---

# Open Items — Web Dev

Last updated: 2026-04-07

## Go-Live Blockers

| Item | Blocker Type | Notes |
|---|---|---|
| /privacy page not built in [[Webflow]] | LEGAL BLOCKER | Content file exists at `/website/pages/privacy/content.md`; page must be live before ads run; legal agent has full draft |
| /terms page not built in Webflow | Legal best practice | Content file exists at `/website/pages/terms/content.md` |
| Phone number missing sitewide | UX/Conversion | Header, footer, mobile CTA bar, TCPA disclosure all show `(715) XXX-XXXX`; user setting up Google Voice; update all instances once number confirmed |
| AI-generated testimonials on site | LEGAL BLOCKER | Per legal agent: all testimonials are AI-fabricated, violates FTC 16 CFR 255. Do not go live until replaced with real testimonials or removed. |

## Manual-Only Items (MCP Cannot Do These)
These require the user to perform in the Webflow Designer directly:

- **FAQPage JSON-LD** — Add to FAQ page `<head>` in Webflow designer (Page Settings → Custom Code)
- **Article JSON-LD schema** — Add to Blog article template `<head>`
- **Calculator JS** — Paste `/website/pages/cost-calculator/calculator.js` into /cost-calculator page settings → Custom Code → Before `</body>` (241 lines; exceeds `data_scripts_tool` 2,000 char limit)
- **GTM container snippet** — Paste into global site `<head>` in Webflow Project Settings → Custom Code
- **All tracking pixels** (GA4, Meta Pixel, Nextdoor Pixel, Google Ads conversion, MS Clarity) — Paste into site-level custom code after GTM is set up

## Phase F — SEO & Analytics (Next Major Phase)
Scope:
- Meta title + description for all 21 pages
- Open Graph tags for all pages
- LocalBusiness JSON-LD schema on homepage
- XML sitemap (Webflow auto-generates; verify)
- GTM + GA4 setup (user needs accounts first — see gaps-identified.md)
- All ad/analytics pixels via GTM

Can be done via MCP: meta tags, Open Graph, most structured data
Must be done manually: GTM snippet, pixel code, JSON-LD in `<head>`

## Content Gaps Needing User Input
- **Gallery photos** — 7 placeholder stock images; replace with real Wisconsin deck project photos
- **Our Builders bios** — [[Ben Barton]] and [[John Garcia]] entries have placeholder copy; need actual bios from contractors
- **Our Builders headshots** — No photos for either contractor; upload to Webflow assets then bind to CMS headshot field
- **Contractor license numbers** — Not captured anywhere; needed for Our Builders page credibility
- **Testimonials** — Must be real homeowner quotes (see legal blocker above)

## TCPA Consent — RESOLVED 2026-04-07
Finalized consent language added to `quote-form-fields.json`. Still needs to be added to Webflow forms (requires Designer open). Forms to update:
1. /get-a-quote (page ID: `69ce4163e79002c5d4762a57`)
2. Service Areas template (page ID: `69cf0c27f69f8fdddb60ccc0`) — covers all 5 city pages

## Our Builders — RESOLVED 2026-04-07
- Ben Barton entry corrected (Barton Builders LLC, Wausau WI)
- John Garcia entry created (John Garcia Construction LLC, Edgar WI)
- Both published to staging
- New item ID for John Garcia: `69d4b9e6b553503a6618ddbf`
