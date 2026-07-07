-- =============================================================
-- 007_construction_kpis.sql - construction-era KPI layer + P&L rebuild
-- Source: 2026-07-05 audit sections 2 (KPI set) + 4 (v_pl_monthly defects)
--         and the 2026-07-06 CWDB HQ dashboard plan.
-- Depends on: schema/013_dashboard_hq.sql (consent_missing,
--             hs_analytics_source, fin_* tables), schema/008 (dim_jobs).
--
-- Changes:
--   A. v_clean_leads: expose the two new fact_leads columns (appended; body
--      otherwise identical to views/006).
--   B. v_lead_funnel: leads_submitted no longer requires tcpa_consent_given
--      (consent is data, not a gate); appends leads_consent_missing.
--      Column set/order preserved for v_validation_gate compatibility.
--   C. v_pl_monthly: kills the phantom $1,000 cwdb-lane referral fee (fees
--      count only when INVOICED and only on non-self-perform lanes) and adds
--      the construction-revenue leg from QBO (fin_pl_monthly income rows).
--      Original 8 columns keep names/positions; new legs appended.
--   D. Six v_kpi_* views for the construction-era scorecard.
-- =============================================================

BEGIN;

-- -------------------------------------------------------------
-- A. v_clean_leads (views/006 body + consent_missing + hs_analytics_source)
-- -------------------------------------------------------------

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
AND (email IS NULL OR email NOT ILIKE '%@cwdb-internal.test');

-- -------------------------------------------------------------
-- B. v_lead_funnel (consent no longer gates leads_submitted)
-- -------------------------------------------------------------

CREATE OR REPLACE VIEW v_lead_funnel WITH (security_invoker = on) AS
WITH monthly_counts AS (
    SELECT
        date_trunc('month', l.submitted_at)::date AS month,
        COUNT(*) AS leads_submitted,
        -- v1 qualification: present in v_clean_leads (valid phone + non-test).
        -- Once a scoring engine populates lead_score, switch to lead_score >= 60.
        COUNT(*) AS leads_qualified,
        COUNT(DISTINCT b.lead_id) AS leads_delivered_to_contractor,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('sent','accepted','declined','paid')) AS leads_with_bid_sent,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('accepted','paid')) AS leads_bid_accepted,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status = 'paid') AS leads_paid,
        COUNT(*) FILTER (WHERE l.consent_missing) AS leads_consent_missing
    FROM v_clean_leads l
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

-- -------------------------------------------------------------
-- C. v_pl_monthly rebuild (two revenue legs, no phantom fees)
-- -------------------------------------------------------------
-- Lane derivation: a bid tied (via job_number) to a dim_jobs row with channel
-- direct_stain/direct_build is the cwdb self-perform lane; NO referral fee
-- exists there regardless of fact_bids.referral_fee_cents defaults. Fee
-- revenue counts ONLY when actually invoiced (referral_fee_invoiced_at).
-- Construction revenue comes from QBO income rows (fin_pl_monthly, cash
-- basis, so invoiced == collected there).

CREATE OR REPLACE VIEW v_pl_monthly WITH (security_invoker = on) AS
WITH spend AS (
    SELECT date_trunc('month', spend_date)::date AS month,
           SUM(cost_cents) / 100.0 AS total_ad_spend
    FROM fact_ad_spend_daily GROUP BY 1
),
bids AS (
    SELECT
        date_trunc('month', b.accepted_at)::date AS month,
        COUNT(*) AS accepted_bids,
        SUM(b.referral_fee_cents) FILTER (
            WHERE b.referral_fee_invoiced_at IS NOT NULL
              AND COALESCE(j.channel, 'lead_purchase') = 'lead_purchase'
        ) / 100.0 AS fee_invoiced,
        SUM(b.referral_fee_cents) FILTER (
            WHERE b.referral_fee_paid_at IS NOT NULL
              AND COALESCE(j.channel, 'lead_purchase') = 'lead_purchase'
        ) / 100.0 AS fee_collected
    FROM fact_bids b
    LEFT JOIN dim_jobs j ON j.job_number = b.job_number
    WHERE b.bid_status IN ('accepted','paid') AND b.accepted_at IS NOT NULL
    GROUP BY 1
),
construction AS (
    SELECT period AS month,
           SUM(amount_cents) FILTER (WHERE account_type = 'Income') / 100.0 AS construction_revenue
    FROM fin_pl_monthly
    GROUP BY 1
)
SELECT
    COALESCE(s.month, b.month, c.month) AS month,
    COALESCE(s.total_ad_spend, 0)       AS ad_spend,
    COALESCE(b.accepted_bids, 0)        AS accepted_bids,
    COALESCE(b.fee_invoiced, 0) + COALESCE(c.construction_revenue, 0)  AS gross_revenue_invoiced,
    COALESCE(b.fee_collected, 0) + COALESCE(c.construction_revenue, 0) AS gross_revenue_collected,
    (COALESCE(b.fee_invoiced, 0) + COALESCE(c.construction_revenue, 0))
        - COALESCE(s.total_ad_spend, 0) AS gross_margin_invoiced,
    (COALESCE(b.fee_collected, 0) + COALESCE(c.construction_revenue, 0))
        - COALESCE(s.total_ad_spend, 0) AS gross_margin_collected,
    ROUND(100.0 * ((COALESCE(b.fee_invoiced, 0) + COALESCE(c.construction_revenue, 0))
                   - COALESCE(s.total_ad_spend, 0))
                / NULLIF(COALESCE(b.fee_invoiced, 0) + COALESCE(c.construction_revenue, 0), 0), 1) AS margin_pct,
    COALESCE(b.fee_invoiced, 0)         AS fee_revenue_invoiced,
    COALESCE(b.fee_collected, 0)        AS fee_revenue_collected,
    COALESCE(c.construction_revenue, 0) AS construction_revenue
FROM spend s
FULL OUTER JOIN bids b ON b.month = s.month
FULL OUTER JOIN construction c ON c.month = COALESCE(s.month, b.month)
ORDER BY month DESC;

-- -------------------------------------------------------------
-- D. Construction-era KPI views (audit section 2 proposed set)
-- -------------------------------------------------------------

-- KPI 1: booked contract revenue per month (signed homeowner contracts)
CREATE OR REPLACE VIEW v_kpi_booked_revenue WITH (security_invoker = on) AS
SELECT
    date_trunc('month', contract_signed_at)::date AS month,
    COUNT(*)                                      AS jobs_booked,
    SUM(total_price_cents) / 100.0                AS booked_revenue,
    array_agg(job_number ORDER BY contract_signed_at) AS job_numbers
FROM dim_jobs
WHERE contract_signed_at IS NOT NULL
  AND status <> 'cancelled'
GROUP BY 1
ORDER BY 1 DESC;

-- KPI 2: gross profit per job and GP% (QBO-sourced revenue/costs)
CREATE OR REPLACE VIEW v_kpi_job_profitability WITH (security_invoker = on) AS
SELECT
    COALESCE(f.job_number, f.job_key)                 AS job,
    j.client_name,
    j.status                                          AS job_status,
    f.revenue_cents / 100.0                           AS revenue,
    f.cost_cents / 100.0                              AS direct_costs,
    (f.revenue_cents - f.cost_cents) / 100.0          AS gross_profit,
    ROUND(100.0 * (f.revenue_cents - f.cost_cents)
                / NULLIF(f.revenue_cents, 0), 1)      AS gp_pct,
    f.updated_at
FROM fin_job_profit f
LEFT JOIN dim_jobs j ON j.job_number = f.job_number
ORDER BY f.revenue_cents DESC;

-- KPI 3: estimate-to-signed close rate + open estimate pipeline value
CREATE OR REPLACE VIEW v_kpi_close_rate WITH (security_invoker = on) AS
SELECT
    date_trunc('month', bid_sent_at)::date AS month,
    COUNT(*) FILTER (WHERE bid_status IN ('sent','accepted','declined','expired','paid')) AS estimates_delivered,
    COUNT(*) FILTER (WHERE bid_status IN ('accepted','paid'))                             AS estimates_accepted,
    ROUND(100.0 * COUNT(*) FILTER (WHERE bid_status IN ('accepted','paid'))
                / NULLIF(COUNT(*) FILTER (WHERE bid_status IN ('sent','accepted','declined','expired','paid')), 0), 1) AS close_rate_pct,
    SUM(bid_amount_cents) FILTER (WHERE bid_status = 'sent') / 100.0                      AS open_estimate_value
FROM fact_bids
WHERE bid_sent_at IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

-- KPI 4: cost per booked job (monthly ad spend / jobs signed that month)
CREATE OR REPLACE VIEW v_kpi_cost_per_booked_job WITH (security_invoker = on) AS
WITH spend AS (
    SELECT date_trunc('month', spend_date)::date AS month,
           SUM(cost_cents) / 100.0 AS ad_spend
    FROM fact_ad_spend_daily GROUP BY 1
),
booked AS (
    SELECT date_trunc('month', contract_signed_at)::date AS month,
           COUNT(*) AS jobs_booked
    FROM dim_jobs
    WHERE contract_signed_at IS NOT NULL AND status <> 'cancelled'
    GROUP BY 1
)
SELECT
    COALESCE(s.month, b.month)          AS month,
    COALESCE(s.ad_spend, 0)             AS ad_spend,
    COALESCE(b.jobs_booked, 0)          AS jobs_booked,
    ROUND((COALESCE(s.ad_spend, 0) / NULLIF(b.jobs_booked, 0))::numeric, 2) AS cost_per_booked_job
FROM spend s
FULL OUTER JOIN booked b ON b.month = s.month
ORDER BY month DESC;

-- KPI 5: lead -> first estimate cycle time, per lead (app aggregates).
-- First-touch time is not yet instrumented anywhere; when it is, add a
-- first_touch_at leg here. Showing the gap honestly beats faking it.
CREATE OR REPLACE VIEW v_kpi_cycle_time WITH (security_invoker = on) AS
SELECT
    l.lead_id,
    l.full_name,
    l.lead_channel,
    l.submitted_at,
    MIN(b.bid_sent_at) AS first_estimate_at,
    ROUND((EXTRACT(EPOCH FROM MIN(b.bid_sent_at) - l.submitted_at) / 86400.0)::numeric, 1) AS days_lead_to_estimate
FROM v_clean_leads l
LEFT JOIN fact_bids b ON b.lead_id = l.lead_id AND b.bid_sent_at IS NOT NULL
GROUP BY l.lead_id, l.full_name, l.lead_channel, l.submitted_at
ORDER BY l.submitted_at DESC;

-- KPI 6: backlog (signed, not yet completed). Weeks-booked needs crew
-- capacity data that does not exist yet; jobs + dollars is the honest v1.
CREATE OR REPLACE VIEW v_kpi_backlog WITH (security_invoker = on) AS
SELECT
    COUNT(*)                                   AS jobs_in_backlog,
    SUM(total_price_cents) / 100.0             AS backlog_value,
    SUM(total_price_cents - COALESCE(deposit_cents, 0)) / 100.0 AS backlog_uncollected_value,
    MIN(contract_signed_at)                    AS oldest_signed_at,
    array_agg(job_number ORDER BY contract_signed_at) AS job_numbers
FROM dim_jobs
WHERE status IN ('contracted','in_progress');

COMMIT;
