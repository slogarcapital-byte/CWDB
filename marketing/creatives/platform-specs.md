# Ad Platform Specs — Canonical Dimensions

Single source of truth for ad creative dimensions, safe zones, and file-size limits. The ad-campaign agent reads this before every creative so nothing is guessed.

**Last verified:** 2026-04-21. Platform specs drift; re-verify against each ad manager's help docs quarterly or when a new format ships.

---

## Meta (Facebook + Instagram)

### Feed placements (most common)

| Format | Dimensions | Aspect | File limit | Notes |
|---|---|---|---|---|
| Square | **1080 × 1080** | 1:1 | ≤30MB PNG/JPG | Works on both Facebook and Instagram feeds |
| Vertical | **1080 × 1350** | 4:5 | ≤30MB PNG/JPG | Instagram feed preferred — takes more vertical space |
| Landscape | **1200 × 628** | 1.91:1 | ≤30MB PNG/JPG | Facebook link-ad fallback, desktop feed |

### Stories / Reels

| Format | Dimensions | Aspect | Safe zones |
|---|---|---|---|
| Story | **1080 × 1920** | 9:16 | Top 250px (profile/username overlap) · Bottom 250px (CTA/sticker overlap). Keep logo, headline, and any text inside the middle 1420px. |
| Reel | **1080 × 1920** | 9:16 | Same safe zones as Story. Reels are video-first; static here rarely wins. |

### Copy character budgets (Meta lead-ad form flow)

- **Headline:** ≤40 characters (truncates beyond)
- **Primary text:** ≤125 characters above the fold (longer truncates behind "See more")
- **Description:** ≤30 characters (appears below headline on some placements)
- **CTA button:** fixed set (Meta-picked) — choose from "Get Quote," "Learn More," "Sign Up," "Apply Now," etc. The custom CTA lives on the creative itself.

### Text-on-image rule

Meta removed the hard 20%-text rule in 2020 but still penalizes text-heavy creatives in delivery. Keep total text area under ~25% of the frame. The Staatliches headline + one-line sub + logo + CTA pill at recommended sizes stays under this threshold.

---

## Google Ads — Responsive Display (RDA)

Google rotates through your uploaded assets to generate combinations. Upload the full matrix.

| Asset | Dimensions | Aspect | Purpose |
|---|---|---|---|
| Landscape image | **1200 × 628** | 1.91:1 | Primary horizontal display |
| Square image | **1200 × 1200** | 1:1 | Catches square feeds and mobile |
| Portrait image | **960 × 1200** | 4:5 | Mobile vertical display |
| Logo horizontal | **1200 × 300** | 4:1 | Required if you have one |
| Logo square | **1200 × 1200** | 1:1 | Required |
| Icon (favicon) | **314 × 314** | 1:1 | Optional but improves delivery |

**File limits:** ≤5MB per asset. PNG or JPG.

**Composition strategy:** One master composition at 1200×1200 square, then use CSS `object-position` to recrop the hero photo for the landscape and portrait variants. This keeps the headline + logo placement consistent across aspects instead of rebuilding each from scratch.

### Copy character budgets (Google RDA)

- **Short headlines:** ≤30 characters, up to 5 variants
- **Long headline:** ≤90 characters, 1 variant
- **Descriptions:** ≤90 characters, up to 5 variants
- **Business name:** ≤25 characters

---

## Nextdoor

Nextdoor's paid inventory is smaller than Meta's and its spec sheet changes more often. Safe defaults:

| Format | Dimensions | Aspect | File limit |
|---|---|---|---|
| Square post | **1080 × 1080** | 1:1 | ≤1MB preferred (upload will accept larger but compress aggressively) |
| Feed link | **1200 × 628** | 1.91:1 | ≤1MB preferred |

### Critical copy rule for Nextdoor

Copy must read as a **conversational neighbor post**, not as an ad. See `brand-voice-positioning.md` — Nextdoor is the only channel where the Handshake tone beats the Hammer tone. "Just got our deck quoted by a crew out of Wausau — 48 hours, no BS" wins. "Book your free quote today!" loses (and violates community guidelines).

---

## TikTok

| Format | Dimensions | Aspect | Safe zones |
|---|---|---|---|
| Full-screen video | **1080 × 1920** | 9:16 | Bottom third (~640px) belongs to the app UI (caption, CTA button, profile). Top ~150px owns the handle. Keep brand + hook inside the middle ~1130px. |

**TikTok warning:** Static poster creatives rarely perform on TikTok. If a TikTok creative is requested, the ad-campaign agent should flag that a video brief is needed and escalate rather than render a static 9:16. Static 9:16s ship to Meta Stories/Reels, not TikTok.

---

## Font-loading warning (applies to all platforms)

The Playwright renderer is Chromium without system fonts. Every creative HTML file **must** include the Google Fonts `<link>` for Staatliches + Public Sans in `<head>`, and must wait for fonts to load before the screenshot is taken. Suggested pattern:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&family=Staatliches&display=swap">
```

Before `browser_take_screenshot`, `browser_wait_for` text that uses each font face to confirm render, or `browser_evaluate("document.fonts.ready")`.

---

## Color-space note

Ad platforms display sRGB. OKLCH values in the design context are for perceptually-uniform *authoring* (palette construction, tint scaling). The actual HTML can use hex/rgb directly — Playwright's screenshot will export in sRGB. Do not embed an ICC profile in the PNG output.
