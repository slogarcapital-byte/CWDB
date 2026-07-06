---
name: phone-leads-count
description: "All HubSpot leads count (phone, webform, manual); lead_channel + tcpa_consent_source columns; phone leads may lack email"
metadata: 
  node_type: memory
  type: project
  originSessionId: a0e0b14f-d836-4245-b2bd-ce398dee1da0
---

# Phone Leads Count (2026-06-10)

Jim gets as many phone leads as webform leads. **Every HubSpot lead counts toward the funnel and validation gate regardless of channel.** Never equate "lead" with "webform submission."

**Implementation (2026-06-10):**
- `fact_leads.lead_channel` (webform | phone | manual | other) and `fact_leads.tcpa_consent_source` (form | verbal | assumed) — schema/009; email nullable for non-webform (schema/010); `v_clean_leads` NULL-safe email exclusion + channel passthrough (views/004).
- `pull-hubspot-snapshot.ps1` consent gate: form-set `tcpa_consent_given=true` OR (`lead_channel` in phone/manual/other AND `tcpa_consent_source` set). Channel inferred webform for legacy form-TCPA rows.
- Workflow for Jim on a phone lead: create the HubSpot contact, set Lead Channel = Phone Call, TCPA Consent Source = Verbal (after asking permission to text/email on the call), phone required, email optional.

**RESOLVED 2026-06-11 (WB-016 done):** scopes added, properties live in HubSpot, all 4 previously skipped contacts tagged and ingested (Sjoberg + Darlene = phone/assumed; Nayak + Keuler = manual/assumed). Clean-lead mix now 7 webform + 2 phone + 2 manual. Their deals also now match leads in `fact_bids` (no_matching_lead went 3 to 0). File-upload note: HubSpot files API `access` must be `PRIVATE` (the HIDDEN_* values need the extra `files.ui_hidden.write` scope and fail with a misleading "Invalid JSON for options input" error).

Related: [[fulfillment-model-pivot-2026-06-10]], [[v-clean-leads-test-exclusion-gap]]
