-- 016_lead_scores.sql
-- Audit fix #23 (audit-2026-07-05): lead scoring that survives the nightly pull.
-- fact_leads is refreshed by the nightly HubSpot pull; lead_score there is
-- legacy and unreliable. This side table is keyed by lead_id and is NEVER
-- written by any ingestion script, so scores persist across refreshes.
-- Scoring rubric: operations/leads/scoring-rules.json (v2, drive-time rubric).
-- Docs: operations/leads/lead-scoring.md

create table if not exists lead_scores (
    lead_id          bigint primary key references fact_leads(lead_id) on delete cascade,
    score            smallint    not null check (score between 0 and 100),
    tier             text        not null check (tier in ('A', 'B', 'C', 'D', 'DQ')),
    drive_time_tier  text        not null check (drive_time_tier in ('inner_30', 'mid_40_60', 'outer_60_plus', 'unknown')),
    next_action      text,
    rationale        text        not null,
    scoring_version  smallint    not null default 2,
    scored_at        timestamptz not null default now()
);

comment on table  lead_scores is 'Persistent lead scores (audit #23). Side table the nightly HubSpot pull never touches. Rubric: operations/leads/scoring-rules.json v2.';
comment on column lead_scores.tier is 'A = act now, B = solid, C = phone-qualify, D = data incomplete or weak, DQ = disqualified';
comment on column lead_scores.drive_time_tier is 'Drive time from CWDB Wausau (906 N 16th Ave): inner_30 (<=30 min), mid_40_60 (40-60 min), outer_60_plus, unknown';
comment on column lead_scores.next_action is 'Rubric-derived action: book-this-week / walkthrough-now-close-after-dsps / phone-qualify-batch-trip / none';

-- Service-role-only access (same posture as other PII tables): RLS on, no policies.
-- Ingestion runs with the service key and does NOT write this table by design.
alter table lead_scores enable row level security;

create index if not exists idx_lead_scores_tier on lead_scores (tier);
