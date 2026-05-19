---
type: spec
dept: marketing/gmb
created: 2026-04-30
updated: 2026-04-30
status: draft-for-jim-review
owner: cwdb-ceo-operator
sibling: profile-spec.md
---

# GMB Initial Content Pack — Central Wisconsin Deck Builders

> **Purpose:** Day-1 content drop for the freshly-published GMB profile. Three pieces:
> 1. **Photo manifest + captions** — pulled from Webflow Gallery CMS
> 2. **Q&A pre-seed** — port the 12 site FAQs into GMB Q&A format (partial proof surrogate while reviews are gated on first close)
> 3. **3 GMB Posts** — Welcome / Service Highlight / Offer
>
> Default ship rule: 24h after this lands in Outbox with no Jim objection.

---

## Part 1 — Photo Pack (10–20 photos, captioned)

### Source

Pull all 7 items from Webflow Gallery CMS (`69cff077a56c28009f3df538`). Each item has photo + `caption` field already populated. **Augment** with up to 13 additional photos to hit the 20-photo target — pull from the same staging-area or have Jim email/upload contractor-supplied jobsite photos.

### Photo categories to fill (target distribution)

| Category | Count | Source |
|---|---|---|
| Finished decks (hero shots) | 5–7 | Webflow Gallery CMS items 1–7 |
| Before/after pairs | 2–4 | Stitch from existing CMS or contractor request |
| Materials close-ups (composite, cedar, PT) | 2–3 | Stock-allowed if labeled honestly |
| Process photos (framing, footings, install) | 2–3 | Contractor request |
| Logo + brand (1) | 1 | `1.2-horizontal-logo-high-res.png` resized to 720×720 |
| Cover photo (1) | 1 | Best CMS hero photo, 1024×576 |

**Cap:** GMB allows ~100 photos but flags as spammy past ~25 in Week 1. Ship 10–20 at launch; trickle 1–2/week to maintain freshness signal.

### Caption template (every photo)

```
[1-line description] · [city served] · Central Wisconsin Deck Builders
```

Examples (port from Webflow Gallery `caption` field where present):

- `Multi-level cedar deck with built-in bench · Wausau · Central Wisconsin Deck Builders`
- `Composite deck rebuild over existing footings · Schofield · Central Wisconsin Deck Builders`
- `Pressure-treated 12×16 starter deck · Mosinee · Central Wisconsin Deck Builders`
- `Composite vs cedar boards — close-up texture comparison · Central Wisconsin Deck Builders`

### Upload workflow (Jim 5-min task once approved)

1. GMB → Photos → Add photos
2. Drag-drop the 10–20 file batch
3. Paste caption per file from this manifest
4. Set Cover (the 16:9 hero) and Logo (the 720×720 brand mark)

---

## Part 2 — Q&A Pre-Seed (12 entries — port from site FAQ)

### Why pre-seed?

GMB Q&A is **public, owner-postable, and crawled for local SEO**. Owner-asked + owner-answered Q&A pairs are an officially-supported tactic — they let CWDB control the answer narrative before a competitor or random user posts a misleading question. While reviews stay structurally blocked (Lever 4 — first deal not yet closed), Q&A is the cleanest partial-proof surrogate available.

### Format per entry

GMB Q&A workflow:

1. Sign in as profile owner
2. GMB → Customers → Q&A → "Ask a question" (post as the public-facing user)
3. Switch to admin → "Answer" (now the post shows owner-verified answer)

**Critical:** Question is posted under the owner's *Google account name* (Jim's). Recommend posting from a personal Google account that does NOT match the GMB business name — looks more authentic. The "Owner" badge appears on the answer regardless.

### The 12 ports

| # | Question (paste verbatim) | Answer (paste verbatim) |
|---|---|---|
| 1 | How does Central Wisconsin Deck Builders work? | Fill out a quick form telling us about your deck project — size, materials, timeline, budget. We match you with a vetted local contractor. The contractor reaches out within 48 hours to discuss your project and provide a quote. Free for homeowners. No obligation. |
| 2 | Is the quote really free? | Yes — 100% free. No charge to submit. No hidden fees. No cost if you decide not to move forward. |
| 3 | How quickly will I hear back? | Most homeowners hear from a contractor within 48 hours. We prioritize fast turnaround because waiting is frustrating. |
| 4 | How do you choose contractors? | Every contractor is vetted before joining. We verify Wisconsin contractor license, general liability insurance, workers' comp coverage, residential deck track record, and customer references. Credentials are monitored over time. |
| 5 | What areas do you serve? | Wausau (including Rib Mountain), Schofield, Weston, Mosinee, and Merrill. Expanding into nearby Central Wisconsin communities. If you're nearby, submit a request — we'll do our best to match you. |
| 6 | What types of deck projects do you handle? | New deck construction, multi-level and wraparound decks, composite and PVC decking, pressure-treated wood, cedar and hardwoods, deck repairs, resurfacing, screened porches, pergolas, railing and stair upgrades. |
| 7 | How much does a deck cost in Central Wisconsin? | Pressure-treated 12×16 deck: $4,000–$8,000. Composite 12×16: $8,000–$15,000. Multi-level or custom: $15,000–$30,000+. Repairs or resurfacing: $1,500–$5,000. Get a free quote at cwdeckbuilders.com for your specific project. |
| 8 | Do I need a permit to build a deck in Wisconsin? | In most cases yes. Wausau, Weston, Schofield, Mosinee, and Merrill each have their own permitting process. Your contractor typically handles the permit application as part of the project. |
| 9 | What decking materials are available? | Pressure-treated lumber (most affordable), composite (Trex, TimberTech — low maintenance), PVC (fully synthetic, low maintenance), cedar (naturally rot-resistant), hardwoods like ipe (premium, longest lifespan). |
| 10 | What if I'm just in the planning phase? | That's fine. Many homeowners get a ballpark quote before making decisions. No obligation to hire. The quote gives you real pricing to factor into your planning. |
| 11 | Can I choose which contractor I work with? | We match you with the best-fit contractor based on location, availability, and specialization. As the network grows, you may receive quotes from multiple builders and choose your preferred one. |
| 12 | Is my information shared with anyone? | Your contact and project details are shared only with the vetted contractor(s) matched to your project. We do not sell information to marketing lists or third parties. See our Privacy Policy for details. |

**Posting cadence:** Don't dump all 12 at once — post 3 per day across 4 days. Staggered posts look organic; bulk drop looks automated.

---

## Part 3 — Three GMB Posts (Welcome / Service / Offer)

GMB Posts appear on the profile and surface in local search. Posts expire after 7 days (except Offer posts, which can have explicit dates). Cadence target post-launch: 3 per week.

### Post 1 — Welcome / Brand Intro (Update post, no expiration)

**Image:** Cover photo (the 1024×576 hero from Gallery CMS)
**Title:** N/A (Update posts have no title field)
**Body (≤1500 chars; recommended ≤300 for mobile readability):**

```
Central Wisconsin Deck Builders is live.

Looking for a new deck, a replacement, or a repair? We connect Wausau-area
homeowners with vetted local contractors. One form. Multiple quotes. Under 48 hours.

Serving Wausau, Schofield, Weston, Mosinee, and Merrill.

Get your free quote today at cwdeckbuilders.com.
```

**Button:** "Learn more" → `https://www.cwdeckbuilders.com`

---

### Post 2 — Service Highlight (Update post)

**Image:** Composite-vs-cedar materials close-up (or strongest finished-deck hero if no materials shot available)
**Body:**

```
Composite or cedar? Both work in Central Wisconsin. Here's the short version:

Composite (Trex, TimberTech) — Low maintenance, 25+ year lifespan, $8,000–$15,000
for a 12×16. No staining required.

Cedar — Naturally rot-resistant, classic look, ages beautifully. Needs occasional
sealing. Mid-range cost.

Pressure-treated — Most affordable, $4,000–$8,000 for a 12×16. Periodic stain/seal.

Not sure what fits your project? Get a free quote and we'll match you with a builder
who can walk through the options. cwdeckbuilders.com
```

**Button:** "Get quote" → `https://www.cwdeckbuilders.com/get-a-quote`

---

### Post 3 — Offer (Offer post type, with explicit dates)

**Image:** Strongest finished-deck hero photo
**Title:** Free Deck Quote — Central Wisconsin
**Body:**

```
Free, no-obligation deck quote. Match with a vetted local contractor in under 48 hours.

Available for homeowners in Wausau, Schofield, Weston, Mosinee, and Merrill.

One short form. Multiple quotes. Zero hassle.
```

**Coupon code:** None — leave blank
**Terms:** "Free for homeowners. No obligation. Limited to projects in our service area."
**Start date:** Day of publish
**End date:** Day of publish + 60 days
**Button:** "Redeem" → `https://www.cwdeckbuilders.com/get-a-quote`

---

## Part 4 — Posting Cadence Beyond Launch

Once the launch pack is live, hand off to content-writer on a weekly maintenance cycle:

| Cadence | Asset | Owner |
|---|---|---|
| 3× per week | New GMB Post (Update or Offer) | content-writer |
| 1× per week | New photo upload (1–2 photos with captions) | content-writer (sourced from contractor jobsite shots if available, gallery-cycled if not) |
| Weekly | Q&A monitoring — answer any user-posted question within 24h | content-writer |
| Monthly | Refresh Offer post (start/end dates) | content-writer |
| First closed deal | Trigger lead-routing review-request flow | lead-routing (gated) |

---

## Part 5 — Owner-Approval Checklist (for Jim, before publish)

- [ ] Profile spec (`profile-spec.md`) approved or edits requested
- [ ] Photo cover pick confirmed (or use newest CMS hero by default)
- [ ] OK to post Q&A pre-seed under Jim's personal Google account
- [ ] OK to publish 3 Posts (Welcome / Service / Offer) at launch
- [ ] OK with weekly content-writer maintenance cadence above

**Default ship:** No objection within 24h of this landing in Outbox → content-writer publishes per spec.

---

## Part 6 — Open Questions for Jim

1. Any contractor-supplied jobsite photos to add to the 7-photo Webflow Gallery base, getting closer to the 20-photo target?
2. OK to post Q&A under your personal Google account (looks more authentic than CWDB-account self-asking)?
3. Want me to add a 4th post — testimonial-shaped — once first deal closes? (Templated and ready, just gated.)
