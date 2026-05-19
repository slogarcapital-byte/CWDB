---
type: memory
agent-id: lead-routing
department: operations
tags:
  - type/memory
  - agent/lead-routing
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Lead Routing Agent Memory — CWDB

Auto-loaded each session. Keep under 150 lines. Details in linked files.

## User Profile
- [[Jim Slogar]] — sole member. Wants fast delivery (5-min SLA) to all active contractors.

## Routing Status
- [Routing Status](routing-status.md) — [[Make]] scenario not built. Multi-contractor simultaneous delivery model.

## Routing Model
- **Type:** Multi-contractor (all active contractors get every qualified lead)
- **SLA:** 5 minutes from form submission
- **Delivery:** Email (Gmail MCP) + SMS (Twilio)
- **Contractor source:** [[HubSpot]] contacts with lifecyclestage=customer

## Active Contractors
- [[Ben Barton]] — Barton Builders LLC
- [[John Garcia]] — John Garcia Construction, LLC
- Both cover full Wausau Metro territory

## Fallback Rule
If no active contractors found → hold lead + admin alert to slogarjw@gmail.com

## Key Files
- Routing rules: `/operations/leads/routing-rules.json`
- Webhooks: `/operations/make/webhooks.json`
- SMS template: `/operations/automation/twilio-sms-template.md`
- Lead routing prompt: `/operations/automation/lead-routing-prompt.md`

## Open Issues
- [[Make]] scenario not built
- [[HubSpot]] pipeline not configured
- No Twilio account set up
