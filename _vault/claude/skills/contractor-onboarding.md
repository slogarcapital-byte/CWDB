---
name: contractor-onboarding
description: Generate and DocuSign-send a Contractor Lead Purchase Agreement for a new CWDB contractor. Use whenever a contractor needs to be onboarded or an agreement needs to be generated and sent.
when_to_use: Any time a new contractor is being onboarded, or an agreement needs to be generated and sent for signature for an existing contractor.
---

# Contractor Onboarding — CWDB

Generates a filled Contractor Lead Purchase Agreement PDF from HubSpot contact data and sends it for e-signature via DocuSign. Agreements are saved to `sales/contractor-agreements/`.

---

## Stored Config

```
DocuSign User ID:       265ec01f-b037-4eae-b96d-0fdebec59723
DocuSign Account ID:    07a2f8c5-1951-4d6d-baab-0c45359ab80e  (GUID — use this in API calls)
DocuSign Base URL:      https://na4.docusign.net/restapi/v2.1/accounts/07a2f8c5-1951-4d6d-baab-0c45359ab80e/envelopes
PDF Generator:          docs/legal/generate_agreement_pdf.py  →  generate_pdf(contractor, output_path)
Send Script:            sales/contractor-agreements/generate_and_send.py
Agreement Log:          sales/contractor-agreements/log.md
HubSpot Contact IDs:
  Ben Barton            462464338657
  John Garcia           465926077160
```

---

## Required HubSpot Contact Properties

All 8 fields must be present before generating an agreement. Map to the `contractor` dict as shown:

| HubSpot property | contractor dict key | Example value |
|---|---|---|
| `firstname` + `lastname` | `contact_name` | "Ben Barton" |
| `company` | `name` | "Barton Builders LLC" |
| `entity_type` (custom) | `entity_type` | "LLC" |
| `address` | `street` | "123 Main St" |
| `city` | `city` | "Wausau" |
| `state` | `state` | "WI" |
| `zip` | `zip` | "54401" |
| `jobtitle` | `contact_title` | "Owner" |
| `email` | `contact_email` | "ben@example.com" |

---

## Step-by-Step Workflow

### Step 1 — Confirm HubSpot fields

```
Tool:   mcp__claude_ai_HubSpot__get_crm_objects
Params: {
  "objectType": "contacts",
  "objectId": "<contact_id>",
  "properties": ["firstname","lastname","company","entity_type","address","city","state","zip","jobtitle","email"]
}
```

Check all 9 properties are non-empty. If any are missing → **stop and tell the user which fields to add in HubSpot before proceeding**.

### Step 2 — Ask for effective date

If the user hasn't specified one, ask: "What effective date should appear on the agreement? (e.g. April 10, 2026)"

### Step 3 — Build contractor JSON

Assemble the dict from HubSpot properties:
```json
{
  "name": "<company>",
  "entity_type": "<entity_type>",
  "street": "<address>",
  "city": "<city>",
  "state": "<state>",
  "zip": "<zip>",
  "contact_name": "<firstname> <lastname>",
  "contact_title": "<jobtitle>",
  "contact_email": "<email>"
}
```

### Step 4 — Dry run (verify PDF)

```
Tool: Bash
Command: cd sales/contractor-agreements && python generate_and_send.py \
  --contractor-json '<json>' \
  --effective-date "<date>" \
  --dry-run
```

Confirm the PDF was created and open it to verify all fields filled correctly.

### Step 5 — Send to DocuSign

Ensure environment variables are set, then run without `--dry-run`:

```powershell
$env:DOCUSIGN_ACCOUNT_ID  = "07a2f8c5-1951-4d6d-baab-0c45359ab80e"
$env:DOCUSIGN_ACCESS_TOKEN = "<token from DocuSign Admin > Apps & Keys>"
```

```
Tool: Bash
Command: cd sales/contractor-agreements && python generate_and_send.py \
  --contractor-json '<json>' \
  --effective-date "<date>"
```

### Step 6 — Confirm and log

- Report the DocuSign envelope ID to the user
- Confirm the row was appended to `sales/contractor-agreements/log.md`
- Tell the user to watch for the signed copy in DocuSign

---

## Generating Access Tokens

DocuSign access tokens are short-lived. To generate one:
1. Log in to DocuSign Admin at `account.docusign.com`
2. Go to **Apps & Keys**
3. Under your integration app, click **Generate Token** (or use **OAuth Sandbox** for dev/test)
4. Copy the token and set `$env:DOCUSIGN_ACCESS_TOKEN` before running

Store the token as a PowerShell session variable only — **never write it to a file or commit it**.

---

## Rules

- **Never hardcode credentials** — always use env vars (`DOCUSIGN_ACCOUNT_ID`, `DOCUSIGN_ACCESS_TOKEN`)
- **Always dry-run first** — verify the PDF looks correct before sending
- **Missing HubSpot fields = stop** — do not generate a partial or placeholder agreement; tell the user what's missing
- **Log every send** — `log.md` is the authoritative record of what was sent and when
- **One agreement per contractor per date** — if re-sending, check the log first to avoid duplicates
- **Save PDFs to `sales/contractor-agreements/`** — never to `docs/legal/` (that's for the template only)
