---
name: ga4-sa-admin-api-grant
description: "GA4 Property Access Management UI rejects service-account emails (\"doesn't match a Google Account\"). Use the Admin API to grant access directly via templates/scripts/grant-ga4-access.ps1."
metadata: 
  node_type: memory
  type: reference
  originSessionId: 404f1392-d53e-44a3-af3d-b957e6233c84
---

GA4's user-management UI (`suiteusermanagement` endpoint) calls Google Workspace identity validator, which doesn't recognize service-account emails as valid principals. Rejects with "This email doesn't match a Google Account" regardless of whether you try Property-level or Account-level grants, in incognito, or with a personal Gmail.

**The fix:** call the Analytics Admin API directly. The same endpoint the UI uses, but with an OAuth user token and IAM-grade identity validation — skips the Workspace validator entirely.

**Script:** `templates/scripts/grant-ga4-access.ps1` (built 2026-06-02).

**Critical gotchas hit during dev (don't re-derive):**
- The endpoint is **`v1alpha`**, not `v1beta`. The accessBindings methods stayed in alpha when the rest of the Analytics Admin API was promoted to beta. v1beta returns generic Google 404 HTML page.
- Body MUST go via curl's **`--data-binary @file`** with a temp file. PowerShell 5.1 strips inner JSON quotes during native-command arg escaping (`& curl -d $jsonstring`); Google sees `{ user: ... }` instead of `{ "user": "..." }` and returns 400 INVALID_ARGUMENT. Writing the body to a temp file and using `@file` syntax bypasses PS arg encoding.
- Requires **Analytics Admin API enabled** in the GCP project (separate from Data API — both must be enabled in `cwdb-ads-pull`).
- The script reuses Google Ads OAuth client (`GOOGLE_ADS_CLIENT_ID` / `SECRET`) — OAuth clients aren't scope-bound at creation, so the existing client works for new scopes via fresh consent. Scope requested: `https://www.googleapis.com/auth/analytics.manage.users`.

**Reuse:** any future GA4 property (expansion cities, new business accounts) will hit the same SA-email rejection. Re-run the script with `-PropertyId <new-id>` and `-PrincipalEmail <new-sa>` after granting Admin on the new property to your Google identity.

Related: [[phase-f-ids]] (Analytics Data API was enabled in Phase F), [[feedback-account-identity-verification]] (always verify which GCP project + Google identity you're operating in before granting).
