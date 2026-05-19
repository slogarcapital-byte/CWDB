# Ad-platform API auto-pull architecture (Phase 2b, 2026-05-05)

**Pattern this memory documents:** how the CEO replaces manual MTD-paste rituals with daily-scheduled scripted API pulls.

## Why this exists

Pre-2026-05-05, every morning Jim manually pulled Google Ads MTD numbers and pasted them into the brief. Meta + GA4 had similar friction. ~5 min/day forever. CEO was lagging Jim because the brief couldn't auto-populate the Live Data Tables block — agent had no source-of-truth for spend/clicks/conv.

Phase 2b inverts that: ~2 hour one-time credential setup -> three PowerShell scripts -> cron at 6:55 AM Central -> JSON snapshots in `_vault/data/` -> `/brief` reads them (already wired since Phase 1.6 of brief skill).

## Files

- `templates/scripts/pull-google-ads-mtd.ps1` — REST against Google Ads API v18 GAQL `customer` level, MTD.
- `templates/scripts/pull-meta-ads-mtd.ps1` — REST against Marketing API `act_<id>/insights` at `account` level, time_range=MTD.
- `templates/scripts/pull-ga4-7d.ps1` — Google Service Account JWT -> access token -> Data API `runReport` on property 533582902, last 7 days.
- `templates/scripts/.env.example` — schema for `.env.local` (gitignored already).
- `operations/automation/api-credentials/README.md` — Jim's credentials runbook.

## Output schema (canonical, all three scripts)

```json
{
  "pulled_at": "2026-05-05T11:55:03.123Z",
  "source": "google-ads | meta-ads | ga4",
  "data": { ...platform-specific metrics... },
  "error": null
}
```

On failure: `data: null`, `error: <string>`, also appended to `_vault/data/<source>-error.log`. The script always writes a stub JSON even on failure so `/brief` can read `error` and surface it explicitly rather than going silent.

## Auth patterns (lift these for any future Google Cloud / ad-platform integration)

| Platform | Auth flow | Token shape | Refresh need |
|---|---|---|---|
| Google Ads | OAuth2 user-consent -> refresh token | refresh_token + dev_token + login_customer_id headers | Refresh exchange every run (1h access token) |
| Meta | System User long-lived token | Single `access_token` query param | None — System User tokens are non-expiring |
| GA4 Data API | Service Account JWT (`urn:ietf:params:oauth:grant-type:jwt-bearer`) | Bearer access token from JWT exchange | Mint fresh JWT every run (1h access token) |

GA4 JWT signing in PowerShell uses `[System.Security.Cryptography.RSA]::Create()` + `ImportFromPem()` — works on .NET 4.7.2+ (Win 10/11 default) without any external SDK. This is the cleanest pure-PowerShell Google Service Account auth path.

## Idempotency

Every script overwrites `_vault/data/<source>-latest.json` on success. Re-running mid-day is safe — it just refreshes the snapshot. The cron is the canonical writer; manual runs by Jim or a specialist agent can also write the same file without contention.

## Cron

Job ID `4d213bd3` registered 2026-05-05 via CronCreate at `55 6 * * *` (America/Chicago). Prompt: run all three scripts and report.

**Caveat learned during 2b build:** Even with `durable: true` requested, the CronCreate tool reported the job as session-only with a 7-day auto-expiry. This means:
- The schedule will fire while this Claude session is alive and idle
- It will NOT survive `claude` CLI restart
- It auto-expires after 7 days regardless

**Re-registration cadence:** Until a durable scheduling primitive lands, the CEO operator must re-register this cron at the start of each new long-running session OR migrate to a Windows Task Scheduler entry that calls the three `.ps1` scripts directly (no Claude required). The latter is the more robust path long-term.

Windows Task Scheduler equivalent (for Jim to run once if Claude-cron proves too fragile):
```powershell
$action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-NoProfile -File "C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\templates\scripts\pull-google-ads-mtd.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 6:55am
Register-ScheduledTask -TaskName "CWDB-Pull-GoogleAds" -Action $action -Trigger $trigger -RunLevel Limited
# Repeat for the other two scripts
```

## Brief skill integration

`.claude/commands/brief.md` step 3 already reads the three JSON files, checks `pulled_at` age, and flags stale (>24h) or missing data. No changes needed in 2b. Phase 1.6 had pre-wired this — verified during 2b build.

## Failure-mode catalog

| Failure | Symptom in brief | Recovery |
|---|---|---|
| Cron didn't fire (laptop asleep) | `WARNING STALE: <file> last pulled <yesterday>` | Re-run scripts manually or wait for next cron |
| API token expired | `error` field populated; `_vault/data/<src>-error.log` has stack | Rotate per README §6 |
| Pre-launch (zero spend on Meta) | `data` populated with zeros, `error: null` | No action — expected |
| Dev token still in review (Google) | `DEVELOPER_TOKEN_NOT_APPROVED` in error log | Wait or use Test Access |

## Pattern for future platforms

When adding TikTok / Nextdoor / LinkedIn:

1. Drop a new `pull-<platform>-mtd.ps1` matching the canonical output schema above.
2. Add env vars to `.env.example`.
3. Document credentials in `operations/automation/api-credentials/README.md` as a new section.
4. Update brief skill step 3 to include the new file.
5. Update cron prompt to include the new script.

The architecture is platform-agnostic — only auth flows differ.
