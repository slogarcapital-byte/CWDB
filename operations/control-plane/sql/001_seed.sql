-- CWDB Control Plane - Seed (objective + agent_registry)
-- Depends on: schema/006_operational_tables.sql
-- Run via: paste into Supabase SQL Editor OR `apply_migration` via the Supabase MCP (after 006).
-- Idempotent: ON CONFLICT DO NOTHING / DO UPDATE on natural keys.
--
-- Inc 0 seeds ONLY the goal and the lead-routing worker as active. The rest of the roster
-- is seeded inactive (is_active = false) so the registry documents the full team while the
-- skeleton runs with one worker. Flip is_active = true in Inc 4 as each worker is brought online.

BEGIN;

-- ---- objective -------------------------------------------------------------
-- Goal (Jim, 2026-06-09): "highest possible number of leads, then highest possible
-- number of accepted bids." Continuous maximization; the 2026-06-18 validation gate is
-- the first checkpoint, not the terminal state. success_signal is machine-read by the
-- orchestrator tick (it does not need an LLM to know whether it is making progress).
INSERT INTO objective (title, description, success_metric, success_signal, status, priority, deadline)
SELECT
    'Maximize qualified leads, then accepted bids',
    'Drive lead volume into the CWDB funnel and convert to accepted bids. Checkpoint: pass the '
        || 'validation gate by 2026-06-18 (>=3 qualified since 2026-06-04 OR >=1 accepted bid lifetime). '
        || 'After the checkpoint, keep maximizing leads then accepted bids within the budget envelope.',
    'v_lead_funnel.leads_qualified and v_lead_funnel.leads_bid_accepted, trending up',
    '{
        "primary":   {"view":"v_validation_gate","column":"qualified_since_gate","op":">=","threshold":3},
        "secondary": {"view":"v_validation_gate","column":"accepted_lifetime","op":">=","threshold":1},
        "maximize":  ["v_lead_funnel.leads_qualified","v_lead_funnel.leads_bid_accepted"],
        "progress_signal": {"view":"v_validation_gate","columns":["qualified_since_gate","accepted_lifetime"]}
     }'::jsonb,
    'open',
    1,
    DATE '2026-06-18'
WHERE NOT EXISTS (
    SELECT 1 FROM objective WHERE title = 'Maximize qualified leads, then accepted bids'
);

-- ---- agent_registry --------------------------------------------------------
-- agent_name MUST equal the .claude/agents/<name>.md subagent_type the orchestrator spawns.
INSERT INTO agent_registry (agent_name, task_types, min_tools, max_permission_tier, is_active, notes) VALUES
    ('lead-routing',
        ARRAY['routing.build_scenario','routing.deliver_lead'],
        ARRAY['make_mcp','supabase_read','hubspot_write'],
        2, true,
        'Inc 1 primary worker. Build/activate the Make routing path; DoD on build = test webhook fires + fact_bids pending row appears. Idempotent: check scenario/bid state before mutating.'),
    ('ad-campaign',
        ARRAY['ads.raise_volume','ads.hook_audit'],
        ARRAY['google_ads_read','meta_read','write_files'],
        2, false,
        'Inc 4. Raise lead volume at the existing $50/day via better hooks (Lever-5 Hook Audit Gate). Budget changes are Tier 1 only within $50/day; raising the ceiling is Tier 3.'),
    ('lead-qualification',
        ARRAY['qual.score_inbound'],
        ARRAY['supabase_read','hubspot_read','write_files'],
        1, false,
        'Inc 4. Score inbound leads so qualifying ones appear in v_clean_leads and count toward the gate.'),
    ('contractor-sales',
        ARRAY['sales.chase_signature'],
        ARRAY['hubspot_read','gmail_draft','docusign_send'],
        2, false,
        'Inc 4. Chase signatures so an accepted bid can be recorded. Gated behind a routed lead. Sends are Tier 2.'),
    ('analytics',
        ARRAY['analytics.funnel_probe'],
        ARRAY['supabase_read'],
        0, false,
        'On-call. Diagnose funnel leaks citing view rows. Read-only (Tier 0).')
ON CONFLICT (agent_name) DO UPDATE
    SET task_types          = EXCLUDED.task_types,
        min_tools           = EXCLUDED.min_tools,
        max_permission_tier = EXCLUDED.max_permission_tier,
        notes               = EXCLUDED.notes,
        updated_at          = now();

COMMIT;

-- Smoke test (run separately):
-- SELECT title, deadline, status FROM objective;
-- SELECT agent_name, task_types, max_permission_tier, is_active FROM agent_registry ORDER BY is_active DESC, agent_name;
