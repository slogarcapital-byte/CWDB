# Trades Lead Generation AI Operating System

## Daily Operating System (read first each session)

- **Today's brief:** `_vault/briefs/<today>.md` (auto-generated 7:03 AM Central via in-session cron + SessionStart check)
- **Yesterday's brief:** `_vault/briefs/<yesterday>.md` — sealed; carries Jim's `[x]` marks + `%...%` comments forward into today's
- **Project board:** `_vault/board/{directives,in-flight,shipped,killed}.md` — Kanban; ship-type tags `build` / `artifact-prod` / `scheduled-recurring-automation`
- **Brief INDEX:** `_vault/briefs/INDEX.md` · **Board INDEX:** `_vault/board/INDEX.md` (next WB-NNN)
- **Singleton DEPRECATED:** `_vault/state-of-cwdb.md` — read-only historical reference; do not write
- **Migration plan:** `C:\Users\jslog\.claude\plans\cwdb-ceo-operator-agent-once-again-hazy-shamir.md`

## Default Delegation Hierarchy (CEO behavior)

Every Top-3 daily brief item must be classified by tier:
1. **Tier 1 — Recipe (default):** Specialty agents own execution. CEO orchestrates only.
2. **Tier 2 — Hybrid:** Mostly automated, minimal Jim touch.
3. **Tier 3 — User-driven:** Jim must do this manually. Requires written justification.

When Agent tool unavailable: CEO diagnoses + attempts fix first; if still blocked, BLOCK + FLAG affected items. Never silently fall back to direct execution.

24h default-ship rule: CEO ships autonomously at deadline, then writes a "Shipped Without Asking" entry in the brief listing what + where + how to roll back.

## Mission

Build and operate a scalable lead generation engine that generates homeowner project leads and sells them to contractors.

Initial focus is **deck building leads in Central Wisconsin** with the potential to expand into additional trades and territories.

The system is designed to operate with minimal human intervention using AI agents and automation.

Primary objective:

Generate profitable contractor leads and scale across markets.

---

# Business Model

Homeowners request quotes for construction projects.

The system captures the lead and sells it to contractors.

Revenue models:

1. Pay per accepted bid (primary — contractor pays $1,000 when they win a job from our lead)
2. Territory licensing (secondary)
3. Multi contractor lead marketplace

Example economics:

Average ad cost per lead: $20–$60
Revenue per accepted bid: $1,000
Estimated cost per accepted bid (at 20% contractor close rate): ~$300

Target margin: ~$700 per accepted bid.

---

# Initial Market

Primary niche:

Deck Builders

Initial geographic market:

Central Wisconsin

Cities:

- Wausau
- Schofield
- Weston
- Mosinee
- Merrill

Expansion markets:

- Eau Claire
- Appleton
- Green Bay
- Stevens Point
- Madison
- Minneapolis suburbs

---

# System Architecture

Traffic Sources  
→ Landing Pages  
→ Quote Request Form  
→ Lead Qualification  
→ Lead Routing  
→ Contractor Delivery  
→ CRM Tracking  
→ Billing

All stages should be automated.

---

# Core Technology Stack

Advertising Platforms

- Google Ads
- Facebook / Instagram Ads
- TikTok
- Nextdoor (primary community channel — where homeowners go for neighbor contractor recommendations)

Landing Pages

- Webflow

Automation

- Make (formerly Integromat)

CRM

- HubSpot (free tier)

Lead Forms

- Webflow native forms (replaced Tally as of 2026-03-29 — simpler stack, better design control)

Website

- 21-page authority site (see `/business-context/website-plan.md` for full spec)
- Design system: `/website/design-system.md`
- Site architecture: `/website/site-architecture.md`

Future upgrades may include custom infrastructure.

---

# Brand Identity

Brand name: Central Wisconsin Deck Builders
Abbreviated: CWDB (internal use, favicons, small UI only)
Domain: cwdeckbuilders.com (GoDaddy)
Tagline: "Fast Quotes. Trusted Builders."

Color palette:

- `#e54c00`  Crafted Orange    — CTAs, highlights, primary accent
- `#323434`  Timber Slate      — backgrounds, primary text
- `#646760`  Builders Grey     — subheadings, secondary text, borders
- `#83b2cf`  Wisconsin Sky Blue — complementary accent, outdoor feel

Logo files (in /branding/logos/):

- `1.1-primary-logo-high-res.png`    — stacked layout; use for website hero, print, large placements
- `1.2-horizontal-logo-high-res.png` — horizontal layout; use for email signatures, banners, constrained widths

Full brand guidelines: /business-context/brand-discovery/

---

# Project File Structure

The system is organized as a company with agents as employees and folders as departments.

```
CWDB/
├── agents/           EMPLOYEES — AI agent system prompts and configs
├── branding/         BRAND — Logo files and brand assets
├── business-context/ PLANNING — Phase plans and brand discovery docs
├── marketing/        DEPT — Ad campaigns (Google, Facebook, TikTok, Nextdoor)
├── website/          DEPT — Webflow pages and templates
├── sales/            DEPT — Contractor outreach, onboarding, CRM
├── operations/       DEPT — Lead processing, qualification, routing, Make automation
├── finance/          DEPT — P&L statements and performance reports
└── templates/        SHARED — Reusable assets across departments
```

---

# AI Agent System

The system operates through multiple AI agents.

Each agent owns a specific operational function.

---

## Agent 1: Market Research Agent

Responsibilities:

- Identify high demand contractor niches
- Analyze local market demand
- Identify underserved cities
- Estimate lead value by niche
- Monitor Nextdoor neighborhood posts to validate demand in target cities

Outputs:

- Niche opportunity reports
- City expansion recommendations
- Keyword demand analysis

---

## Agent 2: Web Dev Agent

Responsibilities:

- Generate landing page copy
- Build landing page structure in Webflow
- Optimize conversion flow
- Generate CTA messaging
- Embed Tally forms

Typical landing page structure:

Headline
Value proposition
Project examples
Trust signals
Quote request form (Tally)

Goal:

Maximize lead conversion rate.

---

## Agent 3: Ad Campaign Agent

Responsibilities:

- Generate ad creatives
- Manage ad targeting
- Optimize cost per lead
- Scale profitable campaigns

Platforms:

Google Ads
Facebook / Instagram Ads
TikTok
Nextdoor (paid ads + organic community engagement)

Key metric:

Cost per lead.

---

## Agent 4: Lead Qualification Agent

Responsibilities:

- Validate lead quality
- Filter spam submissions
- Confirm homeowner intent
- Capture project details

Collected data:

Name  
Address  
Phone  
Project type  
Budget  
Timeline

Goal:

Ensure contractors receive high quality leads.

---

## Agent 5: Lead Routing Agent

Responsibilities:

- Deliver leads to contractors
- Route based on territory
- Handle multi contractor distribution
- Trigger notifications

Notifications may include:

SMS  
Email  
CRM updates

Automation platform:

Make (formerly Integromat)

---

## Agent 6: Contractor Sales Agent

Responsibilities:

- Identify potential contractor partners
- Generate contractor outreach scripts
- Handle contractor onboarding
- Negotiate pricing

Primary sales model:

Pay per accepted bid.

Example:

Contractor pays $1,000 each time they win a job
sourced from one of our leads (homeowner accepts their bid).

---

## Agent 7: Revenue Optimization Agent

Responsibilities:

- Analyze lead conversion rates
- Optimize pricing models
- Identify profitable markets
- Adjust ad spend allocation

Key metrics:

Cost per lead (ad efficiency)
Revenue per accepted bid (target: $1,000)
Cost per accepted bid (target: <$400)
Contractor retention
Ad ROI

---

## Agent 8: Accounting Agent

Responsibilities:

- Track contractor payments and billing cycles
- Generate and send invoices
- Reconcile ad spend vs. revenue
- Produce monthly P&L statements

Outputs:

P&L statements → /finance/pl/
Performance summaries → /finance/reports/performance/

---

## Agent 9: Analytics Agent

Responsibilities:

- Monitor landing page traffic and conversion rates
- Analyze ad platform performance by channel
- Track lead funnel drop-off points
- Identify top-performing creatives and keywords

Key funnel:

Ad Impression → Click → Page Visit → Form Submit → Qualified Lead → Contractor Delivery

Outputs:

Funnel and channel reports → /finance/reports/performance/

---

# Operating Principles

1. Own the lead asset

Contractors are replaceable.  
The lead flow is the true asset.

---

2. Validate demand before building infrastructure

Do not build complex systems until contractors confirm willingness to pay.

---

3. Focus on one niche first

Start with deck builders before expanding into additional trades.

---

4. Replicate profitable systems

Once a profitable funnel exists, clone it into new cities.

---

5. Automation first

Every operational task should eventually be automated.

---

# Phase 1: Validation

Goal:

Prove contractors will pay for leads.

Steps:

1. Contact 10–20 deck contractors
2. Ask if they would pay for deck project leads
3. Secure at least one contractor commitment ✅ DONE — $1,000/accepted bid (2026-03-12)
4. Confirm brand name and domain ✅ DONE — Central Wisconsin Deck Builders / cwdeckbuilders.com (2026-03-28)
5. Build full 21-page website ← EXPANDED from single landing page (2026-03-29, see `/business-context/website-plan.md`)
6. Run small ad campaign
7. Deliver first leads

Timeline:

30 days.

---

# Phase 2: Profitability

Goal:

Build a stable lead generation funnel.

Targets:

20–50 leads per month.

Revenue target:

$3K–$10K per month.

Focus:

Optimize cost per lead and conversion rates.

---

# Phase 3: Replication

Goal:

Expand geographically.

New cities added once the system proves profitable.

Each new city replicates the same funnel.

---

# Phase 4: Marketplace Expansion

Goal:

Expand into multiple trades.

New verticals may include:

- Roofing
- Bathroom remodels
- Concrete
- Basement finishing
- Pole barns

Multiple contractors receive each lead.

This increases revenue per lead.

---

# Long Term Vision

Create a regional contractor lead marketplace.

Potential revenue scale:

$50K–$150K per month.

Eventually operate across multiple states.

Comparable platforms include:

Angi  
Thumbtack

---

# Success Metrics

Primary metrics:

Cost per lead (ad efficiency)
Revenue per accepted bid
Contractor lifetime value
Lead-to-accepted-bid conversion rate

Target benchmarks:

Cost per lead: <$60
Revenue per accepted bid: $1,000
Cost per accepted bid: <$400
ROI: 2x+ advertising return

---

# Core Strategic Advantage

The system combines:

Digital marketing expertise  
Automation systems  
Fragmented contractor markets

Most contractors lack digital marketing capability.

This creates a strong opportunity to own the lead flow.

---

# End State

The system becomes a scalable lead infrastructure platform serving contractors across multiple trades and cities.