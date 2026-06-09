-- CWDB Control Plane - Operational / Autonomy Tables (v1)
-- Target: Supabase Postgres (same project as the warehouse: iabiwsbmnbxmkjvkgfhg)
-- Depends on: schema/001_initial.sql (+ migrations 002-005)
-- Run via: paste into Supabase SQL Editor OR `apply_migration` via the Supabase MCP.
-- Idempotent: safe to re-run (uses IF NOT EXISTS / ON CONFLICT DO NOTHING).
--
-- WHY THIS EXISTS
-- The autonomous control loop has no persistent process. Every "tick" is a fresh,
-- amnesiac episode that reads control state from these tables, advances it ONE step,
-- writes it back, and dies. The loop is reconstructed from rows every tick - so these
-- tables ARE the loop. Layer separation: the control plane only READS the warehouse
-- (fact_*/v_*) and only WRITES these 006 tables.
--
-- Convention parity with 001_initial.sql: bigserial PKs, bigint cents, timestamptz
-- NOT NULL DEFAULT now(), text + CHECK for enums (no native ENUM types), jsonb payloads,
-- GIN on jsonb, partial indexes on hot predicates, RLS enabled with NO policies
-- (deny-all to anon/authenticated; service_role + postgres/MCP bypass - see migration 002).

BEGIN;

-- =============================================================
-- control_state - the singleton heartbeat / gate / budget rollup
-- One row, id = 1. The 30-min PowerShell control tick owns the gate + budget columns;
-- the orchestrator tick reads them and refuses to reason unless gate_open with a fresh token.
-- =============================================================

CREATE TABLE IF NOT EXISTS control_state (
    id                          smallint PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    -- On/off switch (human) vs. breaker (system). running = go; paused = Jim; halted = a breaker.
    run_mode                    text NOT NULL DEFAULT 'paused'
                                  CHECK (run_mode IN ('running','paused','halted')),
    paused_at                   timestamptz,
    paused_by                   text,
    paused_reason               text,
    resume_at                   timestamptz,            -- auto-resume target for `off -Until`
    halted_reason               text,                   -- which breaker, if run_mode = 'halted'
    -- Watchdog gate: the control tick computes this; the orchestrator obeys it.
    gate_open                   boolean NOT NULL DEFAULT false,
    gate_reason                 text,
    gate_token                  text,
    gate_token_at               timestamptz,
    -- Budget rollup (mirrors budget_ledger; cents like the warehouse).
    day_key                     date NOT NULL DEFAULT (now() AT TIME ZONE 'America/Chicago')::date,
    day_tokens_spent            bigint NOT NULL DEFAULT 0,
    day_cents_spent             bigint NOT NULL DEFAULT 0,
    total_tokens_spent          bigint NOT NULL DEFAULT 0,
    total_cents_spent           bigint NOT NULL DEFAULT 0,
    -- Breaker counters.
    consecutive_critic_fails    smallint NOT NULL DEFAULT 0,
    ticks_since_progress        smallint NOT NULL DEFAULT 0,
    last_progress_at            timestamptz,            -- re-anchored on resume so a pause gap != failure
    -- Funnel-progress watermark: orchestrator compares live v_validation_gate to these to
    -- decide whether real progress happened (drives the dead-man's switch - NOT task busyness).
    last_qualified_seen         smallint NOT NULL DEFAULT 0,
    last_accepted_seen          smallint NOT NULL DEFAULT 0,
    -- Tier-2 -> Tier-1 delivery hinge (flips true after the first human-approved delivery).
    proven_delivery_path        boolean NOT NULL DEFAULT false,
    -- Heartbeats.
    last_control_tick_at        timestamptz,
    last_orchestrator_tick_at   timestamptz,
    updated_at                  timestamptz NOT NULL DEFAULT now()
);
INSERT INTO control_state (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- =============================================================
-- objective - the goal(s) the orchestrator reasons about. success_signal is machine-readable.
-- =============================================================

CREATE TABLE IF NOT EXISTS objective (
    objective_id    bigserial PRIMARY KEY,
    title           text NOT NULL,
    description     text,
    success_metric  text NOT NULL,
    -- {view, column, op, threshold, since} - how a tick reads progress without an LLM.
    success_signal  jsonb NOT NULL,
    status          text NOT NULL DEFAULT 'open'
                      CHECK (status IN ('open','met','missed','abandoned')),
    priority        smallint NOT NULL DEFAULT 100,
    deadline        date,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- =============================================================
-- agent_registry - available workers, their scoped task types, tools, and tier ceiling.
-- agent_name must match a .claude/agents/<name>.md subagent_type the orchestrator can spawn.
-- =============================================================

CREATE TABLE IF NOT EXISTS agent_registry (
    agent_id            bigserial PRIMARY KEY,
    agent_name          text NOT NULL UNIQUE,
    task_types          text[] NOT NULL,
    min_tools           text[] NOT NULL DEFAULT '{}',
    max_permission_tier smallint NOT NULL DEFAULT 0 CHECK (max_permission_tier BETWEEN 0 AND 3),
    is_active           boolean NOT NULL DEFAULT true,
    notes               text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- =============================================================
-- council_verdict - persisted LLM-council output (audit + de-dup memory for future councils).
-- Declared before `task` so task.council_verdict_ref can FK to it.
-- =============================================================

CREATE TABLE IF NOT EXISTS council_verdict (
    council_id          bigserial PRIMARY KEY,
    task_id             bigint NOT NULL,   -- FK added after task exists (below)
    trace_id            text NOT NULL,
    trigger_reason      text NOT NULL,
    lens_reviews        jsonb NOT NULL,    -- {advisors:[...], peer_reviews:[...]}
    chairman_verdict    text NOT NULL CHECK (chairman_verdict IN ('pass','changes','escalate')),
    chairman_rationale  text,
    one_thing_first     text,
    tokens_spent        bigint NOT NULL DEFAULT 0,
    cents_spent         bigint NOT NULL DEFAULT 0,
    created_at          timestamptz NOT NULL DEFAULT now()
);

-- =============================================================
-- task - the work queue. parent_id gives the decomposition tree.
-- The reaper (control tick) requeues any 'active' task whose lease_until has passed.
-- =============================================================

CREATE TABLE IF NOT EXISTS task (
    task_id             bigserial PRIMARY KEY,
    objective_id        bigint REFERENCES objective(objective_id) ON DELETE CASCADE,
    parent_id           bigint REFERENCES task(task_id) ON DELETE CASCADE,
    type                text NOT NULL,
    title               text NOT NULL,
    status              text NOT NULL DEFAULT 'queued'
                          CHECK (status IN ('queued','active','done','failed','needs_approval','blocked')),
    priority            smallint NOT NULL DEFAULT 100,
    assigned_agent      text REFERENCES agent_registry(agent_name),
    permission_tier     smallint NOT NULL DEFAULT 0 CHECK (permission_tier BETWEEN 0 AND 3),
    attempts            smallint NOT NULL DEFAULT 0,
    max_attempts        smallint NOT NULL DEFAULT 3,
    payload             jsonb NOT NULL DEFAULT '{}'::jsonb,  -- {dod:[...], inputs:{...}}
    output              jsonb,
    critic_verdict      jsonb,
    council_verdict_ref bigint REFERENCES council_verdict(council_id) ON DELETE SET NULL,
    lease_until         timestamptz,
    trace_id            text NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Backfill the deferred FK from council_verdict.task_id -> task now that `task` exists.
ALTER TABLE council_verdict DROP CONSTRAINT IF EXISTS council_verdict_task_fk;
ALTER TABLE council_verdict
    ADD CONSTRAINT council_verdict_task_fk
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE CASCADE;

-- =============================================================
-- event_log - append-only audit spine. NEVER UPDATE/DELETE.
-- event_uid is a client-generated GUID -> makes appends idempotent under retry.
-- =============================================================

CREATE TABLE IF NOT EXISTS event_log (
    event_id    bigserial PRIMARY KEY,
    event_uid   text NOT NULL UNIQUE,
    trace_id    text,
    task_id     bigint REFERENCES task(task_id) ON DELETE SET NULL,
    actor       text NOT NULL,   -- 'control_tick'|'orchestrator'|'<agent>'|'critic'|'council'|'human'
    event_type  text NOT NULL,
    severity    text NOT NULL DEFAULT 'info'
                  CHECK (severity IN ('debug','info','warn','error','critical')),
    detail      jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- =============================================================
-- budget_ledger - every token/dollar charge, per task + per tick kind.
-- The control tick sums this into control_state each cycle.
-- =============================================================

CREATE TABLE IF NOT EXISTS budget_ledger (
    ledger_id   bigserial PRIMARY KEY,
    entry_uid   text NOT NULL UNIQUE,   -- idempotent insert key
    trace_id    text,
    task_id     bigint REFERENCES task(task_id) ON DELETE SET NULL,
    tick_kind   text NOT NULL
                  CHECK (tick_kind IN ('orchestrator','worker','critic','council','control')),
    tokens_in   bigint NOT NULL DEFAULT 0,
    tokens_out  bigint NOT NULL DEFAULT 0,
    cents       bigint NOT NULL DEFAULT 0,
    day_key     date NOT NULL DEFAULT (now() AT TIME ZONE 'America/Chicago')::date,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- =============================================================
-- approval_queue - Tier-2 actions held for Jim. The orchestrator never executes these
-- directly; on approval, a later tick reads proposed_action and performs it.
-- =============================================================

CREATE TABLE IF NOT EXISTS approval_queue (
    approval_id     bigserial PRIMARY KEY,
    task_id         bigint REFERENCES task(task_id) ON DELETE CASCADE,
    trace_id        text,
    action_kind     text NOT NULL,
    summary         text NOT NULL,
    proposed_action jsonb NOT NULL,     -- enough to execute deterministically on approval
    recommended     text,               -- the system's recommended answer (with reasoning)
    rollback_plan   text,
    council_verdict_ref bigint REFERENCES council_verdict(council_id) ON DELETE SET NULL,
    status          text NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending','approved','rejected','expired','executed')),
    decided_by      text,
    decided_at      timestamptz,
    expires_at      timestamptz,        -- pushed forward by pause duration on resume
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- =============================================================
-- INDEXES - hot paths: pull next queued task, reap expired leases, find pending approvals.
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_task_queued        ON task (priority, created_at) WHERE status = 'queued';
CREATE INDEX IF NOT EXISTS idx_task_lease          ON task (lease_until) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_task_needs_approval ON task (updated_at) WHERE status = 'needs_approval';
CREATE INDEX IF NOT EXISTS idx_task_trace          ON task (trace_id);
CREATE INDEX IF NOT EXISTS idx_task_objective      ON task (objective_id, status);

CREATE INDEX IF NOT EXISTS idx_event_log_trace     ON event_log (trace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_event_log_type_time ON event_log (event_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_event_log_severity  ON event_log (severity, created_at DESC) WHERE severity IN ('error','critical');
CREATE INDEX IF NOT EXISTS idx_event_log_detail_gin ON event_log USING gin (detail);

CREATE INDEX IF NOT EXISTS idx_budget_day          ON budget_ledger (day_key, tick_kind);
CREATE INDEX IF NOT EXISTS idx_budget_task         ON budget_ledger (task_id);

CREATE INDEX IF NOT EXISTS idx_approval_pending    ON approval_queue (created_at) WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_council_task        ON council_verdict (task_id, created_at DESC);

-- =============================================================
-- ROW LEVEL SECURITY - deny-all to anon/authenticated; service_role + postgres/MCP bypass.
-- Same posture as migration 002. The control plane runs server-side only.
-- =============================================================

ALTER TABLE public.control_state   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.objective       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_registry  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.council_verdict ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_log       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget_ledger   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_queue  ENABLE ROW LEVEL SECURITY;

COMMIT;

-- Smoke test (run separately after commit):
-- SELECT run_mode, gate_open FROM control_state;                 -- expect ('paused', false)
-- SELECT table_name FROM information_schema.tables
--   WHERE table_schema = 'public'
--     AND table_name IN ('control_state','objective','agent_registry','task',
--                        'council_verdict','event_log','budget_ledger','approval_queue');  -- expect 8
