---
name: HubSpot Forms API direct-fetch relay (Plan B) beats Non-HubSpot Forms tracking (Plan A)
description: Pattern shipped 2026-05-05; deterministic field mapping beats auto-detection for production form integration
type: project
---

When wiring a Webflow (or any non-HubSpot) form to HubSpot, use the Forms API direct-fetch pattern over HubSpot's "Non-HubSpot Forms" auto-tracking script.

**Why Plan B won (2026-05-05):**
- Plan A (Non-HubSpot Forms tracking) auto-detects field names from a mix of `name` attribute and label-derived snake_case. Caused field-name mismatch in CWDB Phase 0 test: `estimated_budget`, `anything_else_we_should_know_`, `by_submitting_i_agree_...` and `timeline` — none matched the HubSpot Contact property internal names that were aligned to Webflow form slug values.
- Plan B uses an explicit JS field map: `{ webflow_form_field_name: 'hubspot_contact_internal_name', ... }`. Deterministic. Adding/renaming a field is a one-line code change.

**The pattern:**
1. Create a HubSpot Form schema in HubSpot UI — never embed it on the site; it serves as the API target only. Capture HUB_ID + FORM_GUID.
2. Ship a capture-phase submit listener on the Webflow form (`form#wf-form-Quote-Request`):
   ```js
   form.addEventListener('submit', handler, true)  // capture phase = true
   ```
3. Build the explicit field map; POST to `https://api.hsforms.com/submissions/v3/integration/submit/{HUB_ID}/{FORM_GUID}` with `keepalive: true` so the request survives page navigation.
4. **Don't preventDefault.** Let Webflow's native submit / email / redirect flow continue untouched. The HubSpot POST runs in parallel.
5. Disconnect the Webflow App if it was previously installed — it caused the "could not get/set child form element ID" error on the multi-step form rebuild (2026-04-28).

**How to apply:** Any time a future form needs to land in HubSpot AND keep an existing redirect/email flow, use this pattern. Don't overthink it with workflow webhooks or Make scenarios — direct API POST is 4761 bytes and does the job.

**Production reference (CWDB 2026-05-05):**
- HUB_ID: 245712220
- FORM_GUID: bb473d64-06b1-4311-8e02-7c70d605b79b
- Region: na2 (api.hsforms.com routes by portal ID; no region prefix needed in URL)
- Script: `website/scripts/hubspot_form_relay-1.0.0.js` (4761B) + `.min.js` (2038B)
- Field map (Webflow `name` → HubSpot Contact internal name): see script source

**Why region matters:** Different HubSpot data residency regions (na2 vs eu1) used to require different domains. As of 2026, `api.hsforms.com` is the single endpoint and routes by portal ID alone.
