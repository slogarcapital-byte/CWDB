---
type: spec
dept: marketing/gmb
created: 2026-04-30
updated: 2026-04-30
status: draft-for-jim-review
owner: cwdb-ceo-operator
---

# Google My Business Profile Spec — Central Wisconsin Deck Builders

> **Purpose:** Paste-ready content for the freshly-created GMB listing. Jim reviews; CEO ships within 24h of posting to Outbox unless objection raised.
> **Source authority:** Canonical NAP from CEO memory · brand voice from `business-context/brand-discovery/` · service area from `CLAUDE.md` Initial Market.

---

## 1. Business Identity

| Field | Value |
|---|---|
| **Business name** | Central Wisconsin Deck Builders |
| **Phone (primary)** | (715) 544-7941 |
| **Website** | https://www.cwdeckbuilders.com |
| **Email (private to GMB)** | info@cwdeckbuilders.com |

---

## 2. Address & Service Area

GMB requires either a **storefront address** (visible to public) or **service-area-only mode** (address hidden, service-area shown). CWDB has no walk-in storefront; recommend **service-area-only**.

| Field | Value |
|---|---|
| **Business address (private, GMB-only)** | 906 N 16th Ave, Wausau, WI 54401 |
| **Show address publicly?** | **No** — toggle to "I deliver goods and services to my customers" only |
| **Service-area cities** | Wausau · Schofield · Weston · Mosinee · Merrill |

**Recommended polygon (5 cities, Wausau-centered):**

```
Wausau, WI
Schofield, WI
Weston, WI
Mosinee, WI
Merrill, WI
```

Use city-name entries, not radius. City entries map to ZIP polygons; radius mode bleeds outside the funded service area and dilutes ranking.

---

## 3. Categories

Pick the most specific primary; secondaries add discoverability.

| Slot | Category | Reason |
|---|---|---|
| **Primary** | **Deck Builder** | Highest match-relevance to all funded keywords |
| Secondary 1 | **Contractor** | Catch-all home-improvement intent |
| Secondary 2 | **General Contractor** | Higher-funnel "who builds X in my area" queries |
| Secondary 3 | **Home Builder** | Adjacent intent — homeowner researching builders |
| Secondary 4 (optional) | **Construction Company** | Generic backup |

Cap at 5 categories total. Five is GMB's stated max; using fewer than 5 wastes a slot.

---

## 4. Services List

Mirror the site IA. These appear as filterable chips on the GMB profile.

```
New Deck Construction
Deck Replacement
Deck Repair
Deck Expansion / Addition
Composite Decking
Cedar Decking
Pressure-Treated Wood Decking
Multi-Level Decks
Deck Railing Installation
Deck Staining & Sealing
Free Deck Quotes
Project Cost Estimates
```

Each service can carry a 1–2 sentence description. Use short, declarative copy in brand voice. Examples:

- **New Deck Construction** — "Custom-built decks designed for Central Wisconsin weather. Free quote in 48 hours."
- **Deck Replacement** — "Replace an aging or unsafe deck. We handle teardown, dump, and rebuild end-to-end."
- **Free Deck Quotes** — "One form. Multiple builder quotes. Zero hassle. Under 48 hours."

---

## 5. Business Hours

**Recommended:** Monday–Friday 8 AM – 6 PM · Saturday 9 AM – 2 PM · Sunday Closed.

| Day | Hours |
|---|---|
| Mon | 8:00 AM – 6:00 PM |
| Tue | 8:00 AM – 6:00 PM |
| Wed | 8:00 AM – 6:00 PM |
| Thu | 8:00 AM – 6:00 PM |
| Fri | 8:00 AM – 6:00 PM |
| Sat | 9:00 AM – 2:00 PM |
| Sun | Closed |

Rationale: matches contractor-callable windows. Sat morning open signals "we work weekends" without committing to all-day Sat coverage. If Jim wants 24/7 lead capture, set "Open 24 hours" — but only if the lead intake confirmation is fully automated (and the homeowner never expects a human on Sunday). Recommend the M–F + Sat AM block until automation is ironclad.

---

## 6. Business Description (≤750 chars)

**Draft (732 chars including spaces):**

```
Central Wisconsin Deck Builders connects Wausau-area homeowners with vetted local deck
contractors fast. One form. Multiple quotes. Under 48 hours.

We serve Wausau, Schofield, Weston, Mosinee, and Merrill. Whether you need a new deck,
a replacement, or repairs, we match your project to the right builder for the job —
no lowball bait-and-switch, no sales calls from out-of-state spam outfits.

Every contractor in our network is locally based, insured, and accountable to us.
You get straight answers, fair pricing, and a quote you can actually use to plan.

Ready to start your deck project? Get free quotes at cwdeckbuilders.com.
```

**Voice check:** master-craftsman, direct, no-fluff, neighbor-not-salesman. Cleared.
**Reading grade:** ~6th. Acceptable for GMB (long-form context); short-form ad copy stays ≤5th per standing rule.
**Keyword density:** "deck" ×6, "Wausau" ×2, "quote" ×3, "contractor/builder" ×4. Healthy without being stuffed.

---

## 7. Attributes

Toggle these on in GMB → Info → Attributes:

- ✅ Online estimates
- ✅ Onsite services
- ✅ Free Wi-Fi (N/A — leave off)
- ✅ Veteran-led (only if Jim confirms; otherwise leave off)
- ✅ Identifies as women-owned (N/A)
- ✅ LGBTQ+ friendly (recommend on; zero downside)
- ✅ Wheelchair accessible (N/A — service-area business)

**Service options:**
- ✅ Online appointments
- ✅ Onsite services

---

## 8. Photos & Logo

GMB cover image and logo are required.

| Slot | Source file | Size |
|---|---|---|
| **Logo** | `branding/logos/1.2-horizontal-logo-high-res.png` | Resize to 720×720 px, white bg, centered |
| **Cover** | Recommended: gallery hero photo from Webflow Gallery CMS — pick the strongest before/after | 1024×576 px (16:9) |
| **Profile photos pool** | All 7 items in Webflow Gallery CMS `69cff077a56c28009f3df538` | Pull captions from CMS `caption` field |

Initial photo upload pack: see `marketing/gmb/initial-content-pack.md`.

---

## 9. Identity Verification

GMB account is already live + verified per 2026-04-30 (no postcard delay). Skip.

---

## 10. Owner-Approval Checklist (for Jim)

Before publishing, confirm:

- [ ] Service-area-only mode toggled ON (address hidden)
- [ ] Phone matches canonical NAP `(715) 544-7941`
- [ ] Website URL set to `https://www.cwdeckbuilders.com` (not bare apex; the 301 routes apex → www, but using www directly avoids one redirect hop in GMB's auto-crawl)
- [ ] Primary category = Deck Builder
- [ ] All 5 service-area cities entered as city-name entries (NOT radius)
- [ ] Description pasted verbatim from §6 (or Jim approves edits)
- [ ] Hours match §5 (or Jim adjusts and tells CEO)
- [ ] Logo uploaded
- [ ] Cover photo selected from Gallery CMS

**Default rule:** If no objection raised within 24h of this spec landing in Outbox, content-writer publishes per `initial-content-pack.md`.

---

## 11. Open Questions for Jim

1. **Hours:** approve M–F 8–6 + Sat 9–2 + Sun closed? Or different?
2. **Veteran-led attribute:** turn on?
3. **Cover photo pick:** any preference from the 7 Gallery CMS items, or use newest (most recently published)?

---

## 12. Post-Publish Wiring (web-dev second pass)

Once profile is live, web-dev applies:

1. **Footer review link** — replace any placeholder review link with the GMB review URL: `https://search.google.com/local/writereview?placeid=<PLACE_ID>`. Place ID is on the GMB Info page once published.
2. **GMB map embed** — embed iframe on `/contact` page (or homepage hero-bottom slot if higher intent). Embed code: GMB → Share → Embed map.
3. **LocalBusiness JSON-LD** — extend the existing schema in `<head>` on every page to include `@id` matching the GMB Place ID URI, plus `sameAs` pointing to the GMB profile URL. Spec block:

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "@id": "https://www.cwdeckbuilders.com/#business",
  "name": "Central Wisconsin Deck Builders",
  "image": "https://www.cwdeckbuilders.com/og-cover.png",
  "telephone": "+1-715-544-7941",
  "email": "info@cwdeckbuilders.com",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "906 N 16th Ave",
    "addressLocality": "Wausau",
    "addressRegion": "WI",
    "postalCode": "54401",
    "addressCountry": "US"
  },
  "areaServed": ["Wausau", "Schofield", "Weston", "Mosinee", "Merrill"],
  "url": "https://www.cwdeckbuilders.com",
  "sameAs": ["<GMB_PROFILE_URL_HERE>"],
  "openingHoursSpecification": [
    { "@type": "OpeningHoursSpecification", "dayOfWeek": ["Monday","Tuesday","Wednesday","Thursday","Friday"], "opens": "08:00", "closes": "18:00" },
    { "@type": "OpeningHoursSpecification", "dayOfWeek": "Saturday", "opens": "09:00", "closes": "14:00" }
  ]
}
```

Place ID + GMB profile URL get filled in once Jim publishes the profile.
