---
type: deployment-checklist
status: ready
created: 2026-04-21
owner: cwdb-ceo-operator
wave: 4 of 4
for: Jim (manual execution in Google Ads + Meta Ads Manager)
tags:
  - type/deployment
  - dept/marketing
  - launch/2026-04
---

# CWDB Ad Launch — DEPLOY.md

**One file. Do these steps in order. Est. 60–90 min total.**

This is the single checklist. Every "paste this" block refers to a file inside `/marketing/launch-2026-04/`. Open this file on one monitor, Google Ads / Meta Ads Manager on the other. Don't skip steps — the verification lap catches attribution errors that cost you leads after launch.

---

## Contents

- [§0 Pre-Flight (5 checks)](#0-pre-flight)
- [§1 Asset Manifest (what exists, where)](#1-asset-manifest)
- [§2 Google Ads — Setup Steps](#2-google-ads--setup-steps)
- [§3 Meta Ads — Setup Steps](#3-meta-ads--setup-steps)
- [§4 Verification Lap (1 test lead, 3 platforms)](#4-verification-lap)
- [§5 Go-Live (un-pause both campaigns)](#5-go-live)
- [§6 Week-1 Monitoring](#6-week-1-monitoring)
- [§7 Rollback / Kill-Switch](#7-rollback--kill-switch)

---

## §0 Pre-Flight

Do not create campaigns until all 5 are GREEN. If any is red, stop and fix before proceeding.

**Completed 2026-04-21 — Jim confirmed all 5 GREEN.**

- [x] **Production site live.** `https://www.cwdeckbuilders.com` loads without errors. Homepage + `/get-a-quote` + `/thank-you` all render.
- [x] **Form → email delivery verified.** Already confirmed 2026-04-21 — one test submission reached `info@cwdeckbuilders.com` → `slogarjw@gmail.com`. If not confirmed this week, submit one more test lead.
- [x] **GTM conversion tags firing.** In GA4 DebugView + Meta Events Manager Test Events + Google Ads conversion diagnostic, verify `form_submit_quote` fires on a fresh `/thank-you` page-view. (Performed inside §4 — but Pre-Flight is your sanity check that tags exist before you even start setup.)
- [x] **Phone answer-path set.** `(715) 544-7941` (Google Voice) rings through to a phone you will answer during Mon–Fri 9am–5pm Central. Call extension schedule matches. If you won't answer, pause the call extension in §2 step 10 before un-pausing the campaign.
- [x] **Ad accounts ready.** Google Ads account `712-991-0870` (CWDB-dedicated) + billing set up + Google Ads conversion tag linked (ID `18113251301` / label `PgcJCL_ck6IcEOWPib1D` — corrected 2026-04-25 from prior AW-10862517194 after account-mismatch discovery). Meta Business Manager access (CWDB Meta Business) + Pixel `1276568654662913` (`cwdeckbuilders.com`) visible in Events Manager + payment method on file.

---

## §1 Asset Manifest

**Reviewed 2026-04-21 — all assets present.**

Everything you need is inside `/marketing/launch-2026-04/`. Files below.

| What | File | Used where |
|---|---|---|
| **Strategy doc** | `01-strategy.md` | Reference only — all architecture decisions with rationale |
| **Hook matrix** | `02-hook-matrix.md` | Reference — why these 3 angles |
| **Google Ads copy (paste-ready)** | `03-google-copy.md` | §2 below — headlines, descriptions, keywords, extensions, negatives |
| **Meta Ads copy (paste-ready)** | `04-meta-copy.md` | §3 below — primary/headline/description per ad, creative briefs |
| **Hook audit** | `05-hook-audit.md` | Verification — 11/11 creatives PASS |
| **Meta creatives — 6 PNGs** | `creatives/meta/*.png` | §3 step 8 — 3 angles × 2 aspect ratios |
| **Google Display creatives — 5 PNGs + README** | `creatives/google-display/*` | **STANDBY** — Search launch does NOT use Display. Hold for Week 4+ expansion. |

**What's NOT in this package (by design):**
- TikTok or Nextdoor ad creatives — deferred per launch brief
- Instant Form / Meta Lead Form copy — intentionally not used (Website Conversion objective preserves full GTM attribution)
- Lookalike audiences — deferred until 50+ conversions banked (Day ~50+)

---

## §2 Google Ads — Setup Steps

> **PRIMARY PATH (added 2026-04-22):** Use the bulk-upload CSVs in `bulk-upload/` instead of clicking through the wizard. ~25 min vs ~60 min, zero copy-paste error risk. See `bulk-upload/README.md` for the upload sequence + the small manual residual (extensions + presence-vs-interest toggle). The numbered steps below are kept as a fallback for fields the bulk upload doesn't cover and as a reference for what's being created.

**Source of truth:** `03-google-copy.md` — open it alongside this checklist. Every paste-block below points to a section there.

### Campaign scaffold

1. Google Ads → **New campaign** → Objective = **Leads** → Campaign type = **Search**.
2. Campaign name: `CWDB — Search — Launch 2026-04`
3. **Networks:** Search only. **UNCHECK** Search Partners. **UNCHECK** Display Network expansion. (Both are budget leaks for local lead gen at our spend.)
4. **Locations:** "Wausau, WI" with **+20 mile radius**. Presence setting = **"People IN or regularly in"** (NOT "interested in"). Confirm the circle covers ZIPs 54401, 54403, 54474, 54476, 54455, 54452.
5. **Languages:** English.
6. **Budget:** `$30.00/day`. **Bid strategy: Manual CPC.** (DO NOT pick Maximize Conversions at launch — we have zero conversion history; it will burn budget.)
7. **Audience segments:** none at launch. Skip.
8. **Ad schedule:** 24/7 Week 1–2. (Don't constrain until we have hour-of-day data.)
9. **Conversion actions:** confirm `form_submit_quote` (ID `18113251301`, label `PgcJCL_ck6IcEOWPib1D`) is included in this campaign's Conversions column. Value = `$300` per conversion.

### Ad Group 1 — Decision-stage

10. Create ad group: `AG1 — Decision — Builder/Contractor Intent`. Max CPC bid: **$3.50**.
11. **Keywords:** paste the 15 AG1 keywords from `03-google-copy.md` § "AG1 Keywords" (7 phrase-match wrapped in `"..."` + 8 exact-match wrapped in `[...]`).
12. **Ad (RSA):** → New ad → Responsive search ad
    - Final URL: copy from `03-google-copy.md` § "AG1 URLs and Paths" (the one starting `https://www.cwdeckbuilders.com/get-a-quote?utm_source=google...&utm_content=g-ag1-rsa1-local...`).
    - Display path 1: `deck-quote` · Display path 2: `wausau-decks`
    - **Headlines:** paste all 15 from `03-google-copy.md` § "AG1 Headlines". **Pin Headline 1 ("Wausau Deck Builders") to Position 1.** All others unpinned.
    - **Descriptions:** paste all 4 from `03-google-copy.md` § "AG1 Descriptions".

### Ad Group 2 — Comparison-stage

13. Create ad group: `AG2 — Comparison — Quote/Estimate/Cost`. Max CPC bid: **$2.50**.
14. **Keywords:** paste the 16 AG2 phrase-match keywords from `03-google-copy.md` § "AG2 Keywords". (Phrase match only — AG2's intent is broader and needs phrase-level catch.)
15. **Ad (RSA):**
    - Final URL: copy from `03-google-copy.md` § "AG2 URLs" (ends `utm_content=g-ag2-rsa1-quote`).
    - Display paths same: `deck-quote` / `wausau-decks`.
    - **Headlines:** paste all 15 AG2 headlines. Pin #1 "Wausau Deck Quotes" to P1.
    - **Descriptions:** paste all 4.

### Campaign-level: negatives + extensions

16. **Negative keywords:** go to campaign → Keywords → Negative keywords → paste all 34+ entries from `03-google-copy.md` § "Negative Keywords — Campaign Level". These apply to BOTH ad groups.
17. **Sitelink extensions (4):** paste exactly from `03-google-copy.md` § "Sitelinks" — each has title + 2 descriptions + URL.
18. **Callout extensions (8):** paste from § "Callouts".
19. **Structured snippet:** Header = "Services" → 5 values from § "Structured Snippets".
20. **Call extension:** phone = `(715) 544-7941` → schedule = **Mon–Fri 9am–5pm Central** → Call reporting ON. (This matches the Google Voice answer-window you committed to.)
21. **Lead Form extension:** **DO NOT ENABLE.** Skip.
22. **Location extension:** skip at launch (pending Google Business Profile). Add later.

### Leave paused

23. Campaign status = **PAUSED**. Do not enable yet — the Verification Lap (§4) runs first.

---

## §3 Meta Ads — Setup Steps

**Source of truth:** `04-meta-copy.md` — open alongside.

### Campaign scaffold

1. Meta Ads Manager → Create campaign → **Leads** objective → Conversion location = **Website**.
2. Campaign name: `CWDB — Leads — Launch 2026-04`
3. **Campaign Budget Optimization (CBO):** OFF. We're using ad-set-level budget.
4. **Special ad categories:** none.

### Ad Set 1 — Manual Core

5. Ad set name: `AS1 — Manual Core — Homeowner 35-65`
6. **Conversion event:** Pixel = CWDB (`1207759804531749`). Event = **Lead**.
7. **Budget:** daily `$10.00` (ad-set level).
8. **Audience:** build manually from `04-meta-copy.md` § "AS1 — Manual Core":
   - **Location:** Wausau, WI + 20 mi radius. Add ZIPs explicitly if UI supports: 54401, 54403, 54474, 54476, 54455, 54452.
   - **Age:** 35–65
   - **Gender:** All
   - **Detailed targeting (INCLUDE, OR logic):** Home improvement, Home & garden, Patio, Backyard, Outdoor living, Landscaping, HGTV, The Home Depot, Lowe's, DIY
   - **Narrow audience (AND — click "Narrow audience"):** Engaged Shoppers OR Likely Movers
   - **Demographics:** Homeowners → select. Household income top 50% in area (if UI offers).
   - **Exclude:** Renters. Exclude "Under 25" if not already excluded by age.
9. **Placements:** Advantage+ Placements (automatic).
10. **Optimization & delivery:** Optimization for ad delivery = **Leads (conversions)**. Bid strategy = Highest volume (no bid cap). Attribution window = **7-day click + 1-day view** (DEFAULT — do not change).

### Ad Set 2 — Advantage+ Audience

11. Ad set name: `AS2 — Advantage+ — Homeowner 35-65`
12. Same Pixel + Lead event.
13. Budget = `$10.00/day`.
14. **Audience:** Advantage+ Audience (Meta's auto-optimized). Hard constraints to set: Location = same ZIPs + 20-mi radius, Age = 35–65. Exclude: Renters. Everything else = let Meta optimize.
15. Placements = Advantage+. Optimization = Leads. Attribution = 7-day click + 1-day view.

### Ads inside AS1

16. **Ad 1:** `AS1 — Problem Solution — v1 — problem`
    - Format: Single Image
    - Image: `creatives/meta/problem-solution-1080x1080.png` (Feed square). Upload `problem-solution-1080x1350.png` in the "additional ratios" slot if Meta lets you provide portrait.
    - **Primary text, Headline, Description, CTA button, Destination URL** — paste all four fields from `04-meta-copy.md` § "AS1 → Ad 1 — Problem/Solution". CTA = **Get Quote**.
17. **Ad 2:** `AS1 — Process Proof — v1 — process`
    - Image: `creatives/meta/process-proof-1080x1080.png` (+ 1080×1350 portrait).
    - Paste fields from § "AS1 → Ad 2 — Process Proof". CTA = **Get Quote**.

### Ads inside AS2

18. **Ad 1:** `AS2 — Problem Solution — v1 — problem` **(CONTROL — identical to AS1 Ad 1)**
    - Image: **reuse the same PNG** as AS1 Ad 1 (`problem-solution-1080x1080.png` + `1080x1350.png`). Do NOT upload a different image.
    - Paste IDENTICAL Primary/Headline/Description as AS1 Ad 1. CTA = Get Quote.
    - **Destination URL must differ** — use `utm_content=m-as2-v1-problem` (from `04-meta-copy.md`). This is the only difference vs AS1 Ad 1 — and it's how we attribute lead performance to audience, not copy.
19. **Ad 2:** `AS2 — Seasonal Urgency — v1 — urgency`
    - Image: `creatives/meta/seasonal-urgency-1080x1080.png` (+ 1080×1350).
    - Paste fields from § "AS2 → Ad 2 — Seasonal Urgency". CTA = Get Quote.

### Leave paused

20. Both ad sets: **PAUSED**. Verification lap (§4) runs first.

---

## §4 Verification Lap

**Do this ONCE before un-pausing either platform. If any check fails, stop and fix before launching.**

1. Open a fresh browser window (incognito or different profile — no cookies).
2. Go to `https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=g-ag1-rsa1-local&utm_term=test_launch_day`
3. Fill out the full form with real-looking but clearly-test data (name "TEST LAUNCH 2026-04-21", a real phone you control, zip 54401, project type, etc.). Submit.
4. **Verify in 5 places (within ~10 minutes):**
   - [ ] **Email:** `slogarjw@gmail.com` receives the lead notification from `info@cwdeckbuilders.com`.
   - [ ] **GA4 DebugView:** `Admin → DebugView` — the test session shows `form_submit_quote` event with the UTM parameters (source=google, campaign=launch-2026-04, content=g-ag1-rsa1-local, term=test_launch_day).
   - [ ] **Google Ads conversion diagnostic:** `Goals → Conversions → form_submit_quote` → "Recent conversions" shows a conversion within 24 hours (may be delayed up to 24 hr for attribution).
   - [ ] **Meta Events Manager:** `Events Manager → Your Pixel → Test Events` tab — enter your site URL, submit another form on the test tab, confirm Lead event fires within ~60 sec.
   - [ ] **MS Clarity:** session recording exists for the test submission. (Confirms the `wdo8r9av0g` project is receiving traffic.)
5. Run the same URL test with a Meta UTM variant: `?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=m-as1-v1-problem` → verify GA4 DebugView captures Meta as source.

**If all 5 pass, you are cleared to go live.**

---

## §5 Go-Live

1. **Google Ads:** Campaign `CWDB — Search — Launch 2026-04` → status PAUSED → UN-PAUSE. Both ad groups enable.
2. **Meta Ads:** Campaign `CWDB — Leads — Launch 2026-04` → status PAUSED → UN-PAUSE. Both ad sets enable.
3. Log the go-live time: Jim's local time + UTC. You'll reference it when reading early metrics.
4. Update `_vault/state-of-cwdb.md` — mark launch live, record timestamp.

---

## §6 Week-1 Monitoring

**Principle: No decisions before Day 7.** Week 1 is data collection. At $50/day, a 2-lead swing is pure statistical noise — don't react to it.

### Daily (≤5 min/day)

- [ ] Check Google Ads: Any **ad disapproval**? Any **0-impression ad groups** (= account setup issue)? Any **$0 spend** (= billing problem)?
- [ ] Check Meta Ads Manager: Any ad rejection? Any ad set in "Learning Limited"?
- [ ] Check inbox: Did any leads arrive overnight? Did you respond / forward to contractor within your commitment window?

### Day 3 checkpoint

- Spend tracking on target? ($30 Google + $20 Meta daily = $150 combined by end of Day 3.)
- If Google has $0 spent and 0 impressions by end-of-Day-3: bid cap too low OR keywords too narrow. Raise AG1 bid to $4.00 temporarily, re-evaluate.
- If Meta "Not delivering" on both ad sets by end-of-Day-3: audience too narrow. Expand interests.

### Day 7 decision gate

Per `01-strategy.md` §5 and the launch brief:
- **Pause individual ad** if >$140 spend with 0 conversions (Meta) or >$200 with 0 conversions (Google).
- **Do NOT pause ad sets / ad groups yet.** Only individual ads.
- If Google CPL is >$80 at Day 7: review the search-terms report. Likely negative-keyword harvest needed.
- If Meta CPL is >$50 at Day 7: consider reopening Instant Form as a Week 2 test (pre-approved escape hatch in `01-strategy.md` §Open Questions #3).

### Day 14 decision gate (full kill criteria apply)

- Pause Google channel if CPL >$80 cumulative.
- Pause Meta channel if CPL >$50 cumulative.
- Pause BOTH if combined CPL >$100.
- Pause any ad set/ad group that has cumulative $250+ spend with 0 conversions.

### Week 3

- First variant refresh per strategy §5. Swap weakest 3 Google RSA headlines per ad group. Consider adding a new Meta angle (standby assets exist — see Google Display folder for starting visuals if we decide to expand).
- First day-parting review: pull Google hour-of-day report, apply +20%/-30% bid modifiers.

### Week 4

- **Scale decision:** if combined CPL <$60 AND first accepted bid banked, scale spend to $100/day.
- **Retargeting activation:** set up Remarketing audience (site visitors 30-day) — activate for a new Meta ad set.
- **Bid strategy promotion:** if Google has 15+ conversions trailing-14-days, switch to Maximize Conversions (no tCPA yet).

---

## §7 Rollback / Kill-Switch

**If something goes wrong during launch, pause before you debug. Cost of pause = zero. Cost of runaway broken spend = real money.**

### Emergency pause (either platform)

- **Google:** Campaign page → toggle Status to Paused. Takes effect in <5 minutes across all auctions.
- **Meta:** Campaigns tab → toggle Campaign switch to Off. Propagates in <15 minutes.

### Conditions that warrant emergency pause (any ONE)

- Production site goes down (form unreachable → ad spend is pure waste)
- Conversion tag stops firing (leads arriving but not tracked — broken attribution)
- You receive a lead and nothing works (no email, no contractor handoff) — cut spend until fixed
- Any ad gets disapproved for policy reasons — pause, understand, rewrite, appeal before reactivating

### Partial rollback (keep one channel, pause the other)

- If Google looks healthy but Meta is breaking CPL ceilings → pause Meta only. Google continues.
- If Meta's running well but Google search terms are garbage → pause Google, audit, harvest negatives, re-enable.

### Full rollback to v1 (if v2 package has a systemic issue)

- The v1 baseline files in `/marketing/google-ads/` and `/marketing/facebook-ads/` are untouched and in git. If you need to fall back, delete the v2 campaign in each platform and build from v1. This is unlikely but the fallback exists.

---

## Appendix A — Post-Launch Logging

Once live, add the following to `_vault/state-of-cwdb.md`:
- Go-live timestamps (Google + Meta)
- First-day spend actuals
- Day-7 metrics snapshot
- Any deviations from the strategy (document + why)

## Appendix B — Not-in-Scope (deferred)

- TikTok paid ads
- Nextdoor paid ads (organic only)
- Google Display Network (creatives ready, launch deferred to Week 4+ — see `creatives/google-display/README.md`)
- Lookalike audiences
- Retargeting / Remarketing campaigns (activate Week 4)
- Performance Max campaigns

---

**End of DEPLOY.md.** If anything here is ambiguous when you hit it in real setup, stop and ask — every paste-block references a specific section in `01-strategy.md` / `03-google-copy.md` / `04-meta-copy.md` for the full context.
