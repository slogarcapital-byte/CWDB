---
type: page-revamp
page: FAQ
url: /faq
source: website/pages/faq/content.md
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# FAQ Revamp: `/faq`

Repositions the answers from "how our matching service works" to "how we build your deck." Removes "licensed" verification claims and the 48-hour promise. JSON-LD answer strings must be updated to match, since they mirror the visible answers (see the JSON-LD section at the bottom and `json-ld-fixes.md`).

Live source: `website/pages/faq/content.md`.

---

## Hero subtext

### REPLACE
OLD:
Everything you need to know about getting a deck quote through Central Wisconsin Deck Builders.
NEW:
Everything you need to know about building, replacing, or refinishing a deck with Central Wisconsin Deck Builders.

---

## Q1: How does Central Wisconsin Deck Builders work?

### REPLACE: visible answer (faq/content.md) AND JSON-LD answer (see json-ld-fixes.md)
OLD:
We make it simple. You fill out a quick form telling us about your deck project — size, materials, timeline, budget. We review your request and match you with a vetted, licensed contractor in your area. The contractor reaches out to discuss your project and provide a detailed quote. The whole process is free for homeowners, and there's never any obligation to move forward.
NEW:
We make it simple. You fill out a quick form telling us about your deck project: size, materials, timeline, budget. We reach out to set up a free on-site walk-through, usually within one business day. Our insured local crew measures, talks through options, and gives you a clear, itemized estimate. The walk-through and estimate are free, and there's never any obligation to move forward.

---

## Q3: How quickly will I hear back?

### REPLACE: visible answer AND JSON-LD answer
OLD:
Most homeowners hear from a contractor within 48 hours. Response times depend on the contractor's schedule, but we prioritize fast turnaround because we know waiting is frustrating.
NEW:
Most homeowners hear from us within one business day. We reach out to book your walk-through as soon as we see your request, because we know waiting on a callback is the worst part of hiring anyone.

---

## Q4: How do you choose which contractors are in your network?

This question assumes a directory. Rewrite it into "who actually builds my deck," and drop the "Active Wisconsin contractor license" verification claim (not substantiable, and CWDB's own DSPS license is still pending).

### REPLACE: question
OLD:
How do you choose which contractors are in your network?
NEW:
Who actually builds my deck?

### REPLACE: visible answer AND JSON-LD answer
OLD:
Every contractor goes through a vetting process before they're approved. We verify:

- Active Wisconsin contractor license
- General liability insurance
- Workers' compensation coverage
- Track record of residential deck projects in Central Wisconsin
- Customer references

If a contractor doesn't meet our standards, they don't join the network. We also monitor credentials over time to make sure nothing lapses.
NEW:
Your deck is built by our own crew: experienced local builders who work under the Central Wisconsin Deck Builders name. We are fully insured (general liability), we build to Wisconsin code, and we handle your project from walk-through to final board. You are not being passed off to a stranger from a directory.

(JSON-LD note: the mirrored answer in the FAQPage schema must be shortened to match: see `json-ld-fixes.md`.)

---

## Q6: What types of deck projects do you handle?

### REPLACE: opening line (drop "Our contractors handle")
OLD:
Our contractors handle a wide range of residential deck projects, including:
NEW:
We handle a wide range of residential deck projects, including:

(The bulleted list of project types stays. JSON-LD mirror answer: change "Our contractors handle" to "We handle": see json-ld-fixes.md.)

---

## Q8: Do I need a permit to build a deck in Wisconsin?

### REPLACE: last paragraph (drop "your contractor," use "we")
OLD:
The good news: your contractor typically handles the permit application as part of the project. When you get your quote, ask your builder about permit requirements and costs for your area.
NEW:
The good news: we handle the permit application as part of the project. At your walk-through, we'll go over permit requirements and costs for your city.

(JSON-LD mirror: "Your contractor typically handles the permit application" → "We handle the permit application": see json-ld-fixes.md.)

---

## Q9: What decking materials are available?

### REPLACE: opening + closing lines
OLD:
The most common materials used by our contractors include:
NEW:
The most common materials we build with include:

OLD:
Your contractor can recommend the best material for your budget, climate, and design preferences.
NEW:
At your walk-through we'll recommend the best material for your budget, climate, and how you plan to use the space.

---

## Q11: Can I choose which contractor I work with?

This whole question is a directory artifact. Replace it with a question that fits a build company.

### REPLACE: question
OLD:
Can I choose which contractor I work with?
NEW:
Do you do the work yourselves, or subcontract it out?

### REPLACE: visible answer AND JSON-LD answer
OLD:
We match you with the contractor in our network who's the best fit for your project based on location, availability, and specialization. As our network grows, you may have the option to receive quotes from multiple builders and choose the one you prefer.
NEW:
We do the work with our own local crew. The people who walk your project and write your estimate are the people who build your deck. You always know exactly who is on your job.

---

## Q12: Is my information shared with anyone?

### REPLACE: first sentence (drop "the vetted contractor(s) matched to your project")
OLD:
Your contact and project details are shared only with the vetted contractor(s) matched to your project. We do not sell your information to marketing lists, spam databases, or unrelated third parties. For full details, see our Privacy Policy.
NEW:
Your contact and project details are used by our team to plan and build your deck. We do not sell your information to marketing lists, spam databases, or unrelated third parties. For full details, see our Privacy Policy.

(JSON-LD mirror updated in json-ld-fixes.md.)

---

## Bottom CTA

### REPLACE: body + button
OLD:
We're happy to help. Email us at info@cwdeckbuilders.com or go ahead and get a free quote — our contractors can answer project-specific questions directly.
NEW:
We're happy to help. Email us at info@cwdeckbuilders.com, call (715) 544-7941, or book a free walk-through and we'll answer project-specific questions in person.

OLD (button):
Get Your Free Quote
NEW (button):
Book a Free Walk-Through

---

## Untouched questions

Q2 (Is the quote really free?), Q5 (What areas), Q7 (deck cost ranges), Q10 (planning phase) have no compliance or positioning problem and need no change. Q7 already reads as construction pricing.
