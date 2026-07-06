---
name: Webflow has NO native Multi-Step Form element
description: Every "multi-step form" in Webflow is a custom convention — Form Block + custom JS hiding/showing wizard-step divs. The `multistepwizard-1.0.0` script on CWDB is exactly this pattern.
type: reference
originSessionId: 7a0b1919-ea22-4cce-8eed-19785562bedd
---
Webflow ships a single `Form Block` element (one `<form>`, one submit button, native HTML validation only). There is no discrete "Multi-Step Form" element in the Designer Add panel and no MCP write path that builds one.

Every multi-step form on a Webflow site in the wild is a custom pattern: hidden `wizard-step` divs + custom next/back JS + custom progress indicator. CWDB's `multistepwizard-1.0.0` site script is exactly this — ~50 lines that bind to `[data-next]`/`[data-back]` clicks and toggle step visibility.

**How to apply:**
- Don't propose "use Webflow native multi-step" as an architectural option. The element doesn't exist.
- Multi-step Webflow forms always require ~30-100 lines of custom JS for navigation, validation gating, and progress display.
- The "elegant, minimum-script" framing for Webflow forms means: minimal JS scope, NOT zero JS. Aim for one focused script that handles step visibility only — let Webflow's native form runtime handle submit/redirect/email.
- Designer-managed fields are still possible: drag/drop fields into the Form Block, configure labels/types/required in Designer. The multi-step wrapper is JS but the field structure is Designer-native.
