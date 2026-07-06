---
name: iOS Safari + flex on <input type="submit"> swallows tap submits
description: WebKit bug — flex display on form-control submit inputs prevents tap-to-click on iOS Safari and iPhone Chrome (which is also WebKit per App Store rules). Submit appears to do nothing.
type: feedback
originSessionId: 7a0b1919-ea22-4cce-8eed-19785562bedd
---
Never apply `display: flex` or `display: inline-flex` to `<input type="submit">` form-control elements. WebKit on iOS silently swallows tap-to-click events on form controls styled with flex display. The button looks fine, the user taps, nothing happens — no error, no redirect, no submission.

**Why:** Bit CWDB hard during 2026-04-27 launch — `cwdb_round_2_fixes-1.2.0` had `.btn-submit.w-button { display: inline-flex !important; align-items: center !important; justify-content: center !important; }`. Submit button worked everywhere on desktop and on Playwright Chromium. Failed silently on Jim's iPhone 11 Safari AND iPhone Chrome (Apple requires Chrome on iOS to use WebKit). Cost ~3 hours of misdirected diagnostic effort before root cause was found.

**How to apply:**
- Submit inputs (`input[type="submit"]`, `.btn-submit.w-button` in Webflow): keep at `display: inline-block` or default `block`. Submit inputs natively center their `value` attribute text — no flex needed.
- Anchor "Next" buttons (`a.btn-submit`): SAFE to use `display: inline-flex` with `align-items: center; justify-content: center`. Anchors don't have the iOS form-control bug.
- When writing CSS for `.btn-submit`, SPLIT the selector: one rule for the input (no flex), one rule for the anchor (flex OK).
- After any change to button styling, verify computed `display` of the submit input at iPhone viewport (414×896) is NOT flex/inline-flex.
