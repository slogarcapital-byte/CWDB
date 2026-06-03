-- CWDB Data Warehouse — fact_bids real-data adaptations (v1.2)
-- Depends on: schema/001_initial.sql
--
-- Why this exists:
-- The original fact_bids design assumed every bid has a known contractor and a
-- "real" status (sent/accepted/etc). Real CWDB HubSpot data contradicts both:
--
-- 1. matched_contractor is free-text in HubSpot. Values like "CWDB" or "Jim"
--    don't map to a dim_contractor row. Forcing NOT NULL would lose those deals.
--
-- 2. Pre-bid stages (New Lead, Qualified, Scheduled, Creating Bid) have no bid
--    yet. The original bid_status CHECK rejected them. Adding 'pending' lets
--    fact_bids serve as the canonical "homeowner deal" table covering the full
--    funnel, not just bid events.
--
-- 3. Knowing the exact HubSpot stage label is useful for stage-specific queries.
--    bid_status is a derived classification; raw stage data is lossless.

BEGIN;

ALTER TABLE fact_bids ALTER COLUMN contractor_id DROP NOT NULL;

ALTER TABLE fact_bids DROP CONSTRAINT IF EXISTS fact_bids_bid_status_check;
ALTER TABLE fact_bids ADD CONSTRAINT fact_bids_bid_status_check
    CHECK (bid_status IN ('pending','sent','accepted','declined','expired','paid'));

ALTER TABLE fact_bids ADD COLUMN IF NOT EXISTS hubspot_deal_stage_id    text;
ALTER TABLE fact_bids ADD COLUMN IF NOT EXISTS hubspot_deal_stage_label text;

COMMIT;
