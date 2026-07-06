-- CWDB Data Warehouse — Job Number re-base onto the QBO invoice series (v1.0)
-- Depends on: schema/008_job_registry.sql
--
-- Why this exists:
-- Job Numbers (CWDB-YYYY-NNN) now mirror the QBO invoice series so a job, its
-- signed contract, and its QBO invoice share one running number. Debbie
-- Overbeck's deposit auto-numbered to INV-2026-043 in QBO, so her job is
-- re-based from CWDB-2026-001 to CWDB-2026-043; Thomas Quinn follows at
-- CWDB-2026-044. allocate_job_number() continues sequentially (next = 045) and
-- is floored at 043 for 2026 so the baseline can never drift below Debbie's
-- number. The locally-filed signed work-order PDF and the INV-2026-001 file
-- keep their original labels for audit; the re-base is recorded in dim_jobs.notes.
--
-- Applied atomically (Supabase migration / single transaction): the fact_bids
-- FK to dim_jobs.job_number is detached, the numbers are re-based, then the FK
-- is re-pointed to the new number.

BEGIN;

-- 1. Detach the one FK dependent (Overbeck's accepted bid) before renumbering.
UPDATE fact_bids SET job_number = NULL WHERE job_number = 'CWDB-2026-001';

-- 2. Re-base the two existing jobs onto the invoice series.
UPDATE dim_jobs
   SET job_number = 'CWDB-2026-043',
       notes = COALESCE(notes, '') ||
               ' | RENUMBERED 2026-06-26: formerly CWDB-2026-001, re-based to align '
               'with QBO deposit invoice INV-2026-043. Local signed work-order PDF '
               'and the INV-2026-001 file keep the old label for audit.',
       updated_at = now()
 WHERE job_number = 'CWDB-2026-001';

UPDATE dim_jobs
   SET job_number = 'CWDB-2026-044', updated_at = now()
 WHERE job_number = 'CWDB-2026-002';

-- 3. Re-point the FK dependent to Overbeck's new number.
UPDATE fact_bids SET job_number = 'CWDB-2026-043' WHERE bid_id = 4;

-- 4. Floor the 2026 allocator at 043 (Debbie's number). Other years unaffected.
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
    SELECT GREATEST(
               COALESCE(MAX(substring(job_number FROM 11)::int), 0),
               CASE WHEN v_year = 2026 THEN 42 ELSE 0 END
           ) + 1
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

COMMIT;
