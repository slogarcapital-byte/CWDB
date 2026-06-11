# Google Voice + HubSpot: Recommendation Memo

**Date:** 2026-06-10 · **Author:** Claude (research agent) · **Number at stake:** (715) 544-7941 (printed on website, estimates, invoices, signage)

## Bottom Line

**Recommendation: Option A. Keep Google Voice, spend $0, and adopt a 2-minute logging discipline in HubSpot Starter.** At a few calls per week, every paid bridge is over-engineering, and the validation gate (2026-06-18) means we should not port the business number anywhere while a pivot or sunset is still on the table.

**Phased upgrade trigger:** when ANY of these fire, port (715) 544-7941 to OpenPhone (rebranded "Quo" in 2026) on the Business plan (~$23-33/mo) and complete A2P 10DLC registration under the LLC's EIN:
1. Validation gate passes (first accepted bid), or
2. Sustained ≥10 inbound calls/week (matches the existing 2026-04-19 routing reactivation trigger), or
3. Outbound texts from Google Voice start failing to deliver (carrier filtering of unregistered business SMS).

Porting out of Google Voice is low-risk and cheap ($3 unlock fee, number is preserved end to end), so deferring costs nothing.

## Comparison Table

| Option | Monthly cost | Keeps (715) 544-7941? | Calls logged in HubSpot | SMS from HubSpot | Migration friction | Verdict |
|---|---|---|---|---|---|---|
| **A. Keep GV + logging discipline** | $0 extra | Yes (unchanged) | Outbound: auto (HubSpot browser calling with GV as caller ID). Inbound: manual log | No (text from GV app, log manually) | None | **Pick now** |
| **B. HubSpot Calling / port number to HubSpot** | $0 extra (Starter incl. 500 outbound min + 1 HubSpot number, inbound supported) | Only via 2-4 week Twilio port; HubSpot becomes number owner | Yes, fully automatic | **No. Marketing SMS add-on ($75/mo) requires Marketing Hub Professional ($800/mo); not purchasable on Starter.** Porting would leave the number with NO texting | High (LOA, 2-4 wks, hard to reverse) | Rejected: kills SMS |
| **C. OpenPhone/Quo Business (best bridge)** | $23/user/mo annual, $33 monthly | Yes, port in ($3 GV unlock; porting included on all plans) | Yes, calls + texts auto-log via native HubSpot integration (Business plan and up) | Yes, after A2P 10DLC brand/campaign registration (EIN 41-5355234; small one-time + monthly carrier fees) | Moderate (port 1-2 wks, 10DLC approval days-weeks) | **Upgrade path at trigger** |
| C-alt. JustCall / Aircall / Kixie | JustCall $58/mo (2-seat min); Aircall $90/mo (3-seat min); Kixie ~$35/mo + minutes | Yes (porting supported) | Yes | Yes (same 10DLC requirement) | Moderate | Dominated by OpenPhone for a solo operator |
| **D. Direct GV integration** | n/a | Yes | No path exists: Google deprecated the Voice API; no Zapier/Make app, no webhooks. Workspace Voice tiers ($10-30/user + Workspace seat) add zero CRM integration | GV business texting now requires paid Workspace Voice + 10DLC anyway | n/a | Dead end |

## Why A over the others

- HubSpot Starter already includes ~500 outbound browser-calling minutes and lets Jim register the Google Voice number as a verified outbound caller ID (GV receives the verification call/text fine). Outbound calls placed from a contact record show (715) 544-7941 to the homeowner and log to the timeline automatically, with recording available.
- Option B's fatal flaw: HubSpot's native SMS is gated to Marketing Hub Professional. Porting the number into HubSpot on Starter would strand it with no texting at all, worse than today.
- Option C is the right answer later, not now: $276-396/yr plus 10DLC fees to automate logging of roughly 3 calls a week is not worth it pre-validation. OpenPhone/Quo beats JustCall (2-seat minimum), Aircall (3-seat minimum), and Kixie (per-minute charges) on solo-operator cost, and its HubSpot integration auto-logs both calls and texts.
- Option D: verified that no reliable direct integration exists in 2026. Voicemail-transcript email parsing is brittle (sender is Google, so HubSpot cannot match the email to the caller's contact record without a custom parser).

## Known risk to monitor (Option A)

Texting homeowners from a personal Google Voice number is application-to-person traffic that carriers expect to be 10DLC-registered; since Feb 2025 carriers silently drop unregistered business SMS. At conversational volume this mostly still delivers, but treat any delivery failures as trigger #3 above. Keep texts low-volume, conversational, and reply-driven.

## Setup Steps (Option A, ~30 minutes once)

1. **Register GV number for outbound calling in HubSpot:** Settings → General → Calling → Register a phone number → enter (715) 544-7941 → answer the verification call in the GV app. From then on, call homeowners from the contact record (browser or HubSpot mobile app); calls auto-log with notes and optional recording. Wisconsin is one-party consent, but use HubSpot's recording-consent prompt anyway.
2. **Inbound logging discipline (manual, 60 seconds per call):** after each inbound GV call, open or create the contact in HubSpot mobile/desktop → Log → Call → outcome + 1-line summary. If the caller is new, create the contact on the spot from the GV caller ID. Do this immediately after hangup, not end of day.
3. **Texts:** keep texting from the GV app. After any meaningful thread, Log → SMS on the contact timeline and paste the exchange (or a summary). At current volume this is 2-3 logs per week.
4. **Voicemail backstop:** in GV settings, enable "Get voicemail via email." In Gmail, add a filter to forward those to the HubSpot conversations inbox address so no missed call disappears, then manually associate to the contact.
5. **TCPA consent capture:** create a HubSpot contact property group "Compliance" with: `sms_consent` (dropdown: Verbal, Written, None), `sms_consent_date` (date), `sms_consent_note` (single-line, e.g. "Verbally agreed to text follow-ups on intro call 6/10"). Fill it during the logging step in #2 before ever texting a lead. This is the record that survives a TCPA dispute and it ports cleanly into OpenPhone's required opt-in evidence later.
6. **Write the trigger down:** add the three upgrade triggers from this memo to the project board so the OpenPhone port is a decision already made, not a research project.

## Sources (verified June 2026)

- HubSpot calling release notes (Starter: 500 min, 1 HubSpot number, inbound): community.hubspot.com/t5/Releases-and-Updates/Now-Live-Updates-to-HubSpot-Calling/ba-p/625719; cloudtalk.io/blog/hubspot-calling-pricing
- HubSpot number porting (2-4 wks, Twilio LOA, HubSpot becomes owner): knowledge.hubspot.com/calling/port-out-a-hubspot-phone-number
- Marketing SMS add-on $75/mo, Pro/Enterprise only, not Starter: messageiq.io/blogs/hubspot-sms-marketing; hubspot.com/products/marketing/sms
- OpenPhone/Quo pricing ($15/$23/$35 annual; HubSpot integration on Business; porting on all plans): ringly.io/blog/openphone-pricing; quo.com/features/hubspot-phone-integration
- GV port-out ($3 unlock, PIN = voicemail PIN): support.google.com/voice/answer/1065667
- A2P 10DLC (EIN entities must register Standard/Low-Volume brand; unregistered business SMS blocked since Feb 2025): help.twilio.com/articles/13718729624091; telgorithm.com/news/sole-prop-registration-guide
- No GV API/Zapier/CRM path; Workspace Voice tiers $10-30 + Workspace seat: quo.com/blog/google-voice-integrations; workspace.google.com/products/voice
- Aircall 3-license minimum; JustCall 2-user minimum; Kixie per-minute: aircall.io/pricing; justcall.io/pricing; cloudtalk.io/blog/kixie-pricing
