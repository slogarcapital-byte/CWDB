---
type: page-revamp
page: Get a Quote
url: /get-a-quote
source: website/pages/get-a-quote/content.md + website/pages/get-a-quote/index.html
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Get a Quote Revamp: `/get-a-quote`

Repositions the form page from "we'll match you with a builder" to "tell us about your deck and we'll book a walk-through." Removes "Licensed & insured builders" trust line (keeps "insured"), removes the 48-hour and 24-hour promises, and removes the live placeholder mini-testimonial.

Live sources: `website/pages/get-a-quote/content.md` and `website/pages/get-a-quote/index.html`.

The 3-step form fields themselves (zip, phone, project type, budget, timeline) do not change.

---

## Hero Section

### REPLACE: headline
OLD:
Get your deck quote within 48 hours.
NEW:
Tell us about your deck.

### REPLACE: subtext
OLD:
3 quick steps. No phone calls. A vetted local builder will reach out within 48 hours to schedule a site visit.
NEW:
3 quick steps. We'll reach out to set up a free on-site walk-through, usually within one business day.

### REPLACE: index.html hero sub (get-a-quote/index.html line 904)
OLD:
Tell us about your project and we'll connect you with a vetted local builder — usually within 24 hours. No cost, no pressure, no obligation.
NEW:
Tell us about your project and we'll set up a free walk-through with our local crew, usually within one business day. No cost, no pressure, no obligation.

---

## Right column: Trust Card

### REPLACE: trust list (content.md line 143 + index.html)
OLD:
- Licensed & insured builders
- Free quote, no obligation
- Fast 48-hour response
- Local Central Wisconsin team
NEW:
- Insured local crew
- Free walk-through and estimate, no obligation
- We answer fast, usually within one business day
- Central Wisconsin only: we build here

### REPLACE: index.html trust badge label (get-a-quote/index.html line 912)
OLD:
Licensed & insured contractors
NEW:
Insured local crew

### REPLACE: index.html trust card item (get-a-quote/index.html lines 1079-1080)
OLD:
Licensed & Insured
Every contractor in our network is licensed and fully insured before we make an introduction.
NEW:
Fully Insured
Our crew carries $1M/$2M general liability insurance. You're covered before we ever set foot on your property.

### REPLACE: index.html "Response Within 24 Hours" badge (line 1091)
OLD:
Response Within 24 Hours
NEW:
Fast Response

---

## Right column: What Happens Next

### REPLACE: Step 1 (content.md lines 151-152)
OLD:
**Step 1 — We review your project** (Within a few hours)
Our team reviews your project details so we can match you with the right builder.
NEW:
**Step 1: We reach out** (Usually within one business day)
We review your details and contact you to set up a free on-site walk-through.

### REPLACE: Step 2 (content.md lines 154-155)
OLD:
**Step 2 — You get matched** (Within 48 hours)
A vetted local contractor in your area reaches out directly.
NEW:
**Step 2: We walk your project** (At your appointment)
Our insured local crew comes out, measures, and talks through materials and budget.

### REPLACE: Step 3 (content.md lines 157-158)
OLD:
**Step 3 — You decide** (On your schedule)
Review the quote, ask questions, move forward only when you're ready.
NEW:
**Step 3: You decide** (On your schedule)
Get a clear, itemized estimate. Move forward only when you're ready. No obligation.

### REPLACE: index.html next-step time label (line 1143)
OLD:
Within 24 hours
NEW:
At your appointment

---

## Right column: REMOVE the placeholder mini-testimonial (index.html lines 1162-1167)

REMOVE entirely:
```
<div class="mini-testimonial">
  <div class="mini-testimonial__stars">★★★★★</div>
  <p class="mini-testimonial__text">"We got three quotes within a day of submitting our form. The whole process was painless."</p>
  <div class="mini-testimonial__author">— Homeowner, Wausau &nbsp;·&nbsp; placeholder</div>
</div>
```
This is a fabricated review (invented quote + invented 5-star rating). It must not be published. Do not replace with another quote; leave the space empty or let the trust card fill it. `get-a-quote/content.md` line 138 already notes the mini-testimonial was meant to be removed, and this makes it real.

---

## Bottom Reassurance

No change. "Still have questions? Check our FAQ..." is fine.

---

## Copy Rules header note

`get-a-quote/content.md` frontmatter and the "Revamped 2026-04-19" note reference the old promise indirectly. No functional change needed beyond the hero and cards above. Meta handled in `meta-descriptions.md`.
