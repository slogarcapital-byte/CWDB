---
name: HubSpot forms can only populate Contact / Company / Ticket — never Deal
description: Architecture rule discovered 2026-05-05; lead detail lives on Contact, deal-lifecycle metadata on Deal
type: project
---

HubSpot forms (both native HubSpot Forms and the Forms API endpoint) can only populate Contact, Company, and Ticket properties. They CANNOT populate Deal properties directly.

**Why:** Original `02-deal-properties.csv` (authored 2026-04-30) put form-fillable lead detail (project_type, budget_range, timeline, etc.) on the Deal object. Jim caught this on 2026-05-05 build day. CSVs were rebuilt as `02-contact-properties.csv` (11 form-fillable Contact properties) + `03-deal-properties.csv` (8 workflow-managed Deal properties).

**The right architecture:**
```
Webflow form → Form relay POST → HubSpot Form
   → Contact created/updated (11 lead properties)
     → Workflow trigger
       → Deal created in homeowner_leads at "New Lead"
       → Deal auto-associated to Contact
```

**How to apply:** When designing any future HubSpot data flow that starts from a form submission, lead detail belongs on the Contact (the *person*) — only deal-lifecycle metadata (lead_score, matched_contractor, routing_sent_at, bid_amount, referral_fee_invoiced_at) belongs on the Deal (the *transaction*). Repeat customers then get fresh deals against existing Contacts; you don't end up with a stale closed-won deal carrying new project data.

**Related files:**
- `operations/automation/hubspot-build/02-contact-properties.csv` (canonical form-fillable list)
- `operations/automation/hubspot-build/03-deal-properties.csv` (canonical workflow-managed list)
- `operations/automation/hubspot-build/README.md` (architecture diagram)
- `operations/automation/hubspot-build/04-lead-routing-workflow-spec.md` (workflow that bridges Contact → Deal)
