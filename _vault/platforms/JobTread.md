# JobTread

**Role:** Jobs platform (estimating, proposals + e-sign, scheduling, job costing, native QBO sync). Adopted 2026-07-13 per `operations/analysis/jobtread-setup-design.md` (accelerated hybrid; HubSpot stays top-of-funnel until cutover).

## Identifiers

- **Org:** Central Wisconsin Deck Builders, id `22PakakWzKDv`
- **Grant:** `cwdb-warehouse` (created at app.jobtread.com/grants; key in `.env.local` as `JOBTREAD_GRANT_KEY`, mirrored as an Edge Function secret)
- **Webhook:** id `22Paua4QmSjs` → `jobtread-gateway/webhook` (token-authed URL; re-register idempotently via `templates/scripts/register-jobtread-webhook.ps1`)
- **AI Connector MCP:** `https://api.jobtread.com/mcp` (Claude Code HTTP server `jobtread`; optional claude.ai custom connector)

## Integration surfaces

| Surface | What | Where |
|---|---|---|
| Edge Function | `jobtread-gateway` (Supabase, project `iabiwsbmnbxmkjvkgfhg`): `/intake` dual-write (JobTread + HubSpot + bronze), `/webhook` event log + Signed/Booked fan-out | `operations/data-warehouse/functions/jobtread-gateway/index.ts` |
| Daily pull | source #5 `jobtread` in `run-daily.ps1`; bronze `raw_jobtread_snapshot` | `templates/scripts/pull-jobtread-snapshot.ps1` |
| Conversion worker | source #6 `google_conv`; uploads `conversions_outbox` pending rows as Google offline conversions | `templates/scripts/push-google-offline-conversions.ps1` |
| Org config | idempotent field/stage/cost-code setup | `templates/scripts/setup-jobtread-org.ps1` |
| Schema prototype | live Pave validation + field dump | `templates/scripts/test-pave-query.ps1` |
| Relay | Webflow form → `/intake` | `website/scripts/cwdb_intake_relay-2.0.0.js` |

## Secrets inventory (names only)

- `.env.local`: `JOBTREAD_GRANT_KEY`, `JOBTREAD_ORG_ID`, `JT_WEBHOOK_TOKEN`, `SUPABASE_PUBLISHABLE_KEY`
- Edge Function secrets: `JOBTREAD_GRANT_KEY`, `JOBTREAD_ORG_ID`, `JT_WEBHOOK_TOKEN` (+ `GA4_MEASUREMENT_ID`, `GA4_API_SECRET` when GA4 fan-out enabled)
- Google conversion action: `GOOGLE_ADS_JT_CONVERSION_ACTION` in `.env.local`

## Platform facts (hard-won; see `operations/jobtread/org-setup-notes.md` for the full Pave schema list)

- Customers are **accounts** (`type` customer|vendor); jobs hang off **locations**; contact phone/email are custom fields.
- Job stages = options on the job `Status` custom field (10-stage funnel; stage 6 exactly `Signed / Booked`).
- Account names UNIQUE, all entity names capped at 30 chars (gateway retries/truncates).
- Pave pages 413 above ~size 25 with nested custom-field connections.
- Webhook payload: `createdEvent.{id,type,job.id,data.next.custom.Status,data.previous.custom.Status}`.
- AI Connector writes are immediate, NO undo: draft-then-confirm for anything customer-visible.

## Rollback (design §9)

Repoint the Webflow relay to `api.hsforms.com` (re-apply `hubspot_form_relay-1.0.0.min.js`), unregister the webhook, remove sources #5/#6 from `run-daily.ps1`, drop migration 015 objects (nothing references them), cancel JobTread, resume Streamlit estimator. HubSpot receives every lead throughout via dual-write, so the funnel never notices.
