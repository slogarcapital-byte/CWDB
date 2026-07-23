---
name: jobtread-hybrid
description: "JobTread is the jobs platform (accelerated hybrid, 2026-07-13/14); gateway architecture, no-undo rule, hybrid data seam"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7db932b2-dda4-41c7-8254-669169f98f9b
---

# JobTread hybrid (adopted 2026-07-13, built 2026-07-14)

Design: `operations/analysis/jobtread-setup-design.md`. Platform profile: `_vault/platforms/JobTread.md`. Org id `22PakakWzKDv`. Plan executed via `docs/superpowers/plans/2026-07-13-jobtread-setup.md`.

**Architecture:** Webflow form → Supabase Edge Function `jobtread-gateway` `/intake` (stamps UTM/gclid/consent, dual-writes JobTread via Pave + HubSpot Forms API, lands bronze `raw_intake_events`) · JobTread webhook → `/webhook` (logs `raw_jobtread_events`; on Status transition into exactly `Signed / Booked` queues `conversions_outbox` + fires GA4 MP) · local worker `push-google-offline-conversions.ps1` uploads outbox rows with the existing Google Ads OAuth stack (outbox pattern: ad-platform secrets never go to the cloud) · daily pull `pull-jobtread-snapshot.ps1` = source #5.

**Hybrid data seam (do not "fix"):** `fact_leads` stays fed by the HubSpot pull until cutover; the Edge Function deliberately does NOT write fact_leads (would double-count). `raw_intake_events` becomes the fact_leads source at cutover. `crm_source` column defaults `'hubspot'`.

**Standing rules:**
- AI Connector (MCP server `jobtread`) writes are immediate, NO undo: draft-then-confirm for anything customer-visible.
- No real customer signs in JobTread until legal sign-off on the proposal template legal block (`operations/jobtread/proposal-template-legal-block.md`; counsel found the first extraction dropped the 429.1(a) near-signature statement + the 779.02(2) Notice to Owner — both now included, sign-off pending).
- Stage 6 name is load-bearing: `Signed / Booked` exactly (webhook fan-out matches the string).
- **Option vocabulary (2026-07-15):** the form/HubSpot/warehouse speak SLUGS (`deck-replacement`, `35k-50k`); JobTread option fields hold the form's human LABELS; the gateway's slug->label maps are the only translation seam. If form options change, update JobTread option lists AND gateway maps together. (The old "byte-match HubSpot" rule was executed against a stale design doc and broke the first real lead.)

**Test protocol quirk (2026-07-17):** HubSpot silently DROPS `@cwdb-internal.test` emails (reserved TLD): test submissions create email-less contacts, so the v_clean_leads email exclusion never sees them and HubSpot cleanup must search by NAME. Keep using @cwdb-internal.test (bronze retains the email); just clean HubSpot by name afterward.

**Platform quirks (cost real debugging time):** accounts not customers; jobs hang off locations; contact phone/email are custom fields; create-mutation `customFieldValues` keyed by FIELD ID; account names unique (gateway retries with phone-last-4 suffix); 30-char name cap; Pave 413s above ~size-25 pages; Pave errors are text not JSON; Supabase functions require `apikey` even with verify_jwt off (rides the URL for webhook + relay); repo `SUPABASE_URL` is the REST url, strip `/rest/v1/` for function URLs. Full list: `operations/jobtread/org-setup-notes.md`.

Related: [[fulfillment-model-pivot-2026-06-10]], [[cwdb-hq-dashboard]], [[estimator-v2-explicit-labor]] (Streamlit estimator = fallback during cutover).
