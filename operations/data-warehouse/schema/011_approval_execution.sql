-- 011_approval_execution.sql
-- Inc 3: make approved approval_queue rows EXECUTABLE.
--
-- WHY: through Inc 2 the loop could only propose and queue; nothing read
-- status='approved' and acted on it. The executor (orchestrator runbook step 3)
-- needs claim semantics so two concurrent ticks cannot double-execute, plus a
-- terminal failure state and an audit of what execution returned.
--
-- Status lifecycle becomes:
--   pending -> approved -> executing -> executed     (happy path)
--                       -> executing -> approved      (attempt failed, released for retry)
--                       -> executing -> failed        (terminal after max attempts)
--   pending/approved -> expired                       (reaped past expires_at, control-tick 4b)
--   pending -> rejected                               (human)
-- Reversible: drop the columns, restore the prior CHECK.

ALTER TABLE approval_queue DROP CONSTRAINT approval_queue_status_check;
ALTER TABLE approval_queue ADD CONSTRAINT approval_queue_status_check
  CHECK (status IN ('pending','approved','executing','executed','failed','rejected','expired'));

ALTER TABLE approval_queue
  ADD COLUMN IF NOT EXISTS claimed_at timestamptz,
  ADD COLUMN IF NOT EXISTS executed_at timestamptz,
  ADD COLUMN IF NOT EXISTS execution_attempts smallint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS execution_result jsonb;

-- The executor claims the OLDEST approved row first.
CREATE INDEX IF NOT EXISTS idx_approval_approved
  ON approval_queue (decided_at) WHERE status = 'approved';
