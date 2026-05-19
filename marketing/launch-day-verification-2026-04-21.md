---
type: checklist
status: pending
created: 2026-04-21
target_launch: 2026-04-21
owner: web-dev + jim
tags:
  - type/checklist
  - dept/marketing
  - phase-1
---

# Launch-Day Verification — 2026-04-21

**Purpose:** Run this checklist AFTER the hero-form bug fix lands and BEFORE paid ads go live. Catches anything that would torch CPL or ship broken conversions on Day 1.

**Expected duration:** 20–30 min end-to-end.

**Environments:**
- Staging: `https://central-wisconsin-deck-builders.webflow.io`
- Production: `https://www.cwdeckbuilders.com`

---

## 1. Form Fix Regression Check (Playwright — web-dev agent)

The hero-form bug was the last blocker. Before trusting the fix, regress the flow end-to-end.

- [ ] Homepage `hero-split` form renders on desktop (1280×800) — field visible, CTA button visible, no layout break
- [ ] Homepage `hero-split` form renders on mobile (375×812) — no overflow, tap targets ≥44px
- [ ] Enter a ZIP in the hero form → submit → lands on `/get-a-quote` step 2 (not step 1)
- [ ] URL params carry correctly: `?zip=54401` (or equivalent) visible in `/get-a-quote` address bar
- [ ] Step 2 form fields pre-fill from URL params where applicable
- [ ] Complete all 3 wizard steps with test data → submit → lands on `/thank-you`
- [ ] Browser console shows zero JS errors across the full flow
- [ ] Network tab: Webflow form POST returns 200

**Playwright startup note:** `browser_close` → `browser_navigate("about:blank")` → `browser_resize(1280, 800)` before first real action (context-death quirk documented in memory).

---

## 2. Conversion Tracking (GTM Preview mode)

Open GTM container in Preview mode connected to staging.

- [ ] **GA4 page_view** fires on homepage load
- [ ] **GA4 form_submission** custom event fires on `/thank-you` load
- [ ] **Meta Pixel PageView** fires on homepage load
- [ ] **Meta Pixel Lead** event fires on `/thank-you` load
- [ ] **Nextdoor Pixel Lead** event fires on `/thank-you` load
- [ ] **Google Ads Conversion** tag fires on `/thank-you` load
- [ ] **MS Clarity** recording captured for the session
- [ ] **Conversion Linker** tag fires on homepage load (attribution)

If any tag fails to fire → do NOT launch ads until fixed. A silent conversion gap = untracked ROAS = no kill-criteria data.

---

## 3. Form → Email Delivery (Jim — manual)

Webflow native forms deliver to a designated inbox. No Make automation backup right now (parked 2026-04-19).

- [ ] Submit a test lead via `/get-a-quote` on production (use a real ZIP in-market)
- [ ] Email notification arrives in Jim's inbox within 2 minutes
- [ ] Email contains all form fields populated correctly
- [ ] Email sender/subject is recognizable (not spam-filtered)

**If this fails, launch is blocked.** Manual contractor SMS is the only delivery path — Jim can't send it if he doesn't see the email.

---

## 4. Cross-URL Smoke Test (all 17 production URLs return 200)

Run as a Playwright batch OR a `curl -I` loop. Spot-check pages render, no 404s, no redirect loops.

- [ ] `/` (homepage)
- [ ] `/get-a-quote`
- [ ] `/thank-you`
- [ ] `/about`
- [ ] `/our-builders`
- [ ] `/gallery`
- [ ] `/faq`
- [ ] `/cost-calculator`
- [ ] `/blog`
- [ ] `/service-areas/wausau`
- [ ] `/service-areas/schofield`
- [ ] `/service-areas/weston`
- [ ] `/service-areas/mosinee`
- [ ] `/service-areas/merrill`
- [ ] `/blog/deck-cost-wisconsin`
- [ ] `/blog/composite-vs-wood`
- [ ] `/blog/deck-permits-wausau`
- [ ] `/blog/best-time-build-deck`

(Note: 18 URLs above — adjust to the real 17 if /blog index is counted separately from articles.)

---

## 5. Phone-Line Answer Confirmation (Jim — manual)

Google Voice kept as primary (port to Twilio cancelled 2026-04-19). Call extensions in Google Ads will ring (715) 544-7941.

- [ ] Call (715) 544-7941 from an outside number → answers within 6 rings OR hits a voicemail that mentions CWDB by name
- [ ] Voicemail-back within business hours is realistic (if not, disable the Call extension in Google Ads before launch)

---

## 6. Meta Creative Assets (if using Website Conversions objective)

If launching Meta Lead Ads with on-site form (not Meta native lead form), creative must be ready:

- [ ] 3 real Wisconsin deck photos exported at 1080×1080 (square), 1200×628 (landscape), 1080×1920 (story)
- [ ] Photos show finished decks (not in-progress construction)
- [ ] No people's faces without consent
- [ ] Filenames keyed to ad-variant IDs (`social-proof-img1.jpg`, etc.)

If using Meta native Lead Form (recommended per brief), field schema must match site wizard (Option A): zip, phone, project_type, address, owns_property, budget, timeline, notes, tcpa_consent. **No name/email.**

---

## 7. Kill-Criteria Instrumentation

Confirm kill-criteria can actually be measured on Day 1.

- [ ] Google Ads dashboard shows spend, impressions, clicks, conversions columns populated correctly
- [ ] Meta Ads Manager shows spend, impressions, clicks, leads columns populated correctly
- [ ] Daily spend caps are set: $30 Google account cap, $20 Meta ad set cap
- [ ] UTM params flowing through to GA4 Acquisition reports

---

## Go / No-Go Decision

All of §1, §2, §3, §5 must pass for launch. §4, §6, §7 are important but a single failure there is recoverable mid-flight.

**If pass →** Launch brief greenlight, ad-campaign agent executes Google + Meta setup, campaigns go live at 12:00 PM Central.

**If fail →** Block launch. Log failures in `/marketing/launch-blockers-2026-04-21.md` and triage.

---

## What This Checklist Does NOT Cover

- Contractor-side funnel (manual SMS flow — separate audit)
- HubSpot pipeline setup (manual lead tracking — still pending in Phase 1 checklist)
- Nextdoor organic content posting (separate post-launch workstream)
- Ad copy final polish (handled by ad-campaign agent)
