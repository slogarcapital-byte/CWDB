-- =============================================================
-- 008_cloud_twin_read_path.sql - RLS read path for the CWDB HQ cloud twin
-- The read-only Streamlit Cloud twin authenticates with the ANON key (the
-- service-role key never leaves the laptop). Principles:
--
--   1. PII stays locked. fact_leads (names/phones/emails/addresses) is never
--      readable via anon. v_clean_leads gains security_invoker=on to close a
--      PRE-EXISTING hole: it was a definer-rights view, so any anon-key
--      holder could read full lead PII through it despite fact_leads RLS.
--   2. Aggregate-only KPI views become definer-rights so the twin can read
--      them: they expose counts/dollars/job numbers, no homeowner contact
--      data. v_kpi_cycle_time is rebuilt WITHOUT full_name first.
--   3. Dashboard tables get explicit anon SELECT policies (RLS stays ON).
--      dashboard_events is intentionally EXCLUDED (it carries queued prompts
--      and is not rendered by the twin).
-- =============================================================

BEGIN;

-- 1. Close the v_clean_leads PII hole (service-role key bypasses RLS, so all
--    pulls and local-mode reads are unaffected; anon now gets nothing).
ALTER VIEW v_clean_leads SET (security_invoker = on);

-- 2. Aggregate views -> definer rights (readable via anon grants).
ALTER VIEW v_lead_funnel            SET (security_invoker = off);
ALTER VIEW v_pl_monthly             SET (security_invoker = off);
ALTER VIEW v_kpi_booked_revenue     SET (security_invoker = off);
ALTER VIEW v_kpi_job_profitability  SET (security_invoker = off);
ALTER VIEW v_kpi_close_rate         SET (security_invoker = off);
ALTER VIEW v_kpi_cost_per_booked_job SET (security_invoker = off);
ALTER VIEW v_kpi_backlog            SET (security_invoker = off);

-- v_kpi_cycle_time carried full_name; drop the column (requires recreate).
DROP VIEW IF EXISTS v_kpi_cycle_time;
CREATE VIEW v_kpi_cycle_time AS
SELECT
    l.lead_id,
    l.lead_channel,
    l.submitted_at,
    MIN(b.bid_sent_at) AS first_estimate_at,
    ROUND((EXTRACT(EPOCH FROM MIN(b.bid_sent_at) - l.submitted_at) / 86400.0)::numeric, 1) AS days_lead_to_estimate
FROM v_clean_leads l
LEFT JOIN fact_bids b ON b.lead_id = l.lead_id AND b.bid_sent_at IS NOT NULL
GROUP BY l.lead_id, l.lead_channel, l.submitted_at
ORDER BY l.submitted_at DESC;
-- NOTE: v_clean_leads is now invoker, but THIS view is definer (created by
-- postgres), so the twin can read the aggregate while anon still cannot open
-- v_clean_leads directly.

-- 3. Anon SELECT policies on the dashboard tables the twin renders.
DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'dashboard_tasks', 'counsel_runs', 'fin_pl_monthly', 'fin_position',
        'fin_job_profit', 'platform_health', 'audit_findings', 'dashboard_settings'
    ] LOOP
        EXECUTE format(
            'DROP POLICY IF EXISTS hq_twin_read ON %I;
             CREATE POLICY hq_twin_read ON %I FOR SELECT TO anon USING (true);',
            t, t);
    END LOOP;
END $$;

COMMIT;
