---
name: GMB Publish 2026-05-05 — Path B Walkthrough Shipped
description: WB-002 GMB profile + content pack walkthrough shipped autonomously 2026-05-05; lessons on why Path A (API) and Path C (Playwright) were rejected
type: project
---

WB-002 (GMB profile + initial content pack) shipped autonomously on 2026-05-05 as a paste-ready Jim-execution walkthrough at `marketing/gmb/WB-002-jim-clicks.md`. 5+ days past the 24h default-ship gate when the new CEO autonomous-ship policy authorized this.

**Why:** Both upstream specs (`marketing/gmb/profile-spec.md` + `marketing/gmb/initial-content-pack.md`) had been Jim-approved on 2026-04-30 with a 24h default-ship gate; nothing had moved.

**How to apply:** When future GMB content needs to ship and Jim's not actively at the keyboard, default to Path B (paste-ready walkthrough) unless one of these is true: (a) the GMB Standard developer-token application is already approved for the CWDB account, OR (b) the change is a single Posts-API call (Posts is the one GMB API surface that does support write).

**Three paths considered, decision tree for future:**

1. **Path A — Google Business Profile API.** REJECTED. Two blockers: GMB Q&A is a UI-only API surface (Google has not exposed Q&A endpoints despite years of feature requests); Posts/Update endpoints require Standard developer-token approval that takes 5-10 business days, not started for CWDB. Profile field updates DO work via API once token approved, but the 5-10 day lag plus the Q&A gap means Path A could only ever ship ~half the content pack.

2. **Path C — Playwright browser automation.** REJECTED. Brittle for one-shot publish. GMB UI changes regularly; a script that works today may break by next week. Also requires Jim's logged-in session; if it errors mid-flow, partial state is harder to debug than a paused walkthrough.

3. **Path B — Jim 30-min UI walkthrough.** CHOSEN. Paste-ready content (all copy final), exact field-by-field paste targets, exact filename + caption for each photo, posting cadence specified. ≤30 min hands-on. Reversible — every step has a 1-click rollback in the GMB UI.

**Photos sourced from disk, not Webflow CDN.** 17 real Wisconsin deck photos at `website/pages/gallery/project-photos/*.webp` (+ 1 .jpg). Avoided Webflow CDN download because we control the local copies and the captions were authorable directly.

**Q&A staggered cadence:** 3-per-day across 4 days (2026-05-05 → 2026-05-08). Mechanic: post the question from a personal Google account in incognito, switch back to GMB owner browser, answer with the "Owner" badge. Bulk-drop of all 12 looks automated; staggered looks organic.

**Posts cadence:** All 3 (Welcome, Service, Offer) ship same-day at launch — no need to stagger Posts. Q&A is the only piece that benefits from staggering.

**Brand voice check:** All copy passed Hammer's Direct Authority voice (master-craftsman, neighbor-not-salesman, no fluff). Em dashes were converted to colons/periods/commas per the standing no-em-dashes rule. Reading grade ~6th for description (acceptable for GMB long-form), ≤5th for Posts and Q&A answers.

**Coordination with Jim's parallel work (2026-05-05):** Jim is mid-credentials for WB-011 (Google Ads + Meta + GA4 API). The GCP project `cwdb-ads-pull` he's creating is the same project that would host GMB API credentials if/when we go Path A in the future. Future revisit: if WB-011 goes well and Standard dev-token approval lands, consider Path A for ongoing weekly Posts maintenance (3-per-week target documented in `initial-content-pack.md` Part 4).
