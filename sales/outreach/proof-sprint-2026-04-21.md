---
type: outreach-draft
status: draft-awaiting-approval
created: 2026-04-21
author: cwdb-ceo-operator
purpose: Proof-sprint outreach to Ben Barton + John Garcia requesting 1 past-client photo + 1 short testimonial each, to seed Lever 4 (Proof) before first paid ad spend.
why: "Zero proof assets at launch is Hormozi Bottleneck #1. Revamp window is prime time to collect 1-2 proof assets. More proof = higher conversion on landing pages = more $1,000 accepted bids for Ben and John."
next_step: Jim reviews, approves, and sends from his personal email / phone. Do NOT send from an automated system — these should feel like a personal note from the founder.
---

# Proof Sprint — Outreach Drafts (2026-04-21)

Two contractors, two channels each (email + SMS). The SMS is the lead — contractors read texts faster than email. The email is the follow-up with the "why" and a Dropbox/email-reply path to send photos.

**Friendly + direct. No corporate tone. Written as if Jim is texting/emailing a business partner he knows.**

---

## Ben Barton — Barton Builders LLC

### SMS (send first)

> Hey Ben — Jim at Central WI Deck Builders. Quick ask: can you send me 1 photo of a recent deck you built + 1 sentence from the homeowner (text or voice memo, whatever's easiest)? We're launching ads next week and authentic proof on the landing pages converts leads way better than stock photos. More closed bids for you. Reply here or email info@cwdeckbuilders.com. Thanks!

*(length: ~60 words / ~320 chars — fits two SMS segments cleanly)*

### Email (send 1 hour after SMS if he's slow to reply, or same-time as backup)

**Subject:** Quick favor — 1 photo + 1 sentence from a past deck job

Hey Ben,

Hope you're having a good week. Quick ask — won't take more than 10 minutes on your end.

We're finalizing the website and launching our first ads next week to start sending deck leads your way. One thing that matters more than anything else for landing page conversion: **real photos of real builds and a sentence or two from a real homeowner.** Stock photos and generic testimonials kill lead quality — authentic proof from local builders raises our close rate significantly, which means more $1,000 accepted bids flowing to Barton Builders.

What I'm asking for:

1. **1 photo** of a deck you built recently — phone photo is fine, doesn't need to be pro-grade. Ideally a finished deck with some character (stained wood, good angle, daylight).
2. **1 short testimonial** from the homeowner — even one sentence like *"Ben was professional, on time, and the deck looks amazing."* Text it to yourself, email, voice memo, whatever's easiest. If you want, I'll draft something based on a phone call with them and you send it for their approval.

You can reply to this email with the photo attached, or text it to me at (715) 544-7941. Whatever's fastest.

Thanks, Ben — this is the kind of thing that makes the difference between ads that work and ads that flop. Appreciate you.

Jim Slogar
Central Wisconsin Deck Builders
(715) 544-7941
info@cwdeckbuilders.com
cwdeckbuilders.com

---

## John Garcia — John Garcia Construction, LLC

### SMS (send first)

> Hey John — Jim at Central WI Deck Builders. Quick ask: can you send me 1 photo of a recent deck you built + 1 sentence from the homeowner (text or voice memo, whatever's easiest)? We're launching ads next week and authentic proof on the landing pages converts leads way better than stock photos. More closed bids for you. Reply here or email info@cwdeckbuilders.com. Thanks!

### Email

**Subject:** Quick favor — 1 photo + 1 sentence from a past deck job

Hey John,

Hope things are going well. Quick ask — maybe 10 minutes on your end.

We're wrapping up the website and launching our first ads next week to start sending deck leads to you and Ben. One thing that matters more than anything else for landing page conversion: **real photos of real builds and a short testimonial from a real homeowner.** Stock photos and canned testimonials actively hurt lead quality — local proof raises the close rate, which means more $1,000 accepted bids flowing to John Garcia Construction.

What I need:

1. **1 photo** of a deck you built recently — phone photo is fine. Just something that shows your work well (daylight, finished build, good angle).
2. **1 short testimonial** from the homeowner — even one sentence like *"John got the job done right — would hire him again."* Text, email, voice memo — whatever's easiest for them. If you'd rather, I'll jump on a 2-minute call with them and draft something for them to approve.

Reply to this email with the photo attached, or text me at (715) 544-7941. Whatever's fastest.

Thanks, John — appreciate you. This one thing has a real impact on how many leads actually close.

Jim Slogar
Central Wisconsin Deck Builders
(715) 544-7941
info@cwdeckbuilders.com
cwdeckbuilders.com

---

## Send plan (for Jim's approval)

1. **Today (2026-04-21) late afternoon / early evening** — send SMS to both. Reason: SMS has ~95% read rate within 90 min. Evening delivery feels personal, not salesy.
2. **Tomorrow morning (2026-04-22)** — if no SMS reply, send email as backup. If they replied to SMS, skip email unless they asked for written detail.
3. **Day 3 (2026-04-24)** — soft nudge SMS: *"Hey Ben/John — any luck finding a photo? No rush, just finalizing the site."*
4. **Day 7 (2026-04-28)** — if still no response, escalate on a phone call. Do not let this drop. Proof is the #1 bottleneck.

## Success criteria

- [ ] ≥1 real photo received from at least 1 contractor by 2026-04-25
- [ ] ≥1 short testimonial received from at least 1 contractor by 2026-04-28
- [ ] Ideally: 1 photo + 1 testimonial from each (2 assets total) by ad launch

## Where assets land when received

- Photos → `/website/assets/proof-photos/` (file naming: `barton-deck-01.jpg`, `garcia-deck-01.jpg`)
- Testimonials → `/website/content/testimonials.md` (pipe-delimited: `Name | City | Quote | Contractor`)
- Upload to Webflow: Gallery CMS collection (existing) + Our Builders CMS (replace Unsplash placeholders)
- Bind to homepage `builders-strip` component + relevant city pages

## Ruthless-mentor note to Jim

This outreach should have gone out the day Ben + John signed on 2026-04-17. We're 4 days late. Every day between signing and launch is a day we could have been stockpiling proof. Do not delay further — approve, tweak, or reject tonight.
