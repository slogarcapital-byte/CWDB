-- =============================================================
-- 014_seed_audit_2026_07_05.sql - seed CWDB HQ from the 2026-07-05 audit
-- Seeds dashboard_tasks (the 28-item consolidated fix list, section 7) and
-- audit_findings (sections 1/4/5/6) with cross-links.
--
-- Items already executed before/at seed time are seeded with status='done'
-- so the dashboard starts truthful:
--   #6  consent gate      - shipped in the 2026-07-06 CWDB HQ Phase 1 build
--   #8  post-gate verdict - adopted by Jim 2026-07-05 (audit section 10)
--   #11 Meta pause        - executed + verified 2026-07-05
--   #15 v_pl_monthly      - rebuilt in the 2026-07-06 CWDB HQ Phase 1 build
--
-- Idempotent: ON CONFLICT (source_ref) DO NOTHING for tasks; findings guarded
-- by a delete-then-insert on audit_date.
-- =============================================================

BEGIN;

INSERT INTO dashboard_tasks
    (source_ref, title, detail, owner_group, owner_detail, priority, status, effort, suggested_agent, files, notes, completed_at)
VALUES
-- ---------- P0: this week, revenue or legal-critical ----------
('audit-2026-07-05#1',
 'Call insurance agent: confirm GL scope',
 'Confirm the bound GL policy ($1M/$2M CGL, ACORD 25 dated 6/26 in docs/legal/) classification covers hands-on deck construction + staining; confirm WI-authorized insurer; confirm 30-day DSPS cancellation endorsement; get the declarations page.',
 'jim', 'Jim', 'P0', 'open', '1 call', NULL, 'docs/legal/', NULL, NULL),

('audit-2026-07-05#2',
 'Start the DSPS licensing clock',
 '12-hr Dwelling Contractor Qualifier course (was targeted Mon 7/7), Form 3097 ~7/10, Form 3096 ~7/14, confirm Wausau/Marathon County registration. Credentials expected late-July/mid-August.',
 'jim', 'Jim', 'P0', 'open', '~1 wk active', NULL, NULL, NULL, NULL),

('audit-2026-07-05#3',
 'Yde Law consult: bring the section 9 package',
 'Consult booked Mon 7/6 3:30 PM. Bring: mutual termination + release concept for the two lead-purchase agreements; subcontractor agreement template for Ben/John; SBG legal-term-sheet questions; homeowner build docs for review; COI + licensing timeline.',
 'jim', 'Jim + legal-compliance-counsel', 'P0', 'open', 'prep 1 hr', 'legal-compliance-counsel',
 'docs/legal/contractor-lead-purchase-agreement-v1.md
docs/legal/templates/
business-context/construction-group/legal-term-sheet.md
sales/estimates/2026-06-26-quinn-deck-build-contract.pdf', NULL, NULL),

('audit-2026-07-05#4',
 'Quinn contract: decide the signing path',
 'Hold prime signature until DSPS Certification issues; OR route builder-lane; OR add a condition-precedent clause and strip "licensed" language. $7,751 contract staged, August start target.',
 'jim', 'Jim', 'P0', 'open', 'decision', 'legal-compliance-counsel',
 'sales/estimates/2026-06-26-quinn-deck-build-contract.pdf', NULL, NULL),

('audit-2026-07-05#5',
 'Follow up the 3 formerly-invisible leads',
 'Hanson first (Wausau repair = the Overbeck playbook), batch a Stevens Point trip for Petersen + Neely. Capture TCPA consent BEFORE any SMS (reply-YES text). All 3 now visible in the warehouse with consent_missing=true.',
 'jim', 'Jim', 'P0', 'open', 'half day', 'lead-qualification', NULL, NULL, NULL),

('audit-2026-07-05#6',
 'Fix warehouse consent gate (ingest + flag, never skip)',
 'Ingest leads missing TCPA consent with consent_missing flag instead of silent skip; alert on occurrences; backfill Petersen/Hanson/Neely.',
 'project', 'analytics', 'P0', 'done', '1-2 h', 'analytics',
 'operations/data-warehouse/schema/013_dashboard_hq.sql
templates/scripts/pull-hubspot-snapshot.ps1',
 'Shipped in CWDB HQ Phase 1 build 2026-07-06: CHECK constraint dropped (schema 013), pull ingests with consent_missing=true + ALERT log line, 3 leads backfilled (verified: Petersen PAID_SOCIAL, Hanson, Neely). Jim re-captures consent via task #5.',
 '2026-07-06T00:00:00Z'),

('audit-2026-07-05#7',
 'Notify-Jim path: HubSpot form-notification email + mobile push',
 'HubSpot Starter has no workflows, but form-notification email + the HubSpot mobile app give <5 min speed-to-lead. Petersen sat 5 days.',
 'jim', 'Jim', 'P0', 'open', '10 min', 'lead-routing', NULL, NULL, NULL),

('audit-2026-07-05#8',
 'Record the post-gate verdict',
 'Adopt section 6 wording: Phase 1 closed with pivot verdict; pay-per-accepted-bid parked as overflow product; validated model = self-perform construction fed by the owned lead engine.',
 'jim', 'Jim', 'P0', 'done', '30 min', 'cwdb-ceo-operator', NULL,
 'Adopted by Jim 2026-07-05 as written (audit section 10, decision 1). Recorded in memory + CLAUDE.md.',
 '2026-07-05T00:00:00Z'),

-- ---------- P1: next 2 weeks, measurement + compliance ----------
('audit-2026-07-05#9',
 'Attribution keeper script + relay v1.1',
 'Site-wide first-touch attribution keeper (localStorage, 90-day expiry); relay v1.1 with param-or-storage fallback, extended key list (utm_medium/term/content, fbclid), and hutk in form context.',
 'project', 'web-dev', 'P1', 'open', '2-4 h', 'web-dev',
 'website/scripts/hubspot_form_relay-1.0.0.js', NULL, NULL),

('audit-2026-07-05#10',
 'Google Ads conversion cleanup',
 'ONE primary lead conversion; demote 4 GBP "Local actions" junk conversions to secondary; remove the stale AW-10862517194 site tag; once-per-session dedupe. The primary from_submit_quotes went silent 6/10.',
 'project', 'ad-campaign', 'P1', 'open', '2 h', 'ad-campaign', NULL, NULL, NULL),

('audit-2026-07-05#11',
 'Pause Meta until the Pixel Lead event is fixed',
 'Pixel has NEVER fired a Lead event; campaign optimized blind since April (~$300/mo recovered). Keep Google at $30/day. Re-enable = one status flip after the Pixel fires.',
 'project', 'ad-campaign', 'P1', 'done', 'Jim approval', 'ad-campaign', NULL,
 'Executed + verified 2026-07-05: campaign 120241408537330461 PAUSED at campaign level via API, ad sets/budgets/Pixel untouched. Do-not-unpause note in ad-campaign agent memory.',
 '2026-07-05T00:00:00Z'),

('audit-2026-07-05#12',
 'TCPA webform consent regression',
 'Every webform lead through 6/15 captured consent; Petersen (6/30) did not. Verify the consent checkbox is required + mapped; backfill-audit webform leads since 6/16.',
 'project', 'web-dev', 'P1', 'open', '1-3 h', 'web-dev', NULL, NULL, NULL),

('audit-2026-07-05#13',
 'WB-017 site copy sweep (licensed/bonded/testimonials)',
 'Remove "licensed"/"bonded" claims until true (8 pages + meta + JSON-LD); reword 24/48h response promises; REMOVE AI-fabricated testimonials sitewide (FTC 16 CFR 255/465 exposure, up to ~$51,744/violation).',
 'project', 'legal + content-writer + web-dev', 'P1', 'open', '0.5 day', 'web-dev', NULL, NULL, NULL),

('audit-2026-07-05#14',
 'Contractor paper cleanup (termination + subcontractor agreements)',
 'Mutual termination + release for the two lead-purchase agreements ($0 accounting, kill the 12-month tail); subcontractor agreements signed with Ben/John BEFORE the August jobs (Winchester Aug 17-21); Amendment No. 1 or fold into termination.',
 'others', 'Jim + Yde Law + Ben/John', 'P1', 'open', '2 h + attorney', 'legal-compliance-counsel',
 'docs/legal/contractor-lead-purchase-agreement-v1.md
docs/legal/templates/', NULL, NULL),

('audit-2026-07-05#15',
 'Rebuild v_pl_monthly (two revenue legs, no phantom fees)',
 'Lane column via dim_jobs channel; zero cwdb-lane fees; construction-revenue leg from QBO; fix dim_jobs Overbeck row + bid 4 accepted_at.',
 'project', 'analytics + accounting', 'P1', 'done', 'half day', 'analytics',
 'operations/data-warehouse/views/007_construction_kpis.sql
templates/scripts/pull-qbo-financials.ps1',
 'Shipped in CWDB HQ Phase 1 build 2026-07-06: v_pl_monthly rebuilt (fees count only when invoiced + lead_purchase lane; construction leg from fin_pl_monthly), Overbeck dim_jobs patched, bid 4 accepted_at=6/11 with earliest-wins protection in the pull. June verified: $3,605 revenue vs $1,179 spend.',
 '2026-07-06T00:00:00Z'),

('audit-2026-07-05#16',
 'Phone intake consent hygiene',
 'lead_channel + tcpa_consent_source dropdowns on the HubSpot create-contact screen + one scripted consent sentence. Retire "assumed" consent.',
 'jim', 'Jim', 'P1', 'open', '15 min', 'lead-routing', NULL, NULL, NULL),

('audit-2026-07-05#17',
 'Retire Make scenarios + rotate the exposed service-role key',
 'Retire scenarios 5361099 (active, pointed at nothing, service-role JWT in plaintext blueprint) and 4792854 (parked); reject approval #61; rotate the Supabase service-role key after retiring.',
 'jim', 'Jim + lead-routing', 'P1', 'open', '1 h', 'lead-routing', NULL, NULL, NULL),

('audit-2026-07-05#18',
 'Tax reserve + Q3 estimates + subscription commingling',
 'Fund a tax reserve (~35% of net income); check Q3 1040-ES by 9/15; move HubSpot/Webflow/GoDaddy/Supabase/Anthropic subscriptions to the business card (currently paid personally, understating expenses).',
 'jim', 'Jim + accounting', 'P1', 'open', '1-2 h', 'accounting', NULL, NULL, NULL),

-- ---------- P2: this month, structure + hygiene ----------
('audit-2026-07-05#19',
 'Retire the control plane formally',
 'Scheduled tasks already disabled; make it official (board/memory record). Keep the warehouse + views.',
 'jim', 'Jim', 'P2', 'open', '1-2 h', 'cwdb-ceo-operator',
 'operations/control-plane/', NULL, NULL),

('audit-2026-07-05#20',
 'Weekly 15-min review replaces daily ritual; reconcile the board',
 'Collapse the board (zombie items WB-010/016/018-GL); the CWDB HQ dashboard to-do tab is now the canonical task list with board files as generated mirrors.',
 'project', 'Jim + cwdb-ceo-operator', 'P2', 'open', '1 h', 'cwdb-ceo-operator',
 '_vault/board/', NULL, NULL),

('audit-2026-07-05#21',
 'Site repositioning: deck construction company',
 'Copy repositions CWDB from lead broker to deck construction company (pairs with #13); /thank-you becomes a walk-through booking page.',
 'project', 'content-writer + web-dev', 'P2', 'open', '2 days', 'content-writer', NULL, NULL, NULL),

('audit-2026-07-05#22',
 'Estimate follow-up cadence + stale-bid resolution',
 '7/14-day touches, 14-day expiry. Resolve stale bids (Kampstra 16 days, Waldman 61 days at audit time). Budget-vs-bid sanity check in /bid. ~$91.7k of sent estimates open.',
 'jim', 'Jim + agents', 'P2', 'open', 'half day', 'contractor-sales', NULL, NULL, NULL),

('audit-2026-07-05#23',
 'Lead scoring that survives the nightly pull + drive-time rubric',
 'Side table (or protected column) the pull cannot wipe; drive-time-tier qualification rubric (repair/stain within 30 min = book this week; builds = book now, close post-cert; 40-60 min = phone-qualify + batch trips); fix scoring-rules.json. NOTE: the pull no longer wipes lead_score (fixed 2026-07-06); the scoring engine itself still does not exist.',
 'project', 'lead-qualification', 'P2', 'open', 'half day', 'lead-qualification', NULL, NULL, NULL),

('audit-2026-07-05#24',
 'Books cleanup: pre-4/28 backfill, reclasses, deposit-timing memo',
 'Backfill the pre-4/28 window; reclass QBO sub miscoding; substantiate the $308.69 sponsorship; write the deposit-timing policy memo before the Quinn deposit.',
 'project', 'accounting + Jim', 'P2', 'open', 'half day', 'accounting',
 'finance/', NULL, NULL),

('audit-2026-07-05#25',
 'Cloud-decouple the warehouse cron',
 'Cron is laptop-coupled and missed 6/27-7/1 and 7/3-7/5. Either decouple to cloud or formally accept a weekly manual run.',
 'project', 'analytics', 'P2', 'open', 'half day', 'analytics',
 'operations/data-warehouse/scripts/run-daily.ps1', NULL, NULL),

('audit-2026-07-05#26',
 'Privacy policy + oral-notice acknowledgment',
 'Publish /privacy on the site; add the combined-doc oral-notice acknowledgment line.',
 'project', 'legal + web-dev', 'P2', 'open', '3 h', 'legal-compliance-counsel', NULL, NULL, NULL),

('audit-2026-07-05#27',
 'Data hygiene: test lead 5 + fact_bids corrections',
 'Exclude test lead 5 (Jim, no email) from v_clean_leads; fact_bids corrections (Hanus $1,000 placeholder amount, contractor_id backfills) AFTER Jim verifies each.',
 'project', 'analytics (after Jim verifies)', 'P2', 'open', '1-2 h', 'analytics',
 'operations/data-warehouse/views/', NULL, NULL),

('audit-2026-07-05#28',
 'Repo hygiene: commit the working tree + branch policy',
 'Commit/clean the 556-file working tree; decide test-branch vs main policy (estimator AND the CWDB HQ cloud twin deploy from test-branch).',
 'jim', 'Jim + Claude', 'P2', 'open', '1 h', NULL, NULL, NULL, NULL)

ON CONFLICT (source_ref) WHERE source_ref IS NOT NULL DO NOTHING;

-- -------------------------------------------------------------
-- audit_findings (sections 1 / 4 / 5 / 6)
-- -------------------------------------------------------------

DELETE FROM audit_findings WHERE audit_date = '2026-07-05';

INSERT INTO audit_findings (audit_date, section, platform, title, body, linked_task_refs, sort_order) VALUES
('2026-07-05','exec_summary',NULL,'The business quietly succeeded at a different game',
$body$Real state: 15 lifetime homeowner leads (not 13), paid ads produced at least 4 of them (not 1), Overbeck is COMPLETE and fully collected ($2,800), CWDB also earned $800 subbing labor to John Garcia, and QBO shows +$1,550 net income YTD. The business is roughly break-even to slightly positive.

What the dashboards said instead: zero leads since 6/15, one attributed ad lead ever at a $912 CPL, June at -$1,179, revenue $1,000 invoiced / $0 collected. Every one of those numbers was wrong -- four independent instrumentation failures (site drops attribution, warehouse consent gate drops leads, v_pl_monthly phantom fee, laptop-coupled cron).

The thesis verdict: pay-per-accepted-bid went 0-for-3 with contractors, $0 of lead-fee revenue ever invoiced. What got validated instead is self-perform construction fed by CWDB's own lead engine. Biggest surprise: GL insurance was apparently already bound ~6/25 ($1M/$2M CGL) and never recorded.$body$,
 ARRAY['audit-2026-07-05#1','audit-2026-07-05#8'], 0),

('2026-07-05','platform','warehouse','Supabase warehouse',
$body$Schema and views are the right asset to keep. Three data-integrity defects found: consent gate silently dropped leads (FIXED 7/6: ingest + flag); pull hardcoded lead_score=0 nightly, wiping scores (FIXED 7/6: column omitted from payload); v_clean_leads still passes test lead 5. v_pl_monthly counted a phantom $1,000 referral fee and had no construction-revenue leg (REBUILT 7/6). Cron is laptop-coupled: missed 6/27-7/1 and 7/3-7/5.$body$,
 ARRAY['audit-2026-07-05#6','audit-2026-07-05#15','audit-2026-07-05#23','audit-2026-07-05#25','audit-2026-07-05#27'], 1),

('2026-07-05','platform','hubspot','HubSpot (portal 245712220)',
$body$The healthiest system in the stack; Jim actively works it. 17 contacts = 2 contractors + 15 real leads. No notification path exists for new leads (Petersen sat 5 days) -- fix is a 10-minute setting + the mobile app. Starter-tier data hygiene: Delivered Bid deals with no amounts (Neely, Hanson, Wroblewski), $1,000 placeholder amounts (Hanus), bids above stated budgets (Reist $30,380 vs under-10k; Keuler $44,238 vs 20k-35k, declined).$body$,
 ARRAY['audit-2026-07-05#7','audit-2026-07-05#16','audit-2026-07-05#22'], 2),

('2026-07-05','platform','qbo','QuickBooks Online (production)',
$body$4 invoices, ALL PAID, A/R $0: $5 test, Overbeck $840 deposit (6/11), Garcia $800 sub-labor (6/28), Overbeck $1,960 final (6/28). Cash collected $3,605. Checking $2,952.04, card liability $1,651.69. Cash-basis net income +$1,550.35 YTD. Overbeck deposit accounting was textbook. Gaps: pre-4/28 window unbooked; subscriptions paid personally (commingling); QBO sub miscoded; $308.69 sponsorship needs substantiation. Tax: fund reserve (~35% of net), check Q3 1040-ES by 9/15; S-corp December review now mandatory.$body$,
 ARRAY['audit-2026-07-05#18','audit-2026-07-05#24'], 3),

('2026-07-05','platform','site','Webflow / cwdeckbuilders.com',
$body$Form and relay WORK (Petersen 6/30 arrived to the second). All 18 pages live. WB-017 exposure worse than the board suggests: "licensed" claims on 8 pages + meta + JSON-LD, "Insured & Bonded" badges (bonded never true), 24/48-hour response promises the fulfillment model missed, and AI-fabricated testimonials sitewide (FTC exposure up to ~$51,744/violation). TCPA regression: consent capture broke between 6/15 and 6/30. Attribution BREAK A: no persistence layer, bare /get-a-quote links; BREAK B: relay never sends hutk.$body$,
 ARRAY['audit-2026-07-05#9','audit-2026-07-05#12','audit-2026-07-05#13','audit-2026-07-05#21','audit-2026-07-05#26'], 4),

('2026-07-05','platform','google_ads','Google Ads (customer 7129910870)',
$body$Search campaign delivering well on proxies during peak season (~6% CTR, ~$3 CPC, 19.9% impression share = budget-limited). TARGET_SPEND does not need conversions to deliver, so the tracking mess corrupts reporting, not delivery. BREAK C: 13 conversion actions, primary went silent 6/10, GA4-import actions deleted, 4 GBP junk conversions marked primary, TWO AW accounts fire site-wide, two GA4 properties double-track. Budget leaks to DIY/retail terms needing negatives.$body$,
 ARRAY['audit-2026-07-05#10'], 5),

('2026-07-05','platform','meta','Meta Ads',
$body$$585 lifetime, ~1.1% CTR, Pixel Lead NEVER fired, campaign optimized blind toward a signal it never received. Weakest channel -- PAUSED 7/5 until the Pixel/Instant-Form fix, then re-judge. It did produce Petersen per HubSpot analytics, so it is unmeasured rather than worthless.$body$,
 ARRAY['audit-2026-07-05#11'], 6),

('2026-07-05','platform','make','Make.com',
$body$Scenario 5361099 ACTIVE but pointed at nothing (Webflow has no webhooks; approval #61 never executed; 17 executions all tests). Scenario 4792854 parked since 4/19 with 1 stuck queue item. SECURITY: Supabase service-role JWT embedded in plaintext in the 5361099 blueprint -- rotate after retiring. Recommendation: retire both, kill approval #61, use HubSpot-native notifications.$body$,
 ARRAY['audit-2026-07-05#17'], 7),

('2026-07-05','platform','control_plane','Control plane + operating system',
$body$Control plane dead since ~6/12 (gate_token_stale, then stale_warehouse_data). Produced 7 tasks, one failed go-live, one 23-day pending approval, zero autonomous revenue. RETIRED per Jim 7/5 (keep warehouse + views). Operating system: daily briefs stopped 5/11, last 3 session notes empty stubs, board carries zombie items (WB-010/016/018-GL). Weekly 15-min review replaces the daily ritual; this dashboard's to-do tab replaces the board.$body$,
 ARRAY['audit-2026-07-05#19','audit-2026-07-05#20','audit-2026-07-05#28'], 8),

('2026-07-05','interview','ceo','cwdb-ceo-operator',
$body$Business is a construction company with a demand-gen front end; write the post-gate pivot verdict (nobody did, 17 days late). Retire the control plane. Kill the daily-brief ritual. Park SBG until licensed + insured + demand engine proven + 2-3 cash-positive months. Reprice the CPL ceiling to $300-500 under job-margin economics. Top move: declare the model and start the license clock the same week.$body$,
 ARRAY['audit-2026-07-05#2','audit-2026-07-05#8','audit-2026-07-05#19'], 10),

('2026-07-05','interview','accounting','accounting',
$body$Books say break-even/positive, not underwater. Overbeck closed and collected in full; Garcia $800 sub-labor is a live preview of the SBG labor model. Fix v_pl_monthly (two revenue legs). Fund tax reserve, Q3 estimates check. SBG gates: attorney on ownership chain, S-corp for SBG-Labor, WI DOR determination on equipment-lease sales tax. Unit economics: chase staining/repair self-perform and sub-labor now; builds need crew leverage to clear real margin.$body$,
 ARRAY['audit-2026-07-05#15','audit-2026-07-05#18','audit-2026-07-05#24'], 11),

('2026-07-05','interview','contractor_sales','contractor-sales',
$body$Relationships already mutated to pre-partner (shared schedules, W-9/COI exchanged, joint Winchester job Aug 17-21). The lead-purchase agreements are adversarial paper between prospective partners: terminate cleanly ($0 accounting, kill the 12-month tail), sign subcontractor agreements before August jobs, bring it all to the Yde consult. 0-for-3 indicts process more than the model. Keep a simplified deposit-triggered referral agreement on the shelf for third parties.$body$,
 ARRAY['audit-2026-07-05#14','audit-2026-07-05#3'], 12),

('2026-07-05','interview','web_dev','web-dev',
$body$Attribution break-point map (section 3). WB-017 claim inventory (8 pages). Form works; the 6/30 lead vanishing was a warehouse problem, not a site problem. Leverage: reposition the site as the deck construction company; ship the attribution keeper; turn /thank-you into a walk-through booking page.$body$,
 ARRAY['audit-2026-07-05#9','audit-2026-07-05#13','audit-2026-07-05#21'], 13),

('2026-07-05','interview','ad_campaign','ad-campaign',
$body$Ads work, measurement broken. Keep Google Search at $30/day (peak season, budget-limited, high intent), pause Meta until the Pixel is fixed, clean the conversion graveyard, add negatives, then consider LSAs + GBP as the highest-intent channel for a licensed construction operator.$body$,
 ARRAY['audit-2026-07-05#10','audit-2026-07-05#11'], 14),

('2026-07-05','interview','legal','legal-compliance-counsel',
$body$BASELINE CORRECTION: GL likely bound ~6/25 ($1M/$2M ACORD 25 in docs/legal). Confirm 3 things by phone: classification covers hands-on construction + staining; WI-authorized insurer; 30-day DSPS cancellation endorsement. Licensing path: 12-hr course, Form 3097, Form 3096, credentials late-July/mid-August. Do NOT sign Quinn as prime before Certification. TCPA: retire "assumed" consent; re-capture before texting the 3 new leads. AI testimonials are the largest single dollar exposure on the site. SBG interim discipline: nothing binding, no commingling, keep the lead engine out.$body$,
 ARRAY['audit-2026-07-05#1','audit-2026-07-05#2','audit-2026-07-05#4','audit-2026-07-05#13'], 15),

('2026-07-05','interview','lead_routing','lead-routing',
$body$Make branch is a working machine pointed at nothing; retire it, use HubSpot form-notification email + mobile push (10 minutes, <5 min speed-to-lead). Phone intake: two dropdowns (lead_channel + tcpa_consent_source) on the create-contact screen plus one scripted consent sentence. Rotate the exposed service-role key. Contractor overflow = Jim forwards a text + moves the deal stage.$body$,
 ARRAY['audit-2026-07-05#7','audit-2026-07-05#16','audit-2026-07-05#17'], 16),

('2026-07-05','interview','lead_qualification','lead-qualification',
$body$Ground-truth ledger: 15 real leads, paid media produced >=4. Scoring never existed (pull wiped it nightly -- pull fixed 7/6, engine still to build). Priority follow-ups: Hanson (Wausau repair, the Overbeck playbook), Petersen (paid Meta lead, was 5-day stale), Neely (Stevens Point, batch trip with Petersen). Drive-time-tier rubric proposed. Territory zip list is dead in practice; Stevens Point is organically producing leads.$body$,
 ARRAY['audit-2026-07-05#5','audit-2026-07-05#23'], 17),

('2026-07-05','strategy',NULL,'Strategy assessment: the data endorses the construction/SBG tilt',
$body$Every dollar ever collected ($3,600) is construction or labor. The contractor-fee leg is 0-for-3 with an unenforceable definition. Ben/John behave like partners, not customers. The lead engine's economics transform under the tilt: a lead worth a $3k-GP job supports a $300-500 CPL, which makes the "failing" ad program actually cheap, and makes fixing attribution the key that unlocks scaling it.

What changes: site repositions to deck construction company; routing means "notify Jim in 5 minutes"; the $1,000 fee survives only as a shelf product; KPIs move to booked revenue, GP/job, close rate, cost per booked job.

SBG posture (consensus): keep evaluating, do not commit. Unlock triggers: (1) DSPS cert + GL confirmed in scope, (2) demand engine reliably producing booked jobs, (3) 2-3 consecutive cash-positive months, (4) attorney + CPA scoping done. Interim discipline: nothing binding, no commingling, lead engine stays 100% CWDB.

Validation verdict (ADOPTED by Jim 7/5): Phase 1 closed 2026-07-05 with a pivot verdict. The pay-per-accepted-bid contractor model is unproven (0 acceptances, $0 fees) and is parked as a secondary overflow product. The validated model is self-perform construction fed by CWDB's owned lead engine (1 job closed and collected, $3,600 revenue, break-even YTD). Phase 2 = construction profitability: licensed, insured, 2-4 booked jobs/month, measured funnel.$body$,
 ARRAY['audit-2026-07-05#8','audit-2026-07-05#2','audit-2026-07-05#9'], 20);

COMMIT;
