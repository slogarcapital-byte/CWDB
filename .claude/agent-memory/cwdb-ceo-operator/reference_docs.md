---
name: Key business documents — plans, specs, legal, design
description: Pointer index to the authoritative docs the CEO references for strategy, specs, and legal
type: reference
---

# Authoritative Documents — CWDB

## Strategy & Plans
- `CLAUDE.md` (project root) — project instructions, stack, agent roster, phase plan
- `business-context/phase-1-plan.md` — the Phase 1 playbook (outreach, build, ads, first lead)
- `business-context/website-plan.md` — 21-page site spec, page-by-page outline
- `business-context/brand-discovery/` — brand voice, positioning, color, style guide

## Website & Design
- `website/design-system.md` — full design system (colors, type, spacing, components)
- `website/site-architecture.md` — page hierarchy, URL map, nav
- `website/templates/base.html` — base HTML template
- `website/pages/*/content.md` — page content files
- `branding/logos/1.1-primary-logo-high-res.png` — stacked logo (hero, print)
- `branding/logos/1.2-horizontal-logo-high-res.png` — horizontal logo (email, banner)

## Legal
- `docs/legal/articles-of-organization.pdf` — LLC formation
- `docs/legal/ein-proof.pdf` — EIN 41-5355234
- `docs/legal/contractor-lead-purchase-agreement-v1.md` — current contractor agreement (also .docx, .pdf)
- `docs/legal/generate_agreement_pdf.py` — parameterized contractor agreement generator
- `sales/contractor-agreements/` — sent/signed agreement PDFs + send log

## Operations Specs
- `operations/leads/quote-form-fields.json` — form schema (9 fields)
- `operations/leads/routing-rules.json` — territory routing
- `operations/leads/scoring-rules.json` — qualification scoring (60+ pts = pass)
- `operations/make/webhooks.json` — Make scenario spec (webhook → qualify → route)
- `sales/crm/pipeline-stages.json` — HubSpot 8-stage deal pipeline

## Sales Materials
- `sales/outreach/call-script.md` — contractor cold-call script
- `sales/outreach/email-template.md` — contractor email outreach template
- `sales/onboarding/contractor-profile.json` — contractor intake template

## Marketing (ad copy per channel)
- `marketing/google-ads/ad-copy.md`
- `marketing/facebook-ads/ad-copy.md` · `audiences.md`
- `marketing/nextdoor/ad-copy.md` · `audiences.md`
- `marketing/tiktok/ad-copy.md` · `audiences.md`

## Financial
- `finance/pl/` — monthly P&L output
- `finance/reports/performance/` — funnel + channel performance reports

## Skills (reusable operations)
- `.claude/skills/contractor-onboarding.md` — generate + send contractor agreements
- `.claude/skills/webflow-connect.md` — MCP-first workflow for Webflow changes

## External Systems (IDs + accounts)
- **Webflow Site ID:** `69c846db9eee02fddb1e2367` · Workspace `69c8468c7b22dbee46e2fe14`
- **Webflow Staging:** central-wisconsin-deck-builders.webflow.io
- **Domain:** cwdeckbuilders.com (GoDaddy)
- **DocuSign User ID:** `265ec01f-b037-4eae-b96d-0fdebec59723` · Account `07a2f8c5-1951-4d6d-baab-0c45359ab80e`
- **HubSpot contacts:** Ben Barton `462464338657` · John Garcia `465926077160`
- **LLC:** WI Entity C138564 · EIN 41-5355234 · Formed 2026-04-06
- **Registered office:** 906 N 16th Ave., Wausau, WI 54401
- **Annual report due:** June 30, 2027 ($25 DFI online)
- **S-Corp election window closes:** ~2026-06-20
