# `/marketing/creatives/`

Static ad creative production pipeline for CWDB. Every PNG/JPG that gets uploaded to Meta, Google Display, Nextdoor, or TikTok originates here.

Owned by the **ad-campaign** agent (`.claude/agents/ad-campaign.md`). Methodology is the `/impeccable` skill's `craft` / `teach` / `extract` loop.

---

## Folder structure

```
/marketing/creatives/
├── README.md                       ← you are here
├── creative-system.md              ← extracted atoms/tokens (grown by /impeccable extract)
├── platform-specs.md               ← exact pixel dimensions, safe zones, file-size limits
├── briefs/
│   └── {campaign-tag}-{angle-tag}-brief.md
├── meta/
│   └── {campaign-tag}/
│       ├── {angle-tag}-v1.html     ← source
│       ├── {angle-tag}-v1.png      ← rendered via Playwright
│       └── {angle-tag}-v1-notes.md ← rationale, copy, photo choice, any ban-break justification
├── google-display/
│   └── {campaign-tag}/
│       ├── landscape-1200x628/
│       ├── square-1200x1200/
│       ├── portrait-960x1200/
│       └── logo-variants/
├── nextdoor/
│   └── {campaign-tag}/
└── tiktok/
    └── {campaign-tag}/
```

---

## Naming conventions

**Campaign tag:** `{program}-{year}-{month}` — e.g. `launch-2026-04`, `summer-2026-06`.

**Angle tag:** short kebab-case benefit-name — e.g. `fast-quotes`, `backyard-season`, `fixed-price`, `neighbor-proof`.

**Variant number:** `v1`, `v2`, `v3` — one per distinct execution of the same angle.

**Full example:** `launch-2026-04-fast-quotes-v2.html`

Rendered PNG sits beside the HTML with the same basename. Notes file is `{basename}-notes.md`.

---

## Brief format

Every campaign gets a brief in `/marketing/creatives/briefs/` before any creative is written. Minimum fields:

```markdown
# {Campaign Tag} — {Angle Tag}

## Angle
One sentence on the benefit this batch tests.

## Copy
- Headline (≤30 char for Google, ≤40 char for Meta)
- Sub / primary text (≤125 char for Meta feed)
- CTA ("Get My Quote", "See How It Works", etc.)

## Photo
Which hero photo and why (e.g. `hero-wausau.webp` — dusk light, classic cedar rail, reads as "my neighbor's deck").

## Platforms + dimensions
Which platforms this brief produces for, and which sizes per platform.

## Success criteria
CPL target and kill criteria (e.g. pause if CPL >$50 after $140 spent).
```

---

## Workflow for a single variant

Run by the ad-campaign agent, not manually:

1. Read the brief.
2. Confirm `.impeccable.md` exists at project root. If not, stop and run `/impeccable teach`.
3. Invoke `/impeccable craft` with the variant spec.
4. Write the HTML/CSS at the canonical path. Body sized to exact platform dimensions. Google Fonts `<link>` for Staatliches + Public Sans. Hero photo referenced with file-relative path to `/branding/logos/web/hero-{city}.webp`.
5. Render via Playwright MCP:
   - `browser_navigate("file:///.../{variant}.html")`
   - `browser_resize({width, height})` — match the creative dimensions exactly
   - `browser_take_screenshot({type: "png", fullPage: false})` — save to the variant PNG path
6. Run `/critique` on the rendered output. If it flags a ban violation, fix before proceeding.
7. Run `/polish` for final surface quality.
8. Write the `-notes.md` sidecar.
9. If this is the last variant in a batch, run `/impeccable extract` against the batch folder — new atoms flow into `creative-system.md`.
10. Update `.claude/agent-memory/ad-campaign/creatives-shipped.md`.

---

## Quality gate (anti-AI-slop test)

Every creative must pass all seven before it ships to an ad manager:

- [ ] Would a Wausau homeowner thumb-stop on this in their feed?
- [ ] Does it look like CWDB, or a generic home-services lead-gen ad?
- [ ] Would someone who saw the website yesterday recognize this as ours **without reading the logo**?
- [ ] Is the CTA unmistakable in under 1 second?
- [ ] Zero side-stripe borders, zero gradient text, zero generic fonts, zero AI cyan-purple palettes?
- [ ] Real Wisconsin deck photo? (Never stock.)
- [ ] Copy sounds like a neighbor, not a marketer?

If any check fails, the creative does not ship. Iterate with a companion skill (`/bolder`, `/quieter`, `/distill`, `/colorize`, `/typeset`, `/layout`, `/delight`) and re-run the gate.

---

## Reference files

- `/.impeccable.md` — Design Context (users, brand personality, aesthetic direction, design principles)
- `/website/design-system.md` — color tokens, type scale, spacing, component rules (creatives mirror site)
- `/business-context/brand-discovery/brand-voice-positioning.md` — Hammer vs Handshake tone rule
- `/marketing/launch-brief-2026-04-20.md` — operative launch brief for first batch
- `C:\Users\jslog\.claude\skills\impeccable\SKILL.md` — methodology source of truth
