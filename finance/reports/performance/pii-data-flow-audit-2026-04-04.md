---
type: report
status: active
created: 2026-04-04
updated: 2026-04-16
tags:
  - type/report
  - dept/legal
  - dept/finance
---

# PII Data Flow Audit — CWDB Lead System
**Prepared by:** Analytics Agent
**Date:** 2026-04-04
**Purpose:** Legal compliance review — privacy policy drafting and TCPA/data retention assessment
**Audience:** Legal Compliance Counsel Agent

---

## 1. PII Collected at the Point of Capture

Source: `/operations/leads/quote-form-fields.json`

The [[Webflow]] native quote form collects the following personally identifiable information (PII) from every homeowner submission:

| Field | Type | Required | PII Classification |
|---|---|---|---|
| Full Name | Text | Yes | Direct identifier |
| Phone Number | Tel (US format) | Yes | Direct identifier — TCPA-regulated |
| Email Address | Email | Yes | Direct identifier |
| Property Address | Text | Yes | Direct identifier + location data |
| Property ownership | Select (Yes/No) | Yes | Qualifying attribute |
| Project type | Select | Yes | Non-PII |
| Budget range | Select | Yes | Financial indicator |
| Start timeline | Select | Yes | Non-PII |
| Project notes | Textarea | No | Potentially PII (free text) |

Phone number is a required field and is the primary contact channel for contractor notification. This is the highest-sensitivity field for TCPA compliance purposes.

---

## 2. Data Flow Diagram

```
HOMEOWNER
    |
    | Fills quote form on Webflow page
    | (homepage, /get-a-quote, or city landing pages)
    v
[1] WEBFLOW FORMS
    - Stores submission in Webflow dashboard
    - Sends confirmation redirect to /thank-you
    - Fires webhook to Make (DESIGNED — not yet built)
    |
    | Webhook payload (all form fields as JSON)
    v
[2] MAKE (automation layer)
    - Receives webhook
    - Parses fields
    - Runs qualification scoring (scoring-rules.json)
    - Routes by ZIP code territory (routing-rules.json)
    |
    |--- IF QUALIFIED ---> Contractor email notification (Gmail/SMTP)
    |                  --> Contractor SMS notification (Twilio)
    |                  --> HubSpot contact/deal record created
    |
    |--- IF NOT QUALIFIED --> Admin notification only
    |                     --> Lead logged (disqualification reason stored)
    v
[3] HUBSPOT CRM (free tier)
    - Contact record: name, phone, email, address
    - Deal record: project type, budget, timeline, qualification status
    - Pipeline stage tracking through contractor delivery lifecycle

[4] CONTRACTOR (end recipient for qualified leads)
    - Receives: name, phone, address, project type, budget, timeline
    - Delivery method: email notification + SMS alert
    - Contractor does NOT receive data via a shared platform — delivery is push-only
```

**Current live status:** Only Stage 1 (Webflow Forms) is confirmed built. Stages 2, 3, and 4 are designed but not yet deployed. See Section 5 for gaps.

---

## 3. PII Storage by Platform

### Stage 1 — Webflow Forms

**What is stored:** All form field values for every submission (qualified and unqualified), plus submission timestamp, page URL, and browser/IP metadata collected automatically by Webflow.

**Where it lives:** [[Webflow]] project dashboard under Site Settings > Forms. Accessible to anyone with Editor or Admin access to the Webflow workspace.

**Retention period:** Webflow does not enforce an automatic deletion period for form submissions on any paid plan. Submissions persist indefinitely until manually deleted by a workspace admin. There is no configurable auto-expiry. Webflow's data processing agreement (DPA) governs how Webflow itself handles data as a processor; the CWDB account holder is the data controller.

**Export options:** CSV export is available from the Webflow dashboard.

**Encryption:** Webflow encrypts data at rest and in transit (TLS). No field-level encryption on form submissions.

**Compliance gap:** Because there is no auto-deletion, CWDB must establish a manual or automated deletion schedule to honor any future data retention policy or deletion requests.

---

### Stage 2 — Make (automation layer)

**What is stored:** [[Make]] logs execution history for each scenario run. This includes the full input payload (all form fields) and output data for each step. Execution logs are the primary PII exposure risk in Make.

**Retention period:** Make's free plan retains execution history for 30 days. Paid plans extend this (Core: 30 days, Pro: 60 days, Teams: 60 days, Enterprise: configurable). At the free tier, execution logs including PII are automatically purged at 30 days.

**Current status:** No Make scenario is built yet (`status: "not_built"` per `/operations/make/webhooks.json`). No PII is flowing through Make at this time.

**Risk note:** Once live, Make execution logs will temporarily hold the full PII payload for each submission for up to 30 days. Legal counsel should determine whether this constitutes a secondary storage location requiring disclosure in the privacy policy.

---

### Stage 3 — HubSpot CRM (free tier)

**What is stored (planned):** Contact records (name, phone, email, address) and deal records (project type, budget, timeline, qualification status, pipeline stage).

**Retention period:** [[HubSpot]] free tier does not enforce automatic deletion of CRM records. Records persist indefinitely unless manually deleted. HubSpot's data retention policies allow account holders to set contact deletion workflows, but these require Operations Hub (paid). On the free tier, deletion must be performed manually or via API.

**Current status:** No contact or deal records have been created yet. The pipeline stage structure is designed (`/sales/crm/pipeline-stages.json`) but has not been confirmed as configured in the live HubSpot account.

**TCPA note:** HubSpot is where contractor communication history and lead delivery records would be tracked. Any future opt-out or do-not-contact requests should be logged here.

---

### Stage 4 — Contractor (end recipient)

**What is shared:** Name, phone, email, property address, project type, budget, timeline.

**Delivery method:** Email and SMS push notifications triggered by Make. The contractor receives a copy of the lead data but CWDB does not control what the contractor does with it after delivery.

**Retention at contractor:** Unknown and uncontrolled. This is a material gap for privacy policy and contractor agreement purposes.

**Current status:** No contractor is currently assigned in `routing-rules.json` (all territories show `"status": "vacant"`). No leads have been delivered.

---

### Other Storage Locations

**Email (Gmail/SMTP):** Contractor notification emails sent by Make will contain the full PII payload in the email body. These emails persist in the sending account's sent folder and the contractor's inbox indefinitely unless deleted. Gmail's standard retention applies (indefinite unless user deletes).

**No spreadsheets confirmed.** No Google Sheets, Airtable, or similar secondary storage is specified in the current system design. This should be confirmed with the operator.

**No local database.** All storage is third-party SaaS.

---

## 4. Duplicate Submission Handling

Per `/operations/leads/scoring-rules.json`, the qualification engine is designed to auto-disqualify duplicate submissions from the same phone number within 30 days. This means:

- A homeowner who submits twice within 30 days will have their second submission rejected at the Make scoring step.
- The first submission's PII remains in Webflow and HubSpot regardless.
- The duplicate check logic requires Make to have memory of prior submissions (likely via a Make data store or HubSpot lookup). This mechanism is not yet built.

---

## 5. Confirmed Gaps and Unknowns

The following items could not be confirmed from project files alone and require either live system access or operator verification:

| Gap | Risk Level | Notes |
|---|---|---|
| Make scenario not built | Low (currently) / High (at launch) | No PII flowing through Make today. Must address before going live. |
| HubSpot account not confirmed configured | Medium | Pipeline stages are designed locally but live HubSpot setup is unverified. |
| Webflow form webhook URL not set | Medium | Webhook destination field in Webflow project settings is blank (`[MAKE_WEBHOOK_URL — fill after scenario creation]`). Form submissions are currently stored in Webflow only, not forwarded. |
| Contractor data handling post-delivery | High | CWDB has no visibility into or control over what contractors do with PII after receiving a lead. Contractor agreement should include data handling obligations. |
| Webflow IP/browser metadata retention | Medium | Webflow collects submission metadata (IP address, user agent, page URL) automatically. Retention period for this metadata is subject to Webflow's own DPA, not configurable by CWDB. |
| No consent language on form | High | The current form spec (`quote-form-fields.json`) includes no TCPA consent disclosure, privacy policy link, or opt-in checkbox. This must be added before the first ad campaign runs. |
| No data deletion workflow | Medium | Neither Webflow nor HubSpot free tier supports automated deletion. Manual process or API-based deletion must be established to handle subject access/deletion requests. |
| Make data store usage | Unknown | The duplicate-submission check requires 30-day memory of prior phone numbers. It is unclear whether this will be stored in a Make data store (which would be an additional PII storage location) or via a HubSpot lookup. |
| Email body PII in Gmail sent folder | Medium | Contractor notification emails will contain full PII. No retention policy is in place for the sending Gmail account. |

---

## 6. Summary — PII Residency Map

| Platform | PII Stored | Retention | Status |
|---|---|---|---|
| Webflow Forms | Full submission (name, phone, email, address + metadata) | Indefinite (no auto-delete) | LIVE — active collection begins when site launches |
| Make execution logs | Full submission payload per run | 30 days (free plan auto-purge) | NOT BUILT |
| HubSpot CRM | Contact + deal fields | Indefinite (no auto-delete on free tier) | NOT CONFIGURED |
| Gmail/SMTP sent | Full PII in email body | Indefinite (standard Gmail retention) | NOT ACTIVE |
| Contractor inbox | Full lead PII | Unknown — contractor-controlled | NOT ACTIVE |

---

## 7. Recommended Actions for Legal Review

The following items are flagged for legal counsel prioritization before the first ad campaign launches:

1. **TCPA consent language** — Add an explicit opt-in disclosure to the quote form (e.g., "By submitting this form, you consent to being contacted by phone or SMS by [[Central Wisconsin Deck Builders LLC|Central Wisconsin Deck Builders]] and its contractor partners.") with a link to the privacy policy.

2. **Privacy policy** — Draft and publish a privacy policy at cwdeckbuilders.com/privacy covering: data collected, purpose of collection, third-party sharing (contractors, Make, HubSpot, Webflow), retention periods, and subject rights.

3. **Contractor data agreement** — Include data handling obligations in the contractor agreement. Contractors receive PII and must be bound by confidentiality and appropriate-use terms.

4. **Retention schedule** — Establish a documented retention period for homeowner PII (e.g., 24 months post-submission) and a process to honor deletion requests across Webflow, Make, HubSpot, and Gmail.

5. **Webflow form webhook gap** — Until the Make webhook is connected, form submissions accumulate only in Webflow with no downstream routing. Confirm this is acceptable for the pre-launch period.

---

*Report generated from local project files. Live system state in Make and HubSpot could not be verified due to access restrictions. All platform retention policies reflect publicly documented defaults as of the report date and should be confirmed against current vendor terms.*
