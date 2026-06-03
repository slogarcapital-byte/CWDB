-- CWDB Data Warehouse — Initial Schema (v1)
-- Target: Supabase Postgres (free tier)
-- Layout: 4 fact + 5 dim + 1 calendar + 2 raw (jsonb bronze layer) = 12 tables
-- Run order: this file first, then 001_views.sql
-- Idempotent: safe to re-run (uses IF NOT EXISTS)

BEGIN;

-- =============================================================
-- DIMENSION TABLES
-- =============================================================

CREATE TABLE IF NOT EXISTS dim_date (
    date_key            date PRIMARY KEY,
    year                smallint NOT NULL,
    quarter             smallint NOT NULL,
    month               smallint NOT NULL,
    month_name          text NOT NULL,
    week                smallint NOT NULL,
    day_of_month        smallint NOT NULL,
    day_of_week         smallint NOT NULL,
    day_name            text NOT NULL,
    is_weekend          boolean NOT NULL,
    fiscal_year         smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_city (
    city_id             smallserial PRIMARY KEY,
    city_name           text NOT NULL UNIQUE,
    state               text NOT NULL DEFAULT 'WI',
    zip_codes           text[] NOT NULL,
    is_active           boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dim_contractor (
    contractor_id           bigserial PRIMARY KEY,
    hubspot_contact_id      text UNIQUE,
    business_name           text NOT NULL,
    contact_name            text,
    email                   text,
    phone                   text,
    service_area_zips       text[],
    lifecycle_stage         text NOT NULL CHECK (lifecycle_stage IN ('lead','opportunity','customer','churned')),
    onboarded_at            timestamptz,
    is_active               boolean NOT NULL DEFAULT true,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dim_campaign (
    campaign_id             bigserial PRIMARY KEY,
    platform                text NOT NULL CHECK (platform IN ('google_ads','meta','nextdoor')),
    platform_campaign_id    text NOT NULL,
    campaign_name           text NOT NULL,
    objective               text,
    status                  text,
    daily_budget_cents      bigint,
    start_date              date,
    end_date                date,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    UNIQUE (platform, platform_campaign_id)
);

CREATE TABLE IF NOT EXISTS dim_ad_group (
    ad_group_id             bigserial PRIMARY KEY,
    campaign_id             bigint NOT NULL REFERENCES dim_campaign(campaign_id) ON DELETE CASCADE,
    platform                text NOT NULL,
    platform_ad_group_id    text NOT NULL,
    ad_group_name           text NOT NULL,
    status                  text,
    max_cpc_cents           bigint,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    UNIQUE (platform, platform_ad_group_id)
);

CREATE TABLE IF NOT EXISTS dim_ad (
    ad_id                   bigserial PRIMARY KEY,
    ad_group_id             bigint NOT NULL REFERENCES dim_ad_group(ad_group_id) ON DELETE CASCADE,
    platform                text NOT NULL,
    platform_ad_id          text NOT NULL,
    ad_name                 text,
    headline_1              text,
    headline_2              text,
    headline_3              text,
    description_1           text,
    description_2           text,
    final_url               text,
    status                  text,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    UNIQUE (platform, platform_ad_id)
);

-- =============================================================
-- FACT TABLES
-- =============================================================

CREATE TABLE IF NOT EXISTS fact_leads (
    lead_id                                 bigserial PRIMARY KEY,
    webflow_submission_id                   text UNIQUE,
    hubspot_contact_id                      text,
    hubspot_deal_id                         text,
    submitted_at                            timestamptz NOT NULL,
    date_key                                date NOT NULL REFERENCES dim_date(date_key),
    -- Homeowner identity (PII; Jim-only access)
    full_name                               text,
    phone                                   text NOT NULL,
    email                                   text NOT NULL,
    property_address                        text,
    city_id                                 smallint REFERENCES dim_city(city_id) ON DELETE SET NULL,
    -- Form fields
    owns_property                           boolean,
    project_type                            text,
    -- budget_range is free text; HubSpot stores values like 'under-10k', '10k-20k'.
    -- See migration 005_relax_budget_range_check — kept this column open since the
    -- source-system format is outside our control.
    budget_range                            text,
    project_timeline                        text,
    lead_notes                              text,
    tcpa_consent_given                      boolean NOT NULL CHECK (tcpa_consent_given = true),
    -- Attribution (HubSpot UTM = primary canonical)
    utm_source                              text,
    utm_medium                              text,
    utm_campaign                            text,
    utm_term                                text,
    utm_content                             text,
    gclid                                   text,
    lead_source_page                        text,
    -- Attribution (GA4 = validation/cross-check)
    utm_source_ga4                          text,
    utm_medium_ga4                          text,
    utm_campaign_ga4                        text,
    -- Resolved attribution joins (FKs nullable; resolved by ingestion)
    attributed_campaign_id_via_utm          bigint REFERENCES dim_campaign(campaign_id) ON DELETE SET NULL,
    attributed_campaign_id_via_gclid        bigint REFERENCES dim_campaign(campaign_id) ON DELETE SET NULL,
    -- Derived (computed nightly; DB-owned)
    lead_score                              smallint DEFAULT 0 CHECK (lead_score BETWEEN 0 AND 100),
    disqualification_reason                 text,
    -- Bookkeeping
    created_at                              timestamptz NOT NULL DEFAULT now(),
    updated_at                              timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fact_bids (
    bid_id                                  bigserial PRIMARY KEY,
    hubspot_deal_id                         text UNIQUE,
    lead_id                                 bigint NOT NULL REFERENCES fact_leads(lead_id) ON DELETE RESTRICT,
    contractor_id                           bigint NOT NULL REFERENCES dim_contractor(contractor_id) ON DELETE RESTRICT,
    bid_amount_cents                        bigint CHECK (bid_amount_cents IS NULL OR bid_amount_cents > 0),
    bid_sent_at                             timestamptz,
    bid_status                              text NOT NULL CHECK (bid_status IN ('sent','accepted','declined','expired','paid')),
    accepted_at                             timestamptz,
    declined_at                             timestamptz,
    declined_reason                         text,
    referral_fee_invoiced_at                timestamptz,
    referral_fee_paid_at                    timestamptz,
    referral_fee_cents                      bigint DEFAULT 100000,  -- $1,000 standard pay-per-accepted-bid
    created_at                              timestamptz NOT NULL DEFAULT now(),
    updated_at                              timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fact_ad_spend_daily (
    spend_id                bigserial PRIMARY KEY,
    spend_date              date NOT NULL REFERENCES dim_date(date_key),
    platform                text NOT NULL CHECK (platform IN ('google_ads','meta','nextdoor')),
    campaign_id             bigint NOT NULL REFERENCES dim_campaign(campaign_id) ON DELETE RESTRICT,
    ad_group_id             bigint REFERENCES dim_ad_group(ad_group_id) ON DELETE RESTRICT,
    ad_id                   bigint REFERENCES dim_ad(ad_id) ON DELETE RESTRICT,
    impressions             bigint DEFAULT 0,
    clicks                  bigint DEFAULT 0,
    cost_cents              bigint NOT NULL DEFAULT 0 CHECK (cost_cents >= 0),
    conversions             numeric(10,2) DEFAULT 0,
    conversion_value_cents  bigint DEFAULT 0,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    UNIQUE (spend_date, platform, ad_id)
);

CREATE TABLE IF NOT EXISTS fact_traffic_daily (
    traffic_id              bigserial PRIMARY KEY,
    session_date            date NOT NULL REFERENCES dim_date(date_key),
    page_path               text NOT NULL,
    source                  text NOT NULL DEFAULT '(none)',
    medium                  text NOT NULL DEFAULT '(none)',
    campaign                text NOT NULL DEFAULT '(none)',
    sessions                bigint DEFAULT 0,
    users                   bigint DEFAULT 0,
    engaged_sessions        bigint DEFAULT 0,
    form_submits            bigint DEFAULT 0,
    conversions             bigint DEFAULT 0,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    UNIQUE (session_date, page_path, source, medium, campaign)
);

-- =============================================================
-- RAW (BRONZE) TABLES — jsonb snapshots for replay/audit
-- =============================================================

CREATE TABLE IF NOT EXISTS raw_hubspot_snapshot (
    snapshot_id             bigserial PRIMARY KEY,
    captured_at             timestamptz NOT NULL DEFAULT now(),
    object_type             text NOT NULL CHECK (object_type IN ('contact','deal','company')),
    object_id               text NOT NULL,
    payload                 jsonb NOT NULL,
    UNIQUE (captured_at, object_type, object_id)
);

CREATE TABLE IF NOT EXISTS raw_ad_platforms_snapshot (
    snapshot_id             bigserial PRIMARY KEY,
    captured_at             timestamptz NOT NULL DEFAULT now(),
    platform                text NOT NULL CHECK (platform IN ('google_ads','meta','nextdoor','ga4')),
    object_type             text NOT NULL,
    object_id               text NOT NULL,
    payload                 jsonb NOT NULL,
    UNIQUE (captured_at, platform, object_type, object_id)
);

-- =============================================================
-- INDEXES
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_fact_leads_submitted_at         ON fact_leads (submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_fact_leads_city_date            ON fact_leads (city_id, submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_fact_leads_utm                  ON fact_leads (utm_source, utm_campaign);
CREATE INDEX IF NOT EXISTS idx_fact_leads_hubspot_contact_id   ON fact_leads (hubspot_contact_id);
CREATE INDEX IF NOT EXISTS idx_fact_leads_gclid                ON fact_leads (gclid) WHERE gclid IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_fact_bids_lead_id               ON fact_bids (lead_id);
CREATE INDEX IF NOT EXISTS idx_fact_bids_contractor_status     ON fact_bids (contractor_id, bid_status);
CREATE INDEX IF NOT EXISTS idx_fact_bids_accepted_at           ON fact_bids (accepted_at) WHERE accepted_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_fact_ad_spend_date_platform     ON fact_ad_spend_daily (spend_date DESC, platform);
CREATE INDEX IF NOT EXISTS idx_fact_ad_spend_campaign          ON fact_ad_spend_daily (campaign_id, spend_date DESC);

CREATE INDEX IF NOT EXISTS idx_fact_traffic_date_source        ON fact_traffic_daily (session_date DESC, source);

CREATE INDEX IF NOT EXISTS idx_raw_hubspot_object              ON raw_hubspot_snapshot (object_type, object_id, captured_at DESC);
CREATE INDEX IF NOT EXISTS idx_raw_hubspot_payload_gin         ON raw_hubspot_snapshot USING gin (payload);
CREATE INDEX IF NOT EXISTS idx_raw_ad_platforms_object         ON raw_ad_platforms_snapshot (platform, object_type, captured_at DESC);
CREATE INDEX IF NOT EXISTS idx_raw_ad_platforms_payload_gin    ON raw_ad_platforms_snapshot USING gin (payload);

-- =============================================================
-- SEEDS — dim_date (2024-01-01 → 2030-12-31)
-- =============================================================

INSERT INTO dim_date (date_key, year, quarter, month, month_name, week, day_of_month, day_of_week, day_name, is_weekend, fiscal_year)
SELECT
    d::date,
    EXTRACT(YEAR FROM d)::smallint,
    EXTRACT(QUARTER FROM d)::smallint,
    EXTRACT(MONTH FROM d)::smallint,
    TO_CHAR(d, 'Month'),
    EXTRACT(WEEK FROM d)::smallint,
    EXTRACT(DAY FROM d)::smallint,
    EXTRACT(ISODOW FROM d)::smallint,
    TO_CHAR(d, 'Day'),
    EXTRACT(ISODOW FROM d) IN (6, 7),
    EXTRACT(YEAR FROM d)::smallint
FROM generate_series('2024-01-01'::date, '2030-12-31'::date, '1 day'::interval) d
ON CONFLICT (date_key) DO NOTHING;

-- =============================================================
-- SEEDS — dim_city (5 Central WI cities)
-- =============================================================

INSERT INTO dim_city (city_name, state, zip_codes) VALUES
    ('Wausau',    'WI', ARRAY['54401','54402','54403']),
    ('Schofield', 'WI', ARRAY['54476']),
    ('Weston',    'WI', ARRAY['54476']),
    ('Mosinee',   'WI', ARRAY['54455']),
    ('Merrill',   'WI', ARRAY['54452'])
ON CONFLICT (city_name) DO NOTHING;

COMMIT;

-- Smoke test queries (run separately after commit):
-- SELECT COUNT(*) FROM dim_date;          -- expect 2557 (2024-01-01 → 2030-12-31)
-- SELECT COUNT(*) FROM dim_city;          -- expect 5
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;  -- expect 12 tables
