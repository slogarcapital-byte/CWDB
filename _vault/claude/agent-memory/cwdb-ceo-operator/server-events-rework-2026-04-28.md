---
name: Server-events architecture reworked — HubSpot↔Webflow native chosen over Cloudflare Worker
description: 2026-04-28 decision; standing pattern of Jim preferring in-platform tooling over custom serverless infra
type: project
---

**Decision (2026-04-28):** Server-events plan reworked from scratch. Cloudflare Worker (Path A) and Make scheduled (Path B) both dropped. Canonical architecture is now Webflow → HubSpot native integration → HubSpot → {Google Ads, Meta, GA4} via native integrations or workflow webhooks.

**Why:** Jim's verbatim ask was *"completely rework plan. i'm going to use the hubspot connection with webflow to update the crm."* This is a continuation of a standing pattern where Jim prefers in-platform tooling over custom serverless infrastructure he can't edit himself in a UI. The Make pivot (2026-04-19) and the now-rework both reflect the same preference — Jim is willing to trade architectural elegance for stack he can administer without an agent in the loop.

**How to apply:**
- Whenever a future plan reaches for Cloudflare Workers, AWS Lambda, custom Node services, or anything wrangler/SST/Pulumi-shaped, **propose the in-platform equivalent first** (Make, Webflow Logic, HubSpot Workflow Webhooks, Zapier, even Google Apps Script). Only escalate to custom infra if the in-platform path fundamentally cannot do the job.
- The trade Jim is making: ongoing maintenance burden lower (he can fix it himself), architectural elegance lower (3 different mechanisms instead of 1), bus-factor on the agent system reduced.
- New canonical doc: `operations/analytics/hubspot-webflow-native-plan.md`. Deprecated: `operations/analytics/path-a-vs-path-b-server-events.md`, `operations/analytics/server-event-spec.md`.
- The HubSpot pipeline build (was a "Phase B Gate 1" prereq under the old plan) is now critical-path for ALL closed-loop attribution. Surface it as the top dependency every time the architecture comes up.
