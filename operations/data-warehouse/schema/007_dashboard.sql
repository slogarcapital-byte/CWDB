-- =============================================================
-- 007_dashboard.sql - dashboard write surfaces.
--   directive: standing human guidance the orchestrator reads each tick (step 2).
--   approval_queue.decision_note: Jim's free-text note on approve/reject/request-changes.
-- Idempotent: IF NOT EXISTS guards throughout.
-- Depends on: schema/006_operational_tables.sql
-- =============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS directive (
    directive_id  bigserial PRIMARY KEY,
    body          text NOT NULL,
    status        text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','done','dismissed')),
    created_by    text NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_directive_active ON directive (created_at) WHERE status = 'active';

ALTER TABLE approval_queue ADD COLUMN IF NOT EXISTS decision_note text;

-- ROW LEVEL SECURITY - deny-all to anon/authenticated; service_role + postgres/MCP bypass.
ALTER TABLE public.directive ENABLE ROW LEVEL SECURITY;

COMMIT;
