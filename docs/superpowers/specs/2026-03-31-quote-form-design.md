---
type: reference
status: active
created: 2026-03-31
updated: 2026-04-16
tags:
  - type/reference
---

# Quote Form Design Spec
**Date:** 2026-03-31  
**Status:** Approved  
**Scope:** Homepage quote form section — [[Webflow]] native implementation

---

## Context

The CWDB homepage needs a lead-capture form section so homeowners can request a free deck quote directly from the homepage. This is the primary conversion point for the site. The form uses [[Webflow]]'s native form element (not an embed) so submissions appear in Webflow's panel, validation works out of the box, and the form stays editable in the Designer. After submission, a [[Make]] webhook processes the lead and the user is redirected to `/thank-you`.

---

## Layout

**Section:** New Webflow Section element added to the homepage, positioned near the bottom (after gallery/testimonials, before footer — section 8 per website plan).

**Background:** Timber Slate `#323434`, full-width  
**Section padding:** 96px top/bottom (desktop), 64px (tablet), 48px (mobile)

**Section header (centered above form card):**
- Eyebrow label: "GET A FREE QUOTE" — Crafted Orange `#e54c00`, Inter 600, 11px, letter-spacing 2.5px, uppercase
- Headline: "Get Your Free Deck Quote" — White, Barlow Condensed 700, 42px desktop / 28px mobile, uppercase, letter-spacing 1px
- Subtext: "Tell us about your project. A trusted local builder will reach out within 24 hours." — `#9a9e9b`, Inter 400, 15px

**Form card:**
- Max-width: 560px, centered (`margin: 0 auto`)
- Background: White `#ffffff`
- Border-radius: 10px
- Padding: 32px 28px
- Box-shadow: `0 8px 40px rgba(0,0,0,0.35)`

**Trust strip (centered, below form card):**
- 4 items in a flex row, wrapping on mobile
- Items: "Local Wisconsin Builders" · "Licensed & Insured" · "Response Within 24 Hours" · "Free, No Obligation"
- Check icon: Wisconsin Sky Blue `#83b2cf`
- Text: `#9a9e9b`, Inter 400, 12px
- Gap between items: 32px

---

## Form Fields (9 fields, Webflow native)

Webflow Form Name: `Quote Request`  
Redirect on submit: `/thank-you`  
Webhook: Make scenario URL (added in Webflow form settings after Make setup)

| Row | Fields | Grid |
|-----|--------|------|
| 1 | Full Name + Phone Number | 2-col (1fr 1fr) |
| 2 | Email Address | Full width |
| 3 | Property Address | Full width |
| 4 | Do you own this property? + Type of project? | 2-col (1fr 1fr) |
| 5 | Estimated budget? + When to start? | 2-col (1fr 1fr) |
| 6 | Anything else we should know? | Full width |

**Field details:**

| # | Label | Webflow Name | Type | Required | Placeholder |
|---|-------|-------------|------|----------|-------------|
| 1 | Full Name | `name` | Text | Yes | Your full name |
| 2 | Phone Number | `phone` | Tel | Yes | (715) 555-0000 |
| 3 | Email Address | `email` | Email | Yes | you@email.com |
| 4 | Property Address | `address` | Text | Yes | Street address, City, WI ZIP |
| 5 | Do you own this property? | `owner` | Select | Yes | Options: Yes / No |
| 6 | Type of project? | `project_type` | Select | Yes | Options: New deck build / Deck replacement / Deck repair / Deck addition/expansion / Not sure yet |
| 7 | Estimated budget? | `budget` | Select | Yes | Options: Under $5,000 / $5,000–$10,000 / $10,000–$20,000 / $20,000–$40,000 / $40,000+ |
| 8 | When to start? | `timeline` | Select | Yes | Options: As soon as possible / Within 1–3 months / 3–6 months / Just planning ahead |
| 9 | Anything else we should know? | `notes` | Textarea | No | Deck size, materials, special features, etc. |

**Required field asterisk:** Crafted Orange `#e54c00` appended to label

**Optional field note:** "(optional)" in `#9a9e9b` Inter 400, appended to notes label

---

## Field & Label Styling (Webflow classes)

### Labels — class: `form-label`
```
font-family: Inter
font-size: 12px
font-weight: 500
color: #323434
margin-bottom: 5px
display: block
letter-spacing: 0.3px
```

### Inputs & Selects — class: `form-input`
```
width: 100%
height: 44px
border: 1px solid #dddddd
border-radius: 6px
padding: 0 14px
font-family: Inter
font-size: 14px
color: #323434
background: #ffffff
transition: border-color 150ms ease, box-shadow 150ms ease
```

**Focus state:**
```
border-color: #83b2cf
box-shadow: 0 0 0 3px rgba(131, 178, 207, 0.18)
outline: none
```

**Error state:**
```
border-color: #d32f2f
```

### Textarea — class: `form-textarea`
Same as `form-input` plus:
```
height: auto
min-height: 88px
padding: 12px 14px
resize: vertical
```

### Field wrapper — class: `form-field`
```
display: flex
flex-direction: column
```

### 2-column row — class: `form-row-2col`
```
display: grid
grid-template-columns: 1fr 1fr
gap: 16px
margin-bottom: 16px
```

### Full-width row — class: `form-row`
```
margin-bottom: 16px
```

---

## Submit Button — class: `btn-submit`
```
width: 100%
height: 52px
background: #e54c00
color: #ffffff
border: none
border-radius: 6px
font-family: Inter
font-size: 13px
font-weight: 600
letter-spacing: 2px
text-transform: uppercase
cursor: pointer
box-shadow: 0 4px 24px rgba(229, 76, 0, 0.45)
transition: all 200ms ease
```

**Hover:**
```
background: #cc4300
transform: scale(1.02)
box-shadow: 0 6px 32px rgba(229, 76, 0, 0.60)
```

**Active:**
```
background: #b33a00
```

**Button text:** "GET MY FREE QUOTE →"

---

## Privacy Note (below submit button)
```
text-align: center
color: #9a9e9b
font-size: 11px
margin-top: 12px
```
Text: "🔒 Your info is private. No spam, no obligation."

---

## Responsive Behavior

| Breakpoint | Change |
|-----------|--------|
| ≤ 767px (mobile) | All `form-row-2col` collapse to single column (grid-template-columns: 1fr) |
| ≤ 767px (mobile) | Trust strip wraps, items stack in pairs |
| ≤ 480px | Form card padding reduces to 20px 16px |

---

## Data Flow

1. User submits form → Webflow validates required fields client-side
2. Webflow sends POST to Make webhook URL (configured in Form Settings → Action)
3. Webflow redirects browser to `/thank-you`
4. [[Make]] scenario receives payload, qualifies lead, pushes to [[HubSpot]] CRM

**Note:** Make webhook URL is added in Webflow Form Settings after the Make scenario is built. The form is built now; webhook URL is plugged in during the Make setup phase.

---

## Webflow Implementation Steps

1. Open homepage in Webflow Designer
2. Add a new **Section** element near bottom of page
3. Inside section: add **Container** (max-width 1200px)
4. Inside container: add section header (Div with eyebrow + H2 + paragraph)
5. Add **Form Block** element — set Form Name to "Quote Request", redirect to `/thank-you`
6. Inside Form Block: build field rows using Div Grid elements with classes above
7. Add 9 fields with correct types, names, placeholders, and required flags
8. Style all elements using Webflow class panel (class names defined above)
9. Add trust strip Div below Form Block
10. Set all responsive overrides at Tablet and Mobile breakpoints

---

## Reused Reference Files
- Field spec: `operations/leads/quote-form-fields.json`
- Design tokens: `website/design-system.md`
- Base template structure: `website/templates/base.html`
