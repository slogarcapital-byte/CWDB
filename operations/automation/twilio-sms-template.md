---
type: reference
status: active
created: 2026-04-04
updated: 2026-04-16
tags:
  - type/reference
  - dept/operations
---

# Twilio SMS — API Call Template for Claude RemoteTrigger

Used by the CWDB lead routing agent to send SMS notifications to contractors on each qualified lead.

---

## Environment Variables

Set these in Claude Code → Settings → Environment before the RemoteTrigger goes live.

| Variable | Description | Example |
|---|---|---|
| `TWILIO_ACCOUNT_SID` | Account SID from Twilio Console (starts with `AC`) | `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `TWILIO_AUTH_TOKEN` | Auth Token from Twilio Console | `your_auth_token_here` |
| `TWILIO_FROM_NUMBER` | Your Twilio phone number in E.164 format | `+17155550000` |

**Never hardcode credentials in any file. Use environment variables only.**

---

## API Endpoint

```
POST https://api.twilio.com/2010-04-01/Accounts/{ACCOUNT_SID}/Messages.json
```

Authentication: HTTP Basic Auth — Account SID as username, Auth Token as password.

---

## Bash / curl Command

The lead routing agent uses the Bash tool with this exact pattern:

```bash
curl -s -X POST \
  "https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json" \
  --user "${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}" \
  --data-urlencode "From=${TWILIO_FROM_NUMBER}" \
  --data-urlencode "To=+17155550123" \
  --data-urlencode "Body=New deck lead: Test User, Wausau WI 54401. Budget: \$10K-\$20K. Call: (715) 555-0001. -CWDB"
```

Replace `To` with the contractor's phone in E.164 format and `Body` with the actual message.

---

## SMS Message Format — Qualified Lead Notification

Keep under 160 characters to avoid multi-part SMS billing:

```
New deck lead: [HOMEOWNER_NAME], [CITY] WI [ZIP].
Budget: [BUDGET_SHORT]. Call: [PHONE]. -CWDB
```

Example (157 chars):
```
New deck lead: Sarah Johnson, Wausau WI 54401. Budget: $10K-$20K. Call: (715) 555-0001. -CWDB
```

Budget shorthand mapping:
- "Under $5,000" → `<$5K`
- "$5,000 – $10,000" → `$5K-$10K`
- "$10,000 – $20,000" → `$10K-$20K`
- "$20,000 – $40,000" → `$20K-$40K`
- "$40,000+" → `$40K+`

---

## Phone Number Normalization (E.164)

Contractor phones from HubSpot may arrive in various formats. Before calling the API:

1. Strip all non-digit characters: `(715) 555-0123` → `7155550123`
2. If 10 digits → prepend `+1`: `7155550123` → `+17155550123`
3. If 11 digits starting with `1` → prepend `+`: `17155550123` → `+17155550123`
4. Any other length → skip SMS for that contractor and log a warning

---

## Success Response

Twilio returns HTTP 201 with JSON. A successfully queued message:

```json
{
  "sid": "SMxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "status": "queued",
  "to": "+17155550123",
  "from": "+17155559999",
  "body": "New deck lead: Sarah Johnson..."
}
```

Check for `"status": "queued"` or `"status": "sent"` to confirm success.

---

## Error Handling

| HTTP Code | Meaning | Action |
|---|---|---|
| 201 | Success — message queued | Continue pipeline |
| 400 | Bad request (invalid phone, missing field) | Log error, skip SMS for this contractor, continue |
| 401 | Invalid credentials | Log error, skip all SMS, flag in admin email |
| 429 | Rate limited | Log error, continue (lead is not dropped) |

SMS failure should **never** abort the lead routing pipeline. Log all errors in the execution summary (Step 5 of lead-routing-prompt.md).

---

## Testing Before Go-Live

Use Twilio test credentials to validate the integration without sending real SMS:

1. In Twilio Console → get your **Test Account SID** and **Test Auth Token**
2. Use magic numbers:
   - `To`: `+15005550006` — always succeeds in test mode
   - `From`: `+15005550006` — always valid in test mode
3. Messages sent to magic numbers appear in Twilio logs but are never actually delivered

After confirming the curl call returns HTTP 201 with test credentials, swap in live credentials.

---

## Twilio Console Links

- Dashboard: https://console.twilio.com
- Sent message logs: Console → Monitor → Messaging → Logs
- Phone numbers: Console → Phone Numbers → Manage → Active Numbers
