---
type: page-revamp
page: Thank You / Book Your Walk-Through
url: /thank-you
source: website/pages/thank-you/content.md + website/pages/thank-you/index.html
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Thank You becomes a Walk-Through Booking Page: `/thank-you`

Task 21 turns the passive "thanks, a contractor will reach out" confirmation into an active **booking page** that pushes the visitor to grab a walk-through time slot right now, with the phone number as the fallback. This is the highest-leverage change in the whole revamp: the visitor is warmest at this exact moment.

Live source: `website/pages/thank-you/content.md` and `website/pages/thank-you/index.html` (the `next-section` component around lines 662-712).

Page stays `noindex`.

---

## Booking mechanism: note for web-dev

Primary CTA should open a real scheduler so the visitor can self-book. Options, in order of preference:
1. Embed the calendar Jim already uses for walk-throughs (Google Calendar appointment schedule, Calendly, or JobTread scheduling) as an inline embed or a button that opens it.
2. If no scheduler is wired yet, the button links to `tel:7155447941` and the copy leans on the phone path.

Everything below is copy. The booking widget is web-dev's to place; the copy assumes a "pick a time" action exists and gives the phone fallback either way.

---

## Confirmation header

### REPLACE: headline
OLD:
You're All Set — Your Quote Request Is In
NEW:
Got it. Now let's get on your calendar.

### REPLACE: subtext
OLD:
Thanks for reaching out. We've received your project details and a vetted local contractor will be in touch soon.
NEW:
Thanks for the details. The next step is a free on-site walk-through so we can measure, talk through what you want, and get you a real number. Pick a time that works and we'll be there.

---

## NEW SECTION: Book your walk-through (primary action, place directly under the header)

**Section label:** The next step
**Heading:** Book your free walk-through
**Body:** Choose a time below and we'll come out to your place. It takes about 30 minutes. No cost, no pressure, no obligation to build.

**Primary CTA button (Crafted Orange #e54c00):** Pick a Time
**Sub-line under the button:** Prefer to talk first? Call or text us at (715) 544-7941.

**If no scheduler is embedded yet, use this variant instead:**
- **Primary CTA button:** Call to Book: (715) 544-7941  (links to `tel:7155447941`)
- **Sub-line:** We answer fast, usually within one business day. We'll find a walk-through time that fits your schedule.

---

## What Happens Next: 3-step timeline (rewrite)

The current timeline promises "a contractor will reach out within 24/48 hours." Replace with the real walk-through-to-build flow.

### REPLACE: Step 1 title + timeframe + body
OLD (title):
Step 1 — We're Reviewing Your Project Now
OLD (timeframe badge):
Right now
OLD (body):
Our team is looking over your details to match you with the right contractor for your deck project.
NEW (title):
Step 1: Pick your walk-through time
NEW (timeframe badge):
Right now
NEW (body):
Grab a slot above, or call us at (715) 544-7941 and we'll set one up together.

### REPLACE: Step 2 title + timeframe + body
OLD (title):
Step 2 — A Contractor Will Reach Out
OLD (timeframe badge):
Within 48 hours
OLD (body):
A licensed, insured deck builder in your area will contact you to discuss your project and provide a detailed quote.
NEW (title):
Step 2: We walk your project
NEW (timeframe badge):
At your appointment
NEW (body):
Our insured local crew comes out, measures, and talks through materials, layout, and budget. About 30 minutes.

### REPLACE: Step 3 title + timeframe + body
OLD (title):
Step 3 — You're in Control
OLD (timeframe badge):
Whenever you're ready
OLD (body):
Review the quote on your own time. Ask questions. Compare options. There's no obligation and no pressure — move forward only when it feels right.
NEW (title):
Step 3: Get your estimate and a build date
NEW (timeframe badge):
Shortly after
NEW (body):
You get a clear, itemized estimate. Like the number? We lock in a build date that works for you. No obligation to move forward.

### REPLACE: index.html Step 2 body (this specific string is live in thank-you/index.html line 693)
OLD:
A licensed, insured deck builder in your area will contact you to discuss your project and provide a detailed quote. Most homeowners hear back the same day.
NEW:
Our insured local crew comes out, measures, and talks through materials, layout, and budget. About 30 minutes.

### REPLACE: index.html Step 2 timeframe (line 691)
OLD:
Within 24 hours
NEW:
At your appointment

---

## While You Wait: Recommended Reading

Keep this section. It works even better on a booking page (gives the visitor something to do while they check their calendar). No copy change needed. Blog links stay as-is.

---

## Contact Information

### REPLACE: phone placeholder (the real number exists now)
OLD:
**Phone:** *(placeholder — add when business line is set up)*
NEW:
**Phone:** (715) 544-7941

### REPLACE: body
OLD:
If you need to update your request or have any questions, reach out anytime.
NEW:
Need to change your walk-through time or ask something first? Reach out anytime.

(Email info@cwdeckbuilders.com stays.)

---

## Meta

Meta title/description handled in `meta-descriptions.md`. The current description ("Your deck quote request has been received. Here's what happens next.") gets a light booking-oriented refresh there.
