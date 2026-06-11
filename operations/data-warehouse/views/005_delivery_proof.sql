-- 005_delivery_proof.sql
-- Inc 3: deterministic input for the proven_delivery_path hinge (control-tick 6b).
--
-- WHY: the Tier-2 -> Tier-1 "hinge" (one human-approved REAL delivery makes
-- subsequent deliveries on the proven path Tier 1) needs a machine-checkable
-- definition of "a real lead was delivered". That is: a fact_bids row whose
-- lead survives the v_clean_leads test exclusions. Test-tagged routing
-- self-checks (utm_source='test', @cwdb-internal.test) never count.
-- The control tick flips control_state.proven_delivery_path only when
-- real_bid_count >= 1 AND an action_executed event exists for a delivery-class
-- action (two-condition AND so a manual warehouse backfill alone cannot flip it).

CREATE OR REPLACE VIEW v_delivery_proof WITH (security_invoker = on) AS
SELECT
    count(*)::int                                   AS real_bid_count,
    count(*) FILTER (WHERE b.bid_status = 'accepted')::int AS real_accepted_count,
    min(b.created_at)                               AS first_real_bid_at
FROM fact_bids b
JOIN v_clean_leads l ON l.lead_id = b.lead_id;
