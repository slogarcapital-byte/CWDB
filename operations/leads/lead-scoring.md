# CWDB Lead Scoring Model (v2)

Audit fix #23 (audit-2026-07-05). Built 2026-07-22.

## Why this exists

The nightly HubSpot pull refreshes `fact_leads` in place. The legacy `fact_leads.lead_score` column is no longer wiped (fixed 2026-07-06) but was never populated by a real engine and should be treated as dead. Scores now live in a dedicated side table, `lead_scores`, keyed by `lead_id`. No ingestion script writes to it, so scores survive every refresh by construction.

- Rules file: `operations/leads/scoring-rules.json` (v2)
- Table DDL: `operations/data-warehouse/schema/016_lead_scores.sql`
- Initial scoring pass: `operations/data-warehouse/schema/017_seed_lead_scores_2026_07_22.sql`
- RLS is enabled with no policies: service-role access only, same PII posture as `fact_leads`.

## The model

Six dimensions, max 100 points. All channels score identically (webform, phone, manual).

| Dimension | Points |
|---|---|
| Homeowner (`owns_property`) | 20 (false = DQ, unknown = 0) |
| Valid phone | 10 (missing = DQ) |
| Drive time | inner_30 = 20, mid_40_60 = 10, unknown = 5, outer_60_plus = 0 |
| Timeline | asap 20, 1-3mo 15, 3-6mo 10, 6-12mo 5, researching 5, unknown 0 |
| Budget | 20k+ 15, 10-20k 12, under-10k 8, not-sure 5, unknown 0 |
| Project fit | repair/stain inner 15, repair/stain mid 12, build/replacement 10, other deck 8, non-deck 0 |

Tiers: **A** >= 75 (act now), **B** >= 60 (solid, this week), **C** >= 40 (phone-qualify first), **D** < 40 (data-incomplete or weak), **DQ** (disqualified, score recorded as 0).

Two deliberate Phase 2 biases:

1. **Repair/stain near home outranks big builds.** The cwdb self-perform lane can take a repair/stain job to revenue immediately (no permit, no DSPS gate). Overbeck ($2,800 collected) is the calibration profile.
2. **A low score from missing data is not a low-intent lead.** Phone leads with thin capture (e.g. Neely) score low because unknown dimensions earn 0. The rationale column must say so, and the fix is a qualification call, not deprioritization.

## Drive-time rubric

Origin: 906 N 16th Ave, Wausau WI 54401.

| Tier | Definition | Playbook |
|---|---|---|
| `inner_30` | <= 30 min: Wausau, Schofield, Weston, Rothschild, Kronenwetter, Mosinee, Merrill | Repair/stain: **book this week** (Overbeck playbook, cwdb lane). New build/replacement: **book the walk-through now, close after DSPS cert** (pre-license, builder-lane rules: never sign as prime, never take a build deposit). |
| `mid_40_60` | 40-60 min: Stevens Point, Plover, Marshfield, Antigo, Wittenberg | **Phone-qualify first, then batch** multiple walk-throughs into one trip. Never drive an hour for one unqualified lead. |
| `outer_60_plus` | > 60 min | Outside Phase 2 working radius. Decline or refer. |
| `unknown` | Rural fire-number address, no city | Resolve drive time on the qualification call before booking. |

Marathon County fire-number addresses (6-digit house numbers) default to `inner_30` with a verify-on-call caveat in the rationale.

## Consent rule

`consent_missing = true` blocks SMS only. It never hides or deprioritizes a lead. Call the lead, use the scripted verbal-consent ask (see call sheets), and log `tcpa_consent_source = verbal` in HubSpot.

## How to re-score

1. Pull the current clean set: `select * from v_clean_leads order by submitted_at;` (join `dim_city` for city names).
2. Score each new or changed lead against the dimensions above; record the arithmetic in `rationale` (e.g. `20+10+20+15+8+15`).
3. Upsert into `lead_scores` with `on conflict (lead_id) do update` (copy the pattern in `017_seed_lead_scores_2026_07_22.sql`), bumping `scored_at`.
4. If the rubric itself changes, bump `version` in `scoring-rules.json`, set `scoring_version` on the new rows, and note the change here.
5. Trigger points for a re-score: any new lead, a status change (bid sent/accepted), DSPS cert landing (re-score all `walkthrough-now-close-after-dsps` rows to `book-this-week`), or a quarterly `/business-audit`.

## Known data issues found during the 2026-07-22 pass

- `fact_leads` lead_id 5 (Jim's "Test"/"Yiou" submission) leaks through `v_clean_leads` because its email is NULL and the test-exclusion predicate keys on email values. Scored DQ here; the view predicate needs a fix (candidate: also exclude `lead_notes = 'Test'` or that specific lead_id).
- `fact_leads.lead_score` is dead weight; any consumer should read `lead_scores` instead.
