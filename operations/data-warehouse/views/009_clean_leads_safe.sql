-- =============================================================
-- 009_clean_leads_safe.sql - non-PII clean-leads base for the cloud twin
--
-- views/008 made v_clean_leads security_invoker (closing the anon PII hole),
-- but definer views that READ it (v_lead_funnel, v_kpi_cycle_time) re-apply
-- invoker semantics inside the chain, so they returned empty for anon.
--
-- Fix: v_clean_leads_safe - a DEFINER view over fact_leads exposing only
-- non-PII columns, with the SAME test-exclusion predicate as v_clean_leads.
-- The aggregate views read it instead.
--
-- MAINTENANCE RULE: the exclusion predicate now lives in TWO views
-- (v_clean_leads in views/007+, v_clean_leads_safe here). Any change to the
-- test-exclusion set must update BOTH.
-- =============================================================

BEGIN;

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
AND (email IS NULL OR email NOT ILIKE '%@cwdb-internal.test');

-- Re-point the definer aggregate views at the safe base.

CREATE OR REPLACE VIEW v_lead_funnel AS
WITH monthly_counts AS (
    SELECT
        date_trunc('month', l.submitted_at)::date AS month,
        COUNT(*) AS leads_submitted,
        COUNT(*) AS leads_qualified,
        COUNT(DISTINCT b.lead_id) AS leads_delivered_to_contractor,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('sent','accepted','declined','paid')) AS leads_with_bid_sent,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('accepted','paid')) AS leads_bid_accepted,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status = 'paid') AS leads_paid,
        COUNT(*) FILTER (WHERE l.consent_missing) AS leads_consent_missing
    FROM v_clean_leads_safe l
    LEFT JOIN fact_bids b ON b.lead_id = l.lead_id
    GROUP BY 1
)
SELECT
    month,
    leads_submitted,
    leads_qualified,
    leads_delivered_to_contractor,
    leads_with_bid_sent,
    leads_bid_accepted,
    leads_paid,
    ROUND(100.0 * leads_qualified / NULLIF(leads_submitted, 0), 1)            AS pct_qualified,
    ROUND(100.0 * leads_delivered_to_contractor / NULLIF(leads_qualified, 0), 1) AS pct_delivered_of_qualified,
    ROUND(100.0 * leads_with_bid_sent / NULLIF(leads_delivered_to_contractor, 0), 1) AS pct_bid_of_delivered,
    ROUND(100.0 * leads_bid_accepted / NULLIF(leads_with_bid_sent, 0), 1)     AS pct_accepted_of_bid,
    ROUND(100.0 * leads_paid / NULLIF(leads_bid_accepted, 0), 1)              AS pct_paid_of_accepted,
    ROUND(100.0 * leads_paid / NULLIF(leads_submitted, 0), 2)                 AS pct_paid_of_submitted,
    leads_consent_missing
FROM monthly_counts
ORDER BY month DESC;

CREATE OR REPLACE VIEW v_kpi_cycle_time AS
SELECT
    l.lead_id,
    l.lead_channel,
    l.submitted_at,
    MIN(b.bid_sent_at) AS first_estimate_at,
    ROUND((EXTRACT(EPOCH FROM MIN(b.bid_sent_at) - l.submitted_at) / 86400.0)::numeric, 1) AS days_lead_to_estimate
FROM v_clean_leads_safe l
LEFT JOIN fact_bids b ON b.lead_id = l.lead_id AND b.bid_sent_at IS NOT NULL
GROUP BY l.lead_id, l.lead_channel, l.submitted_at
ORDER BY l.submitted_at DESC;

COMMIT;
