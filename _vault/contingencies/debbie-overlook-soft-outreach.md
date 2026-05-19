---
type: contingency
created: 2026-05-10
owner: jim (sends) + cwdb-ceo-operator (composed)
status: ready-to-send
related: _vault/contingencies/debbie-overlook-real-lead-playbook.md
---

# Debbie Overlook — Soft Outreach Templates

## Why this exists

Debbie Overlook submitted a quote request for **deck-repair**, **under-10k**, **asap**, **zip 54474** on 2026-05-08 19:13:15 UTC. Phone (715) 393-7145, email need@getemail.com. Two days have passed with no Jim confirmation that this was a smoke test. With each day of silence, the prior probability shifts toward "real homeowner sitting un-routed." A 30-second polite check-in falsifies the worst case cheaply: she replies (real lead, activate routing playbook), or it bounces / no-reply (fake or cold, close out).

## Jim sends, not CEO

CEO will NOT auto-send because:
1. **Email and phone unverified.** `need@getemail.com` looks suspicious (getemail.com is a known disposable email service); the phone is unverified. CEO does not have authority to fire outbound on unverified contacts.
2. **Outbound contact is reversibility-asymmetric.** A sent text or email cannot be unsent. Even if benign, the wrong tone or phrasing on a real homeowner could burn the lead.
3. **TCPA / Wisconsin compliance posture.** Form submission creates implied consent for follow-up about the requested service, but Jim should personally acknowledge the send (especially the SMS, which Wisconsin treats more strictly than email).

Jim copy-pastes one or both messages and hits send. Sender should be Jim's personal Gmail (`slogarjw@gmail.com`) for the email and Jim's personal cell for the SMS. CWDB business email (`info@cwdeckbuilders.com`) is still gated on WB-009 hosting decision.

## Text template (~50 words)

```
Hi Debbie, this is Jim from Central Wisconsin Deck Builders. Saw your
quote request for deck repair on Thursday. Wanted to check in - is
this still active? Happy to swing by this week to take a look and
give you a free estimate. Reply STOP to opt out.
```

Character count: 256 (fits in 2 SMS segments). Tone: professional, low-pressure, homeowner-direct. No marketing language. Mentions specific project type (deck repair) and submission timing (Thursday) so a real Debbie remembers the form. STOP language for TCPA hygiene.

## Email template

**To:** need@getemail.com
**From:** Jim Slogar (slogarjw@gmail.com)
**Subject:** Following up on your deck repair quote request

```
Hi Debbie,

This is Jim from Central Wisconsin Deck Builders. I saw your quote
request for deck repair come through our site on Thursday and wanted
to check in - is this still something you're looking to tackle?

If yes, happy to set up a free estimate this week. Just reply with
the best time and I'll have one of our builders (Ben or John) swing
by to take a look. Most repairs get a quote back within 48 hours.

If you've already moved forward with someone else, no worries - just
reply and I'll close out the request on our end.

Thanks,
Jim Slogar
Central Wisconsin Deck Builders
(715) 544-7941
cwdeckbuilders.com
```

Tone: matches the text. Adds the contractor names (Ben and John) for proof + the 48-hour quote promise from the homepage. Includes a graceful "if you've moved on" exit so a real Debbie who already hired someone replies rather than ignores.

## What to expect

| Outcome | Read | Next action |
|---|---|---|
| Debbie replies "yes still active" | **REAL LEAD** | Activate `_vault/contingencies/debbie-overlook-real-lead-playbook.md`. Route to Ben (primary) + John (secondary). Build deal in HubSpot at "Scheduled / Delivered to Contractor" stage 3610478272. |
| Debbie replies "already hired someone" or "not interested" | **REAL but cold** | Close out. Mark contact lifecycle stage `marketingqualifiedlead` → `other`. Add note. Move on. |
| SMS bounces or email bounces | **FAKE** (`need@getemail.com` was disposable, `(715) 393-7145` was invalid) | Close out. Mark contact `unqualified`. Add note "outreach bounced 2026-05-10". Move on. |
| No reply within 72 hours (by 2026-05-13 EOD) | **COLD or fake** | Close out. Mark contact `unqualified`. Add note. Move on. |

## Logging

When Jim sends, log to `_vault/board/shipped.md`:

```
- 2026-05-10 — Debbie soft outreach sent (text + email) — awaiting reply by 2026-05-13 EOD. Resolves Day 2 ambiguity. Real → activate `debbie-overlook-real-lead-playbook.md`. Bounce / no-reply → close out contact, mark unqualified.
```

Update WB-002 / WB-014 carry status as appropriate.

## Reversibility

- **Text:** sent from Jim's personal cell. Cannot be unsent. STOP language gives Debbie an exit.
- **Email:** sent from slogarjw@gmail.com. Can be deleted from sent folder but recipient already has it. No way to recall.
- **CRM impact:** none until Debbie replies. The HubSpot contact already exists and is unchanged by the outreach.

This outreach is **strictly recoverable** in the bounce/no-reply case and **strictly upside** in the real-lead case. The downside scenario is sending to a real homeowner who is annoyed by the follow-up — mitigated by the polite, low-pressure tone and the 2-day gap (not the same day).
