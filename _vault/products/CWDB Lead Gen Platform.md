---
type: product
product-name: CWDB Lead Generation Platform
components:
  - quote-form
  - landing-pages
  - ad-funnels
  - make-automation
  - hubspot-crm
revenue-model: pay-per-accepted-bid
price-point: 1000
tags:
  - type/product
aliases:
  - Lead Gen Platform
  - The Platform
created: 2026-03-11
updated: 2026-04-16
status: active
---

# CWDB Lead Gen Platform

## What It Is
A scalable lead generation engine owned by [[Central Wisconsin Deck Builders LLC]]. Generates homeowner deck project leads in Central Wisconsin and sells them to contractors.

## Revenue Model
**Pay per accepted bid** — contractor pays $1,000 each time they win a job sourced from our lead (homeowner accepts their bid).

### Economics
| Metric | Target |
|--------|--------|
| Ad cost per lead | $20–$60 |
| Revenue per accepted bid | $1,000 |
| Cost per accepted bid (at 20% close rate) | ~$300 |
| **Target margin per accepted bid** | **~$700** |

## System Architecture
```
Traffic Sources → Landing Pages → Quote Form → Lead Qualification → Lead Routing → Contractor Delivery → CRM Tracking → Billing
```

## Tech Stack
| Component | Platform | Status |
|-----------|----------|--------|
| Website | [[Webflow]] (21 pages) | Phases A-E complete |
| Forms | [[Webflow]] native | Built |
| Automation | [[Make]] | Not built |
| CRM | [[HubSpot]] (free tier) | Not configured |
| Ads | [[Google Ads]], [[Meta Ads]], [[Nextdoor]], [[TikTok]] | Not launched |
| Analytics | GA4, GTM, Meta Pixel, MS Clarity | Not configured |
| Contracts | [[DocuSign]] | Active |

## Agents (AI Workforce)
The platform is operated by 11 AI agents:

| Agent | Domain |
|-------|--------|
| [[Market Research Agent]] | Market analysis, city expansion |
| [[Web Dev Agent]] | [[Webflow]] site building |
| [[Ad Campaign Agent]] | Ad creatives, targeting, optimization |
| [[Content Writer Agent]] | Copy, blog posts, brand voice |
| [[Lead Qualification Agent]] | Lead scoring, spam filtering |
| [[Lead Routing Agent]] | Contractor delivery, notifications |
| [[Contractor Sales Agent]] | Contractor outreach, onboarding |
| [[Revenue Optimization Agent]] | Pricing, ROI analysis |
| [[Accounting Agent]] | Billing, P&L, invoicing |
| [[Analytics Agent]] | Funnel tracking, performance |
| [[Legal Compliance Agent]] | Compliance, contracts, privacy |

## Current State
- **Phase:** [[Phase 1 - Validation]]
- **Website:** 21 pages live on staging
- **Contractors:** 2 signed up ([[Ben Barton]], [[John Garcia]])
- **Leads generated:** 0 (pre-launch)
- **Revenue:** $0 (pre-launch)
