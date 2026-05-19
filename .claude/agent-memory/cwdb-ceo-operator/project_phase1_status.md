---
name: Phase 1 Validation status — what's shipped, what's left
description: Current state of the Phase 1 push to get ads running and the first lead delivered
type: project
---

# Phase 1 Validation — Current Status (as of 2026-04-18)

**Goal:** Prove contractors will pay for leads. Complete when (1) ≥1 contractor signed, (2) full lead capture system live, (3) ≥1 qualified lead delivered and paid.

**Why this matters now:** James wants ads running *this week*. Phase 1 has been compounding for 5+ weeks — we have the infrastructure but not the live campaigns. Every day without ads = zero leads = zero revenue validation. Dragging Phase 1 into week 7+ burns momentum and Jame's patience.

**How to apply:** Every daily briefing should measure against the open Phase 1 checklist below. Every "MUST-SHIP today" should be a Phase 1 closer unless there's an explicit reason otherwise.

## Shipped ✅
- Strategy, agent definitions, ad copy, form spec, call/email scripts
- LLC formed · EIN · Registered office · Contractor Agreement v1
- Brand: Name, domain (cwdeckbuilders.com), logos, color palette, design system
- Website: Webflow Phases A–E complete — 21-page site live on staging
- CMS: Service Areas (5 cities), Gallery, Our Builders, FAQs (12), Blog Posts (4)
- 2 contractor agreements sent via DocuSign (Ben Barton, John Garcia — 2026-04-07)
- Both contractor DocuSigns signed and returned ✅ (2026-04-17) — PDFs in /sales/contractor-agreements/
- All 6 Phase F analytics/pixel IDs received ✅ (2026-04-18) — see /memory/phase-f-ids.md

## Open Phase 1 Checklist
- [ ] Contact 10–20 deck contractors (currently 2 of 10–20 target)
- [x] Receive signed contractor agreements ✅ (2026-04-17)
- [ ] Webflow Phase F — SEO & analytics: INSTALL IN FLIGHT (2026-04-18, web-dev agent, all IDs in hand)
- [ ] Add phone number to site (blocker — not sourced yet)
- [ ] Build /privacy page (go-live blocker)
- [ ] Manual: Add FAQPage JSON-LD to FAQ page head (MCP can't apply)
- [ ] Manual: Replace gallery placeholder stock photos with real Wisconsin deck photos
- [ ] Manual: Paste calculator.js into /cost-calculator page Custom Code
- [ ] Manual: Add Article JSON-LD to blog template page head
- [ ] Publish Webflow site to cwdeckbuilders.com (needs James approval)
- [ ] Build Make scenario (form → qualification → routing → notifications)
- [ ] Set up HubSpot deal pipeline and contact records
- [ ] Launch first ad campaign (Google + Facebook + Nextdoor)
- [ ] Monitor end-to-end: submit → qualify → route → contractor receives → close → pay

## This Week's Mission
Get ads running. Blocking path: Phase F analytics + privacy page + site publish + Make scenario. Everything else is sequencing behind or parallel to those.

## Risk Watch
- Contractor signatures still out 9+ days (as of today) — chase them
- Only 2 contractors in pipeline — if either backs out pre-launch we have thin coverage
- Manual paste-jobs (JSON-LD, calculator.js) require James or a browser session — don't let these quietly slip
