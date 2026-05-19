---
title: Phase 1 Roadmap — Central Wisconsin Deck Builders
status: in-progress
phase: "1 — Validation"
target-completion: 2026-04-30
last-updated: 2026-04-17
updated-by: CEO Operator
owner: James Slogar (Sole Member)
ceo-agent: cwdb-ceo-operator
tags:
  - cwdb
  - phase-1
  - roadmap
  - validation
  - active
aliases:
  - Phase 1 Roadmap
  - CWDB Roadmap
cssclasses:
  - roadmap
---

# Phase 1 Roadmap — Central Wisconsin Deck Builders

> [!abstract] Purpose
> Single source of truth for Phase 1 execution. James checks items off as they land. CEO agent updates state each session. Both parties leave feedback inline via callouts. If it's not on this page, it's not committed.

> [!tip] How to use this note
> - James: check boxes, drop feedback callouts in the **James Feedback Log**, reply to any **⚠ NEEDS JAMES** item by flipping its status.
> - CEO agent: update **Master Checklist**, **Blockers Board**, **Unit Economics Scorecard**, **Contractor Pipeline**, and **Mentor Notes** at the start of every session. Log every major decision in the **Decision Log**. Queue the next pickup in **Next Session Pickup**.
> - Dates are `YYYY-MM-DD`. Today is `2026-04-16`.

---

## 1. Phase 1 Goal — Definition of Done

Phase 1 is complete when three conditions are simultaneously true: (1) at least one contractor agreement is signed, countersigned, and active under the $1,000-per-accepted-bid pricing model; (2) the end-to-end lead capture system is live in production — homeowner submits the form on `cwdeckbuilders.com`, the lead is qualified, routed via [[Make]] to [[HubSpot]], and delivered to the correct contractor by SMS and email within 5 minutes; and (3) at least one qualified homeowner lead has been delivered to a contractor, won as a job, and invoiced + paid at $1,000. Until all three are true, the business has not validated that contractors will actually pay for our leads.

**Target date:** `2026-04-30` (two weeks from today — aligned with James's "ads running this week" directive, plus a buffer for first-lead conversion).

---

## 2. Master Checklist

> [!info] Sub-phase structure
> Five sub-phases, sequenced. Foundation and Outreach have been compounding for 5+ weeks — they are mostly done. Build, Launch, and Deliver are where the next two weeks of attention go.

### Foundation — Legal, Brand, Website Skeleton

- [x] Form Wisconsin LLC (Central Wisconsin Deck Builders, LLC) — `2026-04-06`
- [x] Obtain EIN (41-5355234) and Wisconsin Entity ID (C138564)
- [x] Confirm brand name, domain (`cwdeckbuilders.com`), logos, color palette — `2026-03-28`
- [x] Build website design system + site architecture — `2026-03-29`
- [x] Webflow Phase A — global styles, header, footer, core components — `2026-04-02`
- [x] Webflow Phase B — homepage, Get a Quote, Thank-You — `2026-04-02`
- [x] Webflow Phase C — Service Areas CMS + 5 city pages (Wausau, Schofield, Weston, Mosinee, Merrill) — `2026-04-03`
- [x] Webflow Phase D — About, FAQ, Gallery, Our Builders — `2026-04-03`
- [x] Webflow Phase E — Cost Calculator, Blog index, 4 blog articles — `2026-04-03`
- [x] Draft contractor agreement v1 — sent via DocuSign

### Outreach — Contractor Acquisition

- [x] Validate pricing model with a real contractor (Ben Barton, $1,000/accepted bid) — `2026-03-12`
- [x] Send contractor agreements via DocuSign to Ben Barton + John Garcia — `2026-04-07`
- [x] ⚠ Receive signed contractor agreement back from Ben Barton
- [x] ⚠ Receive signed contractor agreement back from John Garcia
- [x] Chase outstanding signatures (nudge email every 3–4 days; phone call after 2 nudges)
- [x] Territory routing model decided — group text, first responder gets the lead — `2026-04-17` (see Decision Log)
- [ ] Expand outreach to bring 3–5 more contractors into pipeline (bench redundancy)
- [ ] Contact 10–20 total deck contractors (currently 2)

### Build — Analytics, Privacy, Automation, CRM

- [ ] **Webflow Phase F — SEO & analytics** (meta tags, JSON-LD) — delegate to [[web-dev]]
- [ ] Install GTM, GA4, Meta Pixel, Nextdoor Pixel, Google Ads Conversion, MS Clarity — delegate to [[analytics]]
- [x] Build `/privacy` page — **go-live blocker** — `2026-04-17` ✅
- [x] Source phone number — `(715) 544-7941` — `2026-04-17` ✅
- [ ] Add phone number `(715) 544-7941` to site header, footer, and Get a Quote page
- [ ] Build [[Make]] scenario: form webhook → qualification → [[HubSpot]] deal → SMS/email contractor — delegate to [[lead-routing]] 
- [ ] Configure [[HubSpot]] deal pipeline + lifecycle stages — delegate to [[contractor-sales]] + [[lead-routing]]
- [ ] Manual paste: FAQPage JSON-LD into FAQ page head in Webflow Designer
- [ ] Manual paste: Article JSON-LD into blog template page head
- [ ] Manual paste: `calculator.js` (241 lines) into `/cost-calculator` Custom Code → Before `</body>`
- [ ] Replace gallery placeholder stock photos with real Wisconsin deck photos

### Launch — Site Live, Ads On

- [ ] ⚠ **Publish Webflow site to `cwdeckbuilders.com`** — **NEEDS JAMES approval**
- [ ] Set up Nextdoor business account + start monitoring neighborhood posts — delegate to [[market-research]]
- [ ] Launch Google Ads campaign (target CPL <$60) — delegate to [[ad-campaign]]
- [ ] Launch Facebook/Instagram Ads campaign — delegate to [[ad-campaign]]
- [ ] Launch Nextdoor Ads campaign — delegate to [[ad-campaign]]
- [ ] ⚠ Approve initial ad budget allocation (recommended: $50/day across 3 channels = ~$1,500/mo) — **NEEDS JAMES**

### Deliver — First Lead to First Paid Bid

- [ ] Receive first form submission from live site
- [ ] Verify end-to-end lead flow: form → Make → qualification → HubSpot → contractor SMS/email
- [ ] Confirm contractor bids on the lead
- [ ] Homeowner accepts contractor bid
- [ ] Generate and send first $1,000 invoice to contractor — delegate to [[accounting]]
- [ ] Collect first $1,000 payment — **Phase 1 validated** ✅

---

## 3. Blockers Board

> [!warning] Hard blockers — ads cannot launch until these are zero
> Any blocker sitting ≥3 days with no movement triggers a Mentor Check in the daily briefing.

| # | Blocker | Owner | Status | Opened | Days Out | Severity |
|---|---|---|---|---|---|---|
| 1 | Webflow Phase F — analytics stack (GTM, GA4, pixels, Clarity) not installed | [[web-dev]] + [[analytics]] | In progress | 2026-04-03 | 14 | Hard |
| 2 | ~~`/privacy` page not built~~ | [[web-dev]] | ✅ Cleared 2026-04-17 | 2026-04-03 | — | — |
| 3 | ~~Phone number not sourced~~ | James | ✅ Cleared 2026-04-17 — `(715) 544-7941` | 2026-04-03 | — | — |
| 4 | Site not published to `cwdeckbuilders.com` | James (approval) | Pending approval | 2026-04-03 | 14 | Hard |
| 5 | Make scenario not built | [[lead-routing]] | In progress | 2026-04-03 | 14 | Hard |
| 6 | HubSpot deal pipeline not configured | [[contractor-sales]] + [[lead-routing]] | In progress | 2026-04-03 | 14 | Hard |
| 7 | FAQPage JSON-LD paste-job | James (browser) | Pending | 2026-04-03 | 14 | Manual |
| 8 | Article JSON-LD paste-job | James (browser) | Pending | 2026-04-03 | 14 | Manual |
| 9 | `calculator.js` paste-job (241 lines) | James (browser) | Pending | 2026-04-03 | 14 | Manual |
| 10 | Phone number not yet added to site | [[web-dev]] | Pending | 2026-04-17 | 0 | Hard |
| 11 | ~~Ben Barton signature not returned~~ | CEO | ✅ Cleared 2026-04-17 | 2026-04-07 | — | — |
| 12 | ~~John Garcia signature not returned~~ | CEO | ✅ Cleared 2026-04-17 | 2026-04-07 | — | — |
| 13 | Only 2 contractors in pipeline — no bench | [[contractor-sales]] | Not started | 2026-04-03 | 14 | Soft |
| 14 | ~~Territory assignments undefined~~ | CEO | ✅ Cleared — group text first-response model adopted 2026-04-17 | 2026-04-07 | — | — |
| 15 | Gallery photos still placeholder stock | James (asset source) | Pending | 2026-04-03 | 14 | Manual |

> [!success] Progress since 2026-04-16
> Four blockers cleared in one day: `/privacy` page done, phone number confirmed, both contractor signatures received. Hard blocker count: 6 → 3. Remaining hard path: analytics stack + site publish + Make + HubSpot + phone number on site.

> [!warning] Still blocking ads-live
> Blockers 1, 4, 5, 6, 10 must all clear before ads can run. Blockers 5 and 6 are in-progress with specialist agents. Blocker 4 (site publish) is the only remaining James-only gate.

---

## 4. Unit Economics Scorecard

> [!info] How to read this table
> Targets are fixed by the business model. Actuals stay N/A until ads run. The CEO updates Actuals weekly once data flows. Any actual that drifts from its target by more than 25% triggers a Mentor Check.

| Metric | Target | Actual (latest) | Updated | Status |
|---|---|---|---|---|
| Cost per lead (CPL) | <$60 | N/A — ads not live | — | Pending |
| Revenue per accepted bid | $1,000 | N/A — no bids yet | — | Contracted |
| Contractor close rate | ~20% | N/A | — | Pending |
| Cost per accepted bid | <$400 | N/A | — | Pending |
| Margin per accepted bid | ~$700 | N/A | — | Pending |
| Advertising ROI | 2x+ | N/A | — | Pending |
| Ad spend to date | — | $0 | 2026-04-16 | — |
| Leads captured to date | — | 0 | 2026-04-16 | — |
| Accepted bids to date | — | 0 | 2026-04-16 | — |
| Revenue to date | — | $0 | 2026-04-16 | — |

**Math sanity check (target state):** 20 leads/mo × 20% close × $1,000 = $4,000 revenue. At $60 CPL: $1,200 ad spend → $2,800 gross margin. One accepted bid covers a full month of ad spend at target CPL. That's the floor we need to hold.

---

## 5. Contractor Pipeline

| Name | Company | HubSpot ID | Sent | Status | Territory | Days Out |
|---|---|---|---|---|---|---|
| Ben Barton | Barton Builders LLC | 462464338657 | 2026-04-07 | ✅ Signed | Shared pool — group text, first response | — |
| John Garcia | John Garcia Construction, LLC | 465926077160 | 2026-04-07 | ✅ Signed | Shared pool — group text, first response | — |
| *(expand bench)* | — | — | — | Not contacted | — | — |
| *(expand bench)* | — | — | — | Not contacted | — | — |
| *(expand bench)* | — | — | — | Not contacted | — | — |

> [!check] Both contractors signed ✅ — 2026-04-17
> Validated pricing model, two active agreements. Routing model is group text / first-response. See Mentor Notes for CEO's assessment of trade-offs.

> [!warning] Bench still thin — run outreach in parallel with launch
> Two contractors is functional for launch. Not resilient. Outreach to 3–5 more is in-flight with [[contractor-sales]] — doesn't block ads-live.

Sales materials ready at `/sales/outreach/` (call script, email template) and `/sales/onboarding/` (contractor profile template). Outreach to delegate to [[contractor-sales]].

---

## 6. Mentor Notes

> [!note] CEO — 2026-04-17
> **Good day. Now let's talk about the group text model.**
>
> Both contractor signatures are in, the phone number is confirmed, and the `/privacy` page is done. That's four blockers cleared in 24 hours after 13 days of stall. Hard blocker count is down from 6 to 3. That's real progress and worth acknowledging.
>
> **The group text / first-response routing model — here's my honest read:**
>
> *What's good about it:* Simple, zero infrastructure required to start. Creates urgency and natural competition between Ben and John. Works with 2 contractors and James's existing phone. No territory map to maintain or negotiate.
>
> *What I'd push back on:* This model has three failure modes you should know before ads run.
>
> **1. Gaming.** Once a contractor figures out that the first responder always wins, they start saying "I'll take it" to every lead — including ones they won't actually pursue hard. You'll end up with leads claimed but not worked. You'll have no visibility into this until close rate data comes back weeks later. Fix for this: track which contractor actually bids on claimed leads. If claimed-but-not-bid rate climbs above ~15%, the model is being gamed.
>
> **2. Manual forever.** Right now you — James personally — send a group text for every lead. That's fine for the first 10. It's not fine at 20 leads/month, and it breaks completely if we add 3 more contractors. This is a Principle 5 violation the moment we scale. I'm already building the Make scenario to fire a simultaneous SMS to all contractors with a claim link — first tap wins. That's the automated version of exactly what you described. We'll run manual for the first few leads to validate, then flip to Make.
>
> **3. Geographic mismatch risk.** Ben lives and works primarily in one area, John in another. If Ben claims a lead 45 minutes from his base because he happened to be faster on the phone, the homeowner may get a worse experience (longer response time to the job site, less familiarity with local subs). Not a launch-blocker — but monitor it. If a pattern emerges, we add a soft territory preference in the routing logic.
>
> **Bottom line:** Group text is the right MVP. Run it. I'll build the automated version in parallel and we flip when volume justifies it — probably around lead 10–15. No action needed from you now. Just know the exit ramp exists and we're building toward it.
>
> **Remaining James-gated item: site publish.** That's the last hard gate that only you can clear. Every other blocker is now in-flight with a specialist agent. When you're ready to go live, one approval in Webflow Designer → cwdeckbuilders.com is live. Say the word and I'll walk you through it in under 5 minutes.

> [!note] CEO — 2026-04-16
> **Phase 1 has stalled on the build phase.** Foundation and Outreach did their jobs — we have an LLC, a brand, a 21-page site on staging, and two contractors committed to a validated pricing model. That's real. But the Build phase has been frozen for 13 days. Six hard blockers opened on `2026-04-03` and none have moved. Phase F analytics, `/privacy`, phone number, site publish, Make scenario, HubSpot pipeline — zero progress, zero dollars of ad spend, zero leads. The business does not make money on a staging site.
>
> **What's actually going on:** the manual paste-jobs (JSON-LD, calculator.js, photos) are waiting on James. The domain publish is waiting on James. The phone number is waiting on James. Four of the ten hard/manual blockers are James-gated. That's the real bottleneck — this isn't a specialist-agent problem, it's a James-inbox problem. James is deferring brand-adjacent decisions that each take ten minutes and together unblock an entire launch.
>
> **What I'm doing about it:** treating the James-gated items as a single batched ask rather than six separate pings — one decision session to clear them together. In parallel, kicking off the non-James-gated work (Make scenario scaffold, HubSpot pipeline config, Phase F analytics spec) with the specialist agents so those aren't waiting on anything.
>
> **The contractor signatures are the other deferral.** 9 days out with zero follow-up from us is on the CEO, not James. That's on me. Nudge going out today via the existing DocuSign thread and a sister email. If no return by `2026-04-21` (14-day mark), we escalate to a phone call — James will need to make at least one of those calls personally because the relationship is his.
>
> **The bench gap is a strategic risk.** Two contractors, both unreturned, zero pipeline. Outreach to 3–5 more contractors needs to start this week, not after ads launch. Principle 2 says validate demand before building — we've been building for five weeks with demand validated by a sample of n=2. That's fragile. [[contractor-sales]] gets the expansion brief today.
>
> **Bottom line for James:** the business is 5–10 billable hours of your time from ads-live. Not 5 weeks. Five hours. Batched. This week. Everything else I can drive.

---

## 7. James Feedback Log

> [!note] James — (date)
> *Reserved for James. Drop reactions, decisions, corrections, or questions here as callouts. One per entry, most recent at the top.*

---

## 8. Decision Log

| Date | Decision | Decided By | Why |
|---|---|---|---|
| 2026-03-12 | Pay-per-accepted-bid at $1,000 (replaced pay-per-lead) | James + Ben Barton | Validated with real contractor willingness-to-pay — higher margin model, fewer billable events, cleaner incentive alignment |
| 2026-03-28 | Brand name "Central Wisconsin Deck Builders" + `cwdeckbuilders.com` | James | Geographic specificity signals local authority; domain available on GoDaddy |
| 2026-03-29 | Expand from single landing page to 21-page authority site | James | SEO authority + conversion quality justifies the build cost; blog + cost calculator add long-term organic value |
| 2026-03-29 | Tally forms dropped → Webflow native forms | James + [[web-dev]] | Simpler stack, better design control, one fewer vendor |
| 2026-04-02 | Webflow MCP protocol — MCP first, then local HTML sync | [[web-dev]] | Ensures live site and local repo stay in sync, avoids drift |
| 2026-04-06 | LLC formed in Wisconsin (single-member) | James | Liability shield; enables contractor contracts in LLC name; S-Corp election window opens |
| 2026-04-07 | Contractor agreements sent to Ben Barton + John Garcia via DocuSign | CEO + James | Two-contractor launch covers five cities with minimal overlap; v1 agreement terms acceptable to both |
| 2026-04-16 | Phase 1 Roadmap established in Obsidian | CEO | Single source of truth for plan execution; replaces ad-hoc checklists in memory files |
| 2026-04-17 | Both contractor agreements signed — Ben Barton + John Garcia | James | DocuSign sent 2026-04-07, returned signed 2026-04-17. Phase 1 condition 1 of 3 met. |
| 2026-04-17 | Lead routing model: group text, first-responder wins | James | No exclusive territories. James sends one group text per lead; first contractor to reply gets it. Manual MVP — automate via Make first-claim SMS at ~lead 10–15. |
| 2026-04-17 | Phone number confirmed: `(715) 544-7941` | James | Business line for site, ads, and contractor communications |

---

## 9. Next Session Pickup

> [!todo] What the CEO should drive at the start of the next session
> 1. Check for any new **James Feedback Log** entries — action them first.
> 2. Status-check in-flight tracks: Phase F analytics ([[web-dev]] + [[analytics]]), Make scenario ([[lead-routing]]), HubSpot pipeline ([[contractor-sales]] + [[lead-routing]]).
> 3. Confirm `(715) 544-7941` has been added to site header, footer, and Get a Quote page by [[web-dev]].
> 4. Update **Blockers Board** — flip anything that cleared.
> 5. Batch single ask for James: approve Webflow staging → production publish (the last hard gate).
> 6. Brief [[contractor-sales]] on group text first-response routing model so outreach scripts and contractor onboarding reflect it correctly.
> 7. Queue Make first-claim SMS automation as a Phase 1 parallel track (don't block launch on it, but start building now).

**In-flight as of `2026-04-17`:**
- Blocker 1: Phase F analytics spec — [[web-dev]] + [[analytics]]
- Blocker 5: Make scenario — [[lead-routing]]
- Blocker 6: HubSpot pipeline — [[contractor-sales]] + [[lead-routing]]
- Blocker 10: Phone number → site — [[web-dev]] (new, actioning now)
- Contractor bench expansion — [[contractor-sales]]

---

## Related Notes

- [[phase-1-plan]] — original Phase 1 plan doc
- [[website-plan]] — 21-page authority site spec
- [[brand-discovery/brand-discovery]] — brand positioning and voice
- [[automation-backlog]] — what's automated vs. manual (to be created)
- Memory index: `.claude/agent-memory/cwdb-ceo-operator/MEMORY.md`
