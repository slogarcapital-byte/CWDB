# QBO Production Cutover (2026-06-11)

Sandbox is connected and verified (INV-2026-001 pushed + idempotency proven).
The scripts now keep sandbox and production credentials side by side in
`.env.local` (`QBO_SANDBOX_*` and `QBO_PRODUCTION_*`); `QBO_ENVIRONMENT`
selects which set is active. Going live is the three steps below, and the
sandbox connection survives untouched for future testing.

## Step 1: Jim, get the Production keys (Intuit portal, ~10 min)

1. Sign in at developer.intuit.com (same Intuit account that owns the live
   QBO company) and open the **CWDB Books Integration** app.
2. Open **Keys & credentials > Production**. If Intuit asks you to complete
   the production questionnaire / compliance form first, do it (app purpose:
   internal accounting automation for our own QBO company; no third-party
   users; scope com.intuit.quickbooks.accounting only).
3. Confirm the redirect URI `http://localhost:8000/callback` is listed for
   the app (production uses the same redirect list).
4. Copy the **Production** Client ID and Client Secret into `.env.local` at
   the repo root as two new lines (never commit this file):
   - `QBO_PRODUCTION_CLIENT_ID=...`
   - `QBO_PRODUCTION_CLIENT_SECRET=...`

## Step 2: One-time authorization against the LIVE company (with Claude, ~3 min)

Run:

```powershell
pwsh templates/scripts/qbo-authorize.ps1 -Environment production
```

Open the printed URL, sign in, and on the consent screen pick the REAL
company: **Central Wisconsin Deck Builders** (realm 9341457249522270), NOT
the sandbox company. The script writes `QBO_PRODUCTION_REFRESH_TOKEN` +
`QBO_PRODUCTION_REALM_ID` and verifies with a CompanyInfo read; success looks
like `CONNECTED: Central Wisconsin Deck Builders (realm 9341457249522270,
env production)`.

## Step 3: Flip the switch

Set `QBO_ENVIRONMENT=production` in `.env.local`. Every qbo-* script now
talks to the live company. To test against the sandbox afterwards, flip it
back temporarily (tokens for both environments stay valid; each refresh
token rotates independently under its own key).

## Notes

- INV-2026-001 was entered manually in the live company by Jim on
  2026-06-11. `push-qbo-invoice.ps1` is idempotent on DocNumber, so pushing
  its JSON after cutover will detect the existing invoice and skip: no
  duplicate risk.
- Refresh-token rotation: the scripts write the rotated token back to the
  active environment's key automatically. The 100-day rolling window means
  any script run (or future daily cron) keeps the chain alive.
- First post-cutover task for the accounting agent: audit the live chart of
  accounts and existing transactions before posting anything (see
  `~/.claude/agent-memory/accounting/qbo-integration.md`).
