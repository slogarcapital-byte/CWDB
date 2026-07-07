-- =============================================================
-- 013_dashboard_hq.sql - CWDB HQ dashboard data layer
-- Source: 2026-07-05 audit + 2026-07-06 dashboard plan
--
-- Four things happen here:
--   1. Consent-gate fix (audit fix #6): fact_leads no longer refuses rows
--      without TCPA consent. The CHECK (tcpa_consent_given = true) constraint
--      was the root cause of 3 real leads (Petersen, Hanson, Neely) being
--      silently dropped by the pull. Consent state is now DATA, not a gate:
--      consent_missing flags rows Jim must re-capture consent for before any
--      SMS/call. Views that count the funnel keep counting all clean leads.
--   2. hs_analytics_source attribution fallback column (audit Break D leg).
--   3. New CWDB HQ tables: dashboard_tasks (canonical to-do), dashboard_events
--      (two-way loop event log), counsel_runs (board-of-counselors output),
--      fin_* (QBO-sourced financials), platform_health, audit_findings,
--      dashboard_settings.
--   4. Data patches from audit section 8: Overbeck job complete + collected,
--      fact_bids bid 4 accepted_at corrected to the true date 2026-06-11.
--
-- Idempotent: IF NOT EXISTS / OR REPLACE / WHERE-guarded updates throughout.
-- Depends on: schema/001, 008, 009, 010.
-- =============================================================

BEGIN;

-- -------------------------------------------------------------
-- 1. Consent gate relaxation (fix #6)
-- -------------------------------------------------------------

ALTER TABLE fact_leads DROP CONSTRAINT IF EXISTS fact_leads_tcpa_consent_given_check;
ALTER TABLE fact_leads ALTER COLUMN tcpa_consent_given DROP NOT NULL;

ALTER TABLE fact_leads ADD COLUMN IF NOT EXISTS consent_missing boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN fact_leads.consent_missing IS
    'true = lead ingested without TCPA consent evidence (no form checkbox, no '
    'recorded verbal consent). Contact is allowed (they submitted/called us); '
    'SMS/robocall outreach is NOT until consent is re-captured (reply-YES text '
    'or verbal + tcpa_consent_source set). Set false once consent recorded.';

-- -------------------------------------------------------------
-- 2. HubSpot native attribution fallback (audit Break D)
-- -------------------------------------------------------------

ALTER TABLE fact_leads ADD COLUMN IF NOT EXISTS hs_analytics_source text;

COMMENT ON COLUMN fact_leads.hs_analytics_source IS
    'HubSpot native original-source bucket (PAID_SEARCH, PAID_SOCIAL, '
    'ORGANIC_SEARCH, DIRECT_TRAFFIC, OFFLINE, ...). Fallback attribution when '
    'utm_*/gclid are empty (the relay drops them for multi-page visitors).';

-- -------------------------------------------------------------
-- 3. CWDB HQ tables
-- -------------------------------------------------------------

-- Canonical to-do list. Replaces _vault/board/*.md as source of truth;
-- the board files are regenerated mirrors.
CREATE TABLE IF NOT EXISTS dashboard_tasks (
    task_id         bigserial PRIMARY KEY,
    source_ref      text,               -- 'audit-2026-07-05#12' | 'WB-017' | 'counsel-run-3' | NULL (manual)
    title           text NOT NULL,
    detail          text,
    owner_group     text NOT NULL DEFAULT 'jim'
                    CHECK (owner_group IN ('jim','project','others')),
    owner_detail    text,               -- e.g. 'Jim + legal', 'analytics agent', 'Ben/John'
    priority        text NOT NULL DEFAULT 'P1'
                    CHECK (priority IN ('P0','P1','P2')),
    status          text NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open','done','deferred','declined')),
    deferred_until  date,
    effort          text,               -- freeform: '1 call', '2-4 h', 'half day'
    suggested_agent text,               -- .claude/agents name for Send-to-Claude
    files           text,               -- newline-separated repo paths for prompt context
    notes           text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    completed_at    timestamptz
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_dashboard_tasks_source_ref
    ON dashboard_tasks (source_ref) WHERE source_ref IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_dashboard_tasks_open
    ON dashboard_tasks (owner_group, priority) WHERE status = 'open';

-- Append-only event log: every dashboard mutation + Claude session summaries.
-- processed_at IS NULL = pending ingestion by /dashboard-sync.
CREATE TABLE IF NOT EXISTS dashboard_events (
    event_id        bigserial PRIMARY KEY,
    event_type      text NOT NULL
                    CHECK (event_type IN ('task_created','task_status_change','task_edited',
                                          'queued_for_claude','sent_to_terminal',
                                          'counsel_convened','decision','session_summary',
                                          'refresh_run','note')),
    task_id         bigint REFERENCES dashboard_tasks(task_id) ON DELETE SET NULL,
    payload         jsonb NOT NULL DEFAULT '{}'::jsonb,
    actor           text NOT NULL DEFAULT 'dashboard',   -- 'dashboard' | 'claude' | 'jim'
    created_at      timestamptz NOT NULL DEFAULT now(),
    processed_at    timestamptz
);

CREATE INDEX IF NOT EXISTS idx_dashboard_events_unprocessed
    ON dashboard_events (created_at) WHERE processed_at IS NULL;

-- Board-of-counselors runs. status drives the Tab 1 button state.
CREATE TABLE IF NOT EXISTS counsel_runs (
    run_id            bigserial PRIMARY KEY,
    ran_at            timestamptz NOT NULL DEFAULT now(),
    status            text NOT NULL DEFAULT 'running'
                      CHECK (status IN ('running','complete','failed')),
    exec_summary      text,
    ceo_brief         text,
    lens_outputs      jsonb,   -- [{key,name,text}] Contrarian/First Principles/Expansionist/Outsider/Executor
    chairman_verdict  text,
    recommended_moves jsonb,   -- [{title,detail,owner_group,priority,suggested_agent}]
    kpi_snapshot      jsonb,   -- numbers the board saw, for later audit
    error             text
);

-- QBO ProfitAndLoss rows (cash basis), one row per month x account path.
CREATE TABLE IF NOT EXISTS fin_pl_monthly (
    period          date NOT NULL,          -- first of month
    account_path    text NOT NULL,          -- 'Income:Construction Services'
    account_name    text NOT NULL,
    account_type    text NOT NULL,          -- Income | COGS | Expense | NetIncome | GrossProfit ...
    amount_cents    bigint NOT NULL DEFAULT 0,
    basis           text NOT NULL DEFAULT 'cash',
    pulled_at       timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (period, account_path)
);

-- Point-in-time financial position snapshots; latest row wins.
CREATE TABLE IF NOT EXISTS fin_position (
    position_id         bigserial PRIMARY KEY,
    as_of               timestamptz NOT NULL DEFAULT now(),
    cash_cents          bigint,
    card_liability_cents bigint,
    ar_total_cents      bigint,
    ytd_net_income_cents bigint,
    ytd_revenue_cents   bigint,
    ytd_expense_cents   bigint,
    open_invoices       jsonb,   -- [{doc_number,customer,amount_cents,due_date,balance_cents}]
    ar_aging             jsonb
);

-- Per-job revenue/costs from QBO (customer-level join + tagged expenses).
CREATE TABLE IF NOT EXISTS fin_job_profit (
    job_key         text PRIMARY KEY,       -- QBO customer display name (or CWDB job number when mapped)
    job_number      text,                   -- dim_jobs.job_number when known
    revenue_cents   bigint NOT NULL DEFAULT 0,
    cost_cents      bigint NOT NULL DEFAULT 0,
    invoices        jsonb,
    expenses        jsonb,
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Diagnostics health checks, computed locally, readable by the cloud twin.
CREATE TABLE IF NOT EXISTS platform_health (
    platform        text NOT NULL,          -- warehouse | hubspot | qbo | google_ads | meta | ga4 | site | scheduler
    check_name      text NOT NULL,
    status          text NOT NULL CHECK (status IN ('ok','warn','fail','unknown')),
    detail          text,
    checked_at      timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (platform, check_name)
);

-- Audit narrative content (sections 1/4/5/6), linked to fix tasks so findings
-- visibly retire as the linked tasks complete.
CREATE TABLE IF NOT EXISTS audit_findings (
    finding_id      bigserial PRIMARY KEY,
    audit_date      date NOT NULL,
    section         text NOT NULL CHECK (section IN ('exec_summary','platform','interview','strategy')),
    platform        text,                   -- for section='platform'
    title           text NOT NULL,
    body            text NOT NULL,
    linked_task_refs text[] NOT NULL DEFAULT '{}',   -- dashboard_tasks.source_ref values
    sort_order      int NOT NULL DEFAULT 0,
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- Small key/value store for dashboard knobs (tax set-aside amount, etc.).
CREATE TABLE IF NOT EXISTS dashboard_settings (
    key         text PRIMARY KEY,
    value       jsonb NOT NULL,
    updated_at  timestamptz NOT NULL DEFAULT now()
);

-- RLS: deny-all to anon/authenticated by default (service_role bypasses).
-- Phase 5 (cloud twin) adds explicit SELECT-only policies for anon.
ALTER TABLE public.dashboard_tasks    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_events   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.counsel_runs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fin_pl_monthly     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fin_position       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fin_job_profit     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_health    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_findings     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_settings ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------------
-- 4. Data patches (audit section 8, corrections 2 + bid-4 date)
-- -------------------------------------------------------------

-- Overbeck CWDB-2026-043: complete and fully collected ($840 deposit 6/11,
-- $1,960 final paid 6/28, total $2,800). dim_jobs still said deposit NULL /
-- not complete.
UPDATE dim_jobs SET
    deposit_received_at = COALESCE(deposit_received_at, '2026-06-11T00:00:00Z'),
    work_started_at     = COALESCE(work_started_at,     '2026-06-15T00:00:00Z'),
    completed_at        = COALESCE(completed_at,        '2026-06-28T00:00:00Z'),
    deposit_cents       = COALESCE(deposit_cents, 84000),
    total_price_cents   = COALESCE(total_price_cents, 280000),
    status              = 'completed',
    updated_at          = now()
WHERE job_number = 'CWDB-2026-043'
  AND status <> 'completed';

-- fact_bids bid 4 (Overbeck): true acceptance (signed work order + deposit)
-- was 2026-06-11. HubSpot's closedate re-stamps whenever the deal is touched
-- (the audit saw 6/27; by 7/6 it read 7/6), so the patch matches any wrong
-- date AND the pull now applies earliest-acceptance-wins so this sticks.
UPDATE fact_bids SET
    accepted_at = '2026-06-11T00:00:00Z',
    updated_at  = now()
WHERE bid_id = 4
  AND accepted_at::date <> '2026-06-11';

COMMIT;
