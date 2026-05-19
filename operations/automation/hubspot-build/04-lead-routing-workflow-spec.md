---
type: spec
dept: operations/automation
created: 2026-05-05
status: ready-for-jim-execution
owner: cwdb-ceo-operator
prereqs:
  - Pipeline live (homeowner_leads — DONE 2026-05-05)
  - Contact properties live (11 — DONE 2026-05-05)
  - Deal properties live (8 — DONE 2026-05-05)
  - Form relay shipped (hubspot_form_relay-1.0.0.js — DONE 2026-05-05)
  - HUB_ID 245712220 + FORM_GUID bb473d64-06b1-4311-8e02-7c70d605b79b
unblocks:
  - First end-to-end lead delivery
  - Native HubSpot ↔ Google Ads + Meta offline conversion sync (downstream)
---

# HubSpot Lead-Routing Workflow — Build Spec

> **Why this exists:** Pipeline + Contact properties + form relay are all live. The last gap is a HubSpot Workflow that turns a form submission into a routed Deal with notification fired. After this ships, a homeowner submitting the Webflow form triggers an automatic, end-to-end lead delivery without Jim touching anything.
>
> **Architecture (locked 2026-05-05):**
>
> ```
> Webflow form submit
>   → hubspot_form_relay-1.0.0.js fires POST to api.hsforms.com
>     → HubSpot Form bb473d64-06b1-4311-8e02-7c70d605b79b
>       → Contact created/updated (11 lead properties populated)
>         → THIS WORKFLOW triggers
>           → Deal created in homeowner_leads pipeline at "New Lead"
>           → Deal associated to Contact (auto)
>           → Notification email fires to Jim (and matched contractor in v2)
> ```

## Scope of this spec

**In scope (v1 — ship today):**
- Trigger: HubSpot Form submission (form GUID bb473d64-06b1-4311-8e02-7c70d605b79b)
- Action 1: Create Deal in `homeowner_leads` pipeline at `New Lead` stage
- Action 2: Auto-associate Deal to the Contact that submitted the form (HubSpot does this natively when workflow runs in Contact-based scope)
- Action 3: Set Deal name = `[firstname] [lastname] — [project_type] — [source_city]` (or fallback if firstname/source_city missing)
- Action 4: Copy contact properties forward to Deal where useful (`matched_contractor` will be set later by routing branch — leave blank in v1)
- Action 5: Send internal notification email to Jim (`slogarjw@gmail.com`) with full lead snapshot

**Out of scope (v2, ship after first 5 leads land):**
- Smart routing branch (Wausau/Schofield/Weston → Ben Barton; Mosinee/Merrill → John Garcia; both fallback)
- SMS notification to contractor (requires HubSpot SMS add-on or Twilio bridge — defer until volume justifies)
- Automatic `routing_sent_at` timestamp
- TCPA consent gate (block routing if `tcpa_consent_given = false`)

**Deferred-by-design (ship when accepted-bid event fires):**
- Stage transition triggers (Qualified, Accepted Bid)
- Invoice trigger at Accepted Bid stage
- Offline conversion sync to Google Ads + Meta

## Build steps (HubSpot UI, ~25–35 minutes)

> **Path:** HubSpot → Automations (left nav) → Workflows → Create workflow → "From scratch" → Object: **Contact-based**

### Step 1 — Workflow setup (2 min)

| Field | Value |
|---|---|
| Workflow name | `Homeowner Lead Routing — v1` |
| Object | Contact-based |
| Description | Form submit → Create Deal in Homeowner Leads → Notify Jim |

### Step 2 — Enrollment trigger (3 min)

> **Important:** Use a **Form submission** filter, not a property change. Form submission gives you the full submission payload + ensures every submission re-enrolls (homeowners who come back next year get a fresh deal).

1. Click **Set up triggers**
2. Filter type: **Form submission**
3. Form: select `Quote Request` (the form with GUID `bb473d64-06b1-4311-8e02-7c70d605b79b`)
4. Page: **Any page** (form relay can fire from anywhere on cwdeckbuilders.com)
5. Re-enrollment: **Allow contacts to re-enroll on form submission** — turn ON

### Step 3 — Action 1: Create Deal (5 min)

1. Add action → **Create record** → **Deal**
2. Properties to set:

| Deal Property | Value |
|---|---|
| Deal name | Token: `Contact: First name` + " " + Token: `Contact: Last name` + " — " + Token: `Contact: Project Type` + " — " + Token: `Contact: Source City` (use HubSpot's text token concat in the field) |
| Pipeline | `Homeowner Leads` |
| Deal stage | `New Lead` |
| Amount | `1000` (referral fee value if won — fixed per contractor agreement) |
| Close date | Token: today + 60 days (use HubSpot's date math; conservative bid window) |
| Deal owner | Jim Slogar |

> **Fallback for empty Deal name:** if firstname/source_city tokens are blank, the concat will leave double dashes. Acceptable for v1; clean up in v2 with a workflow branch.

### Step 4 — Action 2: Associate Deal to Contact (auto, 0 min)

In a Contact-based workflow, the **Create record → Deal** action shows a dropdown asking "Associate this deal with the enrolled record?" Set to **Yes — Contact**. HubSpot auto-creates the Deal↔Contact association.

### Step 5 — Action 3: Send internal notification email (10 min)

1. Add action → **Send internal email notification**
2. Send to: `slogarjw@gmail.com`
3. Subject: `🔔 New CWDB Lead: {{contact.firstname}} — {{contact.source_city}}`
4. Body (HubSpot tokens; copy verbatim):

```
New homeowner lead just submitted the quote form.

NAME: {{contact.firstname}} {{contact.lastname}}
EMAIL: {{contact.email}}
PHONE: {{contact.phone}}
ADDRESS: {{contact.address}}
ZIP: {{contact.zip}}
CITY: {{contact.source_city}}

PROJECT TYPE: {{contact.project_type}}
BUDGET: {{contact.budget_range}}
TIMELINE: {{contact.project_timeline}}
OWNS PROPERTY: {{contact.owns_property}}
TCPA CONSENT: {{contact.tcpa_consent_given}}

NOTES: {{contact.lead_notes}}

ATTRIBUTION:
  utm_source: {{contact.utm_source}}
  utm_campaign: {{contact.utm_campaign}}
  gclid: {{contact.gclid}}
  page: {{contact.lead_source_page}}

DEAL: open in HubSpot → https://app.hubspot.com/contacts/245712220/contact/{{contact.hs_object_id}}

Action needed:
  1. Call homeowner within 5 minutes (Lever 2: speed-to-lead).
  2. Forward lead to matched contractor (Ben Barton: Wausau/Schofield/Weston · John Garcia: Mosinee/Merrill · both: any overlap).
  3. Update Deal stage in HubSpot once contractor confirms acceptance.
```

> **Token availability check:** If a token shows as empty in test, it means the Contact property internal name is wrong — verify against `02-contact-properties.csv` Internal Name column.

### Step 6 — Save + activate (2 min)

1. Click **Review** → verify enrollment trigger + 3 actions in correct order
2. **Turn workflow ON** (top right toggle)
3. Confirm "Run actions for existing contacts who meet the trigger" = **OFF** (fresh leads only; we don't want past test contacts re-running)

## Verification (5 min, run immediately after activation)

1. Go to cwdeckbuilders.com/get-a-quote in a new private/incognito window.
2. Submit the form with test data (use `test-{date}-{time}@example.com` to avoid duplicate Contact merge).
3. Within 30 seconds, check:
   - **HubSpot → Contacts** — new Contact appears with all 11 lead properties populated.
   - **HubSpot → Deals → Homeowner Leads pipeline** — new Deal appears at "New Lead" stage.
   - **HubSpot → Contact → Deals tab** on the new Contact — Deal is associated.
   - **slogarjw@gmail.com inbox** — notification email arrives with all tokens populated.
4. If any of the 4 fail: check workflow execution log (Automations → Workflows → click workflow → Performance tab → click latest enrollment) for which step errored.

## Rollback path (if v1 misbehaves in production)

1. **Turn workflow OFF** (top-right toggle on the workflow page).
2. Form submissions still create Contacts (form relay continues to work; Contact creation is a HubSpot Form action, not a workflow action).
3. Manual lead handling resumes: Jim watches `slogarjw@gmail.com` for the form's native email, calls homeowner, manually creates Deal.

## Post-ship metrics to capture (after 5 form submissions)

| Metric | Source | Target |
|---|---|---|
| Time from submit to Deal created | Workflow execution log | <30 sec |
| Time from submit to notification email received | Email timestamp - submit timestamp | <60 sec |
| % of submissions where all 11 contact properties populated | Manual spot-check on Contacts | 100% |
| % of Deals correctly named | Spot-check on Deals list view | 100% (any blank dashes = v2 cleanup) |

## What this unblocks (downstream)

After this workflow is live + verified with at least 1 real test lead:
1. **Native HubSpot ↔ Google Ads offline conversion sync** — HubSpot Settings → Integrations → Google Ads → "Send conversions for this Deal stage = Accepted Bid". Closes the loop on Smart Bidding.
2. **Native HubSpot ↔ Meta sync** — same pattern via Meta Business integration.
3. **Meta launch (DEPLOY.md continuation)** — was blocked on attribution. Once HubSpot is the system-of-record for closed-loop, Meta can go live without breaking Google Ads attribution.
4. **A1 Enhanced Conversions** — independent of this workflow but landed today's spec sequence.

## v2 enhancements (queue, do not build today)

1. Routing branch on `source_city`:
   - Wausau / Schofield / Weston → set `matched_contractor = Barton Builders LLC`
   - Mosinee / Merrill → set `matched_contractor = John Garcia Construction LLC`
   - Other / blank → both contractors get notified
2. Set `routing_sent_at` to "now" timestamp inside routing branch
3. TCPA consent gate: if `tcpa_consent_given = false`, skip notification email (compliance — no SMS/call without consent)
4. Lead score calculation (project_type weight + budget_range weight + timeline weight + ownership flag) → set `lead_score` on Deal
5. Stage automation: when Deal stage = `Accepted Bid`, set `referral_fee_invoiced_at = now` and trigger invoice email (or QBO API call when payment-rails decision lands)
