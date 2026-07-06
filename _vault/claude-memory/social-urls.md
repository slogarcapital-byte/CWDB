---
name: CWDB social media URLs
description: Canonical social media profile URLs for Central Wisconsin Deck Builders, used in footer, JSON-LD sameAs, HubSpot company record, and any future outreach
type: project
originSessionId: cdcb19cc-25cd-4c0a-a160-75559756347b
---
# CWDB Social Media URLs (canonical)

Confirmed by Jim 2026-05-10. Use these exact URLs everywhere — do not append tracking params.

| Platform | URL |
|---|---|
| Instagram | https://www.instagram.com/cwdeckbuilders/ |
| Facebook  | https://www.facebook.com/profile.php?id=61564720918864 |
| Nextdoor  | https://nextdoor.com/page/central-wisconsin-deck-builders-wausau-wi |

**Why:** These are the public-facing brand profiles. Used as Schema.org `sameAs` for entity disambiguation in Google's knowledge graph, and as footer links across the 21-page Webflow site.

**How to apply:** When asked to add or update social URLs anywhere (new page footer, new schema block, new email template, contractor outreach, contractor agreement signature blocks, ad-platform business profile fields, Google Business Profile, HubSpot company record), use these three URLs verbatim. The Nextdoor share link Jim originally pasted included `utm_campaign=...&share_action_id=...` query params; those were stripped to get the canonical page URL above.

**Future:** If Facebook gets a vanity username (Page Settings → "Username"), the URL becomes `facebook.com/cwdeckbuilders` and we should swap it in. The `profile.php?id=` form stays valid for `sameAs` either way. Other platforms (X, YouTube, LinkedIn, TikTok, Google Business Profile) do not exist for CWDB as of 2026-05-10.

**Live deployment status (2026-05-10):**
- Project memory: this file ✅
- Homepage JSON-LD `sameAs`: staged in `operations/analytics/json-ld-snippets/homepage-localbusiness.html` ✅; awaiting Jim's bundled re-paste in Webflow Designer
- Webflow footer (3 anchor `href` values on `.social-icon-link`): updated via Webflow MCP ✅; needs publish
- Webflow Site Settings → SEO → Social profiles: Jim Designer step (manual) ⏳
- HubSpot company record (Social Profiles fields): updated via HubSpot MCP ✅
