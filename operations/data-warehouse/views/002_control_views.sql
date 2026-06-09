-- CWDB Control Plane - Control & Gate Views (v1)
-- Depends on: schema/001_initial.sql (+ 002-005), views/001_views.sql, schema/006_operational_tables.sql
-- Purpose: (1) make the validation-gate success signal machine-readable and correctly defined;
--          (2) give one-screen control-loop health for the digest, status CLI, and session-start hook.
-- Run via: paste into Supabase SQL Editor OR `apply_migration` via the Supabase MCP (after 006).

BEGIN;

-- =============================================================
-- v_validation_gate - the Phase-1 checkpoint, computed correctly.
-- =============================================================
-- Fixes a naming/definition drift: CLAUDE.md + session-start.ps1 reference
-- `qualified_count`/`accepted_count`, but v_lead_funnel exposes monthly `leads_qualified`/
-- `leads_bid_accepted` with no since-date filter and no lifetime-accepted column. The gate is:
--   PASS if (qualified leads since 2026-06-04) >= 3  OR  (lifetime accepted bids) >= 1.
-- v1 "qualified" == present in v_clean_leads (TCPA + valid contact + non-test), matching
-- v_lead_funnel's own definition. Switch to `lead_score >= 60` here if/when scoring lands -
-- keep this view and v_lead_funnel.leads_qualified in lockstep.

CREATE OR REPLACE VIEW v_validation_gate WITH (security_invoker = on) AS
WITH params AS (
    SELECT DATE '2026-06-04' AS gate_since, 3 AS qualified_target, 1 AS accepted_target
),
qualified AS (
    SELECT COUNT(*) AS qualified_since_gate
    FROM v_clean_leads, params
    WHERE submitted_at >= params.gate_since
),
accepted AS (
    SELECT COUNT(DISTINCT lead_id) AS accepted_lifetime
    FROM fact_bids
    WHERE bid_status IN ('accepted','paid')
)
SELECT
    p.gate_since,
    q.qualified_since_gate,
    p.qualified_target,
    a.accepted_lifetime,
    p.accepted_target,
    (q.qualified_since_gate >= p.qualified_target
        OR a.accepted_lifetime >= p.accepted_target) AS gate_met
FROM params p, qualified q, accepted a;

-- =============================================================
-- v_budget_rollup - single-row spend rollup the control tick reads (PostgREST can't SUM).
-- =============================================================
-- "Today" is Central time, matching budget_ledger.day_key's default. The control tick
-- patches these sums into control_state every 30 minutes.

CREATE OR REPLACE VIEW v_budget_rollup WITH (security_invoker = on) AS
SELECT
    COALESCE(SUM(tokens_in + tokens_out) FILTER (WHERE day_key = (now() AT TIME ZONE 'America/Chicago')::date), 0) AS day_tokens,
    COALESCE(SUM(cents)                  FILTER (WHERE day_key = (now() AT TIME ZONE 'America/Chicago')::date), 0) AS day_cents,
    COALESCE(SUM(tokens_in + tokens_out), 0) AS total_tokens,
    COALESCE(SUM(cents), 0)                  AS total_cents
FROM budget_ledger;

-- =============================================================
-- v_control_status - single-row control-loop dashboard.
-- =============================================================
-- One screen for the daily digest, `control-power.ps1 status`, and the session-start hook:
-- run mode, goal progress, queue depth, spend vs budget, breaker state, pending approvals.
-- Budget targets are duplicated here as literals so the view is self-describing; the
-- authoritative thresholds live in operations/control-plane/config/control-config.json
-- and are enforced by the control tick. Keep the two in sync if you retune.

CREATE OR REPLACE VIEW v_control_status WITH (security_invoker = on) AS
SELECT
    -- Run mode / switch
    cs.run_mode,
    cs.gate_open,
    cs.gate_reason,
    cs.paused_at,
    cs.paused_reason,
    cs.resume_at,
    cs.halted_reason,
    -- Goal progress (validation-gate checkpoint)
    g.qualified_since_gate,
    g.qualified_target,
    g.accepted_lifetime,
    g.accepted_target,
    g.gate_met,
    (SELECT MIN(deadline) FROM objective WHERE status = 'open') AS next_deadline,
    ((SELECT MIN(deadline) FROM objective WHERE status = 'open')
        - (now() AT TIME ZONE 'America/Chicago')::date)         AS days_to_deadline,
    -- Queue depth
    (SELECT COUNT(*) FROM task WHERE status = 'queued')          AS tasks_queued,
    (SELECT COUNT(*) FROM task WHERE status = 'active')          AS tasks_active,
    (SELECT COUNT(*) FROM task WHERE status = 'needs_approval')  AS tasks_needs_approval,
    (SELECT COUNT(*) FROM task WHERE status = 'blocked')         AS tasks_blocked,
    (SELECT COUNT(*) FROM task WHERE status = 'failed')          AS tasks_failed,
    (SELECT COUNT(*) FROM task
        WHERE status = 'done' AND updated_at > now() - INTERVAL '24 hours') AS tasks_done_24h,
    -- Spend today vs budget (cents -> dollars). Soft $8 / hard $15 / project $150.
    ROUND(cs.day_cents_spent / 100.0, 2)    AS day_dollars_spent,
    8.00                                    AS day_soft_dollars,
    15.00                                   AS day_hard_dollars,
    cs.day_tokens_spent,
    ROUND(cs.total_cents_spent / 100.0, 2)  AS total_dollars_spent,
    150.00                                  AS project_cap_dollars,
    -- Breaker state
    cs.consecutive_critic_fails,
    cs.ticks_since_progress,
    cs.last_progress_at,
    cs.proven_delivery_path,
    -- Pending approvals
    (SELECT COUNT(*) FROM approval_queue WHERE status = 'pending') AS approvals_pending,
    (SELECT MIN(created_at) FROM approval_queue WHERE status = 'pending') AS oldest_pending_approval_at,
    -- Heartbeats
    cs.last_control_tick_at,
    cs.last_orchestrator_tick_at,
    cs.updated_at
FROM control_state cs
CROSS JOIN v_validation_gate g
WHERE cs.id = 1;

COMMIT;

-- Smoke test (run separately after commit):
-- SELECT * FROM v_validation_gate;   -- expect 1 row; gate_met false until 3 qualified or 1 accepted
-- SELECT run_mode, gate_open, qualified_since_gate, accepted_lifetime, days_to_deadline,
--        tasks_queued, day_dollars_spent FROM v_control_status;  -- expect 1 row
