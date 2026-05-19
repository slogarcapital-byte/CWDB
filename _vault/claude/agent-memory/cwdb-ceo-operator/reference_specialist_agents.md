---
name: The 9 specialist agents — what each owns and how to delegate
description: Direct-reports map. Who does what, when to hand off, where their memory lives.
type: reference
---

# Specialist Agent Directory (Direct Reports)

The CEO does not do a specialist's job unless the specialist is unavailable or the task is trivial. When delegating, invoke via the Agent tool with the matching subagent_type and give them a self-contained brief.

## 1. market-research
- **Owns:** Demand signals, niche/city expansion candidates, keyword volume, Nextdoor community monitoring, competitor landscape.
- **Delegate when:** Evaluating a new city, validating demand before build, scouting for underserved trades, watching Nextdoor for homeowner "who built your deck?" posts.
- **Memory:** `.claude/agent-memory/market-research/MEMORY.md`

## 2. web-dev
- **Owns:** Webflow site, components, CMS, page builds, forms, design system adherence.
- **Delegate when:** Any site/page change. Phase F analytics installation. /privacy page build. JSON-LD schema additions.
- **Key rules:** Webflow MCP first → sync local HTML. Native forms only (no Tally). Component-first.
- **Memory:** `.claude/agent-memory/web-dev/MEMORY.md`

## 3. ad-campaign
- **Owns:** Google, Facebook, Nextdoor, TikTok creative + targeting + budget allocation + bid management.
- **Delegate when:** Ads-live launch, new creative variants, CPL optimization, audience expansion.
- **Memory:** `.claude/agent-memory/ad-campaign/MEMORY.md`

## 4. lead-qualification
- **Owns:** Scoring rules, spam filter, intent validation, form field tuning.
- **Delegate when:** Leads are converting poorly, spam volume is high, score thresholds need calibration.
- **Memory:** `.claude/agent-memory/lead-qualification/MEMORY.md`

## 5. lead-routing
- **Owns:** Make scenarios, contractor delivery, SMS/email notifications, territory routing logic.
- **Delegate when:** Building the primary Make scenario, routing by city, adding contractors to the pool.
- **Memory:** `.claude/agent-memory/lead-routing/MEMORY.md`

## 6. contractor-sales
- **Owns:** Outreach, onboarding, DocuSign, contractor relationships, HubSpot pipeline.
- **Delegate when:** Chasing signatures, expanding the contractor bench, renegotiating territories, onboarding a new partner.
- **Memory:** `.claude/agent-memory/contractor-sales/MEMORY.md`

## 7. revenue-optimization
- **Owns:** ROI analysis, ad spend allocation, pricing strategy, close-rate tracking, channel mix.
- **Delegate when:** Reallocating budget between channels, evaluating a pricing change, analyzing lead-to-bid conversion.
- **Memory:** `.claude/agent-memory/revenue-optimization/MEMORY.md`

## 8. accounting
- **Owns:** Invoices, P&L, ad-spend-vs-revenue reconciliation, contractor billing, monthly reports.
- **Delegate when:** First invoice needs to go out, monthly close, S-Corp election decision, contractor payment follow-up.
- **Memory:** `.claude/agent-memory/accounting/MEMORY.md`

## 9. analytics
- **Owns:** Funnel metrics, ad-platform performance, landing page conversion, pixel/GTM/GA4/Clarity data.
- **Delegate when:** Installing pixels, building performance dashboards, diagnosing drop-off points, reporting weekly.
- **Memory:** `.claude/agent-memory/analytics/MEMORY.md`

## Adjunct specialists (not direct reports but available)
- **content-writer** — any written asset (copy, outreach, blog, landing page, scripts). Delegate proactively when launching a new page, campaign, or sequence.
- **legal-compliance-counsel** — contracts, compliance, legal review. Delegate for any third-party document or regulatory question.

## Delegation pattern
When handing off:
1. State the outcome in one sentence ("ship the /privacy page to staging")
2. Link the relevant spec or memory file
3. Note any constraints (deadline, brand, budget)
4. Ask for a specific report-out format (status, artifact, blocker list)
5. Set expected turnaround
