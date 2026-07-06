---
name: Webflow MCP — site-script slots cap at 15, inline scripts cap at 2000 chars, hosted-script registration not exposed
description: Hard limits on data_scripts_tool. Workaround for >2000-char scripts is page-scoped scripts via data_pages_tool upsert_page_script (page-only, doesn't count toward 15-slot site limit).
type: reference
originSessionId: 7a0b1919-ea22-4cce-8eed-19785562bedd
---
Webflow MCP `data_scripts_tool` capabilities and limits, learned 2026-04-27 during form rebuild:

- **Site-applied scripts cap: 15.** Once 15 scripts are applied site-wide, adding a 16th fails. CWDB hit 15/15 saturation from stacked old versions of `cwdb_launch_polish` (1.0.0 through 1.2.0, 5 versions) and `cwdb_round_2_fixes` (1.0.0 through 1.2.0, 3 versions). Resolved by deleting+re-applying — but `delete_all_site_scripts` clears the entire apply block, requiring each keeper to be re-applied individually.
- **Inline-script char cap: ~2000.** `add_inline_site_script` rejects content over ~2000 chars. CWDB's consolidated `cwdb_site_polish-2.0.1` is 4368 chars — exists hosted on Webflow CDN but cannot be re-registered or modified via current MCP. Hosted-script registration (`add_hosted_script` or equivalent) is NOT exposed in the current MCP tool set.
- **Page Settings → Custom Code (Before `</body>`)** body field is Designer-only via REST. `update_page_settings` schema has no `customCode`/`bodyEmbed` field.
- **Page-scoped scripts via `upsert_page_script`** are the API-accessible workaround: register an inline script under 2000 chars, then apply it to a single page only. Page-scoped scripts do NOT count toward the 15-slot site limit. Used on /get-a-quote (`quote_page_polish-1.0.0`) for the page-specific button-centering fix that couldn't go in the global polish script.
- **Page duplication is not exposed.** `de_page_tool` only supports `create_page` (blank), `switch_page`, `get_current_page`, `create_page_folder`. To "duplicate" a page, either rebuild from scratch via MCP or have Jim right-click → Duplicate in Designer.
- **`publish_site` requires domain IDs, not hostnames.** Passing `cwdeckbuilders.com` returns 400; pass the domain GUID instead. Look up domain IDs via `data_sites_tool` first.

**How to apply:**
- Before adding a new site-applied script, check the current applied count via `list_applied_scripts`. If at 15, consolidate before adding.
- For polish scripts that grow beyond 2000 chars: split site-wide vs page-scoped concerns. Page-specific tweaks go in `upsert_page_script`; truly global tweaks go in the consolidated polish script (and Jim manually pastes them in Designer if they exceed inline cap).
- After any apply call, ALWAYS re-read `list_applied_scripts` to confirm. "Registered" without "applied" is a silent no-op.
