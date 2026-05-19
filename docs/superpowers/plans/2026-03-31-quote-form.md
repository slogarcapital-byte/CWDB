---
type: reference
status: active
created: 2026-03-31
updated: 2026-04-16
tags:
  - type/reference
---

# Quote Form Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fully-styled 9-field quote form section to the CWDB homepage in [[Webflow]] using the MCP Designer tools.

**Architecture:** Create CSS styles first, then build the DOM structure in 4 batches (section shell → header → form card → trust strip), then apply styles to each element. Form uses DOM-type elements (form/input/select/textarea) since `element_builder` doesn't expose native Webflow FormForm presets — DOM forms POST directly to the Make webhook which is our actual lead processor.

**Tech Stack:** Webflow MCP (element_builder, style_tool, element_tool), DOM form elements, CWDB design system (#e54c00, #323434, #83b2cf, Inter/Barlow Condensed)

**Site ID:** `69c846db9eee02fddb1e2367`  
**Page:** Homepage (ID: `69c846dd9eee02fddb1e2376`)

**Reference files:**
- `operations/leads/quote-form-fields.json` — field names, types, options
- `website/design-system.md` — typography, colors, spacing
- `docs/superpowers/specs/2026-03-31-quote-form-design.md` — approved design spec

---

## Task 1: Create all CSS styles

Create all Webflow styles before building elements. Styles must exist before they can be assigned.

**Files:** Webflow style panel (via `style_tool`)

- [ ] **Step 1: Create `quote-section` style** (outer section)

```
style_tool > create_style
name: "quote-section"
properties:
  - background-color: #323434
  - padding-top: 96px
  - padding-bottom: 96px
  - padding-left: 24px
  - padding-right: 24px
```

- [ ] **Step 2: Create `quote-section` medium breakpoint override**

```
style_tool > update_style
style_name: "quote-section"
breakpoint_id: "medium"
properties:
  - padding-top: 64px
  - padding-bottom: 64px
```

- [ ] **Step 3: Create `quote-section` small breakpoint override**

```
style_tool > update_style
style_name: "quote-section"
breakpoint_id: "small"
properties:
  - padding-top: 48px
  - padding-bottom: 48px
```

- [ ] **Step 4: Create `quote-container` style** (centered max-width wrapper)

```
style_tool > create_style
name: "quote-container"
properties:
  - max-width: 720px
  - margin-left: auto
  - margin-right: auto
```

- [ ] **Step 5: Create `quote-eyebrow` style** (orange label above headline)

```
style_tool > create_style
name: "quote-eyebrow"
properties:
  - color: #e54c00
  - font-size: 11px
  - font-weight: 600
  - letter-spacing: 2.5px
  - text-transform: uppercase
  - text-align: center
  - display: block
  - margin-bottom: 6px
  - font-family: Inter, sans-serif
```

- [ ] **Step 6: Create `quote-headline` style** (H2 heading)

```
style_tool > create_style
name: "quote-headline"
properties:
  - color: #ffffff
  - font-family: Barlow Condensed, sans-serif
  - font-size: 42px
  - font-weight: 700
  - text-transform: uppercase
  - letter-spacing: 1px
  - text-align: center
  - margin-top: 0px
  - margin-bottom: 8px
```

- [ ] **Step 7: Create `quote-headline` small breakpoint override**

```
style_tool > update_style
style_name: "quote-headline"
breakpoint_id: "small"
properties:
  - font-size: 28px
```

- [ ] **Step 8: Create `quote-subtext` style**

```
style_tool > create_style
name: "quote-subtext"
properties:
  - color: #9a9e9b
  - font-size: 15px
  - font-family: Inter, sans-serif
  - text-align: center
  - margin-top: 0px
  - margin-bottom: 36px
```

- [ ] **Step 9: Create `quote-card` style** (white form card)

```
style_tool > create_style
name: "quote-card"
properties:
  - background-color: #ffffff
  - border-radius: 10px
  - padding-top: 32px
  - padding-bottom: 32px
  - padding-left: 28px
  - padding-right: 28px
  - box-shadow: 0 8px 40px rgba(0,0,0,0.35)
  - max-width: 560px
  - margin-left: auto
  - margin-right: auto
```

- [ ] **Step 10: Create `quote-card` tiny breakpoint override**

```
style_tool > update_style
style_name: "quote-card"
breakpoint_id: "tiny"
properties:
  - padding-top: 20px
  - padding-bottom: 20px
  - padding-left: 16px
  - padding-right: 16px
```

- [ ] **Step 11: Create `form-row` style** (full-width field row)

```
style_tool > create_style
name: "form-row"
properties:
  - margin-bottom: 16px
```

- [ ] **Step 12: Create `form-row-2col` style** (2-column field row)

```
style_tool > create_style
name: "form-row-2col"
properties:
  - display: grid
  - grid-template-columns: 1fr 1fr
  - grid-column-gap: 16px
  - margin-bottom: 16px
```

- [ ] **Step 13: Create `form-row-2col` small breakpoint override** (collapse to single col)

```
style_tool > update_style
style_name: "form-row-2col"
breakpoint_id: "small"
properties:
  - grid-template-columns: 1fr
```

- [ ] **Step 14: Create `form-field` style** (individual field wrapper)

```
style_tool > create_style
name: "form-field"
properties:
  - display: flex
  - flex-direction: column
```

- [ ] **Step 15: Create `form-label` style**

```
style_tool > create_style
name: "form-label"
properties:
  - color: #323434
  - font-size: 12px
  - font-weight: 500
  - font-family: Inter, sans-serif
  - letter-spacing: 0.3px
  - margin-bottom: 5px
  - display: block
```

- [ ] **Step 16: Create `form-input` style**

```
style_tool > create_style
name: "form-input"
properties:
  - width: 100%
  - height: 44px
  - border-top-width: 1px
  - border-right-width: 1px
  - border-bottom-width: 1px
  - border-left-width: 1px
  - border-top-style: solid
  - border-right-style: solid
  - border-bottom-style: solid
  - border-left-style: solid
  - border-top-color: #dddddd
  - border-right-color: #dddddd
  - border-bottom-color: #dddddd
  - border-left-color: #dddddd
  - border-top-left-radius: 6px
  - border-top-right-radius: 6px
  - border-bottom-left-radius: 6px
  - border-bottom-right-radius: 6px
  - padding-left: 14px
  - padding-right: 14px
  - font-family: Inter, sans-serif
  - font-size: 14px
  - color: #323434
  - background-color: #ffffff
  - box-sizing: border-box
  - outline: none
  - transition-property: border-color, box-shadow
  - transition-duration: 150ms
  - transition-timing-function: ease
```

- [ ] **Step 17: Create `form-input` focus pseudo style**

```
style_tool > update_style
style_name: "form-input"
pseudo: "focus"
properties:
  - border-top-color: #83b2cf
  - border-right-color: #83b2cf
  - border-bottom-color: #83b2cf
  - border-left-color: #83b2cf
  - box-shadow: 0 0 0 3px rgba(131,178,207,0.18)
```

- [ ] **Step 18: Create `form-textarea` style**

```
style_tool > create_style
name: "form-textarea"
properties:
  - width: 100%
  - min-height: 88px
  - border-top-width: 1px
  - border-right-width: 1px
  - border-bottom-width: 1px
  - border-left-width: 1px
  - border-top-style: solid
  - border-right-style: solid
  - border-bottom-style: solid
  - border-left-style: solid
  - border-top-color: #dddddd
  - border-right-color: #dddddd
  - border-bottom-color: #dddddd
  - border-left-color: #dddddd
  - border-top-left-radius: 6px
  - border-top-right-radius: 6px
  - border-bottom-left-radius: 6px
  - border-bottom-right-radius: 6px
  - padding-top: 12px
  - padding-bottom: 12px
  - padding-left: 14px
  - padding-right: 14px
  - font-family: Inter, sans-serif
  - font-size: 14px
  - color: #323434
  - background-color: #ffffff
  - box-sizing: border-box
  - resize: vertical
  - outline: none
```

- [ ] **Step 19: Create `form-textarea` focus pseudo style**

```
style_tool > update_style
style_name: "form-textarea"
pseudo: "focus"
properties:
  - border-top-color: #83b2cf
  - border-right-color: #83b2cf
  - border-bottom-color: #83b2cf
  - border-left-color: #83b2cf
  - box-shadow: 0 0 0 3px rgba(131,178,207,0.18)
```

- [ ] **Step 20: Create `btn-submit` style**

```
style_tool > create_style
name: "btn-submit"
properties:
  - width: 100%
  - height: 52px
  - background-color: #e54c00
  - color: #ffffff
  - border-top-width: 0px
  - border-right-width: 0px
  - border-bottom-width: 0px
  - border-left-width: 0px
  - border-top-left-radius: 6px
  - border-top-right-radius: 6px
  - border-bottom-left-radius: 6px
  - border-bottom-right-radius: 6px
  - font-family: Inter, sans-serif
  - font-size: 13px
  - font-weight: 600
  - letter-spacing: 2px
  - text-transform: uppercase
  - cursor: pointer
  - box-shadow: 0 4px 24px rgba(229,76,0,0.45)
  - transition-property: all
  - transition-duration: 200ms
  - transition-timing-function: ease
  - margin-top: 4px
```

- [ ] **Step 21: Create `btn-submit` hover pseudo style**

```
style_tool > update_style
style_name: "btn-submit"
pseudo: "hover"
properties:
  - background-color: #cc4300
  - transform: scale(1.02)
  - box-shadow: 0 6px 32px rgba(229,76,0,0.60)
```

- [ ] **Step 22: Create `form-privacy` style** (privacy note below button)

```
style_tool > create_style
name: "form-privacy"
properties:
  - text-align: center
  - color: #9a9e9b
  - font-size: 11px
  - font-family: Inter, sans-serif
  - margin-top: 12px
  - margin-bottom: 0px
```

- [ ] **Step 23: Create `trust-strip` style** (trust items row below card)

```
style_tool > create_style
name: "trust-strip"
properties:
  - display: flex
  - justify-content: center
  - flex-wrap: wrap
  - grid-column-gap: 32px
  - grid-row-gap: 12px
  - margin-top: 28px
```

- [ ] **Step 24: Create `trust-item` style**

```
style_tool > create_style
name: "trust-item"
properties:
  - display: flex
  - align-items: center
  - grid-column-gap: 7px
```

- [ ] **Step 25: Create `trust-icon` style**

```
style_tool > create_style
name: "trust-icon"
properties:
  - color: #83b2cf
  - font-size: 14px
```

- [ ] **Step 26: Create `trust-text` style**

```
style_tool > create_style
name: "trust-text"
properties:
  - color: #9a9e9b
  - font-size: 12px
  - font-family: Inter, sans-serif
```

---

## Task 2: Build section shell and header

Get the homepage body element ID, then build the outer section and header content.

- [ ] **Step 1: Get all homepage elements to find the body/root ID**

```
element_tool > get_all_elements
query: "all"
include_style_properties: false
include_all_breakpoint_styles: false
```

Note the root body element ID — it will be the parent for the new section.

- [ ] **Step 2: Create the section shell + header**

```
element_builder (append to body element)
{
  type: "Section",
  set_style: { style_names: ["quote-section"] },
  children: [
    {
      type: "Container",
      set_style: { style_names: ["quote-container"] },
      children: [
        {
          type: "TextBlock",
          set_style: { style_names: ["quote-eyebrow"] },
          set_text: { text: "GET A FREE QUOTE" }
        },
        {
          type: "Heading",
          set_heading_level: { heading_level: 2 },
          set_style: { style_names: ["quote-headline"] },
          set_text: { text: "Get Your Free Deck Quote" }
        },
        {
          type: "Paragraph",
          set_style: { style_names: ["quote-subtext"] },
          set_text: { text: "Tell us about your project. A trusted local builder will reach out within 24 hours." }
        }
      ]
    }
  ]
}
```

Save the returned Section ID and Container ID for next steps.

---

## Task 3: Build the form card wrapper and form element

- [ ] **Step 1: Create the white form card div inside the container**

```
element_builder (append to Container from Task 2)
{
  type: "DivBlock",
  set_style: { style_names: ["quote-card"] },
  children: [
    {
      type: "DOM",
      set_dom_config: { dom_tag: "form" },
      set_attributes: {
        attributes: [
          { name: "name", value: "Quote Request" },
          { name: "method", value: "POST" },
          { name: "data-redirect", value: "/thank-you" }
        ]
      }
    }
  ]
}
```

Save the returned DivBlock ID (quote-card) and the DOM form element ID.

---

## Task 4: Build form rows 1–3 (Name/Phone, Email, Address)

Max 3 levels deep per call — build each row as a separate call inside the form element.

- [ ] **Step 1: Row 1 — Name + Phone (2-col)**

```
element_builder (append to form DOM element)
{
  type: "DivBlock",
  set_style: { style_names: ["form-row-2col"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Full Name *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "input" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "type", value: "text" },
              { name: "name", value: "name" },
              { name: "placeholder", value: "Your full name" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    },
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Phone Number *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "input" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "type", value: "tel" },
              { name: "name", value: "phone" },
              { name: "placeholder", value: "(715) 555-0000" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Row 2 — Email (full width)**

```
element_builder (append to form DOM element)
{
  type: "DivBlock",
  set_style: { style_names: ["form-row"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Email Address *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "input" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "type", value: "email" },
              { name: "name", value: "email" },
              { name: "placeholder", value: "you@email.com" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 3: Row 3 — Property Address (full width)**

```
element_builder (append to form DOM element)
{
  type: "DivBlock",
  set_style: { style_names: ["form-row"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Property Address *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "input" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "type", value: "text" },
              { name: "name", value: "address" },
              { name: "placeholder", value: "Street address, City, WI ZIP" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    }
  ]
}
```

---

## Task 5: Build form rows 4–5 (selects)

Select elements need their options added as DOM children.

- [ ] **Step 1: Row 4 — Own Property + Project Type (2-col selects)**

```
element_builder (append to form DOM element)
{
  type: "DivBlock",
  set_style: { style_names: ["form-row-2col"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Do you own this property? *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "select" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "name", value: "owner" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    },
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Type of project? *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "select" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "name", value: "project_type" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Add options to the `owner` select**

Get the select element IDs from the previous call, then for each select append option DOM children:

For `owner` select — append 3 option elements:
```
element_builder (append to owner select)
{ type: "DOM", set_dom_config: { dom_tag: "option" }, set_attributes: { attributes: [{ name: "value", value: "" }] }, set_text: { text: "Select..." } }

element_builder (append to owner select)
{ type: "DOM", set_dom_config: { dom_tag: "option" }, set_attributes: { attributes: [{ name: "value", value: "yes" }] }, set_text: { text: "Yes" } }

element_builder (append to owner select)
{ type: "DOM", set_dom_config: { dom_tag: "option" }, set_attributes: { attributes: [{ name: "value", value: "no" }] }, set_text: { text: "No" } }
```

- [ ] **Step 3: Add options to the `project_type` select**

```
Append to project_type select:
{ option value: "", text: "Select..." }
{ option value: "new-build", text: "New deck build" }
{ option value: "replacement", text: "Deck replacement" }
{ option value: "repair", text: "Deck repair" }
{ option value: "addition", text: "Deck addition/expansion" }
{ option value: "not-sure", text: "Not sure yet" }
```

- [ ] **Step 4: Row 5 — Budget + Timeline (2-col selects)**

```
element_builder (append to form DOM element)
{
  type: "DivBlock",
  set_style: { style_names: ["form-row-2col"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Estimated budget? *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "select" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "name", value: "budget" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    },
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "When to start? *" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "select" },
          set_style: { style_names: ["form-input"] },
          set_attributes: {
            attributes: [
              { name: "name", value: "timeline" },
              { name: "required", value: "true" }
            ]
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 5: Add options to `budget` select**

```
{ option value: "", text: "Select..." }
{ option value: "under-5k", text: "Under $5,000" }
{ option value: "5k-10k", text: "$5,000–$10,000" }
{ option value: "10k-20k", text: "$10,000–$20,000" }
{ option value: "20k-40k", text: "$20,000–$40,000" }
{ option value: "40k-plus", text: "$40,000+" }
```

- [ ] **Step 6: Add options to `timeline` select**

```
{ option value: "", text: "Select..." }
{ option value: "asap", text: "As soon as possible" }
{ option value: "1-3mo", text: "Within 1–3 months" }
{ option value: "3-6mo", text: "3–6 months" }
{ option value: "planning", text: "Just planning ahead" }
```

---

## Task 6: Build form rows 6–7 (notes + submit + privacy)

- [ ] **Step 1: Row 6 — Notes textarea (full width)**

```
element_builder (append to form DOM element)
{
  type: "DivBlock",
  set_style: { style_names: ["form-row"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["form-field"] },
      children: [
        {
          type: "DOM",
          set_dom_config: { dom_tag: "label" },
          set_style: { style_names: ["form-label"] },
          set_text: { text: "Anything else we should know? (optional)" }
        },
        {
          type: "DOM",
          set_dom_config: { dom_tag: "textarea" },
          set_style: { style_names: ["form-textarea"] },
          set_attributes: {
            attributes: [
              { name: "name", value: "notes" },
              { name: "placeholder", value: "Deck size, materials, special features, etc." },
              { name: "rows", value: "4" }
            ]
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Submit button + privacy note**

```
element_builder (append to form DOM element)
{
  type: "DOM",
  set_dom_config: { dom_tag: "button" },
  set_style: { style_names: ["btn-submit"] },
  set_attributes: {
    attributes: [
      { name: "type", value: "submit" }
    ]
  },
  set_text: { text: "GET MY FREE QUOTE →" }
}

element_builder (append to form DOM element)
{
  type: "Paragraph",
  set_style: { style_names: ["form-privacy"] },
  set_text: { text: "🔒 Your info is private. No spam, no obligation." }
}
```

---

## Task 7: Build trust strip

- [ ] **Step 1: Create trust strip with 4 items** (append to Container, after quote-card div)

```
element_builder (append to Container)
{
  type: "DivBlock",
  set_style: { style_names: ["trust-strip"] },
  children: [
    {
      type: "DivBlock",
      set_style: { style_names: ["trust-item"] },
      children: [
        { type: "TextBlock", set_style: { style_names: ["trust-icon"] }, set_text: { text: "✓" } },
        { type: "TextBlock", set_style: { style_names: ["trust-text"] }, set_text: { text: "Local Wisconsin Builders" } }
      ]
    },
    {
      type: "DivBlock",
      set_style: { style_names: ["trust-item"] },
      children: [
        { type: "TextBlock", set_style: { style_names: ["trust-icon"] }, set_text: { text: "✓" } },
        { type: "TextBlock", set_style: { style_names: ["trust-text"] }, set_text: { text: "Licensed & Insured" } }
      ]
    },
    {
      type: "DivBlock",
      set_style: { style_names: ["trust-item"] },
      children: [
        { type: "TextBlock", set_style: { style_names: ["trust-icon"] }, set_text: { text: "✓" } },
        { type: "TextBlock", set_style: { style_names: ["trust-text"] }, set_text: { text: "Response Within 24 Hours" } }
      ]
    },
    {
      type: "DivBlock",
      set_style: { style_names: ["trust-item"] },
      children: [
        { type: "TextBlock", set_style: { style_names: ["trust-icon"] }, set_text: { text: "✓" } },
        { type: "TextBlock", set_style: { style_names: ["trust-text"] }, set_text: { text: "Free, No Obligation" } }
      ]
    }
  ]
}
```

---

## Task 8: Add form submission JavaScript via page custom code

The DOM form needs a submit handler that POSTs to the Make webhook and redirects to `/thank-you`. This is added via Webflow's page custom code (footer).

- [ ] **Step 1: Get current page metadata to check existing custom code**

```
data_pages_tool > get_page_metadata
page_id: "69c846dd9eee02fddb1e2376"
```

- [ ] **Step 2: Update page with form submission script**

```
data_pages_tool > update_page_settings
page_id: "69c846dd9eee02fddb1e2376"
customCode:
  footer: |
    <script>
    (function() {
      var form = document.querySelector('form[name="Quote Request"]');
      if (!form) return;
      form.addEventListener('submit', function(e) {
        e.preventDefault();
        var data = new FormData(form);
        var payload = {};
        data.forEach(function(v, k) { payload[k] = v; });
        // Make webhook URL — replace WEBHOOK_URL_HERE after Make scenario is built
        var webhookUrl = 'WEBHOOK_URL_HERE';
        if (webhookUrl === 'WEBHOOK_URL_HERE') {
          window.location.href = '/thank-you';
          return;
        }
        fetch(webhookUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        }).finally(function() {
          window.location.href = '/thank-you';
        });
      });
    })();
    </script>
```

**Note:** The webhook URL placeholder is intentional — it's filled in during the Make scenario setup phase. The form redirects to `/thank-you` regardless so UX is unbroken.

---

## Task 9: Take snapshot and verify

- [ ] **Step 1: Take visual snapshot of the new section**

```
element_snapshot_tool
element_id: <section element ID from Task 2>
```

Review the snapshot. Verify: dark background, white card, orange button, all 6 rows visible.

- [ ] **Step 2: Check responsive at small breakpoint**

Select the `form-row-2col` style and confirm small breakpoint shows `grid-template-columns: 1fr`.

- [ ] **Step 3: Commit progress note**

```bash
git add docs/superpowers/plans/2026-03-31-quote-form.md docs/superpowers/specs/2026-03-31-quote-form-design.md
git commit -m "feat: add quote form plan and design spec"
```

---

## Notes

- **Make webhook URL:** Placeholder `WEBHOOK_URL_HERE` in the page footer script. Replace after Make scenario is built (next phase).
- **Thank-you page:** `/thank-you` page must exist in Webflow — create it as a simple confirmation page if not already present.
- **Font loading:** Barlow Condensed and Inter must be added in Webflow Project Settings → Fonts if not already loaded. Check before verifying the snapshot.
