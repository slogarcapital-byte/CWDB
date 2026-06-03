-- CWDB Data Warehouse — UPSERT key for HubSpot-sourced leads
-- Depends on: schema/001_initial.sql
-- Purpose: add UNIQUE on fact_leads.hubspot_contact_id so the HubSpot loader can
-- UPSERT on it. webflow_submission_id is also UNIQUE but is NULL when leads enter
-- via HubSpot directly (e.g., manually-created contacts, or future direct API push).

BEGIN;

ALTER TABLE fact_leads
    ADD CONSTRAINT fact_leads_hubspot_contact_id_key UNIQUE (hubspot_contact_id);

COMMIT;
