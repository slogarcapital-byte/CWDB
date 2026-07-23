-- 017_seed_lead_scores_2026_07_22.sql
-- Initial scoring pass over v_clean_leads (20 leads as of 2026-07-22) using
-- scoring-rules.json v2. Hand-scored; rationale records the arithmetic.
-- Rubric: homeowner 20 + phone 10 + drive (inner 20 / mid 10 / unknown 5)
--         + timeline (asap 20 / 1-3mo 15 / 3-6mo 10 / 6-12mo 5 / researching 5)
--         + budget (20k+ 15 / 10-20k 12 / under-10k 8 / not-sure 5)
--         + fit (repair-stain inner 15 / repair-stain mid 12 / build-replace 10 / other 8 / non-deck 0)
-- Tiers: A >= 75, B >= 60, C >= 40, D < 40, DQ = disqualified (score 0).
-- Re-score by re-running this pattern; on conflict updates in place.

-- scoring_version defaults to 2 for every row.
insert into lead_scores (lead_id, score, tier, drive_time_tier, next_action, rationale)
values
  (3,  73, 'B', 'inner_30',   'walkthrough-now-close-after-dsps',
      'Gundersen, Merrill new deck (old one torn out). 20 own + 10 phone + 20 inner + 5 researching + 8 under-10k + 10 build. Real project, soft timeline; book walk-through, close after DSPS.'),
  (2,  73, 'B', 'unknown',    'phone-qualify-batch-trip',
      'Hanus, W10194 County Road J, no city; 847 (Chicago-area) phone. 20 own + 10 phone + 5 unknown drive + 20 asap + 8 under-10k + 10 build. Resolve location on the call before anything else; lead is from 5/5 and stale.'),
  (4,  70, 'B', 'inner_30',   'walkthrough-now-close-after-dsps',
      'Waldman, Weston deck replacement (composite or patio). 20 own + 10 phone + 20 inner + 5 researching + 5 not-sure budget + 10 build.'),
  (98, 90, 'A', 'inner_30',   'none',
      'Keuler, Wausau new deck, 20k-35k, 1-3 months. 20 own + 10 phone + 20 inner + 15 timeline + 15 budget + 10 build. Already an active deal in fact_bids; manage in pipeline, not as a new lead.'),
  (97, 88, 'A', 'inner_30',   'none',
      'Nayak, Wausau, 3 decks to refinish (stain lane), 1-3 months. 20 own + 10 phone + 20 inner + 15 timeline + 8 budget + 15 repair-stain inner. Existing deal in fact_bids ($4,900). consent_missing=true: NO SMS until verbal consent logged.'),
  (5,   0, 'DQ', 'unknown',   'none',
      'Internal test submission (Jim Slogar, address "Yiou", notes "Test"). DATA NOTE: this row evades the v_clean_leads test-exclusion predicate because its email is NULL (predicate keys on slogarjw@gmail.com / @cwdb-internal.test). Flag for a views fix.'),
  (6,  88, 'A', 'inner_30',   'none',
      'Overbeck, deck repair/stain inner. 20+10+20+15+8+15. CLOSED WON and COMPLETE: CWDB-2026-043, $2,800 collected. Kept for model calibration; this is the reference A-tier profile.'),
  (103, 92, 'A', 'inner_30',  'none',
      'Sjoberg, Wausau resurface, 10k-20k, 1-3 months. 20+10+20+15+12+15. Active bid $13,443 outstanding in fact_bids; work the bid, not the lead.'),
  (104, 87, 'A', 'inner_30',  'book-this-week',
      'Wroblewski, 167256 River Rd (Marathon County fire number, inner assumed), deck replacement, 10k-20k, 1-3 months. 20+10+20+15+12+10. Phone lead from 6/3; needs follow-up.'),
  (49, 73, 'B', 'inner_30',   'walkthrough-now-close-after-dsps',
      'Johnson, Weston replacement (2009 build wearing). 20+10+20+5 researching + 8 + 10. Qualified 6/11, Jim followed up; keep warm for post-DSPS close.'),
  (50, 80, 'A', 'inner_30',   'walkthrough-now-close-after-dsps',
      'Kampstra, 212727 Hayes Rd (Marathon County), replace/repair with joist rot detail. 20+10+20+15+5 not-sure + 10. Detailed, structurally literate note = high intent. Qualified 6/8.'),
  (75, 73, 'B', 'mid_40_60',  'none',
      'Quinn, County Road Mm (Stevens Point area, uwsp.edu), 8x16 porch replacement from ice storm. 20+10+10 mid + 15 + 8 + 10. HIC CWDB-2026-044 staged $7,751, start Aug 2026, SEND HELD pending DSPS cert/GL. Nothing to do until license.'),
  (147, 88, 'A', 'inner_30',  'walkthrough-now-close-after-dsps',
      'Reist, Wausau (Granite Road), two-level 14x30 PT rear deck with railings + wrap stairs, ASAP, rough plans in hand. 20+10+20+20+8+10. Budget says under-10k but scope reads 20k+; reset expectations at walk-through. Alt contact Cheryl (cell).'),
  (306, 20, 'D', 'mid_40_60', 'phone-qualify-batch-trip',
      'Neely, Stevens Point phone lead 6/19. Only name/phone/address captured: ownership, project, budget, timeline all unknown (0+10+10+0+0+0). Low score = missing data, NOT low intent; she called us. Phone-qualify and batch with Petersen trip. consent_missing=true: NO SMS.'),
  (307, 88, 'A', 'inner_30',  'book-this-week',
      'Hanson, Wausau deck repair, under-10k, 1-3 months. 20+10+20+15+8+15. THE Overbeck playbook lead: repair inside 30 min, self-perform cwdb lane, book the walk-through this week. consent_missing=true: call only, capture verbal consent.'),
  (308, 50, 'C', 'mid_40_60', 'phone-qualify-batch-trip',
      'Petersen, Stevens Point new deck via Meta ad (PAID_SOCIAL, launch-2026-04): the only paid-social lead ever. 20+10+10+0 timeline unknown + 0 budget unknown + 10 build. Phone-qualify, then batch a Stevens Point trip with Neely. consent_missing=true: NO SMS.'),
  (351, 88, 'A', 'inner_30',  'book-this-week',
      'Nelson-Claeys, Mosinee deck repair, under-10k, 1-3 months. 20+10+20+15+8+15. Overbeck-profile repair inside 30 min; phone lead 7/8. consent_missing=true: call only, capture verbal consent.'),
  (442, 88, 'A', 'inner_30',  'book-this-week',
      'Peksa, 224220 County Road Q (Marathon County fire number, inner assumed; verify on call), deck repair, under-10k, 1-3 months. 20+10+20+15+8+15. Webform 7/8 with no consent checkbox data: consent_missing=true, call only.'),
  (459,  0, 'DQ', 'unknown',  'none',
      'Dubois, "building a new home" inquiry, 332 (NYC) phone, no city. Whole-home construction is out of CWDB scope; pattern matches spam/solicitation. Disqualified: non-deck project.'),
  (477,  0, 'DQ', 'outer_60_plus', 'none',
      'Brown, St. Petersburg FL, estimating-services vendor solicitation, owns_property false. Disqualified: spam/vendor, non-homeowner, out of territory.')
on conflict (lead_id) do update set
  score = excluded.score,
  tier = excluded.tier,
  drive_time_tier = excluded.drive_time_tier,
  next_action = excluded.next_action,
  rationale = excluded.rationale,
  scoring_version = excluded.scoring_version,
  scored_at = now();
