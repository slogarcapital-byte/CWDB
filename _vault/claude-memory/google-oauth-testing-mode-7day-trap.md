---
name: google-oauth-testing-mode-7day-trap
description: "Google Cloud OAuth apps in \"Testing\" mode cap refresh tokens at 7 days; symptom is invalid_grant 1 week after setup, mistakenly diagnosed as dev-token issue"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 28fa1d24-471e-48f0-bcac-c5c528656d3c
---

Google Cloud OAuth apps in **"Testing"** publishing status (the default after creating an External-type consent screen) issue **refresh tokens that expire after 7 days**, regardless of `access_type=offline` or any other setting. Pushing the app to **"In production"** removes this cap; refresh tokens then last indefinitely (subject to other Google rules).

**Symptom signature:**
- Script worked perfectly for ~7 days after `.env.local` setup, then started failing.
- POST to `https://oauth2.googleapis.com/token` (the refresh exchange) returns HTTP 400 with body `{"error":"invalid_grant","error_description":"Token has been expired or revoked."}`.
- If the calling script swallows the response body and only logs `Exception.Message`, you see `The remote server returned an error: (400) Bad Request` and easily misattribute to the downstream API (e.g. Google Ads `DEVELOPER_TOKEN_NOT_APPROVED`).

**CWDB recurrence history:**
- 2026-05-21: first 400 in `_vault/data/google-ads-warehouse-error.log`, days after `pull-google-ads-warehouse.ps1` was deployed.
- Commit 95ac556 (2026-06-03) misattributed the failure to "WB-011 dev-token issue, separate workstream."
- 2026-06-04: instrumented `pull-google-ads-warehouse.ps1` catch block to capture response body, ran once, saw `invalid_grant`. Published `cwdb-ads-pull` consent screen to "In production." Re-minted refresh token via README §1c. Pull succeeded: 2 campaigns / 2 ad groups / 2 ads / 49 spend rows UPSERTed. Dev token (Test access) was fine all along.

**Prevention:**
- `operations/automation/api-credentials/README.md` §1b step 5 now explicitly tells the operator to publish the app.
- For solo-dev sensitive-scope apps (e.g. `adwords`), publishing does NOT require Google verification. Users see a one-time "App isn't verified" warning during consent and click Advanced -> Go to (unsafe). Verification is only required for actual distribution.

**Recovery procedure when this fires again:**
1. Open `https://console.cloud.google.com/apis/credentials/consent?project=<project>`. If status reads "Testing," click PUBLISH APP first.
2. Re-run README §1c (consent URL -> paste code -> exchange for refresh token).
3. Write the new refresh token into `.env.local` (`GOOGLE_ADS_REFRESH_TOKEN=` or equivalent for other Google APIs).
4. Re-run the script.

**Applies to:** any Google OAuth integration in CWDB using `access_type=offline` with refresh tokens. Currently: Google Ads (pull-google-ads-warehouse.ps1, pull-google-ads-mtd.ps1). The GA4 path uses service-account auth, NOT OAuth user flow, so it is not affected by this rule.

Related: [[pivot-2026-04-19]] (Make scenario park), [[ga4-sa-admin-api-grant.md]] (parallel "Google UI rejects valid input" workaround).
