-- 006_exclude_internal_test_domain.sql
-- Harden v_clean_leads: exclude the @cwdb-internal.test synthetic email domain.
--
-- WHY (council_id 1, verdict 'changes', 2026-06-11): the routing self-test fires
-- a webhook with email routing-selftest@cwdb-internal.test and relies on
-- utm_source='test' for gate exclusion, then deletes its rows. Deletion races
-- the 06:55 warehouse refresh: a snapshot taken between insert and delete would
-- count the synthetic lead. The view filter, not row deletion, must be the
-- gate-safety guarantee, so the synthetic domain is excluded declaratively here.
-- Body identical to views/004 plus the one new predicate (last line).
-- Reversible: re-run views/004_clean_leads_all_channel.sql.

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
    tcpa_consent_source
FROM fact_leads
WHERE
    (email IS NULL OR email NOT IN ('test@test.com', 'dcebighitta12@aim.com', 'slogarjw@gmail.com'))
AND COALESCE(full_name, '') NOT ILIKE 'test%'
AND COALESCE(utm_source, '') <> 'test'
AND (email IS NULL OR email NOT ILIKE '%@cwdb-internal.test');
