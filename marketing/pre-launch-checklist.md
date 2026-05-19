---
type: checklist
status: active
created: 2026-04-21
target_launch: 2026-04-24
tags:
  - type/checklist
  - dept/marketing
  - phase-1
  - launch-gate
---

# Pre-Launch Checklist — First $1 of Ad Spend Gate

**Purpose:** No ads go live until Section 1 is fully green. Section 2 can go green in parallel with Jim's fix. Section 3 is live-monitoring readiness — must be green before Week 1 spend decisions.

**Owner:** CEO Operator (verification) + Jim (manual actions)
**Companion doc:** `/marketing/launch-brief-2026-04-20.md`

---

## Section 1 — Pre-Launch Blockers (ALL MUST BE GREEN)

*No spend until every box below is checked and verified.*

| #    | Item                                                                                                                                                                                             | Owner                                                   | Status |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- | ------ |
| 1.1  | Form → email delivery verified on production (Jim submits 1 real test entry, confirms notification lands in expected inbox)                                                                      | Jim (manual)                                            | [x ]   |
| 1.2  | 4 stock Gallery CMS photos replaced with real Wisconsin deck photos — see jim-manual-actions-2026-04-20.md item 8 + Phase 4 audit; OR hidden via CMS Featured toggle with Jim's explicit consent | Jim (manual)                                            | [x ]   |
| 1.3  | All 11 Phase 4 pages verified clean via Workstream B staging audit (Playwright, all 17 URLs — double-hero, CMS binds, console errors)                                                            | web-dev agent / Workstream B                            | [ x]   |
| 1.4  | `hero-interior` Designer overrides completed on `/faq`, `/blog`, `/gallery`, `/our-builders`, `/cost-calculator`, blog article template                                                          | Jim (manual — per jim-manual-actions-2026-04-20 item 3) | [ x]   |
| 1.5  | Collection List CMS binds completed on `/blog` index, `/gallery`, `/our-builders`, blog article template                                                                                         | Jim (manual)                                            | [x ]   |
| 1.6  | Ben + Garcia headshots uploaded to `Our Builders` CMS items (enables populated `/our-builders` grid)                                                                                             | Jim (manual)                                            | [ x]   |
| 1.7  | Updated `calculator.js` pasted into `/cost-calculator` Page Settings Custom Code                                                                                                                 | Jim (manual)                                            | [x ]   |
| 1.8  | Service Areas `quote-form-inline` Title CMS rebind verified (all 5 city pages show correct city in the form eyebrow)                                                                             | Jim (manual)                                            | [ x]   |
| 1.9  | Jim reviews + approves `/marketing/launch-brief-2026-04-20.md` (explicit written sign-off in state-of-cwdb Inbox)                                                                                | Jim (decision)                                          | [ x]   |
| 1.10 | Production deploy from staging (Webflow Publish → `cwdeckbuilders.com` with all Phase 4 changes live)                                                                                            | Jim (1-click in Webflow)                                | [x ]   |
| 1.11 | Phone (715) 544-7941 answer-test (Jim calls from another number, confirms Google Voice rings through and he or the designated answerer picks up or returns within 1 hr during business hours)    | Jim (manual)                                            | [ x]   |

**Section 1 gate count: 11 blockers**

---

## Section 2 — Soft Gates (SHOULD BE GREEN, launch-in-parallel acceptable)

*If any of these slip past launch, they MUST be closed within 72 hours of launch.*

| # | Item | Owner | Status |
|---|---|---|---|
| 2.1 | Real Facebook, Instagram, Nextdoor business URLs added to footer (replace placeholders) | Jim (provide URLs) + CEO (wire via MCP) | [ ] |
| 2.2 | Nextdoor business account verified (Jim carried from 2026-04-18) | Jim (manual) | [ ] |
| 2.3 | FAQPage JSON-LD schema verified firing on `/faq` (GTM Preview or schema.org validator) | CEO verification | [ ] |
| 2.4 | Article JSON-LD schema verified on blog article template (spot-check 1 post) | CEO verification | [ ] |
| 2.5 | HubSpot pipeline stages built (reference `/sales/crm/pipeline-stages.json`) — required for manual lead tracking from Meta CSV export | contractor-sales agent | [ ] |
| 2.6 | TCPA consent text reviewed (optional rubber-stamp per jim-manual-actions-2026-04-20 Phase 3) | Jim (review) | [ ] |

**Section 2 gate count: 6 soft gates**

---

## Section 3 — Live-Monitoring Setup (MUST BE GREEN before Week 1 spend decisions)

*These unlock the feedback loop. Without them, we're spending blind.*

| # | Item | Owner | Status |
|---|---|---|---|
| 3.1 | GA4 real-time view bookmarked in Jim's browser; CEO has the property ID on file | CEO | [ ] |
| 3.2 | Google Ads Conversion firing test — submit 1 real lead through the wizard, confirm conversion appears in Google Ads Manager within 24 hr | Jim + CEO verification | [ ] |
| 3.3 | Meta Pixel Lead event test — same test lead, confirm Lead event in Meta Events Manager (Pixel tab) within 60 min | Jim + CEO verification | [ ] |
| 3.4 | First-lead notification path confirmed: Jim's inbox receives the form email AND Jim has Ben's + Garcia's phone numbers saved on his phone for immediate manual SMS | Jim (verify on phone) | [ ] |
| 3.5 | Kill-criteria alerts configured in Google Ads + Meta dashboards (Google: CPA threshold alert at $80; Meta: CPA alert at $50; combined spend alert at $200) | ad-campaign agent post-launch setup | [ ] |
| 3.6 | Daily monitoring ritual confirmed: Jim (or CEO via `/brief` skill) reviews spend + CPL + conversions every morning Week 1 | Operational | [ ] |

**Section 3 gate count: 6 monitoring gates**

---

## Summary

| Section | Gates | Status |
|---|---|---|
| 1 — Pre-launch blockers | 11 | Open |
| 2 — Soft gates | 6 | Open |
| 3 — Live-monitoring | 6 | Open |
| **Total** | **23** | **Open** |

---

## Sign-Off

- [x] CEO Operator verifies Section 1 fully green before initiating any ad account configuration
- [x] Jim explicitly approves in state-of-cwdb.md Inbox: "Launch approved for [DATE]"
- [x] Launch proceeds at 12:00 PM Central on target date

**Target launch:** 2026-04-24 (flexible ±1 day based on Designer batch + Jim approval)
