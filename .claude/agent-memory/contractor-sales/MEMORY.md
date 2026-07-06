---
type: memory
agent-id: contractor-sales
department: sales
tags:
  - type/memory
  - agent/contractor-sales
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Contractor Sales Agent Memory — CWDB

Auto-loaded each session. Keep under 150 lines. Details in linked files.

## User Profile
- [[Jim Slogar]] — handles contractor relationships directly. Prefers pay-per-accepted-bid model.

## Contractor Roster
- [Contractor Roster](contractor-roster.md) — 2 active contractors, target 10-20 total
- [Outreach Status](outreach-status.md) — 2 of 10-20 contacted

## Active Contractors
| Contractor | Company | Agreement | Status |
|-----------|---------|-----------|--------|
| [[Ben Barton]] | Barton Builders LLC | Signed 2026-04-17 | Active (deal closedwon 2026-04-19) |
| [[John Garcia]] | John Garcia Construction, LLC | Signed 2026-04-17 | Active (deal closedwon 2026-04-19) |

## DocuSign (shared facts)
- Account ID: `07a2f8c5-1951-4d6d-baab-0c45359ab80e` · Base: `https://na4.docusign.net/restapi/v2.1`
- Env vars: `DOCUSIGN_ACCOUNT_ID`, `DOCUSIGN_ACCESS_TOKEN` (token from Admin > Apps & Keys, ~8h expiry, NOT in .env.local)
- Contractor agreements: `sales/contractor-agreements/generate_and_send.py` (fixed page-4 tab coordinates)
- Homeowner work orders / contracts: `sales/estimates/generate_and_send_sow.py` (anchor-string tabs, homeowner signs first, Jim second)

## Homeowner Contracting (added 2026-06-10)
- CWDB signs homeowners directly on staining jobs NOW (interim work order, ATCP 110 compliant); full builds wait for insurance + DSPS gate
- Quote-to-contract pipeline: estimate JSON -> `generate_work_order_pdf.py` (stain) or `generate_sow_pdf.py` (build) -> DocuSign
- Job Numbers (CWDB-YYYY-NNN) issued from Supabase `dim_jobs` at contract formation; CWDB-2026-001 = Overbeck stain
- Lead-purchase channel gets NO CWDB-signed homeowner contract: the contractor must be the named seller and deposit holder, or CWDB inherits the home-improvement seller duties

## Pricing Model
- **Primary:** Pay per accepted bid at $1,000
- Contractor pays when they win a job sourced from our lead
- 5-layer bid verification system (see agreement)
- **Secondary (future):** Territory licensing at ~$1,200/mo

## Sales Materials
- Call script: `/sales/outreach/call-script.md`
- Email template: `/sales/outreach/email-template.md`
- Contractor profile template: `/sales/onboarding/contractor-profile.json`
- Agreement generator: `.claude/skills/contractor-onboarding.md`

## Open Issues
- Only 2 of target 10-20 contractors contacted
- Need to expand outreach to more deck builders in Central Wisconsin
- Signed copies of agreements still pending
