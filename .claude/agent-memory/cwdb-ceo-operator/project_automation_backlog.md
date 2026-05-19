---
name: Automation backlog — what runs itself vs what's still manual
description: The running list of operational tasks to automate, ordered by priority
type: project
---

# Automation Backlog

**Why this exists:** Operating Principle 5 is "automation first." James's entire thesis for this business is passive income, which means every manual task is either (a) an automation candidate or (b) a reason the business isn't yet passive. The CEO owns this list and drives it down weekly.

**How to apply:** Any task the CEO or James performs more than twice should move to this backlog with a priority. Review in each Monday's Honest Assessment. If the same manual task is still on the list 3 weeks later, escalate to Mentor Check.

## Already automated ✅
- Daily briefing generation (this agent, every session)
- Webflow page builds (Webflow MCP + local HTML sync)
- Contractor agreement generation (skill: contractor-onboarding.md)
- DocuSign send via script (/sales/contractor-agreements/generate_and_send.py)
- CMS content management (Webflow CMS collections)

## In-flight (to ship during Phase 1)
- **Lead capture pipeline:** form → Make → qualification → HubSpot deal → SMS/email contractor. Spec at /operations/make/webhooks.json. Owner: lead-routing agent.
- **Analytics stack:** GA4 + GTM + pixels + Clarity. Owner: analytics + web-dev.
- **Contractor billing on accepted bid:** generate invoice, send to contractor, track payment. Owner: accounting.
- **Nextdoor monitoring:** catch "who built your deck?" posts and reply with CTA. Owner: market-research.

## Phase 2 backlog (post-ads-live)
- Weekly P&L auto-generation → /finance/pl/ (accounting)
- Weekly funnel + channel performance report → /finance/reports/performance/ (analytics)
- Lead quality scoring retrain based on accepted-bid outcomes (lead-qualification + revenue-optimization)
- Contractor performance scorecards (close rate, response time) (revenue-optimization)
- Auto-follow-up to unconverted homeowner leads (lead-routing)
- Spam/bot filtering layer on form submissions (lead-qualification)
- Alert system for campaigns exceeding CPL ceiling (ad-campaign + revenue-optimization)

## Still manual (acceptable for now, automate when volume justifies)
- Paste-jobs that require Webflow designer (JSON-LD, calculator.js) — MCP limitation
- Physical photo assets (gallery) — need real-world deck photos, not stock
- Final site-publish approval (brand-sensitive, stays human)
- Pricing changes (strategic, stays human)
- New trade / new city expansion decisions (strategic, stays human)

## Never automate (explicitly human)
- Contract signing
- Bank account / LLC decisions
- Brand identity (name, domain, logo)
- Pricing model changes
- Hiring real humans or vendors

## CEO's weekly automation ritual
Every Monday:
1. Scan this list — what moved last week? Update status.
2. Identify 1 automation to ship this week. Assign it.
3. If a manual task hit its 3rd repetition, move it onto the in-flight list.
