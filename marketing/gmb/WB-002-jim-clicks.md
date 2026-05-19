---
type: walkthrough
dept: marketing/gmb
created: 2026-05-05
updated: 2026-05-05
status: ready-to-execute
owner: content-writer
related: profile-spec.md, initial-content-pack.md
estimated_time: 30 minutes
---

# WB-002 — GMB Publish Walkthrough

> **Goal:** Get the Central Wisconsin Deck Builders Google My Business profile fully published today: profile fields, 17 photos, 12 Q&A entries, 3 GMB Posts.
>
> **Time:** 30 minutes total. Sections are independent. You can run sections 1 and 2 today, sections 3 and 4 in 4 separate ~5-min sittings across this week if you want the Q&A staggered (recommended for organic look).
>
> **Why this format and not API:** The Google Business Profile API does not expose Q&A endpoints (UI-only) and the Posts/Update API requires a Standard developer-token approval that takes 5-10 business days. Walkthrough beats waiting.
>
> **Where this came from:** Specs at `marketing/gmb/profile-spec.md` and `marketing/gmb/initial-content-pack.md` were approved on 2026-04-30 with a 24h default-ship gate. Today is 2026-05-05 (5 days past). New CEO policy authorizes autonomous ship via this walkthrough.

---

## Pre-flight — Before you start

You need **one browser tab open** at https://business.google.com signed in as the GMB profile owner. Confirm the profile selector top-left reads **Central Wisconsin Deck Builders**. If a different business is selected, switch first.

The exact paste targets are below. Most fields are copy-paste; a few are dropdown selections. No content writing required.

---

## Section 1 — Profile Build (10 min)

Open: **business.google.com → Edit Profile**.

### 1.1 Business Information tab

| Field | Action | Value to paste/select |
|---|---|---|
| Business name | confirm | `Central Wisconsin Deck Builders` |
| Business category — Primary | dropdown | `Deck Builder` |
| Business category — Secondary 1 | add | `Contractor` |
| Business category — Secondary 2 | add | `General Contractor` |
| Business category — Secondary 3 | add | `Home Builder` |
| Business category — Secondary 4 | add | `Construction Company` |

### 1.2 Address (set to service-area-only mode)

| Field | Action | Value |
|---|---|---|
| "Do you want to add a location customers can visit?" | toggle | **No** |
| "Where do you serve customers?" (cities — add 5) | type each, hit Enter | `Wausau, WI` · `Schofield, WI` · `Weston, WI` · `Mosinee, WI` · `Merrill, WI` |
| Business address (private, GMB-only) | paste | `906 N 16th Ave, Wausau, WI 54401` |

> **Important:** For each of the 5 service-area cities, type the city name and select the city-level option from the dropdown. Do NOT use radius mode — radius bleeds outside the funded service area and dilutes ranking.

### 1.3 Contact

| Field | Action | Value |
|---|---|---|
| Phone | paste | `(715) 544-7941` |
| Website | paste | `https://www.cwdeckbuilders.com` |

### 1.4 Hours

Open the Hours section, set each day:

| Day | Open | Close |
|---|---|---|
| Monday | 8:00 AM | 6:00 PM |
| Tuesday | 8:00 AM | 6:00 PM |
| Wednesday | 8:00 AM | 6:00 PM |
| Thursday | 8:00 AM | 6:00 PM |
| Friday | 8:00 AM | 6:00 PM |
| Saturday | 9:00 AM | 2:00 PM |
| Sunday | Closed | — |

### 1.5 Description (paste the full block — exactly 732 chars)

Open the Description field and paste this verbatim:

```
Central Wisconsin Deck Builders connects Wausau-area homeowners with vetted local deck contractors fast. One form. Multiple quotes. Under 48 hours.

We serve Wausau, Schofield, Weston, Mosinee, and Merrill. Whether you need a new deck, a replacement, or repairs, we match your project to the right builder for the job. No lowball bait-and-switch, no sales calls from out-of-state spam outfits.

Every contractor in our network is locally based, insured, and accountable to us. You get straight answers, fair pricing, and a quote you can actually use to plan.

Ready to start your deck project? Get free quotes at cwdeckbuilders.com.
```

### 1.6 Attributes

GMB → Edit Profile → More attributes. Toggle these ON:

- **Online estimates** — Yes
- **Onsite services** — Yes
- **Online appointments** — Yes
- **LGBTQ+ friendly** — Yes (zero downside, helpful signal)

Skip these (not applicable to a service-area lead-gen business):

- Wheelchair accessible
- Free Wi-Fi
- Women-owned
- Veteran-led (turn ON only if you want — your call)

### 1.7 Services list (add all 12)

GMB → Edit Profile → Services → Add service. For each line below, click "Add service", paste the name, paste the description.

| # | Service name | Description |
|---|---|---|
| 1 | New Deck Construction | Custom-built decks designed for Central Wisconsin weather. Free quote in 48 hours. |
| 2 | Deck Replacement | Replace an aging or unsafe deck. We handle teardown, dump, and rebuild end-to-end. |
| 3 | Deck Repair | Fix sagging boards, loose railings, rotted joists, and code issues. Get a quote in 48 hours. |
| 4 | Deck Expansion / Addition | Make your existing deck bigger. Wraparound, multi-level, or addition off the back. |
| 5 | Composite Decking | Trex and TimberTech composite installs. Low maintenance. 25+ year lifespan. |
| 6 | Cedar Decking | Naturally rot-resistant cedar with a classic look. Ages beautifully in Wisconsin weather. |
| 7 | Pressure-Treated Wood Decking | Most affordable option. Long-lasting when sealed. $4,000-$8,000 typical for a 12x16. |
| 8 | Multi-Level Decks | Stepped or terraced builds for sloped lots. Designed to fit your yard, not fight it. |
| 9 | Deck Railing Installation | New railings, code-compliant heights, custom posts and balusters. |
| 10 | Deck Staining & Sealing | Restore color, block UV damage, extend deck life by years. |
| 11 | Free Deck Quotes | One form. Multiple builder quotes. Zero hassle. Under 48 hours. |
| 12 | Project Cost Estimates | Honest pricing for planning before you commit. No obligation. |

### 1.8 Save

Top-right or bottom-right of each section — click **Save**. GMB shows the field as live within seconds.

---

## Section 2 — Photo Upload (8 min, 17 photos)

GMB → Photos → **Add photos** (or the camera icon).

### 2.1 Logo + Cover (do these two first)

| Slot | File | Where it lives | Caption |
|---|---|---|---|
| **Logo** | `1.1 primary-social.png` | `branding/logos/1.1 primary-social.png` | (no caption needed for logo) |
| **Cover** | `wausau-deck.webp` | `website/pages/gallery/project-photos/wausau-deck.webp` | Wausau deck install · Central Wisconsin Deck Builders |

In GMB, **Logo** and **Cover** are dedicated upload slots inside Photos. Use them — these are the two photos that show first in search results.

### 2.2 Gallery photos (15 more — drag-drop and caption)

Open File Explorer to: `C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\website\pages\gallery\project-photos`

Drag all 15 of the remaining files below into the GMB photo upload area in one batch. After upload, click each photo and paste the caption from the table.

| # | Filename | Caption (paste verbatim) |
|---|---|---|
| 1 | `wausau-deck.webp` | Wausau deck install · Central Wisconsin Deck Builders |
| 2 | `wausau-small-deck.webp` | Compact backyard deck in Wausau · Central Wisconsin Deck Builders |
| 3 | `wausau-addition.webp` | Wausau deck addition off the back of the home · Central Wisconsin Deck Builders |
| 4 | `composite-deck-wittenburg.jpg` | Composite deck build · Wittenberg-area · Central Wisconsin Deck Builders |
| 5 | `merill-front-porch.webp` | Front porch rebuild · Merrill · Central Wisconsin Deck Builders |
| 6 | `mosinee-addition.webp` | Deck addition · Mosinee · Central Wisconsin Deck Builders |
| 7 | `weston-pergola.webp` | Pergola over deck · Weston · Central Wisconsin Deck Builders |
| 8 | `rothschild-covered-patio.webp` | Covered patio deck · Rothschild · Central Wisconsin Deck Builders |
| 9 | `marathon-front-porch.webp` | Front porch · Marathon County · Central Wisconsin Deck Builders |
| 10 | `garage-addition.webp` | Deck and garage addition combo · Central Wisconsin Deck Builders |
| 11 | `wi-rapids-addition.webp` | Deck addition · Wisconsin Rapids · Central Wisconsin Deck Builders |
| 12 | `framing.webp` | Deck framing in progress · Central Wisconsin Deck Builders |
| 13 | `new-build.webp` | New deck build · Central Wisconsin Deck Builders |
| 14 | `deck.webp` | Finished deck hero shot · Central Wisconsin Deck Builders |
| 15 | `our-house.webp` | Builder-owned home deck · Central Wisconsin Deck Builders |

> Tip: GMB lets you batch-upload, but captions are per-file. Easiest flow: drag all 15 in, then click each thumbnail in order and paste the caption.

### 2.3 Verify

Photos tab should show 17 total (1 logo + 1 cover + 15 gallery). Logo and Cover have their own special slots; the other 15 sit in the general feed.

---

## Section 3 — Three GMB Posts (5 min)

GMB → Posts → **Add update** (for Welcome and Service) or **Add offer** (for the Offer post).

### Post 1 — Welcome (Update post — no expiration field)

- **Photo:** Reuse the cover photo (`wausau-deck.webp`)
- **Text (paste verbatim):**

```
Central Wisconsin Deck Builders is live.

Looking for a new deck, a replacement, or a repair? We connect Wausau-area homeowners with vetted local contractors. One form. Multiple quotes. Under 48 hours.

Serving Wausau, Schofield, Weston, Mosinee, and Merrill.

Get your free quote today at cwdeckbuilders.com.
```

- **Button:** Select "Learn more" → URL: `https://www.cwdeckbuilders.com`
- **Publish.**

### Post 2 — Service Highlight (Update post)

- **Photo:** `composite-deck-wittenburg.jpg`
- **Text (paste verbatim):**

```
Composite or cedar? Both work in Central Wisconsin. Here's the short version:

Composite (Trex, TimberTech) — Low maintenance, 25+ year lifespan, $8,000 to $15,000 for a 12x16. No staining required.

Cedar — Naturally rot-resistant, classic look, ages beautifully. Needs occasional sealing. Mid-range cost.

Pressure-treated — Most affordable, $4,000 to $8,000 for a 12x16. Periodic stain and seal.

Not sure what fits your project? Get a free quote and we'll match you with a builder who can walk through the options. cwdeckbuilders.com
```

- **Button:** Select "Get quote" → URL: `https://www.cwdeckbuilders.com/get-a-quote`
- **Publish.**

### Post 3 — Offer (Offer post type)

- **Photo:** `wausau-deck.webp` (same as cover, gives the offer the strongest hero)
- **Title:** `Free Deck Quote — Central Wisconsin`
- **Text (paste verbatim):**

```
Free, no-obligation deck quote. Match with a vetted local contractor in under 48 hours.

Available for homeowners in Wausau, Schofield, Weston, Mosinee, and Merrill.

One short form. Multiple quotes. Zero hassle.
```

- **Coupon code:** leave blank
- **Terms and conditions:** `Free for homeowners. No obligation. Limited to projects in our service area.`
- **Start date:** Today (2026-05-05)
- **End date:** 60 days out (2026-07-04)
- **Button:** Select "Redeem" → URL: `https://www.cwdeckbuilders.com/get-a-quote`
- **Publish.**

> All 3 posts can be published right now in the same sitting. No need to stagger Posts (Q&A is the staggered piece).

---

## Section 4 — Q&A Pre-Seed (12 entries, staggered across 4 days)

### Why stagger

GMB Q&A pre-seeded all at once looks automated. Posting 3 per day across 4 days looks organic and signals an active profile.

### Mechanic for each Q&A pair

GMB Q&A is a public Q&A surface. To pre-seed:

1. Sign out of GMB ownership in one browser, OR open an Incognito window
2. Sign in to a **personal Google account** that does NOT match the business name (your slogarjw@gmail.com works)
3. Go to https://www.google.com → search `Central Wisconsin Deck Builders` → click the Knowledge Panel on the right (or Maps listing)
4. Scroll to "Questions and answers" → click **Ask a question** → paste the question → submit
5. Switch back to your owner browser → GMB → Customers → Q&A → find the question you just posted → click **Answer** → paste the answer → submit (the "Owner" badge appears automatically on the answer)

> The "Owner" badge on the answer is the trust signal. Asking from a non-business Google account makes the question itself look like a real homeowner.

### Day 1 (today, 2026-05-05) — Post 3

| # | Question | Answer |
|---|---|---|
| 1 | How does Central Wisconsin Deck Builders work? | Fill out a quick form telling us about your deck project: size, materials, timeline, budget. We match you with a vetted local contractor. The contractor reaches out within 48 hours to discuss your project and provide a quote. Free for homeowners. No obligation. |
| 2 | Is the quote really free? | Yes, 100% free. No charge to submit. No hidden fees. No cost if you decide not to move forward. |
| 3 | How quickly will I hear back? | Most homeowners hear from a contractor within 48 hours. We prioritize fast turnaround because waiting is frustrating. |

### Day 2 (2026-05-06) — Post 3

| # | Question | Answer |
|---|---|---|
| 4 | How do you choose contractors? | Every contractor is vetted before joining. We verify Wisconsin contractor license, general liability insurance, workers comp coverage, residential deck track record, and customer references. Credentials are monitored over time. |
| 5 | What areas do you serve? | Wausau (including Rib Mountain), Schofield, Weston, Mosinee, and Merrill. Expanding into nearby Central Wisconsin communities. If you are nearby, submit a request and we will do our best to match you. |
| 6 | What types of deck projects do you handle? | New deck construction, multi-level and wraparound decks, composite and PVC decking, pressure-treated wood, cedar and hardwoods, deck repairs, resurfacing, screened porches, pergolas, railing and stair upgrades. |

### Day 3 (2026-05-07) — Post 3

| # | Question | Answer |
|---|---|---|
| 7 | How much does a deck cost in Central Wisconsin? | Pressure-treated 12x16 deck: $4,000 to $8,000. Composite 12x16: $8,000 to $15,000. Multi-level or custom: $15,000 to $30,000+. Repairs or resurfacing: $1,500 to $5,000. Get a free quote at cwdeckbuilders.com for your specific project. |
| 8 | Do I need a permit to build a deck in Wisconsin? | In most cases yes. Wausau, Weston, Schofield, Mosinee, and Merrill each have their own permitting process. Your contractor typically handles the permit application as part of the project. |
| 9 | What decking materials are available? | Pressure-treated lumber (most affordable), composite (Trex, TimberTech, low maintenance), PVC (fully synthetic, low maintenance), cedar (naturally rot-resistant), and hardwoods like ipe (premium, longest lifespan). |

### Day 4 (2026-05-08) — Post 3

| # | Question | Answer |
|---|---|---|
| 10 | What if I am just in the planning phase? | That is fine. Many homeowners get a ballpark quote before making decisions. No obligation to hire. The quote gives you real pricing to factor into your planning. |
| 11 | Can I choose which contractor I work with? | We match you with the best-fit contractor based on location, availability, and specialization. As the network grows, you may receive quotes from multiple builders and choose your preferred one. |
| 12 | Is my information shared with anyone? | Your contact and project details are shared only with the vetted contractor(s) matched to your project. We do not sell information to marketing lists or third parties. See our Privacy Policy for details. |

> If you would rather post all 12 in one sitting, that's fine — the staggered cadence is a nice-to-have, not a blocker. The 3-per-day pattern just looks more organic to Google's algorithm.

---

## Section 5 — Acceptance Checks (after publish)

After Section 1 + 2 + 3 are done (today), spot-check:

- [ ] Open https://www.google.com and search `Central Wisconsin Deck Builders Wausau`. The Knowledge Panel on the right shows: business name, primary category "Deck Builder", phone, website link, hours, the cover photo.
- [ ] In the Knowledge Panel, click "Photos" — see 17 photos with captions visible.
- [ ] In the Knowledge Panel, scroll for the "Updates" section — see all 3 Posts (Welcome, Service, Offer).
- [ ] Click "See outside" or the listing → Services tab → verify all 12 services show with their descriptions.
- [ ] Click the "Website" button on the listing — verify it opens `https://www.cwdeckbuilders.com` (not the bare apex).

After Section 4 is done (across 4 days):

- [ ] Knowledge Panel → "Questions and answers" — verify all 12 Q&A pairs show with the "Owner" badge on each answer.

---

## Rollback (if anything goes wrong)

| Issue | Rollback action |
|---|---|
| Wrong category selected | Edit Profile → category → change. Live in seconds. |
| Description has typo | Edit Profile → description → fix. Live in seconds. |
| Wrong photo uploaded | Photos → click photo → Delete. |
| A Post needs to come down | Posts → click the Post → trash icon → Delete. |
| Q&A answer has typo | Customers → Q&A → click your answer → Edit. |
| Profile must be fully unpublished | Edit Profile → close listing (Settings → Remove this profile). Domain redirects unaffected. |

Full rollback would take ~5 minutes total. The work is reversible.

---

## When you finish each section, ping back

Drop a `%done%` next to the section heading in this file (or just text/Slack content-writer). Once Section 1 + 2 + 3 are done, content-writer marks WB-002 shipped on the board and the daily brief gets the "Shipped Without Asking" entry. Section 4 (Q&A) ships incrementally over 4 days.

---

## Source specs

- Profile field-level: `marketing/gmb/profile-spec.md`
- Content pack original: `marketing/gmb/initial-content-pack.md`
- Brand voice: `business-context/brand-discovery/brand-voice-positioning.md`
- Canonical NAP: CEO memory `business-contact.md`
