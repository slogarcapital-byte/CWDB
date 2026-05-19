---
type: reference
tags:
  - type/reference
  - phase/1-validation
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Phase 1 Planning Document — CWDB Lead Generation
**Prepared for:** CEO Review
**Date:** March 11, 2026
**Status:** In progress — contractor commitment secured ✅
**Goal:** Deliver the first qualified deck project lead to a paying contractor.

---

## What We're Building (Plain English)

We're starting a business that connects homeowners who want a deck built with local deck contractors who want more customers.

**How money is made:**
- A homeowner fills out a form asking for a deck quote
- We capture that as a "lead" and send it to a contractor
- The contractor bids the job. When the homeowner accepts their bid, the contractor pays us $1,000
- We spent maybe $20–$60 per lead in ads; at a 20% close rate that's ~$300 per accepted bid in ad cost
- We keep the difference — roughly $700 profit per accepted bid

**Phase 1 is about proving this works before spending big money.**

We do NOT start running ads until we have a contractor lined up who will pay for leads. That is the number one rule.

---

## Starting Point (Current State)

| Item | Status |
|---|---|
| Business strategy and plans | Done — documented |
| AI agent instructions | Done — all 9 agents defined |
| Ad copy written | Done — Google, Facebook, Nextdoor, TikTok |
| Landing page template | Done — HTML template ready |
| Lead form questions | Done — schema defined |
| Automation workflow | Done — on paper, not built yet |
| Contractor outreach scripts | Done — call + email scripts ready |
| Tools ([[HubSpot]], [[Webflow]], etc.) | DONE ✅ |
| Contractors contacted | 1 COMMITTED ✅ ($1,000/accepted bid) |
| Money spent | ZERO |

**Bottom line:** The blueprint is complete. Now we build the house.

---

## Budget & Time

**Available budget:** $1,500–$5,000
**Available time:** 5–15 hours/week
**Brand name:** [[Central Wisconsin Deck Builders LLC|Central Wisconsin Deck Builders]] | **Domain:** cwdeckbuilders.com (GoDaddy) ✅

**Recommended budget allocation:**
| Item | Estimated Cost |
|---|---|
| Webflow Starter plan | ~$14/mo |
| [[Make]] (free tier to start) | $0 |
| [[HubSpot]] (free tier) | $0 |
| Tally (free) | $0 |
| Google Ads — test campaign | $300–$500 |
| Facebook Ads — test campaign | $200–$400 |
| Nextdoor Ads — test campaign | $100–$200 |
| Domain name | ~$15 ✅ cwdeckbuilders.com (GoDaddy) |
| Misc (Twilio SMS, etc.) | ~$20/mo |
| **Total to launch** | **~$700–$1,200** |

We have significant budget headroom. The extra $500–$4,000 stays as reserve for scaling once the first lead is delivered.

---

## Phase 1 Overview

Phase 1 has **5 sub-phases** that run roughly 6 weeks total.

```
Week 1       Weeks 1–2     Weeks 2–4     Weeks 3–5     Week 5–6
[SETUP]  →  [OUTREACH]  →  [BUILD]    →  [LAUNCH]   →  [DELIVER]
```

Sub-phases 2 (Outreach) and 3 (Build) overlap intentionally — we start building while outreach is happening so we don't lose time.

---

## Sub-Phase 1: Foundation Setup
**Timeline:** Week 1 (est. 5–8 hours)
**Owner:** CEO
**Goal:** Get all tools accounts created and configured.

### What "Foundation Setup" means
Think of this like setting up the office before opening a store. We need the software tools live and connected before anything else can happen.

### Tasks

**1.1 — Pick a brand name** ✅ DONE
- **Brand name:** Central Wisconsin Deck Builders (CWDB internally)

**1.2 — Register a domain** ✅ DONE
- **Domain:** cwdeckbuilders.com — registered on GoDaddy

**1.3 — Create accounts** ✅ DONE
- HubSpot (free): `hubspot.com` → free CRM to track contractors and leads
- Webflow (Starter ~$14/mo): `webflow.com` → website/landing page builder
- Tally (free): `tally.so` → lead capture form
- Make (free): `make.com` → automation (connects form to CRM and sends lead alerts)

**1.4 — Set up HubSpot pipeline** ✅ DONE
- Created 8 deal stages in HubSpot (from `/sales/crm/pipeline-stages.json`)
- First committed contractor entered as "Closed — Active" deal

### Success Criteria ✅ COMPLETE
All 4 accounts created. Domain registered. Brand name decided. HubSpot pipeline configured.

---

## Sub-Phase 2: Contractor Outreach
**Timeline:** Weeks 1–3 (est. 10–20 hours total)
**Owner:** CEO
**Goal:** Contact 10–20 deck contractors. Secure at least 1 commitment to buy leads.

### What "Contractor Outreach" means
Before we spend a single dollar on ads, we need to confirm that a real contractor will actually pay for leads. This is the most important step in Phase 1.

Think of it like testing if people want your product before opening a restaurant. You ask first. Then you cook.

### Where to Find Contractors
1. Google search: "deck builders [[Wausau]] WI" — call everyone on the first 2 pages
2. Google Maps: Search "deck contractor" near Wausau — look at every pin
3. Yelp and Angi listings for deck builders in Central WI
4. Facebook: Search "deck builder Wausau" — local groups and pages
5. Drive around looking for job site signs (seriously — this works)

Target: 20 businesses contacted in the first 2 weeks.

### What to Say

**By phone (call script already written at `/sales/outreach/call-script.md`):**

Short version of the pitch:
> "Hi, I run a digital marketing company that generates deck project leads in Central Wisconsin. I'm looking for one deck contractor per area to get exclusive access to these leads. Would you be interested in a conversation about that?"

Key points:
- Pricing model: $1,000 per accepted bid (contractor pays only when they WIN the job)
- Territory model: One contractor per city gets all the leads
- Trial offer: Send them a free sample lead first if they're on the fence

**By email (template already written at `/sales/outreach/email-template.md`):**
- Send after calling if no answer
- Follow up 3 days later if no response

### Tracking Outreach in HubSpot
Every contractor contacted gets added to HubSpot as a "contact" and moved through the pipeline stages:
1. Prospect Identified → 2. Outreach Sent → 3. Connected → 4. Trial Lead Sent → 5. Proposal Sent → 6. Closed

### Pricing Strategy
Primary model (confirmed with first contractor):
- **Pay per accepted bid: $1,000** — contractor pays only when they win the job from our lead
  This is zero-risk for contractors: no charge for leads that don't convert.

Secondary model (available if needed):
- **Monthly territory license:** flat monthly fee for exclusive territory access

### Success Criteria ✅ COMPLETE
At least 1 contractor verbally agrees to pay for leads AND we have their contact info, service area, and payment method ready.
**DONE — first contractor committed at $1,000 per accepted bid.**

---

## Sub-Phase 3: System Build
**Timeline:** Weeks 2–4 (runs parallel to outreach, est. 8–12 hours)
**Owner:** CEO
**Goal:** Build the lead capture system so it's ready to go live when ads launch.

### What "System Build" means
This is building the actual machinery:
1. A webpage that homeowners land on
2. A form they fill out
3. Automation that takes the form submission, scores it, and sends it to the contractor

Think of it like a vending machine. The landing page is the front panel. The form is the button they press. The automation is the mechanism that delivers the product.

### 3A: Build the Tally Form ✅ DONE (2026-03-28)
**Form ID:** 81GbEO
**Share URL:** https://tally.so/r/81GbEO
**What it is:** A simple online form homeowners fill out to request a deck quote
**Where:** tally.so (free account)
**Note:** Post-submit message requires Tally Pro. Using Webflow redirect to `cwdeckbuilders.com/thank-you` instead.

**To run:**
1. Get your Tally API key: tally.so → Account Settings → API Keys
2. Open PowerShell and run:
   ```powershell
   cd "...\CWDB\operations\leads"
   .\create-tally-form.ps1 -ApiKey "YOUR_API_KEY"
   ```
3. Copy the Share URL and Embed code from the output.

Script location: `/operations/leads/create-tally-form.ps1`
Form ID (after running): `/operations/leads/tally-form-id.txt`

**Fields created by the script:**
1. Full name
2. Phone number (US format)
3. Email address
4. Property address
5. Do you own this property? (Yes/No — renter filtering handled by Make in 3C)
6. Project type (new build, replacement, repair, addition, not sure)
7. Budget range (Under $5K / $5K–$10K / $10K–$20K / $20K–$40K / $40K+)
8. Timeline (ASAP / 1–3 months / 3–6 months / just planning)
9. Additional notes (optional)

**Time estimate:** ~15 minutes (get API key + run script + verify in browser)

### 3B: Build the Full CWDB Website ← EXPANDED (2026-03-29)
**What it is:** A complete 21-page website replacing the original single landing page.
**Where:** webflow.com
**Full plan:** `/business-context/website-plan.md`
**Design system:** `/website/design-system.md`
**Site architecture:** `/website/site-architecture.md`

**Key tech stack change:** Webflow native forms replace Tally (confirmed 2026-03-29). The existing Tally form (ID: 81GbEO) is superseded.

The website serves as both a high-converting lead gen machine AND a local authority site for organic SEO growth.

**Pages at launch (21 total):**
- Homepage, Get a Quote, Thank You (core conversion)
- 5 city pages: Wausau, [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]] (SEO)
- Our Builders, About, Gallery, FAQ (trust & authority)
- Deck Cost Calculator (interactive engagement)
- Blog + 4 articles (organic traffic)
- Privacy, Terms (legal)

**Form tool:** Webflow native form (9 fields, same as original Tally spec)
**Form flow:** Webflow form → Make webhook → lead scoring → contractor notification

Key rules:
- Dark & bold visual design (Timber Slate dominant, Wisconsin Sky Blue accent)
- Mobile-first with sticky CTA bar and click-to-call
- Full analytics from day one: GA4, GTM, Meta Pixel, Nextdoor Pixel, Clarity
- Fully unique content on all 5 city pages (no templates)

**Build sequence:** Design system → Core pages → City pages → Authority pages → Interactive + blog → SEO/analytics → Mobile QA

**Reference files:**
- All page content: `/website/pages/*/content.md`
- Base HTML template: `/website/templates/base.html`
- Cost calculator JS: `/website/pages/cost-calculator/calculator.js`

**Time estimate:** 15–25 hours (expanded scope from original 3–5 hours)

### 3C: Build the Make Automation
**What it is:** The behind-the-scenes workflow that fires every time someone submits the form
**Where:** make.com
**Workflow spec already exists** at `/operations/make/webhooks.json`

What it does step-by-step:
1. Tally form submitted → Make receives the data automatically
2. Make checks if the lead is qualified (homeowner? In territory? Real phone?)
3. If qualified: Emails the contractor with lead details + sends SMS alert
4. Creates a deal record in HubSpot automatically
5. If not qualified: Logs the reason, notifies admin

**Time estimate:** 2–4 hours (need a Make account and basic familiarity)

### Success Criteria
- Tally form live with a working URL
- Webflow page published with brand name and Tally form embedded
- Make automation built and tested with a dummy submission
- Full flow tested: Submit form → contractor receives email notification within 5 minutes

---

## Sub-Phase 4: First Ad Campaign
**Timeline:** Weeks 3–5 (est. 3–5 hours setup, then monitoring)
**Owner:** CEO
**Goal:** Drive homeowner traffic to the landing page. Generate form submissions.

### What "First Ad Campaign" means
We pay Google and/or Facebook to show ads to homeowners in Central Wisconsin who might want a deck. When they click the ad, they land on our page and (hopefully) fill out the form.

Think of it like fishing. The ad is the bait. The landing page is the hook. The form submission is catching the fish.

### Starting Budget Recommendation
- **Total first month:** $700–$1,100
- **Google Ads:** $300–$500 (higher intent — people actively searching)
- **Facebook Ads:** $200–$400 (broader awareness, lower cost per click)
- **Nextdoor Ads:** $100–$200 (community trust — where homeowners ask neighbors for contractor recs; lower competition = lower CPL)
- Hold TikTok until first lead is delivered — one channel at a time

### Google Ads Setup
**Account:** ads.google.com (free to create, pay only for clicks)

Key settings:
- Campaign type: Search (text ads that appear when someone Googles a keyword)
- Location: Wausau, WI + 30-mile radius
- Keywords to target (ad copy already written at `/marketing/google-ads/ad-copy.md`):
  - "deck builders Wausau WI"
  - "deck contractor near me"
  - "deck quote central Wisconsin"
  - "deck installation Wausau"
- Daily budget: $10–$20/day to start
- Headline examples: "Get a Free Deck Quote Today" | "Wausau Deck Builders" | "Local Licensed Contractors"

### Facebook/Instagram Ads Setup
**Account:** Meta Business Suite (free to create)

Key settings:
- Campaign type: Lead Generation
- Location: Wausau + 30 miles
- Age: 30–65
- Interests: Home improvement, outdoor living, decks/patios, HGTV, Home Depot
- Budget: $10–$15/day
- 3 ad angles to test (copy already written at `/marketing/facebook-ads/ad-copy.md`):
  1. Social proof: "Hundreds of homeowners in Wausau got free deck quotes this year..."
  2. Problem/solution: "Still waiting on a deck contractor to call you back?"
  3. Seasonal urgency: "Book your deck build now before spring fills up"

### Nextdoor Ads + Organic Setup
**Account:** Nextdoor for Business (nextdoor.com/business)
**Why:** Market research confirms Nextdoor is the primary platform where homeowners go for contractor recommendations. Lower ad competition than Google/Facebook = lower CPL.

**Paid Ads (Nextdoor Local Deals):**
- Targeting: Zip codes 54401, 54403, 54476, 54474, 54455, 54452 (all 5 service cities)
- Homeowner filter: Yes
- Budget: $5–$10/day
- Ad copy already written at `/marketing/nextdoor/ad-copy.md`

**Organic / Free tactic (Phase 1 priority):**
- Create a personal Nextdoor profile in Wausau area neighborhoods
- Monitor posts where homeowners ask: "Does anyone know a good deck builder?" or "Who built your deck?"
- Reply with a helpful message directing them to the landing page for a free quote
- This costs $0 and can generate leads before ads are even running
- Do this in Week 1–2 before ads launch

### What to Watch
- **Click-through rate (CTR):** How many people click after seeing the ad (goal: >2%)
- **Cost per click (CPC):** What each click costs (expect $2–$8 on Google, $1–$4 on Facebook)
- **Form submissions:** Most important number — how many people filled out the form
- **Cost per lead (CPL):** Ad spend ÷ number of form submissions (goal: <$60)

### Success Criteria
At least 5–10 form submissions in first 2 weeks of running ads.

---

## Sub-Phase 5: First Lead Delivered
**Timeline:** Week 5–6 (ongoing from launch)
**Owner:** CEO + Make automation
**Goal:** Deliver 1 qualified lead to a contractor. Collect first payment.

### What "First Lead Delivered" means
A homeowner filled out the form. The Make automation scored it as qualified. It fired an email and SMS to the contractor. The contractor received the lead details and called the homeowner.

That is the finish line for Phase 1.

### Lead Qualification Criteria (from `/operations/leads/scoring-rules.json`)
A lead passes if it scores 60+ points out of 100:
- Homeowner confirmed (30 pts) — REQUIRED
- In service territory (20 pts) — REQUIRED
- Valid US phone number (10 pts) — REQUIRED
- Budget $5,000+ (20 pts)
- Near-term timeline — within 6 months (20 pts)

Auto-disqualified if: renter, outside territory, invalid phone, duplicate within 30 days.

### What the Contractor Receives
Within 5 minutes of form submission:
- Email with: name, phone, address, project type, budget, timeline, notes
- SMS alert: "New deck lead — [Name], [City], $[Budget] budget. Check email."
- HubSpot deal record created automatically

### Collecting Payment
Pay per accepted bid model:
1. Send the lead to the contractor
2. Follow up 24–48 hours later: "Did you reach them? Any questions?"
3. Check in again after 1–2 weeks: "Did they accept your bid?"
4. When contractor confirms the homeowner accepted their bid → invoice $1,000 via email
5. Payment via Venmo, Zelle, or check to start — no need to set up complex billing yet

### Success Criteria
1 qualified lead delivered. Contractor received it, confirmed receipt, and paid the invoice.

---

## 30-Day Execution Timeline

| Week | Hours | Focus | Key Deliverable |
|---|---|---|---|
| Week 1 | 5–8 hrs | Setup + Start Outreach | All 4 accounts live, 5+ contractors called |
| Week 2 | 5–8 hrs | Outreach + Start Build | 15+ contractors called, Tally form live |
| Week 3 | 5–8 hrs | Build + 1st Contractor Commit | Webflow page live, Make automation built |
| Week 4 | 3–5 hrs | Launch Ads | Google Ads + Facebook Ads running |
| Week 5 | 2–3 hrs | Monitor + Optimize | First form submissions coming in |
| Week 6 | 1–2 hrs | Deliver | First qualified lead delivered and paid |

**Total Phase 1 hours:** ~25–40 hours over 6 weeks
**Total Phase 1 spend:** ~$700–$1,200
**Phase 1 revenue goal:** $1,000 (first accepted bid payment)

---

## Risk Register

| Risk | Likelihood | What To Do |
|---|---|---|
| Contractors say no or don't respond | Medium | Contact 20 not 10. Adjust pricing. Offer free trial lead. |
| Low form submissions from ads | Medium | Improve landing page headline. Increase budget. Test different ad angles. |
| Leads disqualified as spam | Low | Review scoring rules. Adjust form questions if needed. |
| Make automation breaks | Low | Test with dummy submission before going live. Keep admin backup notification. |
| No paying contractor after 3 weeks | Low | Try adjacent market (Stevens Point, Eau Claire). Consider roofing as alternative niche. |

---

## Definition of Done for Phase 1

Phase 1 is complete when **all three** of these are true:
1. At least 1 contractor is signed up and has agreed to pay for leads
2. The full lead capture system is live (page + form + automation)
3. At least 1 qualified lead has been delivered to that contractor

Everything after this is Phase 2: scaling to 20–50 leads/month.

---

## Next Steps

~~1. Decide on brand name~~ ✅ Central Wisconsin Deck Builders
~~2. Register domain~~ ✅ cwdeckbuilders.com (GoDaddy)
~~3. **Create all 4 accounts** (HubSpot, Webflow, Tally, Make)~~ ✅ Done
~~4. **Set up HubSpot pipeline**~~ ✅ Done — 8 stages configured, first contractor entered
5. **Sub-Phase 1 complete — move to Sub-Phases 2 + 3 in parallel:**
   - Continue contractor outreach — script at `/sales/outreach/call-script.md`
   - Build Tally form — fields at `/operations/leads/quote-form-fields.json`

---

*Document version: 1.0 | Phase: 1 — Validation | Prepared by: Claude Code (CWDB AI OS)*
