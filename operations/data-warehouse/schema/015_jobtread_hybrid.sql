-- 015_jobtread_hybrid.sql
-- Additive JobTread hybrid layer per operations/analysis/jobtread-setup-design.md §5.
-- No existing columns or views change. Rollback: drop the four tables + the five
-- added columns (nothing references them).

create table if not exists raw_jobtread_snapshot (
    id          bigint generated always as identity primary key,
    pulled_at   timestamptz not null default now(),
    object_type text not null check (object_type in ('account','contact','job','location')),
    object_id   text not null,
    payload     jsonb not null,
    unique (object_type, object_id)
);

create table if not exists raw_intake_events (
    id                   bigint generated always as identity primary key,
    received_at          timestamptz not null default now(),
    source               text not null default 'webform',
    payload              jsonb not null,
    jobtread_customer_id text,
    jobtread_job_id      text,
    hubspot_status       int,
    jobtread_status      int,
    error                text
);

create table if not exists raw_jobtread_events (
    id           bigint generated always as identity primary key,
    received_at  timestamptz not null default now(),
    event_id     text,
    event_type   text,
    payload      jsonb not null,
    processed_at timestamptz
);
create unique index if not exists raw_jobtread_events_event_id_uq
    on raw_jobtread_events (event_id) where event_id is not null;

create table if not exists conversions_outbox (
    id                     bigint generated always as identity primary key,
    created_at             timestamptz not null default now(),
    platform               text not null default 'google_ads',
    gclid                  text,
    conversion_time        timestamptz not null default now(),
    conversion_value_cents bigint,
    currency               text not null default 'USD',
    jobtread_job_id        text,
    status                 text not null default 'pending'
                           check (status in ('pending','uploaded','failed','skipped')),
    uploaded_at            timestamptz,
    error                  text
);

alter table fact_leads add column if not exists jobtread_customer_id text;
alter table fact_leads add column if not exists jobtread_job_id      text;
alter table fact_leads add column if not exists crm_source           text not null default 'hubspot';
alter table fact_bids  add column if not exists jobtread_job_id      text;
alter table fact_bids  add column if not exists crm_source           text not null default 'hubspot';

-- RLS: deny-all like the rest of the warehouse (002); service role bypasses.
alter table raw_jobtread_snapshot enable row level security;
alter table raw_intake_events     enable row level security;
alter table raw_jobtread_events   enable row level security;
alter table conversions_outbox    enable row level security;
