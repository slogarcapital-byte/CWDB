-- 009_lead_channel.sql
-- All-channel lead tracking (2026-06-10 pivot: phone leads count).
--
-- Leads arrive by webform, phone call, or manual entry. Until now only
-- webform leads (which carry tcpa_consent_given=true from the form relay)
-- survived ingestion. These columns let the ingestion script record HOW the
-- lead arrived and HOW consent was captured, so phone/manual leads flow into
-- fact_leads and the funnel/gate views without weakening the test-lead
-- exclusion in v_clean_leads (views/003).
--
--   lead_channel        : webform | phone | manual | other
--   tcpa_consent_source : form (relay-set) | verbal (Jim, on the call) | assumed
--
-- v_clean_leads / v_lead_funnel / v_validation_gate are SELECT * over
-- fact_leads-derived sets, so no view changes are required.

ALTER TABLE fact_leads
    ADD COLUMN IF NOT EXISTS lead_channel text
        CHECK (lead_channel IN ('webform', 'phone', 'manual', 'other')),
    ADD COLUMN IF NOT EXISTS tcpa_consent_source text
        CHECK (tcpa_consent_source IN ('form', 'verbal', 'assumed'));

COMMENT ON COLUMN fact_leads.lead_channel IS
    'How the lead arrived: webform | phone | manual | other. Inferred as webform for legacy rows with form-set TCPA.';
COMMENT ON COLUMN fact_leads.tcpa_consent_source IS
    'How TCPA consent was captured: form | verbal | assumed. Verbal = Jim recorded consent on a phone lead.';

-- Backfill legacy webform rows (all pre-existing rows came through the form
-- relay, which is the only path that ever set tcpa_consent_given=true).
UPDATE fact_leads
SET lead_channel = 'webform',
    tcpa_consent_source = 'form'
WHERE lead_channel IS NULL
  AND tcpa_consent_given IS TRUE;
