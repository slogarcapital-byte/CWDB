---
type: memory
agent-id: lead-routing
name: routing-status
description: Make automation status, notification setup, and routing configuration
tags:
  - type/memory
  - agent/lead-routing
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Routing Status

**Why:** Lead delivery speed directly impacts contractor satisfaction and lead-to-bid conversion.

**How to apply:** Build Make scenario matching this spec. Test end-to-end before ad launch.

## Make Scenario
- Status: NOT BUILT
- Trigger: Webhook from [[Webflow]] form submission
- Webhook spec: `/operations/make/webhooks.json`
- Steps: Receive form → validate/score → if qualified → lookup contractors in [[HubSpot]] → send email + SMS → log in HubSpot

## Notification Methods
- **Email:** Gmail MCP (`mcp__claude_ai_Gmail__*`)
- **SMS:** Twilio REST API — template at `/operations/automation/twilio-sms-template.md`
- **CRM:** [[HubSpot]] deal/contact creation

## Routing Logic
- All contractors with lifecyclestage=customer get every qualified lead
- No territory exclusivity in Phase 1
- Fallback: admin alert if no active contractors found

## Related
- [[Lead Qualification Agent]] scores leads before routing
- [[Make]] platform for automation
- [[HubSpot]] for contractor lookup
