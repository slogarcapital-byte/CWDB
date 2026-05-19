# Ad-Platform API Credentials Setup (Jim's runbook)

This is the one-time credentials setup that unlocks the daily auto-pull of Google Ads, Meta, and GA4 metrics into the morning brief. Total time: **~50-70 minutes hands-on + 24-72 hour wait on Google Ads dev token approval**. Saves 5+ minutes every morning forever after.

The agent has already scaffolded the three pull scripts, the cron job, the brief integration, and this runbook. Your job is creating credentials and pasting them into `.env.local`.

## Prereqs

1. Copy `templates/scripts/.env.example` to `.env.local` at the repo root:
   ```powershell
   Copy-Item templates\scripts\.env.example .env.local
   ```
2. Open `.env.local` in your editor. You will paste values into it as you complete each section.
3. Confirm `.env.local` is gitignored:
   ```powershell
   git check-ignore -v .env.local
   ```
   Expected output: a hit on the `.env.local` rule. If nothing returns, STOP and add it before pasting any secrets.

---

## 1. Google Ads API (~30-45 min hands-on, plus 24-72 hour wait)

### 1a. Apply for a Developer Token

1. Sign into the **CWDB-dedicated** Google Ads account at https://ads.google.com (verify the account selector top-right reads "Central Wisconsin Deck Builders" — see memory `feedback-account-identity-verification.md`).
2. Tools (wrench icon) -> Setup -> **API Center**.
3. Read and accept the API Terms.
4. Apply for **Test Access** first (instant). Test access works against your own account. Standard access (~24-72 hour review) is only required if we ever query other accounts; for CWDB-only Standard is not strictly needed but is recommended once approved.
5. Copy the developer token shown on the API Center page into `.env.local` as:
   ```
   GOOGLE_ADS_DEVELOPER_TOKEN=...
   ```

### 1b. Create an OAuth2 client in Google Cloud

1. Open https://console.cloud.google.com/ in the **same Google identity** that owns the Google Ads account.
2. Top bar -> project picker -> **New Project** -> name it `cwdb-ads-pull`.
3. Left nav -> APIs & Services -> Library -> search "Google Ads API" -> **Enable**.
4. Left nav -> APIs & Services -> OAuth consent screen.
   - User Type: **External**.
   - App name: `CWDB Ads Pull`. User support email: yours. Developer contact: yours.
   - Scopes: skip / save and continue.
   - Test users: add your Google identity.
   - Save.
5. Left nav -> APIs & Services -> Credentials -> **+ Create Credentials** -> **OAuth client ID**.
   - Application type: **Desktop app**.
   - Name: `cwdb-ads-pull-desktop`.
   - Create.
6. The dialog shows Client ID and Client Secret. Paste both into `.env.local`:
   ```
   GOOGLE_ADS_CLIENT_ID=...
   GOOGLE_ADS_CLIENT_SECRET=...
   ```

### 1c. Generate a refresh token (one-time consent)

PowerShell at the repo root:

```powershell
$ClientId     = $env:GOOGLE_ADS_CLIENT_ID
$ClientSecret = $env:GOOGLE_ADS_CLIENT_SECRET
$Scope        = "https://www.googleapis.com/auth/adwords"
$Redirect     = "http://localhost:8765/"

# 1. Open the consent URL in your browser
$AuthUrl = "https://accounts.google.com/o/oauth2/v2/auth" +
           "?client_id=$ClientId&redirect_uri=$Redirect&response_type=code" +
           "&scope=$Scope&access_type=offline&prompt=consent"
Start-Process $AuthUrl

# 2. After consent, your browser redirects to http://localhost:8765/?code=4/0Aef...
#    The page will fail to load (expected). Copy the FULL `code=...` value from the URL bar.
$Code = Read-Host "Paste the code from the redirect URL"

# 3. Exchange the code for a refresh token
$resp = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/token" `
    -Body @{ code = $Code; client_id = $ClientId; client_secret = $ClientSecret;
             redirect_uri = $Redirect; grant_type = "authorization_code" } `
    -ContentType "application/x-www-form-urlencoded"
$resp.refresh_token
```

Paste the printed refresh token into `.env.local`:
```
GOOGLE_ADS_REFRESH_TOKEN=...
```

### 1d. Confirm customer IDs

`GOOGLE_ADS_CUSTOMER_ID=7129910870` is already set (CWDB account 712-991-0870). If a Manager (MCC) account fronts CWDB, also fill `GOOGLE_ADS_LOGIN_CUSTOMER_ID` with the MCC ID (digits only). If no MCC, leave blank.

### 1e. Test

```powershell
.\templates\scripts\pull-google-ads-mtd.ps1
Get-Content _vault\data\google-ads-latest.json
```

Expected: `data` block populated, `error: null`. Pre-launch we may see a 401 if the dev token is still in review; the script will write the error to `_vault/data/google-ads-error.log` and the brief skill will flag it.

---

## 2. Meta Marketing API (~10 min)

### 2a. Confirm Business Manager + ad account

1. Open https://business.facebook.com and confirm the **Central Wisconsin Deck Builders** business is selected (top-left). Refer to memory `feedback-account-identity-verification.md`.
2. Note the ad account ID: Ad Accounts panel -> "Ad Account ID" (digits only). Paste into `.env.local`:
   ```
   META_AD_ACCOUNT_ID=...
   ```

### 2b. Create a System User + token

1. Business Settings -> Users -> **System Users** -> **Add** -> name `cwdb-pull-bot` -> Role: Employee.
2. Click the new System User -> **Add Assets** -> Ad Accounts -> select CWDB -> Tasks: **Manage Campaigns** (read implies). Save.
3. Click **Generate New Token** -> select your Meta App (or create one named `cwdb-pull` under https://developers.facebook.com/apps if none exists, then return) -> Scopes: `ads_read` -> Generate.
4. **Copy the token immediately** — it is shown once. Paste into `.env.local`:
   ```
   META_ACCESS_TOKEN=...
   ```
   System User tokens default to non-expiring (no 60-day refresh dance).

### 2c. Test

```powershell
.\templates\scripts\pull-meta-ads-mtd.ps1
Get-Content _vault\data\meta-ads-latest.json
```

Expected pre-launch: zeros across the board with `error: null`. That confirms the auth path is good.

---

## 3. GA4 Data API (~15 min)

### 3a. Reuse the Google Cloud project

If you completed §1b, the `cwdb-ads-pull` project already exists. Otherwise create it.

### 3b. Enable the Google Analytics Data API

1. https://console.cloud.google.com/ -> project `cwdb-ads-pull` -> APIs & Services -> Library.
2. Search "Google Analytics Data API" -> **Enable**.

### 3c. Create a Service Account + key

1. APIs & Services -> Credentials -> **+ Create Credentials** -> **Service account**.
2. Name: `cwdb-ga4-reader`. Skip role grants (the role we need is on the GA4 property, not GCP). Done.
3. Click the new service account -> **Keys** -> **Add Key** -> **Create new key** -> **JSON** -> Create. The JSON downloads.
4. Move the file out of Downloads to a stable location, e.g. `%USERPROFILE%\.cwdb\ga4-sa.json`. **Do not place it in the repo.**
5. Open the JSON in a text editor and copy the `client_email` value (looks like `cwdb-ga4-reader@cwdb-ads-pull.iam.gserviceaccount.com`).
6. Paste the absolute path into `.env.local`:
   ```
   GA4_SERVICE_ACCOUNT_JSON=C:\Users\jslog\.cwdb\ga4-sa.json
   ```

### 3d. Grant the service account access to the GA4 property

1. Open https://analytics.google.com -> Admin (gear, bottom-left) -> select the **Central Wisconsin Deck Builders** account (391847241) -> property `533582902`.
2. Property column -> **Property Access Management** -> `+` -> Add users.
3. Email: paste the `client_email` from §3c step 5. Role: **Viewer**. Save.

### 3e. Test

```powershell
.\templates\scripts\pull-ga4-7d.ps1
Get-Content _vault\data\ga4-latest.json
```

Expected: real numbers (sessions / users / conversions / topChannel) from the last 7 days.

---

## 4. Wire-up verification

After all three scripts pass:

```powershell
# Run all three
.\templates\scripts\pull-google-ads-mtd.ps1
.\templates\scripts\pull-meta-ads-mtd.ps1
.\templates\scripts\pull-ga4-7d.ps1

# Confirm all three JSON files are fresh
Get-ChildItem _vault\data\*-latest.json | Select-Object Name, LastWriteTime
```

Then trigger `/brief` — the Live Data Tables section should render auto-populated rows for all three platforms with the current `pulled_at` timestamp. If any source is older than 24 hours when `/brief` runs, the brief flags it visibly with `WARNING STALE`.

## 5. Daily cron

A CronCreate task fires at 6:55 AM Central daily and runs all three scripts. The cron is registered automatically by the CEO operator session that built this runbook (see `[WB-011]` in `_vault/board/in-flight.md` for cron job ID). Cron expression: `55 6 * * *`.

## 6. Rotating / revoking credentials

- **Google Ads refresh token:** revoke at https://myaccount.google.com/permissions -> remove "CWDB Ads Pull". Re-run §1c.
- **Meta System User token:** Business Settings -> System Users -> select bot -> tokens tab -> Revoke. Re-run §2b step 3.
- **GA4 service account:** Cloud Console -> IAM -> Service Accounts -> select `cwdb-ga4-reader` -> Keys -> rotate. Re-download JSON, update `GA4_SERVICE_ACCOUNT_JSON` path.

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| Google Ads: `DEVELOPER_TOKEN_NOT_APPROVED` | Wait for the 24-72h Standard access review, or run against the test account first. |
| Google Ads: `USER_PERMISSION_DENIED` | The OAuth identity doesn't have access to customer 7129910870. Re-do §1c with the right Google identity. |
| Meta: `(#100) Object does not exist` | Wrong `META_AD_ACCOUNT_ID`. Drop the `act_` prefix — the script adds it. |
| GA4: `PERMISSION_DENIED` | The service-account `client_email` is not added as Viewer on property 533582902. Re-do §3d. |
| Brief flags `WARNING STALE` | The cron didn't run (laptop was off / asleep at 6:55 AM) OR a token expired. Check `_vault/data/<source>-error.log`. |
