-- 004_clean_leads_all_channel.sql
-- Two fixes for all-channel lead counting (2026-06-10 pivot):
--   1. NULL-safe test-email exclusion. The old predicate
--      (email <> ALL (...)) evaluates to NULL for rows with no email,
--      silently dropping phone leads from every downstream view
--      (v_lead_funnel, v_validation_gate).
--   2. Pass through lead_channel + tcpa_consent_source (schema/009) so
--      funnel and gate metrics can segment by channel.
-- Test-lead exclusions are unchanged (views/003): test emails, test names,
-- utm_source='test'.

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
AND COALESCE(utm_source, '') <> 'test';
