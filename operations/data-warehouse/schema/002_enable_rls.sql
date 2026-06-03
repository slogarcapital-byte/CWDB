-- CWDB Data Warehouse — Security Hardening (v1.1)
-- Depends on: schema/001_initial.sql
-- Purpose: enable Row Level Security on all 12 tables with no policies = deny-all to anon + authenticated.
-- The service_role key (used by ingestion scripts) bypasses RLS.
-- The postgres superuser (used by the Supabase SQL editor and MCP) bypasses RLS.
-- Effect: only server-side ingestion + Jim's dashboard queries can read/write. anon key becomes useless.
-- Run via: paste into Supabase SQL Editor OR `apply_migration` via the Supabase MCP.

BEGIN;

ALTER TABLE public.dim_date                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dim_city                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dim_contractor            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dim_campaign              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dim_ad_group              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dim_ad                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fact_leads                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fact_bids                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fact_ad_spend_daily       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fact_traffic_daily        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.raw_hubspot_snapshot      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.raw_ad_platforms_snapshot ENABLE ROW LEVEL SECURITY;

COMMIT;
