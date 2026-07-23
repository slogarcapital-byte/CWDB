# Decision: Warehouse Cron Stays Laptop-Coupled (with Logon Catch-Up Guardrail)

- **Date:** 2026-07-22
- **Decided by:** Jim (formal acceptance; audit item audit-2026-07-05#25, dashboard task 25)
- **Status:** ACCEPTED. No cloud move.

## Decision

The daily warehouse refresh (`\CWDB\CWDB-Warehouse-Daily`, 06:55 Central, running
`operations/data-warehouse/scripts/run-daily.ps1`) remains coupled to Jim's laptop.
We formally accept the failure mode that no refresh happens on days the laptop is
off at 06:55, and mitigate it with a catch-up guardrail instead of migrating the
pipeline to cloud infrastructure.

## Rationale

1. **Scale does not justify cloud plumbing.** Six sources, a ~1 to 3 minute total
   run, and a business currently operating at roughly 20 lifetime clean leads. A
   cloud runner (VM, GitHub Actions with secrets, or Supabase cron + edge rewrites
   of five PowerShell pulls) adds surface area, secret-distribution risk, and
   maintenance for near-zero freshness gain.
2. **The laptop is where the secrets already live.** `.env.local` OAuth tokens
   (Google Ads refresh token, HubSpot, Meta, GA4 service creds, QBO) are managed
   locally by design; the service-role Supabase key never leaves the laptop
   (cloud-twin rule, views/008-009). Moving the cron means moving the secrets.
3. **`StartWhenAvailable` already covers same-boot misses.** The remaining gap is
   only multi-day laptop-off windows, which the logon catch-up now closes at the
   next login.
4. **Staleness is visible, not silent.** `_vault/data/cron-runs.log` is scanned at
   session start, and the HQ dashboard reads live Supabase data whose `updated_at`
   betrays a stale pull.

## Guardrail shipped 2026-07-22

- **Task:** `\CWDB\CWDB-Warehouse-Catchup`, fires at user logon with a 3-minute
  delay (PT3M), runs `operations/data-warehouse/scripts/run-catchup.ps1`.
- **Logic:** parse `cron-runs.log` for the last `RUN_END` with `overall_exit=0`;
  if it is older than 24 hours (or absent), invoke `run-daily.ps1`; otherwise
  no-op. Skips if the daily task is mid-run. Every invocation appends a
  `CATCHUP  decision=<noop|run|skip_daily_running>` line to the same log.
- **Idempotent:** repeated logons in one day no-op; `MultipleInstances IgnoreNew`
  on the task prevents stacking.
- **Installer:** `operations/data-warehouse/scripts/install-catchup.ps1`
  (idempotent re-registration, mirrors install-cron.ps1 conventions).
- **Unlock trigger:** optional via `-IncludeUnlockTrigger`, NOT registered by
  default. Verified 2026-07-22 that registering a session-state-change (unlock)
  trigger returns Access denied from a non-elevated prompt, while logon triggers
  register fine. If Jim wants the unlock trigger, re-run the installer with the
  switch from an elevated PowerShell.
- **Acceptance test 2026-07-22:** manual run with last success 1.98h old logged
  `CATCHUP decision=noop` and exited 0 without invoking run-daily.ps1.

## Reopen triggers (conditions that put the cloud-decouple question back on the table)

Reopen the decision if ANY of the following occurs:

1. **Freshness starts costing money:** a same-day operational decision (ad-spend
   change, lead follow-up, offline-conversion push) is provably delayed or wrong
   because of a stale warehouse, twice in one month.
2. **Multi-day gaps become routine:** three or more distinct gaps of 48h+ between
   successful RUN_ENDs in any rolling 60-day window (grep `RUN_END` +
   `overall_exit=0` in cron-runs.log).
3. **The laptop stops being the natural home:** Jim goes full-time on the tools
   (SBG scenario) and the laptop is regularly off or offline during business days,
   or a second operator needs the warehouse without Jim's machine.
4. **A consumer needs sub-daily data:** Google offline-conversion upload windows,
   dashboard users, or an automation begin to require more than one refresh per
   day (intraday SLA).
5. **Secret architecture changes anyway:** if credentials move to a managed
   secret store for another reason, the main cost of cloud-hosting the cron
   disappears; re-evaluate opportunistically.

Until one of these fires, laptop-coupled + logon catch-up is the accepted
steady state.
