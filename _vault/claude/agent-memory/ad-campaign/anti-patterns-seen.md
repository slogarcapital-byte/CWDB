---
name: anti-patterns-seen
description: Log of AI-slop patterns caught during /critique or /polish on CWDB ad creatives. Each entry records what was caught and why it must not recur, so future creative batches do not regress toward generic AI output.
type: feedback
---

# Anti-Patterns Seen — CWDB Ad Creatives

Every time `/critique` or `/polish` flags a pattern that would have shipped and shouldn't have, add an entry here. This file is how the agent gets smarter about CWDB's specific brand-safety boundaries over time.

Not every critique flag belongs here — only patterns that are:
1. **Not already in the impeccable absolute bans** (those are enforced universally and don't need re-documenting)
2. **Specific to CWDB** — a trap this brand falls into that generic guidelines wouldn't catch
3. **Likely to recur** — if it's a one-off error, skip the entry

---

## Entry format

```markdown
### {short pattern name}

**What:** one-line description of the pattern.
**Caught in:** which creative/batch flagged it.
**Why it's wrong for CWDB:** the specific brand reason (tone violation, persona mismatch, competitive-brand resemblance, etc.).
**What to do instead:** the corrective pattern.
```

---

## Entries

### Wrong-photo-for-angle (pergola when the brief says deck)

**What:** Reached for `branding/logos/web/hero-wausau.webp` as the default "Wausau deck" hero without auditing the actual image content. The file is a pergola walkway in a garden — NOT a deck.
**Caught in:** launch-2026-04 batch · problem-solution-1080x1080 first render · 2026-04-21.
**Why it's wrong for CWDB:** Breaks "unmistakable as CWDB." A deck-builder ad showing a pergola asks the homeowner to do cognitive work that the 0.8-second thumb-stop window does not allow. Fails the "would they recognize this as ours without reading the logo" test, because the subject itself is wrong.
**What to do instead:** Before committing a photo to a creative, render a thumbnail sheet of ALL candidate assets (see `/marketing/launch-2026-04/creatives/_photo-audit.html` as a reference pattern). Do NOT trust filenames like "hero-wausau" to imply "deck in Wausau." The reliable verified-real WI deck inventory is in `/website/pages/gallery/project-photos/` — use that first; use the `/branding/logos/web/hero-*.webp` files only after visual verification. `hero-merrill.webp` is the one genuine lifestyle deck shot in the hero set; the rest are pergola / house exteriors / aerial landscape / etc.

### Orange tempted twice (eyebrow + CTA)

**What:** First pass of Seasonal Urgency used Crafted Orange for the "WISCONSIN SUMMER 2026" eyebrow label AND for the CTA pill.
**Caught in:** launch-2026-04 batch · seasonal-urgency-1080x1080 first draft · 2026-04-21.
**Why it's wrong for CWDB:** Violates the "Orange lies once" design principle locked in `/.impeccable.md`. Orange means "do this thing." Two orange affordances dilute the CTA's semantic load. At 0.8-second thumb-stop, the eye splits and the click rate suffers.
**What to do instead:** Enforce at render-time — after drafting HTML, scan the stylesheet for `--cwdb-orange` or `#e54c00`; it must occur in exactly one rule and that rule must be a CTA affordance. Substitute tinted eyebrows with white/78%-opacity on dark hero or Builders Grey on light. The "leading 28×2 tick before eyebrow label" pattern introduced on seasonal-urgency is a good neutral alternative — candidate for atom extraction.

### White-CTA-on-photo (because the orange was "clashing" with another orange)

**What:** Mid-draft I swapped the CTA pill from orange to white to visually "solve" a clash with an orange eyebrow. The actual problem was the orange eyebrow, not the orange CTA.
**Caught in:** launch-2026-04 batch · seasonal-urgency-1080x1080 · 2026-04-21.
**Why it's wrong for CWDB:** The CTA is a locked design atom. Desaturating it because another element is also orange is fixing the wrong thing. The CTA's orange is the brand's single load-bearing color signal — moving it loses brand recognition and reduces click affordance.
**What to do instead:** CTA is always `background: #e54c00; color: #ffffff; border-radius: 4px`. When another element is fighting the CTA for attention, tone the OTHER element down — the CTA is immovable.

---

## Patterns to watch for (seed list — convert to full entries when actually observed)

These are anticipated traps based on the `/impeccable` methodology and the CWDB brand context. They are NOT yet confirmed anti-patterns — they become real entries only if `/critique` catches them in production work.

- **"Outdoor living" language** — generic home-services vernacular, not how Wisconsin homeowners talk about decks. Risk: the creative reads as Pinterest, not as a neighbor.
- **Aspirational dawn/dusk photography with empty decks** — stock-magazine energy. The brand voice is plainspoken, not aspirational. Photos should feel like "my neighbor's deck," not "a deck I'll have someday."
- **Handshake icons, checkmark-list creatives, "5-step process" diagrams** — home-services ad-template clichés that signal "generic lead-gen ad" in 0.5 seconds.
- **Rounded-icon wrappers above headlines** — explicitly banned in the design system (`/website/design-system.md`) and a top AI-slop tell in display ads.
- **"Free quote" as the primary benefit** — every competitor says this. It's not a differentiator. The differentiator is speed + trust + vetted-not-marketplace.
- **CTA button copy "Learn More" or "Click Here"** — dead verbs. Use action + outcome: "Get My Quote," "See My Match," "Start My Deck."
- **Blue-dominant creatives** — Thumbtack/Angi/HomeAdvisor all use blue as primary. Our primary accent is orange. Any creative where blue reads as dominant is in the competitor color lane.
