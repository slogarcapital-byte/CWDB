-- =============================================================
-- 010_exclude_lead5_jim_phone_test.sql - drop Jim's no-email test lead
-- (audit-2026-07-05#27, data hygiene)
--
-- lead_id 5 ("Jim Slogar", 2026-05-05, webform) is Jim's own test
-- submission. It slips through every existing exclusion rule because it
-- has NO email (the email blocklist and @cwdb-internal.test rules pass
-- NULL emails), full_name does not start with 'test', and utm_source is
-- NULL. There is no attribute-based predicate that catches it without
-- risking false positives, so it is excluded by lead_id.
--
-- MAINTENANCE RULE (from views/009): the test-exclusion predicate lives
-- in BOTH v_clean_leads and v_clean_leads_safe. This migration updates
-- BOTH, keeping them in sync.
--
-- v_clean_leads is security_invoker=on since views/008 (anon PII hole);
-- re-asserted explicitly after the replace so the option can never be
-- lost by a definition rebuild. v_clean_leads_safe stays definer-rights
-- (the cloud twin reads aggregates through it).
--
-- Expected effect: clean-lead count drops by exactly 1 (20 -> 19 as of
-- 2026-07-22). lead_id 5 has no fact_bids rows, so funnel bid stages
-- are unchanged.
-- =============================================================

BEGIN;

CREATE OR REPLACE VIEW v_clean_leads AS
SELECT
    lead_id,
    webflow_submission_id,
    hubspot_contact_id,
    hubspot_deal_id,
    submitted_at,
    date_key,
    full_name,
    phone,
    email,
    property_address,
    city_id,
    owns_property,
    project_type,
    budget_range,
    project_timeline,
    lead_notes,
    tcpa_consent_given,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_term,
    utm_content,
    gclid,
    lead_source_page,
    utm_source_ga4,
    utm_medium_ga4,
    utm_campaign_ga4,
    attributed_campaign_id_via_utm,
    attributed_campaign_id_via_gclid,
    lead_score,
    disqualification_reason,
    created_at,
    updated_at,
    lead_channel,
    tcpa_consent_source,
    consent_missing,
    hs_analytics_source
FROM fact_leads
WHERE
    (email IS NULL OR email NOT IN ('test@test.com', 'dcebighitta12@aim.com', 'slogarjw@gmail.com'))
AND COALESCE(full_name, '') NOT ILIKE 'test%'
AND COALESCE(utm_source, '') <> 'test'
AND (email IS NULL OR email NOT ILIKE '%@cwdb-internal.test')
AND lead_id <> 5;  -- Jim's no-email phone-test submission (2026-05-05)

-- Re-assert the anon PII guard from views/008.
ALTER VIEW v_clean_leads SET (security_invoker = on);

CREATE OR REPLACE VIEW v_clean_leads_safe AS
SELECT
    lead_id,
    submitted_at,
    date_key,
    city_id,
    project_type,
    budget_range,
    project_timeline,
    tcpa_consent_given,
    consent_missing,
    lead_channel,
    tcpa_consent_source,
    utm_source,
    utm_medium,
    utm_campaign,
    gclid,
    hs_analytics_source,
    lead_score
FROM fact_leads
WHERE
    (email IS NULL OR email NOT IN ('test@test.com', 'dcebighitta12@aim.com', 'slogarjw@gmail.com'))
AND COALESCE(full_name, '') NOT ILIKE 'test%'
AND COALESCE(utm_source, '') <> 'test'
AND (email IS NULL OR email NOT ILIKE '%@cwdb-internal.test')
AND lead_id <> 5;  -- Jim's no-email phone-test submission (2026-05-05)

COMMIT;
