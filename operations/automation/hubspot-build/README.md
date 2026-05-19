---
type: spec
dept: operations/automation
created: 2026-04-30
updated: 2026-05-05
status: ready-for-jim-execution
owner: cwdb-ceo-operator
---

# HubSpot Build — Paste-Ready Sheets

> **Why this format:** HubSpot MCP can't create pipelines, custom properties, or workflows (Settings-page actions; not exposed via the Anthropic claude.ai HubSpot MCP toolset — verified 2026-04-30).
> **Per Jim's standing rule:** heavy copy-paste workflows ship as spreadsheets, not prose walkthroughs.
>
> **2026-05-05 correction:** Original spec had form-fillable fields on the Deal object. **HubSpot forms cannot populate Deal properties — only Contact, Company, and Ticket.** Spec corrected: form-fillable lead detail moved to Contact; only deal-lifecycle metadata stays on Deal.

## Files

| File | Action | Status |
|---|---|---|
| `01-pipeline-stages.csv` | Create the Homeowner Leads pipeline + 9 stages. ~5 minutes in HubSpot UI. | DONE 2026-05-05 |
| `02-contact-properties.csv` | Create 11 custom **Contact** properties (form-fillable lead detail). ~7 minutes. | DONE 2026-05-05 |
| `03-deal-properties.csv` | Create 8 custom **Deal** properties (workflow-managed, not form-fillable). ~5 minutes. | DONE 2026-05-05 |
| `04-lead-routing-workflow-spec.md` | Build HubSpot Workflow: form submit → Deal at New Lead → notify Jim. ~25-35 min in HubSpot UI. | READY 2026-05-05 — Jim builds next |

## Order of operations (single sit-down, ~17 minutes)

1. **Create the pipeline first** (`01-pipeline-stages.csv` — 9 stages).
2. **Create Contact properties** (`02-contact-properties.csv` — 11 properties). These are what the form will populate.
3. **Create Deal properties** (`03-deal-properties.csv` — 8 properties). These are what workflows + manual updates manage as deals progress through stages.
4. **Capture IDs.** After save, click into each stage to grab stage IDs from URL. Paste back into `operations/automation/hubspot-lead-pipeline.json`. Same for the pipeline ID.
5. **Confirm.** Drop the IDs into the Inbox → CEO patches §6 Dashboard + flips the `[~]` Phase 1 checklist row to `[x]`.

## Architecture (corrected 2026-05-05)

```
Webflow form submission
        ↓
HubSpot Form (or Non-HubSpot Forms tracking script)
        ↓
Contact created (with all 11 Lead-information properties + standard fields)
        ↓
Workflow trigger: "Form Quote Request submitted"
        ↓
Deal created in Homeowner Leads pipeline at "New Lead" stage
        ↓
Deal associated to the Contact (one-click in workflow)
        ↓
Reports/views join Deal + Contact via association — full picture available
```

**Why this is right:** Lead detail (project type, budget, timeline) belongs to the *person*, not the *deal*. If a homeowner comes back next year for a second deck, you want a fresh deal opening against an existing Contact — not a stale closed-won deal carrying the new project's data.

## What this unblocks

- HubSpot Workflow build (lead-routing scope, ~1-2 hrs) — sequenced after this completes
- Native HubSpot ↔ Google Ads + Meta offline conversion sync setup (analytics scope, ~2 hrs)
- Webflow → HubSpot wiring via Webflow App OR Non-HubSpot Forms tracking (web-dev scope, ~1-2 hrs after Phase 0 gate + Contact properties exist)

## What's NOT in scope here

- The HubSpot workflow (`form submit → contact → deal at new → notification email`) — separate sheet ships once pipeline + properties are live
- Tracking script install — separate file `phase-0-gate-spec.md` covers that test
- Native ad-platform integrations — separate spec ships after pipeline is live
