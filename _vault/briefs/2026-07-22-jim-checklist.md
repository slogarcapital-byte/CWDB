# Jim's Manual Checklist (clear-the-board session, 2026-07-22)

Everything Claude could do is done. These are the steps only you can do, ordered by impact. Estimated total: under 2 hours of clicking/calling, plus the course hours.

## This week (revenue + legal critical path)

1. **DSPS licensing clock (task 2). THE critical path.** Enroll in the WI Contractors Institute $99 initial 12-hr Dwelling Contractor Qualifier course, finish it, file Form 3097 the same day, Form 3096 ~3 days later. Legal confirmed today: the subcontractor paper does NOT cure this; without the cert you cannot sign Winchester as prime on Aug 17. Roadmap: `docs/legal/construction-setup/01-jim-qualifier-licensing-roadmap.md`.
2. **Call the 3 leads (task 5).** Call sheets in `sales/call-sheets/`: Hanson first (Wausau repair, the Overbeck playbook, book this week; also confirm on the call whether a bid was actually delivered 6/24 because the CRM says yes but has no amount). Petersen + Neely as one Stevens Point trip. Petersen's consent was backfilled today (she DID check the box; texting her is legal). Hanson/Neely: phone first, use the consent script.
3. **Nelson-Claeys walk-through.** New Mosinee repair lead, scored A/88, sitting in Creating Bid since 7/9. Book the walk-through this week.
4. **Approve the follow-up sends (task 22).** Quinn keep-warm email draft (33 days out, contract held pending DSPS) + cadence templates: `sales/follow-ups/2026-07-22-cadence-and-stale-bids.md`. Say go and I send/log them.

## 10-minute clicks (all steps documented)

5. **HubSpot notify path (task 7).** Form Options: add notification recipients; install the HubSpot mobile app + enable push. Steps: `operations/leads/phone-intake-consent.md`. Closes the "Petersen sat 5 days" hole.
6. **HubSpot create-contact screen (task 16).** Add Lead Channel + TCPA Consent Source to the create form (2 min, same doc).
7. **Google Ads clicksheet (task 10).** Demote the 4 GBP junk conversions to Secondary (not API-mutable, verified). RECOMMENDED while you are in there: flip the Search campaign to Maximize Clicks until the restored conversion signal banks 30 conversions (this re-applies your own 5/19 decision; it has been on Maximize Conversions with a dead signal since 6/10). Clicksheet: `marketing/google-ads/2026-07-22-conversion-cleanup-clicksheet.csv`.
8. **Rotate the Supabase service-role key (task 17).** Supabase Dashboard > Settings > API > rotate service_role. Then in the SAME sitting update: `.env.local`, Streamlit Cloud secrets (estimator + HQ twin), and the edge-function secrets if shown. Until updated, the warehouse cron and cloud twin will fail; do it right before a refresh so we catch problems.

### Unblock the site finish (2 minutes, high leverage)

- **Re-authorize the Webflow connection with the `page_client:write` scope** (claude.ai > Settings > Connectors > Webflow > reconnect and grant all scopes), or open the Webflow Designer with the MCP companion app active. This unblocks the remaining static-page edits: the last licensed/bonded/24-48h strings on Home/About/Get-a-Quote/Our-Builders + city trust badges, the /thank-you booking page body, the /privacy body, and (most important) the missing TCPA consent checkbox on the 5 service-area forms. Say the word after reconnecting and I run the finishing pass.
- **Conversion-signal test**: after the reconnect pass, submit the quote form once using slogarjw@gmail.com (auto-excluded from clean-lead views) from your iPhone and confirm you land on /thank-you. Then delete the test job it creates in JobTread (JobTread writes have no undo, so it needs a manual delete). This proves the Google Ads conversion is firing again after 6 silent weeks.

## Money (task 18 + 24)

9. **Move subscriptions to the business card**: HubSpot, Webflow, GoDaddy, Supabase, Anthropic (confirm JobTread, DocuSign, Streamlit). List + treatment: `finance/memos/2026-07-22-tax-reserve-q3-subscriptions.md`.
10. **Tax**: reserve $2,350 now; **Q3 1040-ES $2,350 due Mon 9/15** (recompute 8/31; if Koy/Peksa deposits land first it rises to ~$3,480). Also send me your 2025 total tax + withholding for the safe-harbor check.
11. **Substantiate the $308.69 sponsorship** (Kwik Trip $200 cash 6/22 + Greenwood Hills $108.69 6/24): receipt/invoice + what CWDB received.
12. **Do NOT collect** INV-2026-047 (Koy $2,325) or INV-2026-048 (Peksa $900) until the DSPS cert is in hand.

## Legal (task 14 + 26)

13. **Send the drafts to Lauren Yde**: both mutual terminations, the subcontractor agreement, the privacy policy, the ToS rewrite, and the cover note (`docs/legal/terminations/README-yde-cover-note.md` lists her 10 questions). Then Ben/John signatures on the sub agreement before Aug 17.

## Verify (task 13/21 + 27)

14. **iPhone check (standing rule).** Safari + Chrome on your iPhone 11: home page, get-a-quote, thank-you, /privacy, one city page. The repositioned copy is live; real-device confirmation is the acceptance gate.
15. **fact_bids verification list**: `operations/data-warehouse/docs/2026-07-22-fact-bids-verification.md` (Hanus placeholder amount, contractor_id backfills, zero the Overbeck referral fee, deactivate the Debbie Overbeck contractor row). Check what is right; I apply corrections next session.
16. **Ship-or-hold the new /services page** (staged as draft in Webflow, not published). It is the strongest "we build decks" signal; your call.
