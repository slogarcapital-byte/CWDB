---
type: page-revamp
page: Wausau city page
url: /wausau
source: website/pages/cities/wausau/content.md + website/pages/cities/wausau/index.html
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Wausau City Page Revamp: `/wausau`

Highest-priority city page: it carries the live **fabricated named testimonials** (the sharpest FTC exposure on the site) and both meta descriptions and the hero still promise "24 hours" and "Licensed, insured contractors." Repositions matching language to "we build," removes the fake testimonials, removes "licensed," and drops the hour promise.

Live sources: `website/pages/cities/wausau/content.md` (canonical copy) and `website/pages/cities/wausau/index.html` (CMS field reference + fabricated testimonials at lines 122-133). JSON-LD in `json-ld-fixes.md`. Meta in `meta-descriptions.md`.

---

## Hero

### REPLACE: hero intro (content.md line 30)
OLD:
Your home deserves a deck that matches the pride you take in this city. Get connected with vetted, local deck contractors who know Wausau — no searching, no guesswork.
NEW:
Your home deserves a deck that matches the pride you take in this city. We're a local crew that builds, replaces, and refinishes decks right here in Wausau. No searching, no guesswork, no lead-selling middleman.

### REPLACE: hero CMS subheadline (index.html lines 117-118)
OLD:
Get free quotes from licensed, insured deck builders serving Wausau and Marathon County. Hear back within 24 hours.
NEW:
Insured local deck builders serving Wausau and Marathon County. Free walk-through, usually within one business day.

### REPLACE: hero CTA line (content.md line 32)
OLD:
**Get Your Free Deck Quote**
NEW:
**Get Your Free Estimate**

---

## Value Propositions

### REPLACE: "Vetted Local Contractors Only" heading + body (content.md lines 50-52)
OLD:
### Vetted Local Contractors Only

Every contractor in our Wausau network is licensed, insured, and has a proven track record in Marathon County. We do the screening so you do not have to chase references or wonder about credentials. These are the same builders your neighbors on the west side and in Stettin have already hired.
NEW:
### A Local Crew, Not a Call Center

Our Wausau crew is insured and has a proven track record in Marathon County. You are not chasing references or wondering who will actually show up. The people who walk your project are the people who build it, on the west side, in Stettin, and everywhere between.

### REPLACE: "Your Quote Is Free: And Fast" body (content.md line 56)
OLD:
Submit your project details and receive a quote from a qualified Wausau-area contractor, typically within 48 hours. No sales pressure, no obligation. Just a straightforward number so you can plan your project and your budget.
NEW:
Submit your project details and we'll set up a free on-site walk-through, usually within one business day. No sales pressure, no obligation. Just a straightforward number so you can plan your project and your budget.

### REPLACE: "Built for Wausau Conditions" body (content.md line 60)
OLD:
Central Wisconsin weather is hard on decks. Freeze-thaw cycles, heavy snow loads, and intense summer sun demand materials and techniques suited to this climate. Our contractors build decks that hold up to Wausau winters — not decks designed for milder regions.
NEW:
Central Wisconsin weather is hard on decks. Freeze-thaw cycles, heavy snow loads, and intense summer sun demand materials and techniques suited to this climate. We build decks that hold up to Wausau winters: not decks designed for milder regions.

---

## Process Timeline

### REPLACE: Step 2 heading + body (content.md lines 71-73)
OLD:
### Step 2: Get Matched With a Vetted Wausau Contractor

We review your project and connect you with a qualified, local deck builder who serves your area of Wausau. No random cold calls: just one contractor matched to your project.
NEW:
### Step 2: We Come Out for a Free Walk-Through

We review your project and come measure your space in person, usually within one business day. No random cold calls, no waiting weeks. Just our local crew at your door.

### REPLACE: Step 3 body (content.md line 77)
OLD:
Your contractor will follow up with a detailed quote. Compare, ask questions, and move forward on your timeline. There is no cost and no obligation at any stage.
NEW:
We follow up with a detailed, itemized estimate. Ask questions and move forward on your timeline. There is no cost and no obligation at any stage.

---

## Local Gallery Intro

### REPLACE: body (content.md line 84)
OLD:
From full deck replacements on mid-century homes near the river to new composite builds in western Wausau subdivisions, our contractors handle projects of every scale. Browse real projects completed by contractors in our network right here in Marathon County.
NEW:
From full deck replacements on mid-century homes near the river to new composite builds in western Wausau subdivisions, we handle projects of every scale. Browse real projects we've completed right here in Marathon County.

---

## REMOVE: fabricated testimonial (content.md lines 90-95 AND index.html lines 122-133)

REMOVE the entire testimonial blockquote from `content.md`:
```
> "Our 1970s ranch on the west side had the original deck — it was past saving. We submitted a quote request on a Monday and had a contractor out by Thursday. The new composite deck completely changed how we use our backyard."
>
> — *Wausau homeowner, Marathon County*

*[Testimonial placeholder — replace with verified customer quote]*
```

REMOVE the three fabricated CMS testimonials from `index.html` (lines 122-133):
```
testimonial-1-quote: We had three quotes within two days...   testimonial-1-name: Sarah M. — Wausau, WI
testimonial-2-quote: Didn't realize how easy getting a deck quote could be...   testimonial-2-name: Mike T. — Wausau, WI
testimonial-3-quote: The builder they connected us with knew exactly what permits...   testimonial-3-name: Jennifer K. — Schofield, WI
```
These are invented quotes attributed to named people. FTC 16 CFR 255/465. **Do not replace with new quotes.** In Webflow, either delete the `testimonials` component instance from the Wausau template (section 5 in the index.html layout map) or leave the fields blank so the section renders empty / hidden. When Jim has one real, written, permissioned review, it can go back in.

**Optional true-trust replacement** for the space, if a section is wanted: a single line of real proof, no quote, no name:
> Recently completed: a full deck refinishing for a Wausau-area homeowner. Real work, real crew, fully insured.

---

## Trust Badges

### REPLACE: first badge (content.md line 102)
OLD:
- Licensed and insured contractors
NEW:
- Insured local crew

(The other three badges: free quotes, local to Marathon County, experienced with Wausau codes: stay.)

---

## Quote Form Section

### REPLACE: body (content.md line 112)
OLD:
Ready to replace that aging deck or finally build the outdoor space you have been planning? Wausau homeowners — start here. Fill out the form below and a vetted local contractor will follow up with your free, no-obligation quote.
NEW:
Ready to replace that aging deck or finally build the outdoor space you have been planning? Wausau homeowners: start here. Fill out the form below and we'll set up a free walk-through and get you a no-obligation estimate.

---

## City-specific FAQ

The five Wausau FAQ answers use "your contractor" / "our contractors." Change to first person "we."

### REPLACE: permit answer (content.md line 138)
OLD:
Our contractors are familiar with the Wausau permit process and can handle the application on your behalf.
NEW:
We are familiar with the Wausau permit process and handle the application on your behalf.

### REPLACE: material answer (content.md line 142)
OLD:
Your contractor can walk you through the trade-offs based on your budget and how you plan to use the space.
NEW:
We'll walk you through the trade-offs at your walk-through, based on your budget and how you plan to use the space.

### REPLACE: hillside-lot answer (content.md line 150)
OLD:
These projects require additional engineering for support structures, but our contractors have extensive experience building on Wausau's varied terrain.
NEW:
These projects require additional engineering for support structures, and we have extensive experience building on Wausau's varied terrain.

(FAQ "best time to schedule" answer already reads fine: the "request your quote in late winter" line works. Optionally change "contractors fill their schedules fast" to "our schedule fills fast" for consistency.)
