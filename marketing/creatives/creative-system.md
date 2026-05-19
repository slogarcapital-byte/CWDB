# CWDB Creative System — Ad Atoms & Tokens

Seed file. Grows via `/impeccable extract` after each creative batch. Every atom here should be reusable across platforms and campaigns.

**Last updated:** 2026-04-21 (seed).

---

## Tokens

### Color (sRGB hex, matched to site)

```css
:root {
  --cwdb-orange:      #e54c00;  /* CTA only — appears once per creative */
  --cwdb-slate:       #323434;  /* primary text on light; dark background */
  --cwdb-grey:        #646760;  /* trust-row text, fine print */
  --cwdb-off-white:   #f8f8f6;  /* primary light bg */
  --cwdb-white:       #ffffff;  /* secondary surface */
}
```

Wisconsin Sky (`#83b2cf`) is **not used in ads**. It competes with orange for attention. Site-only token.

### Type

```css
@import url('https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&family=Staatliches&display=swap');

:root {
  --cwdb-font-display: 'Staatliches', sans-serif;
  --cwdb-font-body:    'Public Sans', sans-serif;
}
```

### Spacing (4pt scale)

```css
:root {
  --cwdb-space-xs:  4px;
  --cwdb-space-sm:  8px;
  --cwdb-space-md:  16px;
  --cwdb-space-lg:  24px;
  --cwdb-space-xl:  40px;
  --cwdb-space-2xl: 64px;
}
```

---

## Atoms

### `.cwdb-hed` — Display headline

Staatliches 400, uppercase, 0.5px letter-spacing. Size is fluid via `clamp` so the same class works at 1080×1080 and 1200×628.

```css
.cwdb-hed {
  font-family: var(--cwdb-font-display);
  font-weight: 400;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  line-height: 0.95;
  color: var(--cwdb-slate);   /* or var(--cwdb-white) on dark compositions */
  font-size: clamp(56px, 9vw, 120px);
  margin: 0;
}
```

### `.cwdb-sub` — Sub-copy / primary text

Public Sans 500, 1.4 line-height, 65–75ch max width.

```css
.cwdb-sub {
  font-family: var(--cwdb-font-body);
  font-weight: 500;
  line-height: 1.4;
  color: var(--cwdb-slate);   /* or rgba(255,255,255,0.92) on dark */
  font-size: clamp(18px, 2vw, 28px);
  max-width: 28ch;
  margin: 0;
}
```

### `.cwdb-cta` — CTA pill

Orange background, white Public Sans 700 uppercase label, 4px radius (**not** pill-round — pill-round reads too "app-y"). Only ONE per creative.

```css
.cwdb-cta {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 16px 28px;
  background: var(--cwdb-orange);
  color: var(--cwdb-white);
  font-family: var(--cwdb-font-body);
  font-weight: 700;
  font-size: 16px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  border-radius: 4px;
  text-decoration: none;
}
```

### `.cwdb-trust-row` — Three-proof row

Three short proofs separated by middle-dots. Public Sans 600, 13px, tracked.

```css
.cwdb-trust-row {
  display: inline-flex;
  gap: 12px;
  font-family: var(--cwdb-font-body);
  font-weight: 600;
  font-size: 13px;
  letter-spacing: 1.2px;
  text-transform: uppercase;
  color: var(--cwdb-grey);
}
.cwdb-trust-row > span:not(:last-child)::after {
  content: "·";
  margin-left: 12px;
  opacity: 0.5;
}
```

Default proofs: `LICENSED · LOCAL · FIXED QUOTE`.

### `.cwdb-logo` — Logo lockup

Use the horizontal lockup. Pick the variant based on background luminance of the photo region it sits on.

```html
<!-- light/bright photo zone -->
<img class="cwdb-logo" src="/branding/logos/web/logo-horizontal@2x.png" alt="Central Wisconsin Deck Builders">

<!-- dark/shaded photo zone -->
<img class="cwdb-logo" src="/branding/logos/web/logo-horizontal@2x-white.png" alt="Central Wisconsin Deck Builders">
```

```css
.cwdb-logo {
  height: clamp(32px, 4vw, 56px);
  width: auto;
  display: block;
}
```

---

## Composition templates

Extraction will grow this section as patterns stabilize. Seed with two starters:

### Template A — Photo-dominant square (1080×1080)

```
+-------------------------------------+
|                                     |
|           [ hero photo ]            |
|         (60–70% of frame)           |
|                                     |
+-------------------------------------+
| logo                                |
|                                     |
| HEADLINE IN STAATLICHES             |
| two-line max                        |
|                                     |
| Sub-copy in Public Sans, one line.  |
|                                     |
| [ CTA PILL ]        LICENSED · LOCAL|
+-------------------------------------+
```

Photo occupies top ~640–700px. Type block sits on off-white below. Logo top-left of type block. Orange CTA bottom-left. Trust row bottom-right.

### Template B — Photo-full with text overlay (for dark-hero compositions)

```
+-------------------------------------+
|                                     |
|         [ full-bleed photo ]        |
|                                     |
|  logo (white)                       |
|                                     |
|  HEADLINE IN                        |
|  WHITE STAATLICHES                  |
|                                     |
|  [ CTA PILL ]                       |
|                                     |
+-------------------------------------+
```

Used when photo has a dark enough zone (shaded deck underside, dusk, interior lighting) to host type legibly. Add a 0–40% black vertical gradient scrim only if the photo alone doesn't carry enough contrast — never as decoration.

---

## Retired / rejected patterns

Log of patterns that were tried and cut. Future variants should not re-introduce these.

*(Empty — populated by `/impeccable extract` and agent memory over time.)*

---

## How this file grows

`/impeccable extract` runs at the end of every creative batch. It should:

1. Diff the new creative HTML against existing atoms — if a new reusable pattern emerged (new composition template, new type lockup, new overlay treatment), add it here.
2. Consolidate — if two creatives invented slightly different versions of the same atom, pick the better one and update both references.
3. Retire — if a pattern was tried and cut, move it to "Retired / rejected patterns" with a one-line reason.

Do not let this file turn into a dumping ground. Every atom should be in active use across at least two creatives.
