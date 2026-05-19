---
title: Jim's Manual Action Items — Phase 1
status: in-progress
last-updated: 2026-04-17
updated-by: CEO Operator
tags:
  - cwdb
  - phase-1
  - action-items
  - jim
aliases:
  - My Action Items
  - Jim Action Items
---

# Jim's Manual Action Items — Phase 1

> [!abstract] What this is
> Everything in Phase 1 that only you can do. Ranked by urgency against the critical path to ads-live. Check boxes as you go — the CEO reads this every session and updates the [[phase-1-roadmap]] accordingly.

---

## Critical Path to Ads-Live

> [!tip] Do these in order — each one unblocks the next

### Step 1 — Webflow Paste-Jobs *(~20 min, one browser session)*

> [!warning] Do these BEFORE publishing so the site launches complete

- [x] Open Webflow Designer → `/cost-calculator` page → Settings → Custom Code → Before `</body>` → paste `calculator.js` (241 lines from `/website/pages/cost-calculator/calculator.js`)
- [x] Open Webflow Designer → FAQ page → Settings → Custom Code → `<head>` → paste FAQPage JSON-LD schema
- [x] Open Webflow Designer → Blog template page → Settings → Custom Code → `<head>` → paste Article JSON-LD schema

---

### Step 2 — Approve Site Publish *(~2 min)*

> [!danger] This is THE gate. Nothing goes live until you click this.

- [x] Webflow Designer → top bar → **Publish** → select domain `cwdeckbuilders.com` → confirm

All agent-side blockers (analytics, Make, HubSpot, phone number on site) are in-flight now. The moment you publish, the live site is up and ads can run.

---

### Step 3 — Approve Ad Budget *(decide now, confirm before publish)*

> [!info] Recommended allocation
> **$50/day total across 3 channels = ~$1,500/mo**
> - Google Ads: $25/day (highest intent — people actively searching)
> - Facebook/Instagram: $15/day (awareness, retargeting)
> - Nextdoor: $10/day (community trust, lowest competition = lowest CPL)
>
> At target CPL of $60: ~25 leads/mo → at 20% close rate → ~5 accepted bids/mo → $5,000 revenue

- [x] Approve budget: **$50/day** (recommended) or adjust below and note your number
  - Your number: ___________

> [!note] Jim — (your feedback here)
> *Drop your budget decision as a note here so the CEO can queue the campaigns.*

---

## Non-Blocking (do when you have the assets)

### Gallery Photos

> [!info] Affects trust and conversion but does not block ads-live

- [ ] Source real Wisconsin deck photos (your own project photos, or source from Ben/John)
- [ ] Upload to Webflow Gallery CMS collection (replace the 7 placeholder stock items)

---

## Completed ✅

- [x] LLC formed — `2026-04-06`
- [x] EIN obtained — `41-5355234`
- [x] Brand confirmed — Central Wisconsin Deck Builders / `cwdeckbuilders.com`
- [x] Contractor agreements signed — Ben Barton + John Garcia — `2026-04-17`
- [x] Phone number sourced — `(715) 544-7941` — `2026-04-17`
- [x] `/privacy` page — `2026-04-17`
- [x] Routing model decided — group text, first-responder wins — `2026-04-17`

---

## Related

- [[phase-1-roadmap]] — full project plan with all blockers, metrics, contractor pipeline
- [[phase-1-plan]] — original Phase 1 playbook
