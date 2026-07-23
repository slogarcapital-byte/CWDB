# Estimate Follow-Up Cadence + Open-Bid Resolution (audit fix #22, 2026-07-22)

## The standing cadence (applies to every estimate from today)

- **Day 0:** estimate sent (logged in sales/estimates/log.md and the HubSpot deal).
- **Day 7:** first touch. Short check-in call or email: any questions, offer to walk the numbers.
- **Day 14:** second touch AND the estimate's stated validity expires (validity default stays 14 days). Message: prices held through today, happy to refresh the quote if timing slipped.
- **Day 21:** close the loop. One final email; if no reply, mark the deal Lost with reason "no response" and stop. No zombie bids: nothing stays in Delivered Bid past 21 days without a documented reply.
- Every touch gets logged on the HubSpot deal. The /bid skill now also blocks bids that blow past the homeowner's stated budget (sanity check added today).

## Current open pipeline (warehouse, 2026-07-22)

The audit-era stale bids (Kampstra, Waldman, and others) were already resolved Lost in the 7/6-7/13 cleanups. Four deals remain open:

### 1. Thomas Quinn: $8,960 bid sent 6/19 (33 days) plus staged HIC contract ($7,751)
Status: NOT a normal stale bid. The contract send is deliberately HELD pending DSPS cert (decision 7/11). Risk: he goes quiet or shops around while we wait.
Action for Jim (approve + send): keep-warm email, no signature ask.

> Subject: Your deck project: on track for August
>
> Hi Thomas, quick update from our side. We are on schedule for the August start we discussed. I am finishing the state licensing paperwork this month and I will send the contract for signature as soon as that clears, so you have everything in writing before we break ground. Nothing needed from you right now. If your timing or plans have shifted at all, just reply and we will adjust. Thanks again for your patience. Jim, Central Wisconsin Deck Builders, (715) 544-7941

### 2. Valeria Hanson: deal shows "Delivered Bid" 6/24 (28 days) but NO amount recorded
Status: data inconsistency. Task 5 treats Hanson as a not-yet-followed-up lead; the deal says a bid was delivered 6/24. Jim: confirm which is true on the call (call sheet: sales/call-sheets/2026-07-22-hanson.md). If a bid was really delivered, log the amount on the deal; if not, fix the stage back to walk-through/qualifying. Phone first (consent_missing: no SMS).

### 3. Dena Petersen: Creating Bid since 7/6, nothing sent
Action: this resolves through the task-5 call (call sheet ready). Do not draft numbers until the walk-through or phone scope is done.

### 4. Jodi Nelson-Claeys: Creating Bid since 7/9, nothing sent (Mosinee repair, scored A/88)
Action for Jim: schedule the walk-through this week (repair within 30 min = book-this-week playbook). Then /bid.

## Follow-up email templates (for the cadence going forward)

**Day 7:**
> Subject: Checking in on your deck estimate
>
> Hi [name], wanted to make sure the estimate landed and see if any questions came up. Happy to walk through the numbers or adjust the scope if something is not quite right. You can reply here or call/text me at (715) 544-7941. Jim

**Day 14 (expiry):**
> Subject: Your estimate expires today: want me to refresh it?
>
> Hi [name], the pricing in your estimate was good for 14 days and that window closes today. Material prices move around, so if you are still deciding I am glad to refresh the quote so you have current numbers. No pressure either way: just let me know where you stand. Jim

**Day 21 (close the loop):**
> Subject: Closing the file on your deck estimate
>
> Hi [name], I have not heard back, so I will assume the timing is not right and close out your file for now. If things change this season or next, reach out any time and we will pick it right back up. Thanks for considering us. Jim

## Rules

- Sends are ALWAYS Jim-approved: nothing in this file goes out automatically.
- No SMS to any consent_missing lead. Phone or email only until consent is logged.
- When a deal moves to Lost, set a reason. "No response" is a valid reason; blank is not.
