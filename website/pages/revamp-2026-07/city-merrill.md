---
type: page-revamp
page: Merrill city page
url: /merrill
source: website/pages/cities/merrill/content.md
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Merrill City Page Revamp: `/merrill`

Removes the "we verify licenses" claim, the "licensed, insured deck builder" matching line, the "from licensed local builders" og_description, the fabricated placeholder testimonial, and the "Licensed and insured contractors" badge. Repositions matching language to "we build." JSON-LD in `json-ld-fixes.md`; meta (including the og_description "licensed" fix) in `meta-descriptions.md`.

Live source: `website/pages/cities/merrill/content.md`.

---

## Hero

### REPLACE: hero intro (line 30)
OLD:
The City of Parks deserves great outdoor spaces at home, too. Get a free deck quote from a trusted contractor who serves Merrill.
NEW:
The City of Parks deserves great outdoor spaces at home, too. We're a trusted local crew that builds, replaces, and repairs decks across Merrill and Lincoln County.

### REPLACE: hero CTA line (line 32)
OLD:
**Get Your Free Deck Quote**
NEW:
**Get Your Free Estimate**

---

## Value Propositions

### REPLACE: "Contractors Who Show Up and Do Honest Work" heading + body (lines 50-52)
OLD:
### Contractors Who Show Up and Do Honest Work

In Merrill, reputation is everything. Our contractors are local builders with track records in Lincoln County: not companies driving in from two hours away. We verify licenses, insurance, and references so you get someone your community already trusts.
NEW:
### A Crew That Shows Up and Does Honest Work

In Merrill, reputation is everything. We're a local, insured crew with a track record in Lincoln County: not a company driving in from two hours away. We build to code, stand behind the work, and answer our phone.

### REPLACE: "Real Prices, Not Sales Tactics" body (line 56)
OLD:
You want to know what a deck costs. Period. Our contractors provide clear, itemized quotes with no hidden markups and no pressure to upgrade to something you did not ask for. Merrill homeowners get the straight answer they expect.
NEW:
You want to know what a deck costs. Period. We provide clear, itemized estimates with no hidden markups and no pressure to upgrade to something you did not ask for. Merrill homeowners get the straight answer they expect.

### REPLACE: "Built to Hold Up" body (line 60)
OLD:
Function first. Our contractors build decks that survive Lincoln County winters, handle the weight of a full family cookout, and still look solid a decade later. Whether that is pressure-treated wood or composite, the priority is durability and value.
NEW:
Function first. We build decks that survive Lincoln County winters, handle the weight of a full family cookout, and still look solid a decade later. Whether that is pressure-treated wood or composite, the priority is durability and value.

---

## Process Timeline

### REPLACE: Step 2 heading + body (lines 71-73)
OLD:
### Step 2: We Connect You With a Merrill-Area Contractor

Your project gets matched with a licensed, insured deck builder who works in Merrill and Lincoln County. No call centers, no random assignments: just a local professional who can come out and look at your property.
NEW:
### Step 2: We Come Out for a Free Walk-Through

Our insured crew comes out to measure and look at your property in person, usually within one business day. No call centers, no random assignments: just a local team who builds in Merrill and Lincoln County.

### REPLACE: Step 3 body (line 77)
OLD:
The contractor follows up with a detailed written estimate. Review it on your schedule. There is no fee, no obligation, and no one calling you back to push a decision.
NEW:
We follow up with a detailed written estimate. Review it on your schedule. There is no fee, no obligation, and no one calling you back to push a decision.

---

## Local Gallery Intro

### REPLACE: body (line 84)
OLD:
From straightforward deck replacements on in-town homes to new builds on larger rural lots outside city limits, our contractors have handled the full range of projects that Merrill properties demand. These are practical builds done right.
NEW:
From straightforward deck replacements on in-town homes to new builds on larger rural lots outside city limits, we've handled the full range of projects that Merrill properties demand. These are practical builds done right.

---

## REMOVE: fabricated testimonial (lines 90-95)

REMOVE entirely:
```
> "We had an old deck on our place just north of downtown — the boards were soft and the railing was pulling away from the posts. Got a quote through the site, contractor came out that same week, and we had a new pressure-treated deck done before Memorial Day. Good price, no drama."
>
> — *Merrill homeowner, Lincoln County*

*[Testimonial placeholder — replace with verified customer quote]*
```
Do not replace with another quote. Leave the section empty/hidden until a real, permissioned review exists.

---

## Trust Badges

### REPLACE: first badge (line 102)
OLD:
- Licensed and insured contractors
NEW:
- Insured local crew

---

## Quote Form Section

### REPLACE: body (line 112)
OLD:
Your deck has done its job. Now it is time for one that will last another twenty years. Get a free quote from a vetted local contractor who serves Merrill and Lincoln County.
NEW:
Your deck has done its job. Now it is time for one that will last another twenty years. Book a free walk-through with the crew that builds in Merrill and Lincoln County.

---

## City-specific FAQ

### REPLACE: repair-vs-replace answer, closing (line 142)
OLD:
Your contractor will assess the structure during the quote process and give you an honest recommendation.
NEW:
We assess the structure at the walk-through and give you an honest recommendation.

### REPLACE: material answer, closing (line 146)
OLD:
Your contractor can price both options so you can compare the real numbers.
NEW:
We price both options so you can compare the real numbers.

### REPLACE: coverage answer, closing (line 150)
OLD:
If you are within a reasonable drive of Merrill, submit a quote request and we will confirm coverage for your address.
NEW:
If you are within a reasonable drive of Merrill, reach out and we will confirm we can get to your address.
