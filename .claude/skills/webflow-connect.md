---
name: webflow-connect
description: Connect to the CWDB Webflow site via MCP and apply changes live. Use whenever a website fix, edit, or build task is requested for cwdeckbuilders.com.
when_to_use: Any time the user asks to fix, update, edit, or build anything on the CWDB website. Also use when verifying staging output or publishing the site.
---

# Webflow Connect — CWDB

Skill for connecting to the Central Wisconsin Deck Builders Webflow site via MCP and applying changes live. The staging URL is the primary deliverable. Local HTML files are synced after.

---

## Stored Site Identifiers

These are permanent — do not re-query unless the site is recreated.

```
Site ID:        69c846db9eee02fddb1e2367
Workspace ID:   69c8468c7b22dbee46e2fe14
Short name:     central-wisconsin-deck-builders
Staging URL:    https://central-wisconsin-deck-builders.webflow.io
Live domain:    cwdeckbuilders.com
```

## Stored Page IDs

```
Home          69c846dd9eee02fddb1e2376   /
Get a Quote   69ce4163e79002c5d4762a57   /get-a-quote
Thank You     69ce7e7446c34cb2d17b7ffb   /thank-you
```

City pages and additional pages have not yet been created in Webflow (as of 2026-04-02). Query `mcp__claude_ai_Webflow__data_pages_tool` with the site ID to get current page list at the start of any session where new pages may have been added.

---

## Connection Checklist

Follow these steps in order for every website change request.

### Step 1 — Authenticate and confirm site access

```
Tool: mcp__claude_ai_Webflow__data_sites_tool
Action: list_sites
```

Confirm site ID `69c846db9eee02fddb1e2367` appears in the response. If authentication fails, stop and inform the user — do not proceed to local-only edits.

### Step 2 — Identify the target page

Use the stored page IDs above. If the target page is not in the list, query for it:

```
Tool: mcp__claude_ai_Webflow__data_pages_tool
Action: list_pages
Params: { "site_id": "69c846db9eee02fddb1e2367" }
```

### Step 3 — Inspect the current element state

Before editing, snapshot the current DOM to understand element IDs and structure:

```
Tool: mcp__claude_ai_Webflow__element_snapshot_tool
Params: { "page_id": "<target-page-id>" }
```

Or use the designer-engine page tool for component-level DOM:

```
Tool: mcp__claude_ai_Webflow__de_page_tool
Params: { "page_id": "<target-page-id>" }
```

### Step 4 — Apply the change

Select the correct tool based on change type:

| Change type              | Tool                                        |
|--------------------------|---------------------------------------------|
| Edit text or content     | mcp__claude_ai_Webflow__element_tool        |
| Update styles/classes    | mcp__claude_ai_Webflow__style_tool          |
| Edit component instance  | mcp__claude_ai_Webflow__de_component_tool   |
| Build new component      | mcp__claude_ai_Webflow__component_builder   |
| Add new elements         | mcp__claude_ai_Webflow__element_builder     |
| Page-level DOM changes   | mcp__claude_ai_Webflow__de_page_tool        |
| Update design variables  | mcp__claude_ai_Webflow__variable_tool       |
| Upload or swap images    | mcp__claude_ai_Webflow__asset_tool          |

### Step 5 — Verify on staging

Open or reference the staging URL to confirm the change renders correctly:

```
https://central-wisconsin-deck-builders.webflow.io
```

Append the page slug for interior pages:

```
https://central-wisconsin-deck-builders.webflow.io/get-a-quote
https://central-wisconsin-deck-builders.webflow.io/thank-you
```

### Step 6 — Sync local HTML reference file

Update the corresponding file under `/website/pages/*/index.html` to match the live Webflow state. Wrap every section with component markers:

```html
<!-- WEBFLOW COMPONENT: [component-name] -->
<section class="[component-name]"> ... </section>
<!-- /WEBFLOW COMPONENT: [component-name] -->
```

### Step 7 — Publish (only when explicitly requested)

```
Tool: mcp__claude_ai_Webflow__data_sites_tool
Action: publish_site
Params: {
  "site_id": "69c846db9eee02fddb1e2367",
  "publishToWebflowSubdomain": true,
  "customDomains": ["cwdeckbuilders.com", "www.cwdeckbuilders.com"]
}
```

Do not publish unless the user explicitly asks to push changes to the live domain.

---

## Common Tool Usage Patterns

### Edit a text node

```
Tool: mcp__claude_ai_Webflow__element_tool
Operation: update element text
Params: { "page_id": "<page-id>", "element_id": "<element-id>", "text": "New copy here" }
```

### Change a style property

```
Tool: mcp__claude_ai_Webflow__style_tool
Operation: update style
Params: { "site_id": "69c846db9eee02fddb1e2367", "style_id": "<style-id>", "properties": { "color": "#e54c00" } }
```

### Update a component instance property

```
Tool: mcp__claude_ai_Webflow__de_component_tool
Operation: update component property
Params: { "page_id": "<page-id>", "component_id": "<component-id>", "properties": { "<prop-name>": "<value>" } }
```

### Add a new section element

```
Tool: mcp__claude_ai_Webflow__element_builder
Params: { "page_id": "<page-id>", "parent_id": "<parent-id>", "element": { ... } }
```

---

## Rules

- Never edit only the local HTML file in response to a website fix request.
- If MCP tools return an auth error, stop and inform the user.
- All sections in Webflow must remain named components — never add raw orphan sections.
- Follow the 3-tier component hierarchy: edit properties → copy+rename → net new (last resort).
- Do not publish to the live domain without explicit user instruction.
