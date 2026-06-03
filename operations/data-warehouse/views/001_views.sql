-- CWDB Data Warehouse . Analytical Views (v2 / Phase E)
-- Depends on: schema/001_initial.sql (+ migrations 002-005)
-- Purpose: answer day-1 KPIs via SELECT * FROM v_*
-- v2 changes (Phase E, 2026-06-02):
--   1) New helper views v_clean_leads + v_clean_traffic centralize test-traffic exclusion.
--      All analytical views now read from helpers so KPIs are not polluted by GTM Tag Assistant,
--      Meta Events Manager test tool, phase0_test relay smoke tests, or Jim's self-test rows.
--   2) New v_thankyou_reconciliation cross-checks /thank-you GA4 sessions against fact_leads
--      and surfaces (a) pre-HubSpot-capture form submits and (b) days when a lead landed
--      without a /thank-you page-view event firing.
--   3) New v_meta_attribution_gap quantifies the Meta-UI vs GA4 conversion mismatch
--      (the pixel-routing diagnostic . corroborated 2026-06-02: 0 vs 6 over 31 days).

BEGIN;

-- =============================================================
-- HELPER VIEWS (Phase E) . single source of truth for test-traffic exclusion
-- =============================================================

-- v_clean_leads: fact_leads minus known test contacts.
-- Maintain the exclusion set here, not inside every analytical view.
CREATE OR REPLACE VIEW v_clean_leads WITH (security_invoker = on) AS
SELECT *
FROM fact_leads
WHERE
    email NOT IN ('test@test.com', 'dcebighitta12@aim.com')
AND COALESCE(full_name, '') NOT ILIKE 'test%';

-- v_clean_traffic: fact_traffic_daily minus known test/debug sources.
-- Sources observed 2026-06-02: tagassistant.google.com (GTM Preview), eventsmanager.facebook.com
-- (Meta Events Manager test tool . fired 9 spurious "conversions"), phase0_test (form relay smoke),
-- "test" with campaign id-audit-2026-04-25 (Phase F account-identity verification).
CREATE OR REPLACE VIEW v_clean_traffic WITH (security_invoker = on) AS
SELECT *
FROM fact_traffic_daily
WHERE
    source NOT IN ('tagassistant.google.com', 'eventsmanager.facebook.com', 'phase0_test', 'test')
AND campaign NOT IN ('phase0_test', 'id-audit-2026-04-25', 'relay_v1');


-- =============================================================
-- v_lead_funnel . funnel conversion rates by month
-- =============================================================
-- Answers: "What % of leads make it to each pipeline stage?"

CREATE OR REPLACE VIEW v_lead_funnel WITH (security_invoker = on) AS
WITH monthly_counts AS (
    SELECT
        date_trunc('month', l.submitted_at)::date AS month,
        COUNT(*) FILTER (WHERE l.tcpa_consent_given) AS leads_submitted,
        -- v1 qualification: present in v_clean_leads (TCPA + valid phone + email pass + non-test).
        -- Once a scoring engine populates lead_score, switch this to `lead_score >= 60`.
        COUNT(*) AS leads_qualified,
        -- Any fact_bids row means lead was routed (status 'pending' = Scheduled/Creating Bid).
        COUNT(DISTINCT b.lead_id) AS leads_delivered_to_contractor,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('sent','accepted','declined','paid')) AS leads_with_bid_sent,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('accepted','paid')) AS leads_bid_accepted,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status = 'paid') AS leads_paid
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
    ROUND(100.0 * leads_paid / NULLIF(leads_submitted, 0), 2)                 AS pct_paid_of_submitted
FROM monthly_counts
ORDER BY month DESC;

-- =============================================================
-- v_cac_by_channel . CAC by platform + month
-- =============================================================
-- Answers: "How much did each platform cost per lead and per accepted bid?"

CREATE OR REPLACE VIEW v_cac_by_channel WITH (security_invoker = on) AS
WITH ad_spend AS (
    SELECT
        date_trunc('month', spend_date)::date AS month,
        platform,
        SUM(cost_cents) / 100.0 AS cost_dollars,
        SUM(impressions)        AS impressions,
        SUM(clicks)             AS clicks
    FROM fact_ad_spend_daily
    GROUP BY 1, 2
),
leads_by_channel AS (
    SELECT
        date_trunc('month', l.submitted_at)::date AS month,
        CASE
            WHEN l.utm_source ILIKE '%google%' OR l.gclid IS NOT NULL THEN 'google_ads'
            WHEN l.utm_source ILIKE '%facebook%' OR l.utm_source ILIKE '%instagram%' OR l.utm_source ILIKE '%meta%' THEN 'meta'
            WHEN l.utm_source ILIKE '%nextdoor%' THEN 'nextdoor'
            ELSE COALESCE(l.utm_source, 'organic_direct')
        END AS platform,
        COUNT(*)                                                              AS leads,
        COUNT(*) FILTER (WHERE l.lead_score >= 60)                            AS qualified_leads,
        COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('accepted','paid')) AS accepted_bids
    FROM v_clean_leads l
    LEFT JOIN fact_bids b ON b.lead_id = l.lead_id
    GROUP BY 1, 2
)
SELECT
    COALESCE(s.month, l.month)        AS month,
    COALESCE(s.platform, l.platform)  AS platform,
    s.cost_dollars                    AS spend,
    s.impressions,
    s.clicks,
    l.leads                           AS leads,
    l.qualified_leads,
    l.accepted_bids,
    ROUND(s.cost_dollars / NULLIF(l.leads, 0), 2)            AS cost_per_lead,
    ROUND(s.cost_dollars / NULLIF(l.qualified_leads, 0), 2)  AS cost_per_qualified_lead,
    ROUND(s.cost_dollars / NULLIF(l.accepted_bids, 0), 2)    AS cost_per_accepted_bid,
    ROUND(100.0 * l.accepted_bids * 1000.0 / NULLIF(s.cost_dollars, 0), 1) AS roas_pct  -- assumes $1K revenue per accepted bid
FROM ad_spend s
FULL OUTER JOIN leads_by_channel l ON l.month = s.month AND l.platform = s.platform
ORDER BY month DESC, platform;

-- =============================================================
-- v_contractor_scorecard . per-contractor performance
-- =============================================================
-- Answers: "Which contractor wins the most? Bids the fastest? Has the highest avg bid?"

CREATE OR REPLACE VIEW v_contractor_scorecard WITH (security_invoker = on) AS
SELECT
    c.contractor_id,
    c.business_name,
    c.contact_name,
    c.lifecycle_stage,
    c.is_active,
    COUNT(b.bid_id)                                                      AS total_bids,
    COUNT(*) FILTER (WHERE b.bid_status IN ('sent','accepted','declined','paid'))  AS bids_sent,
    COUNT(*) FILTER (WHERE b.bid_status IN ('accepted','paid'))          AS bids_accepted,
    COUNT(*) FILTER (WHERE b.bid_status = 'paid')                        AS bids_paid,
    ROUND(AVG(b.bid_amount_cents / 100.0) FILTER (WHERE b.bid_amount_cents IS NOT NULL), 2) AS avg_bid_dollars,
    ROUND(SUM(b.referral_fee_cents) FILTER (WHERE b.bid_status = 'paid') / 100.0, 2) AS total_referral_fees_earned,
    ROUND(100.0 * COUNT(*) FILTER (WHERE b.bid_status IN ('accepted','paid'))
                / NULLIF(COUNT(*) FILTER (WHERE b.bid_status IN ('sent','accepted','declined','paid')), 0), 1) AS win_rate_pct,
    ROUND(EXTRACT(EPOCH FROM AVG(b.bid_sent_at - l.submitted_at)) / 3600.0, 2) AS avg_response_hours,
    MAX(b.accepted_at) AS most_recent_win
FROM dim_contractor c
LEFT JOIN fact_bids b ON b.contractor_id = c.contractor_id
LEFT JOIN v_clean_leads l ON l.lead_id = b.lead_id
GROUP BY c.contractor_id, c.business_name, c.contact_name, c.lifecycle_stage, c.is_active
ORDER BY bids_paid DESC NULLS LAST, win_rate_pct DESC NULLS LAST;

-- =============================================================
-- v_city_demand . per-city lead volume + quality
-- =============================================================
-- Answers: "Which cities produce the highest-quality leads at the best ROAS?"

CREATE OR REPLACE VIEW v_city_demand WITH (security_invoker = on) AS
SELECT
    ct.city_id,
    ct.city_name,
    date_trunc('month', l.submitted_at)::date AS month,
    COUNT(*)                                                              AS leads,
    COUNT(*) FILTER (WHERE l.lead_score >= 60)                            AS qualified_leads,
    ROUND(AVG(l.lead_score), 1)                                           AS avg_lead_score,
    COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('accepted','paid')) AS accepted_bids,
    ROUND(100.0 * COUNT(DISTINCT b.lead_id) FILTER (WHERE b.bid_status IN ('accepted','paid'))
                / NULLIF(COUNT(*), 0), 1)                                 AS conversion_rate_pct
FROM dim_city ct
LEFT JOIN v_clean_leads l ON l.city_id = ct.city_id
LEFT JOIN fact_bids b ON b.lead_id = l.lead_id
GROUP BY ct.city_id, ct.city_name, date_trunc('month', l.submitted_at)
ORDER BY month DESC NULLS LAST, leads DESC NULLS LAST;

-- =============================================================
-- v_pl_monthly . P&L reconciliation
-- =============================================================
-- Answers: "What's our gross margin per month? Ad spend vs accepted-bid revenue."

CREATE OR REPLACE VIEW v_pl_monthly WITH (security_invoker = on) AS
WITH spend AS (
    SELECT date_trunc('month', spend_date)::date AS month, SUM(cost_cents) / 100.0 AS total_ad_spend
    FROM fact_ad_spend_daily GROUP BY 1
),
revenue AS (
    SELECT date_trunc('month', accepted_at)::date AS month,
           COUNT(*) AS accepted_bids,
           SUM(referral_fee_cents) / 100.0 AS gross_revenue,
           SUM(referral_fee_cents) FILTER (WHERE referral_fee_paid_at IS NOT NULL) / 100.0 AS collected_revenue
    FROM fact_bids
    WHERE bid_status IN ('accepted','paid') AND accepted_at IS NOT NULL
    GROUP BY 1
)
SELECT
    COALESCE(s.month, r.month) AS month,
    COALESCE(s.total_ad_spend, 0) AS ad_spend,
    COALESCE(r.accepted_bids, 0)  AS accepted_bids,
    COALESCE(r.gross_revenue, 0)  AS gross_revenue_invoiced,
    COALESCE(r.collected_revenue, 0) AS gross_revenue_collected,
    COALESCE(r.gross_revenue, 0) - COALESCE(s.total_ad_spend, 0)        AS gross_margin_invoiced,
    COALESCE(r.collected_revenue, 0) - COALESCE(s.total_ad_spend, 0)    AS gross_margin_collected,
    ROUND(100.0 * (COALESCE(r.gross_revenue, 0) - COALESCE(s.total_ad_spend, 0))
                / NULLIF(r.gross_revenue, 0), 1) AS margin_pct
FROM spend s
FULL OUTER JOIN revenue r ON r.month = s.month
ORDER BY month DESC;

-- =============================================================
-- v_lead_attribution_disagreement . diagnostic
-- =============================================================
-- Answers: "Where do HubSpot UTM and GA4 attribution disagree?"
-- A populated result means tracking is leaking somewhere.
-- 2026-06-02 status: expected to return empty until the HubSpot Forms relay
-- begins forwarding utm_* and gclid from the URL into Contact properties
-- (currently null on all leads . a separate workstream).

CREATE OR REPLACE VIEW v_lead_attribution_disagreement WITH (security_invoker = on) AS
SELECT
    lead_id,
    submitted_at,
    email,
    utm_source        AS hubspot_utm_source,
    utm_source_ga4    AS ga4_utm_source,
    utm_campaign      AS hubspot_utm_campaign,
    utm_campaign_ga4  AS ga4_utm_campaign,
    attributed_campaign_id_via_utm,
    attributed_campaign_id_via_gclid
FROM v_clean_leads
WHERE
    (utm_source IS DISTINCT FROM utm_source_ga4)
 OR (utm_campaign IS DISTINCT FROM utm_campaign_ga4)
 OR (attributed_campaign_id_via_utm IS DISTINCT FROM attributed_campaign_id_via_gclid)
ORDER BY submitted_at DESC;

-- =============================================================
-- v_unjoined_leads . diagnostic
-- =============================================================
-- Answers: "Which leads have UTM values that don't match any known campaign?"
-- A populated result means dead/typo'd UTMs in live ads.

CREATE OR REPLACE VIEW v_unjoined_leads WITH (security_invoker = on) AS
SELECT
    lead_id,
    submitted_at,
    email,
    utm_source,
    utm_medium,
    utm_campaign,
    gclid,
    lead_source_page
FROM v_clean_leads
WHERE
    (utm_campaign IS NOT NULL OR gclid IS NOT NULL)
AND attributed_campaign_id_via_utm IS NULL
AND attributed_campaign_id_via_gclid IS NULL
ORDER BY submitted_at DESC;


-- =============================================================
-- v_thankyou_reconciliation (Phase E NEW) . funnel-leak detector
-- =============================================================
-- Answers: "On any given day, did every /thank-you page-view result in a HubSpot
-- contact creation? Did any HubSpot contact appear without a /thank-you event?"
-- Pre-2026-05-05 thank-you sessions exist with no fact_leads rows . those represent
-- form submits that emailed Jim before the HubSpot Forms API relay went live and are
-- lost-lead evidence rather than a code defect.

CREATE OR REPLACE VIEW v_thankyou_reconciliation WITH (security_invoker = on) AS
WITH ty AS (
    SELECT
        session_date,
        SUM(sessions)    AS thankyou_sessions,
        SUM(conversions) AS thankyou_ga4_conv
    FROM v_clean_traffic
    WHERE page_path = '/thank-you'
    GROUP BY 1
),
leads AS (
    SELECT
        submitted_at::date AS d,
        COUNT(*)           AS leads_created
    FROM v_clean_leads
    GROUP BY 1
)
SELECT
    COALESCE(ty.session_date, leads.d)         AS d,
    (COALESCE(ty.session_date, leads.d)
        < DATE '2026-05-05')                   AS pre_hubspot_capture,
    COALESCE(ty.thankyou_sessions, 0)          AS thankyou_sessions,
    COALESCE(ty.thankyou_ga4_conv, 0)          AS thankyou_ga4_conv,
    COALESCE(leads.leads_created, 0)           AS leads_created,
    COALESCE(ty.thankyou_sessions, 0)
        - COALESCE(leads.leads_created, 0)     AS thankyou_minus_leads,
    CASE
        WHEN COALESCE(leads.leads_created, 0) > 0
         AND COALESCE(ty.thankyou_sessions, 0) = 0 THEN 'lead_without_thankyou_event'
        WHEN COALESCE(ty.thankyou_sessions, 0) > 0
         AND COALESCE(leads.leads_created, 0) = 0 THEN 'thankyou_without_lead'
        WHEN COALESCE(ty.thankyou_sessions, 0) = COALESCE(leads.leads_created, 0) THEN 'match'
        ELSE 'partial_match'
    END                                        AS match_status
FROM ty FULL OUTER JOIN leads ON ty.session_date = leads.d
ORDER BY d DESC;

-- =============================================================
-- v_meta_attribution_gap (Phase E NEW) . pixel-routing diagnostic
-- =============================================================
-- Answers: "Does Meta's own reported conversion count agree with GA4's count of
-- conversions attributed to source=meta/medium=cpc? A persistent gap means the
-- Meta Pixel + Conversions API are reporting into a different Business Manager
-- than the one fact_ad_spend_daily is pulling from (Phase F account-identity bug)."
-- 2026-06-02 baseline: 0 (Meta UI) vs 6 (GA4) over 2026-04-28 → 2026-05-28.

CREATE OR REPLACE VIEW v_meta_attribution_gap WITH (security_invoker = on) AS
WITH meta_ui AS (
    SELECT
        date_trunc('month', spend_date)::date AS month,
        SUM(impressions)              AS impressions,
        SUM(clicks)                   AS clicks,
        SUM(cost_cents) / 100.0       AS spend_dollars,
        SUM(conversions)              AS conv_meta_ui
    FROM fact_ad_spend_daily
    WHERE platform = 'meta'
    GROUP BY 1
),
meta_ga4 AS (
    SELECT
        date_trunc('month', session_date)::date AS month,
        SUM(sessions)                 AS sessions_meta_cpc,
        SUM(conversions)              AS conv_meta_ga4
    FROM v_clean_traffic
    WHERE source = 'meta' AND medium = 'cpc'
    GROUP BY 1
)
SELECT
    COALESCE(u.month, g.month)                 AS month,
    COALESCE(u.impressions, 0)                 AS impressions,
    COALESCE(u.clicks, 0)                      AS clicks,
    COALESCE(u.spend_dollars, 0)               AS spend_dollars,
    COALESCE(u.conv_meta_ui, 0)                AS conv_meta_ui,
    COALESCE(g.sessions_meta_cpc, 0)           AS sessions_meta_via_ga4,
    COALESCE(g.conv_meta_ga4, 0)               AS conv_meta_via_ga4,
    COALESCE(g.conv_meta_ga4, 0)
        - COALESCE(u.conv_meta_ui, 0)          AS gap_ga4_minus_ui,
    CASE
        WHEN COALESCE(u.conv_meta_ui, 0) = 0
         AND COALESCE(g.conv_meta_ga4, 0) > 0 THEN 'pixel_routing_broken'
        WHEN COALESCE(u.conv_meta_ui, 0) > 0
         AND COALESCE(g.conv_meta_ga4, 0) = 0 THEN 'ga4_missing_meta_attribution'
        WHEN COALESCE(u.conv_meta_ui, 0) = COALESCE(g.conv_meta_ga4, 0) THEN 'agree'
        ELSE 'partial_disagreement'
    END                                        AS diagnosis
FROM meta_ui u FULL OUTER JOIN meta_ga4 g ON u.month = g.month
ORDER BY month DESC;

COMMIT;
