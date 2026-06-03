-- CWDB Data Warehouse — Relax budget_range constraint
-- Depends on: schema/001_initial.sql
-- Purpose: drop the budget_range CHECK constraint.
--
-- Rationale: HubSpot stores form values in its own format (e.g., 'under-10k', '10k-20k')
-- that doesn't match our original title-case enum. Source-of-truth is HubSpot; the
-- warehouse is read-only. Constraints on free-form text fields whose values are
-- controlled outside our schema are brittle and cause false rejections during
-- source-system refactors. Soft validation (in views or queries) is better.

BEGIN;

ALTER TABLE fact_leads DROP CONSTRAINT IF EXISTS fact_leads_budget_range_check;

COMMIT;
