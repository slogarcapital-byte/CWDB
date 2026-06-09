-- CWDB Data Warehouse, Tighten test-traffic exclusion in v_clean_leads
-- Depends on: views/001_views.sql
-- Run via: paste into Supabase SQL Editor OR apply_migration via the Supabase MCP.
--
-- WHY: the control-plane validation gate (v_validation_gate) counts "qualified" leads as
-- rows present in v_clean_leads. On 2026-06-09 the gate read 3/3 qualified, but one of the
-- three (lead_id 48) was Jim's own self-test (email slogarjw@gmail.com, utm_source='test').
-- The original exclusion screened specific test emails + names starting with 'test', but not
-- the owner's email or utm_source='test', so the self-test counted as a real qualified lead
-- and produced a FALSE gate_met = true. This corrects the single source of truth so the gate,
-- v_lead_funnel, and every downstream view stop counting owner self-tests.
-- Reversible: CREATE OR REPLACE back to the prior definition.

CREATE OR REPLACE VIEW v_clean_leads WITH (security_invoker = on) AS
SELECT *
FROM fact_leads
WHERE
    email NOT IN ('test@test.com', 'dcebighitta12@aim.com', 'slogarjw@gmail.com')
AND COALESCE(full_name, '') NOT ILIKE 'test%'
AND COALESCE(utm_source, '') <> 'test';
