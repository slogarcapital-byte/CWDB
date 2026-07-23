# TCPA Webform Consent Backfill Audit (2026-07-22)

Scope: dashboard task 12 (audit-2026-07-05#12). Webform leads since 2026-06-16, cross-checked across three layers: Webflow native form submissions, HubSpot contact records (record source + conversion events), and the warehouse (`fact_leads`, `raw_intake_events`). Report only: no lead data was modified.

## Root cause of the Petersen consent miss

Dena Petersen (6/30) DID check the required consent box. The Webflow native submission record (id `6a43c6e76aa5d236eaf92bd3`, form `wf-form-Quote-Request`, /get-a-quote) contains `tcpa_consent: "true"`. The regression was in transport, not capture:

1. On 6/30 the only path that carried `tcpa_consent_given` to HubSpot was the browser-side relay (`hubspot_form_relay-1.0.0` logic, embedded as page footer custom code). That POST never landed for her session.
2. Her HubSpot contact was created solely by HubSpot's collected-forms auto-capture (tracking script). Evidence: `hs_object_source_detail_1 = "#wf-form-Quote-Request"` and BOTH first and recent conversion events are the collected-forms event. Compare James Reist (6/15, consent OK): his record shows the collected-forms event AND the relay's Forms API submission ("quote request"), which carried consent + UTM.
3. Collected-forms capture only maps standard fields (name, email, phone). Custom properties (`tcpa_consent_given`, `utm_*`, `lead_source_page`) were never written, hence `consent_missing = true` in the warehouse.

Why the browser POST failed cannot be proven retroactively; she arrived from Facebook mobile (`hs_analytics_source_data_1 = Facebook`), where the in-app browser is known to cancel in-flight `fetch(keepalive)` requests on the redirect to /thank-you. The single-path client-side POST with no delivery guarantee was the structural defect. The task hypothesis (2026-07-14 relay v2 vocabulary window) is ruled out: that change shipped two weeks after Petersen.

Note: her checked consent box is recoverable evidence. The Webflow form submission record retains `tcpa_consent: "true"` with a server-side timestamp (2026-06-30T13:38:47Z) if consent ever needs to be demonstrated for this lead.

## What is fixed as of 2026-07-22 (see session summary for exact changes)

- Beacon-first delivery (`navigator.sendBeacon`, survives navigation and in-app webviews) with `fetch(keepalive)` fallback, relay v2.1.0, deployed site-wide.
- Gateway (server-side) has dual-written HubSpot + JobTread + bronze since 2026-07-14; consent verified flowing (Dubois 7/18, Brown 7/19 both `tcpa_consent_given = true`, source `form`).
- Relay now fills the form's hidden fields (`hutk`, `pageUri`, `pageName`, real `utm_source`) before submit, so even a total gateway outage leaves an attribution-complete, consent-bearing Webflow native record.
- Gateway v11 forwards the `hutk` cookie in the HubSpot Forms API context so the server-side submission merges with any collected-forms contact instead of leaving a consent-less duplicate.

## Lead-by-lead audit (all leads since 2026-06-16, fact_leads)

| Lead | Date | Channel | Consent in CRM | Finding |
|---|---|---|---|---|
| Sherry Neely (306) | 6/19 | phone | missing | Phone lead, no verbal consent recorded. Out of webform scope; needs `tcpa_consent_source = verbal` backfill by Jim if consent was given on the call. |
| Valeria Hanson (307) | 6/24 | phone | missing | Same as Neely: phone channel, verbal consent never recorded. |
| Dena Petersen (308) | 6/30 | webform | missing | CONSENT WAS CAPTURED at the form (Webflow record `6a43c6e76aa5d236eaf92bd3`, `tcpa_consent: "true"`). Lost in transport (see root cause). Candidate for manual `tcpa_consent_given` backfill citing the Webflow submission record; left untouched per report-only scope. |
| Jodi Nelson-Claeys (351) | 7/8 | phone | missing | Phone channel, verbal consent never recorded. |
| Jim Peksa (442) | 7/8 | webform (mislabeled) | missing | NOT a webform lead: `hs_object_source = MOBILE_IOS` (created manually in the HubSpot iOS app, user 90179883). No Webflow submission exists for this contact. The webform channel label is wrong; consent, if any, would be verbal. |
| Carl Dubois (459) | 7/18 | webform | given (form) | Correct end-to-end via gateway. Content looks like a B2B solicitation, not a homeowner. |
| Mark Brown (477) | 7/19 | webform | given (form) | Correct end-to-end via gateway. Also reads as a B2B solicitation (estimating services, FL address). |

Webflow native submissions since 6/16 with no matching real lead: 6/23 `test@test.com`, 7/16 `dcebighitta12@aim.com`, 7/17 `test@cwdb-internal.test` (all Jim's tests, correctly excluded).

## Open gaps flagged (not fixed in this pass)

1. **City-page quote forms have NO consent checkbox.** The Service Areas Template form (live on all 5 /service-area/* pages, same `wf-form-Quote-Request` id) has fields name/phone/email/address/ownership/project_type/budget/timeline/notes and no `tcpa_consent` field. Zero submissions to date, but any future submission produces a consent-less lead by construction. As of this pass the site-wide relay v2.1.0 now at least delivers those submissions to the gateway (lead captured, `consent_missing` flagged, JobTread `tcpa_consent_given = false`) instead of silently dying in Webflow storage. The proper fix is adding the same required consent checkbox + disclosure text to the template form; that adds legal copy to 5 pages and touches a CMS-bound component, so it is deferred to the planned content pass. Until then the checkbox absence is the top TCPA exposure.
2. **Phone-channel verbal consent is never recorded** (3 of 7 leads since 6/16). Process gap, not a website bug: the call script should capture consent and Jim should stamp `tcpa_consent_source = verbal` when creating the contact.
3. **Peksa channel mislabel** (`webform` but MOBILE_IOS-created) will slightly overstate webform counts in `v_lead_funnel` splits.
