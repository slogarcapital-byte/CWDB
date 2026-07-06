-- CWDB Data Warehouse — Job Number registry (v1.0)
-- Depends on: schema/001_initial.sql, schema/005_fact_bids_schema_adaptation.sql
--
-- Why this exists:
-- CWDB direct jobs (staining work orders now; full builds once the DSPS /
-- insurance gate clears) need a canonical Job Number (CWDB-YYYY-NNN) issued at
-- contract formation. The signed work order / Home Improvement Contract,
-- change orders (JOB/CO-1), lien waivers, and the QBO invoice all tie together
-- by this key. Canonical issuance lives here (warehouse = source of truth);
-- the number is mirrored to HubSpot deal property `cwdb_job_number`.
--
-- Channel hygiene (conflict-of-interest memo): every job records which channel
-- the homeowner came through, so direct-build revenue and lead-purchase fee
-- revenue stay auditable and separable.

BEGIN;

CREATE TABLE IF NOT EXISTS dim_jobs (
    job_id                  bigserial PRIMARY KEY,
    job_number              text UNIQUE NOT NULL
                            CHECK (job_number ~ '^CWDB-[0-9]{4}-[0-9]{3}$'),
    client_name             text NOT NULL,
    property_address        text NOT NULL,
    channel                 text NOT NULL
                            CHECK (channel IN ('direct_stain','direct_build','lead_purchase')),
    contract_type           text
                            CHECK (contract_type IN ('staining_work_order','home_improvement_contract')),
    estimate_number         text,
    -- lifecycle timestamps
    contract_signed_at      timestamptz,
    cancellation_deadline   date,          -- midnight of 3rd business day after signing
    deposit_received_at     timestamptz,   -- must be >= signing; deposit HELD until deadline passes
    work_started_at         timestamptz,
    completed_at            timestamptz,
    -- money (cents, mirroring fact_bids convention)
    total_price_cents       bigint CHECK (total_price_cents IS NULL OR total_price_cents > 0),
    deposit_cents           bigint CHECK (deposit_cents IS NULL OR deposit_cents >= 0),
    -- joins
    hubspot_deal_id         text,
    lead_id                 bigint REFERENCES fact_leads(lead_id),
    status                  text NOT NULL DEFAULT 'reserved'
                            CHECK (status IN ('reserved','contracted','cancelled',
                                              'in_progress','completed','closed')),
    notes                   text,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE dim_jobs IS
    'Canonical CWDB Job Number registry. One row = one homeowner contract '
    '(staining work order or home improvement contract). Numbers are issued '
    'at contract formation via allocate_job_number() and never reused. '
    'Retention: signed docs filed by job_number, kept >= 6 years (Wis. Stat. 893.43).';

-- Link bids/deals to jobs (nullable: lead-purchase deals have no CWDB job).
ALTER TABLE fact_bids ADD COLUMN IF NOT EXISTS job_number text
    REFERENCES dim_jobs(job_number);

CREATE INDEX IF NOT EXISTS idx_dim_jobs_status   ON dim_jobs (status);
CREATE INDEX IF NOT EXISTS idx_dim_jobs_channel  ON dim_jobs (channel);
CREATE INDEX IF NOT EXISTS idx_fact_bids_job     ON fact_bids (job_number)
    WHERE job_number IS NOT NULL;

-- Atomic allocator: next CWDB-YYYY-NNN for the (current) year. Advisory lock
-- serializes concurrent allocations; UNIQUE constraint backstops.
CREATE OR REPLACE FUNCTION allocate_job_number(
    p_client_name      text,
    p_property_address text,
    p_channel          text,
    p_contract_type    text DEFAULT NULL,
    p_estimate_number  text DEFAULT NULL,
    p_year             int  DEFAULT NULL
) RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
    v_year int  := COALESCE(p_year, EXTRACT(year FROM now())::int);
    v_next int;
    v_job  text;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('dim_jobs_allocate'));
    SELECT COALESCE(MAX(substring(job_number FROM 11)::int), 0) + 1
      INTO v_next
      FROM dim_jobs
     WHERE job_number LIKE 'CWDB-' || v_year::text || '-%';
    v_job := format('CWDB-%s-%s', v_year, lpad(v_next::text, 3, '0'));
    INSERT INTO dim_jobs (job_number, client_name, property_address, channel,
                          contract_type, estimate_number)
    VALUES (v_job, p_client_name, p_property_address, p_channel,
            p_contract_type, p_estimate_number);
    RETURN v_job;
END $$;

ALTER TABLE public.dim_jobs ENABLE ROW LEVEL SECURITY;

COMMIT;
