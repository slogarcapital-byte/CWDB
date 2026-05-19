---
name: Verify platform-account identity before configuring tags
description: Always confirm which Google/Meta/Nextdoor/etc. account is selected before creating pixels or conversion actions — Phase F was set up in Jim's CPA work account, costing 6 days of zero-data attribution
originSessionId: 7d02e16e-0b63-4430-a01f-1d4bf3ea0719
title: Verify platform-account identity before configuring tags
type: memory
memory_type: feedback
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/feedback-account-identity-verification.md
tags:
  - type/memory
  - memory/feedback
---
# Feedback — Verify platform-account identity BEFORE configuring tags

**Rule:** When setting up a tracking pixel, conversion action, or analytics property in any ad platform (Google Ads, Meta Business, Nextdoor, GA4, Clarity, TikTok, etc.), the FIRST step is to confirm which account/business is selected at the top of the UI — verify it's the CWDB-dedicated account, not a work/personal account that happens to be logged in.

**Why:** During Phase F (2026-04-18), Jim collected pixel/conversion IDs across 6 platforms in a single batch. He was logged into his CPA / Slogar Capital work Google account at the time. The IDs collected were correct for the platform they were created in, but those platforms turned out to be Jim's work-account pixels — not CWDB-dedicated. Specifically:

- **Google Ads conversion `AW-10862517194`**: created in work Google Ads account; CWDB-dedicated account `712-991-0870` was created later (around 2026-04-23 launch). Result: GTM fired conversions to a phantom that no live campaign was monitoring.
- **Meta Pixel `1207759804531749`**: created in work Meta Business; CWDB Meta Business has its own pixels (`1276568654662913` cwdeckbuilders.com + `4411592295757520` CWDB) that were never wired up. Result: 6+ days of fired Meta events landing in the wrong building.
- **GA4 `G-ZQ19JEF9KC`**: actually correct — landed in the "Central Wisconsin Deck Builders" GA4 account (391847241) because Google Ads / Meta auto-discover GA4 properties bound to a domain. GA4's domain-binding model rescued this case from the same fate.

When Jim launched the live Google Ads campaign on 2026-04-23, "No Recent Data" warnings surfaced the issue. By 2026-04-24, it had cost ~24 hours of corrupted attribution + bid-optimization on a campaign that was actually optimizing toward PAGE_VIEW (a GA4-imported conversion that Google auto-promoted to Primary because no native conversion was set up in the new account).

**How to apply:**
1. **First click of every platform-setup session:** confirm the account/business selector at the top of the UI matches the dedicated entity for the project (e.g., for CWDB → "CWDB Ad Account", "Central Wisconsin Deck Builders" GA4, "CWDB Meta Business"). Read it out loud if helpful.
2. **Before pasting any pixel/ID into GTM or a launch doc:** verify the source platform's account selector one more time. The 5-second check has saved >24-hr cleanup.
3. **For domain-bound pixels (Meta, Nextdoor):** prefer the pixel named after the domain (`cwdeckbuilders.com`) over the brand-named one (`CWDB`). Domain-tied pixels are self-documenting in reports + audit trails.
4. **When the same human controls multiple businesses (CPA firm + side ventures):** never trust "I'm logged in" — always check which workspace.
5. **Resolution playbook reference:** see `/plans/image-1-i-think-hidden-sky.md` for the 6-platform verification walkthrough used to surface and fix the Phase F mismatch on 2026-04-25.

**Diagnostic shortcut for "is this the right account?":** if Phase F docs reference an ID that the live UI doesn't show, either (a) you're in the wrong account, or (b) the asset was deleted. Either way, do not paste-fix — diagnose account identity first.
