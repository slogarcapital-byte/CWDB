---
type: platform
platform-name: Make
category: automation
tags:
  - type/platform
  - platform/make
aliases:
  - Make.com
  - Integromat
  - Make (formerly Integromat)
created: 2026-03-29
updated: 2026-04-16
status: planned
---

# Make

Automation platform for [[Central Wisconsin Deck Builders LLC]]. Replaced Zapier (see [[2026-03-29 Zapier to Make]]).

## Usage
- Webhook receives form submissions from [[Webflow]]
- Routes qualified leads to contractors via [[Lead Routing Agent]]
- Triggers SMS (Twilio) and email notifications
- Updates [[HubSpot]] CRM

## Configuration
- **Scenario:** Not built yet
- **Webhook spec:** `/operations/make/webhooks.json`
- **SMS Template:** `/operations/automation/twilio-sms-template.md`

## Managed By
- [[Lead Routing Agent]]
