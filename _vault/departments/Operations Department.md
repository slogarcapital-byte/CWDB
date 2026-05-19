---
type: department
department: operations
source-path: operations/
owner: "[[Lead Qualification Agent]] / [[Lead Routing Agent]]"
tags:
  - type/department
  - dept/operations
created: 2026-04-18
updated: 2026-04-18
---

# Operations Department

Lead processing, qualification, routing, and automation plumbing. Owned by [[Lead Qualification Agent]] and [[Lead Routing Agent]].

## Leads
- **Form fields:** `operations/leads/quote-form-fields.json`
- **Scoring rules:** `operations/leads/scoring-rules.json`
- **Routing rules:** `operations/leads/routing-rules.json`

## Automation ([[Make]])
- **Webhooks:** `operations/make/webhooks.json`
- **HubSpot pipeline:** `operations/automation/hubspot-lead-pipeline.json`
- **SMS template:** [[operations/automation/twilio-sms-template]]
- **Lead routing prompt:** [[operations/automation/lead-routing-prompt]]

## Analytics
- **Tracking plan:** [[operations/analytics/tracking-plan]]
- **JSON-LD snippets:** `operations/analytics/json-ld-snippets/` (homepage + 5 city pages + template)
- **GTM snippets:** `operations/analytics/gtm-snippets.txt`

## Status
Analytics pipeline live (GA4, Meta Pixel, Nextdoor Pixel, Google Ads conv, MS Clarity). Make scenario not built yet. HubSpot pipeline spec ready.
