# CWDB Data Warehouse

Centralized Supabase Postgres database that consolidates Webflow, HubSpot, Google Ads, Meta Ads, and GA4 into a single queryable store for analytics.

**Design plan:** `C:\Users\jslog\.claude\plans\i-m-trying-to-consolidate-silly-spindle.md`
**DB provider:** Supabase (Postgres, free tier)
**Refresh cadence:** daily 6:55 AM Central (cron, extends existing pull-*.ps1 pipeline)

---

## Setup (one-time, ~15 min — Jim manual step)

1. Sign in to **supabase.com** and create a new project
   - Name: `cwdb-warehouse`
   - Region: `us-east-1` (closest to Central WI)
   - Database password: generate a strong one, save to your password manager
   - Plan: Free

2. Copy three credentials from **Project Settings -> API**:
   - `SUPABASE_URL` (e.g., `https://abcdefg.supabase.co`)
   - `SUPABASE_ANON_KEY` (long JWT, public-safe)
   - `SUPABASE_SERVICE_ROLE_KEY` (long JWT, **server-only, never commit**)

3. Add to `operations/automation/api-credentials/.env.local` (gitignored):
   ```
   SUPABASE_URL=https://abcdefg.supabase.co
   SUPABASE_ANON_KEY=eyJ...
   SUPABASE_SERVICE_ROLE_KEY=eyJ...
   ```

4. Run schema migrations (in order):
   - Open Supabase SQL Editor -> New query
   - Paste `schema/001_initial.sql` -> **Run**. Expect `Success. No rows returned.`
   - New query -> paste `schema/002_enable_rls.sql` -> **Run**. (Locks anon key out of all tables.)
   - Verify: 12 tables under **Table Editor**

5. Run analytical views:
   - New query -> paste `views/001_views.sql` -> **Run**. (Views include `WITH (security_invoker = on)` so they respect RLS.)
   - Verify: 7 views appear under **Database -> Views**

6. Smoke-test:
   ```sql
   SELECT COUNT(*) FROM dim_date;          -- expect 2557
   SELECT COUNT(*) FROM dim_city;          -- expect 5
   SELECT table_name FROM information_schema.tables WHERE table_schema='public';
   ```

---

## Schema summary

### Fact tables (events)
| Table | Grain | Source |
|---|---|---|
| `fact_leads` | one Webflow form submission | Webflow -> Make -> HubSpot |
| `fact_bids` | one bid issued by a contractor | HubSpot Deal records |
| `fact_ad_spend_daily` | one ad x day spend row | Google Ads + Meta APIs |
| `fact_traffic_daily` | one (page, source, day) | GA4 Data API |

### Dimension tables (descriptive context)
| Table | Grain |
|---|---|
| `dim_contractor` | one contractor partner |
| `dim_campaign` | one ad campaign |
| `dim_ad_group` | one ad group / ad set |
| `dim_ad` | one ad creative |
| `dim_city` | one service-area city |
| `dim_date` | one calendar day (2024-2030) |

### Raw / bronze tables (jsonb)
| Table | Purpose |
|---|---|
| `raw_hubspot_snapshot` | full nightly HubSpot contact/deal/company payloads |
| `raw_ad_platforms_snapshot` | full nightly Google/Meta/GA4 payloads |

---

## Analytical views (the answers)

| View | Question it answers |
|---|---|
| `v_lead_funnel` | What % of leads make it to each pipeline stage by month? |
| `v_cac_by_channel` | What's our cost per lead / per accepted bid, by platform + month? |
| `v_contractor_scorecard` | Per-contractor: bids sent, win rate, avg response time, revenue earned |
| `v_city_demand` | Per-city lead volume + quality + conversion rate |
| `v_pl_monthly` | Monthly P&L: ad spend vs accepted-bid revenue, gross margin |
| `v_lead_attribution_disagreement` | Diagnostic: leads where HubSpot UTM != GA4 UTM (tracking leak detector) |
| `v_unjoined_leads` | Diagnostic: leads with UTMs that don't match any known campaign (dead UTMs in live ads) |

### Query examples

```sql
-- Funnel for the last 6 months
SELECT * FROM v_lead_funnel WHERE month >= now() - interval '6 months';

-- Which Google Ads campaign produced the cheapest qualified lead in May?
SELECT * FROM v_cac_by_channel
WHERE month = '2026-05-01' AND platform = 'google_ads'
ORDER BY cost_per_qualified_lead;

-- Contractor leaderboard
SELECT * FROM v_contractor_scorecard WHERE is_active = true;

-- How much did we spend on ads in April vs revenue earned?
SELECT * FROM v_pl_monthly WHERE month = '2026-04-01';
```

---

## Conventions

- **Money: integer cents.** All amounts are `bigint cents` (multiply by 0.01 for display). No floats; rounding-safe across millions of rows. Display layer formats as dollars.
- **Times: `timestamptz`.** Always UTC under the hood; rendered in client's timezone. No naive timestamps.
- **PII: stored raw, single-user only.** Phone, email, address are plaintext in `fact_leads`. Supabase access is locked to Jim's account.
- **Surrogate PKs + natural-key UNIQUE.** Every table has a `bigserial` PK plus a UNIQUE on the source-system natural key. Ingestion scripts UPSERT on the natural key — re-running is safe (idempotent).
- **`ON DELETE` policies are intentional.** `fact_bids -> fact_leads` uses RESTRICT (never lose revenue evidence); `dim_ad_group -> dim_campaign` uses CASCADE (clean up child rows with parent).
- **No floats in money columns.** Cents only. Always.

---

## Ingestion pipeline (Phases B-E, in progress)

```
6:55 AM cron  ->  pull-*.ps1 (existing JSON dumps to _vault/data/)
             ->  load-supabase.ps1 (UPSERT helper, dot-sourced)
             ->  Supabase UPSERT via REST API
```

Source-by-source status:

| Source | Pull script | Loads | Status |
|---|---|---|---|
| HubSpot contacts/deals/companies | `pull-hubspot-snapshot.ps1` | raw_hubspot_snapshot + dim_contractor | Phase B1 built |
| HubSpot contacts -> fact_leads | (extension of above) | fact_leads | Phase B2 pending |
| HubSpot deals -> fact_bids | (extension of above) | fact_bids | Phase B3 pending (blocked on homeowner-lead pipeline live in HubSpot) |
| Webflow form (direct) | (relies on HubSpot ingest above) | n/a | Captured via HubSpot |
| Google Ads | `pull-google-ads-mtd.ps1` (exists) | append step | Pending Phase C |
| Meta Ads | `pull-meta-ads-mtd.ps1` (exists) | append step | Pending Phase C |
| GA4 | `pull-ga4-7d.ps1` (exists) | append step | Pending Phase D |

---

## Phase B setup — HubSpot private app + first pull

### 1. Create the HubSpot private app (~5 min)

1. HubSpot -> **Settings** (gear, top-right)
2. Left sidebar: **Integrations -> Private Apps**
3. **Create a private app**
   - Name: `CWDB Warehouse Pull`
   - Description: `Read-only daily snapshot of contacts, deals, companies for the analytics warehouse.`
4. **Scopes** tab — check these (Read only):
   - `crm.objects.contacts.read`
   - `crm.objects.deals.read`
   - `crm.objects.companies.read`
   - `crm.schemas.contacts.read`
   - `crm.schemas.deals.read`
5. Click **Create app** -> Continue creating
6. The **Access token** is shown ONCE. Copy it immediately.
7. Paste into `.env.local`:
   ```
   HUBSPOT_PRIVATE_APP_TOKEN=pat-na1-...
   ```

### 2. Run the loader (dry-run first)

```powershell
# Dry-run: pulls + writes JSON snapshot but skips Supabase write
.\templates\scripts\pull-hubspot-snapshot.ps1 -DryRun

# Inspect the local snapshot
Get-Content _vault\data\hubspot-latest.json | ConvertFrom-Json | Select-Object pulled_at, source, error
(Get-Content _vault\data\hubspot-latest.json | ConvertFrom-Json).data.contact_count
(Get-Content _vault\data\hubspot-latest.json | ConvertFrom-Json).data.deal_count
```

If counts look right, run for real:

```powershell
.\templates\scripts\pull-hubspot-snapshot.ps1
```

Expected console output:
```
Pulling HubSpot contacts...
  -> N contacts
Pulling HubSpot deals...
  -> N deals
Pulling HubSpot companies...
  -> N companies
Wrote _vault\data\hubspot-latest.json
Upserted N rows into raw_hubspot_snapshot
Upserted 2 rows into dim_contractor
hubspot pull OK: contacts=N deals=N companies=N
```

### 3. Verify in Supabase

In Supabase SQL Editor:

```sql
SELECT COUNT(*) FROM raw_hubspot_snapshot;
SELECT * FROM dim_contractor;
-- Should see Ben Barton + John Garcia
SELECT object_type, COUNT(*) FROM raw_hubspot_snapshot GROUP BY object_type;
```

### 4. Re-run idempotency check

Run `.\templates\scripts\pull-hubspot-snapshot.ps1` a second time. `dim_contractor` row count should not double (UPSERT on `hubspot_contact_id`). `raw_hubspot_snapshot` row count grows by one snapshot worth — each captured_at is a new point-in-time, by design.

---

## Backfill

One-time `--all-history` pull on first install:

```powershell
.\templates\scripts\backfill-supabase.ps1 -Source all
# or per-source:
.\templates\scripts\backfill-supabase.ps1 -Source hubspot
```

Idempotent: re-running does not duplicate rows (every loader UPSERTs on the natural key).

---

## Retention

- **2 years detailed** then aggregate. Not implemented in v1 — revisit when `fact_ad_spend_daily` exceeds ~50K rows or storage approaches 400 MB.
- **Free tier limits:** 500 MB storage, 2 GB egress/mo. Current estimated burn at full scale (5 contractors, 50 leads/mo): <10 MB after 1 year.

---

## Schema versioning

- `schema/001_initial.sql` — v1 (this file)
- Future migrations live in `schema/002_*.sql`, `003_*.sql`, etc.
- Every migration must be additive (`CREATE`, `ALTER ... ADD`) where possible; destructive changes require a sibling backfill file.

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `permission denied for table fact_leads` | Used `SUPABASE_ANON_KEY` instead of `SUPABASE_SERVICE_ROLE_KEY` in an ingestion script |
| `duplicate key value violates unique constraint` | Two ingestion runs raced on the same natural key. Safe to ignore (UPSERT design absorbs it); investigate if persistent |
| `dim_date` query returns 0 rows after migration | Seed block was skipped because `BEGIN;` was committed early. Re-run just the `INSERT INTO dim_date...` block |
| View returns NULL for `cost_per_lead` | Either no spend OR no leads in that platform/month. Check `fact_ad_spend_daily` and `fact_leads` separately |

---

## Related files

- **Plan:** `C:\Users\jslog\.claude\plans\i-m-trying-to-consolidate-silly-spindle.md`
- **Schema:** `operations/data-warehouse/schema/001_initial.sql`
- **Views:** `operations/data-warehouse/views/001_views.sql`
- **Form spec (drives `fact_leads`):** `operations/leads/quote-form-fields.json`
- **HubSpot pipelines:** `operations/automation/hubspot-lead-pipeline.json`, `sales/crm/pipeline-stages.json`
- **Contractor profile spec:** `sales/onboarding/contractor-profile.json`
- **Existing pull scripts:** `templates/scripts/pull-*.ps1`
- **API credentials runbook:** `operations/automation/api-credentials/README.md`
