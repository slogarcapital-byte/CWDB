---
name: Webflow — component-first section building
description: Every section on a CWDB Webflow page must be a named Webflow component. Use a strict 3-tier hierarchy before creating anything new — edit property values first, copy+rename to create a styling variation second, build net new only as a last resort.
type: feedback
---

Every section on every CWDB Webflow page must be a named Webflow component. No raw sections, no orphaned divs used as page sections.

**Why:** The Get a Quote page (untitled-2) was built without using existing Webflow components — just raw HTML sections. This breaks the component library, makes the 21-page site inconsistent, and creates a maintenance problem. The user explicitly flagged this and established the correct methodology going forward.

**The 3-tier hierarchy (in order):**

1. **Edit property values first** — change text, headings, CTAs, images like a normal content editor. This is always the starting point. Do not create anything new if property values cover the difference.
2. **Copy the closest existing component, rename it, then edit its styling variables** — when property editing is not enough to express the design difference. Copying preserves all other instances of the original component. Rename using the `[base]-[descriptor]` schema.
3. **Build a net new component from scratch** — last resort only, when no existing component is close enough to copy. Base the structure on section requirements and best practices.

**Naming convention:** `[base]-[descriptor]` — all lowercase, hyphen-separated.
- `hero-section-subpage` ← canonical reference (already exists)
- `hero-section-confirmation` ← copy of hero-section-subpage with confirmation-specific styling
- `contact-section-minimal` ← copy with email + phone only, no form

**Fixed rules:**
- Page headers always use a `hero-` component (`hero-section-subpage` default for interior pages)
- Footers always use the `footer` component — never build footer markup inline
- Mobile structural variations use `-mobile` suffix (only when Webflow's breakpoint controls are genuinely insufficient)

**HTML reference files:** Wrap every section with component comment markers:
```
<!-- WEBFLOW COMPONENT: [component-name] -->
<section class="[component-name]"> ... </section>
<!-- /WEBFLOW COMPONENT: [component-name] -->
```

**How to apply:** Before building any page, list every section it needs. Map each to an existing component. Try property values, then copy+rename, then build new. If uncertain, pause and ask rather than building raw sections. Component inventory is maintained in `/website/design-system.md` — Webflow Component Methodology section.
