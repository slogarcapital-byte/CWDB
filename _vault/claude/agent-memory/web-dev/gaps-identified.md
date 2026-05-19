---
name: Gaps Identified — Self Audit 2026-04-07
description: Gaps in system prompt, project data, and site completeness found during web-dev agent self-audit on 2026-04-07
type: project
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-04-16
status: active
---

# Gaps Identified — Web Dev Self Audit

Audit date: 2026-04-07

## Information Missing from System Prompt (needs to be there)
These are things I needed for real work that weren't in my prompt:

1. **Full page ID list** — Only Home, Get a Quote, Thank You are listed. All other page IDs require a live MCP query each session. Phase D/E page IDs should be added to system prompt.
2. **CMS collection IDs** — Not listed in system prompt at all; require live MCP query or memory lookup.
3. **Our Builders contractor IDs** — Needed for CMS updates; not stored anywhere before this session.
4. **Phase completion status** — System prompt has no awareness of what phases are done vs pending.

## Information Missing from Project (needs user input)
These gaps block specific tasks:

1. **Phone number** — No CWDB business number exists yet. Blocks: header, footer, mobile CTA, TCPA disclosure, click-to-call. User is setting up Google Voice with 715 area code.
2. **Contractor headshots** — Neither [[Ben Barton]] nor [[John Garcia]] has a photo in any system. Blocks: Our Builders page final state.
3. **Contractor bios** — Both have placeholder copy. Blocks: Our Builders page credibility.
4. **Real testimonials** — All testimonials on the site are AI-generated (legal blocker per legal agent). Blocks: go-live.
5. **GA4 / GTM / ad accounts** — User hasn't set up these accounts yet. Blocks: Phase G (SEO & analytics).

## Ambiguities in System Prompt
These rules exist but edge cases are unclear:

1. **Homepage component names** — Phase B components are documented with a placeholder note "[Phase B homepage components — add names here as confirmed in designer]". These have never been formally confirmed or documented. Need to query Webflow designer to get the actual component names.
2. **City page forms** — City pages use `quote-form-inline` component. It's listed in the city template section order but not in the component inventory table. Need to confirm if it's a separate component or part of another.

## Resolved This Session
- TCPA consent language finalized and deployed to quote-form-fields.json (2026-04-07)
- Our Builders CMS updated with real contractor data (2026-04-07)
- Web-dev memory files created (this session)
