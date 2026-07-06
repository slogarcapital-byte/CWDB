---
name: ios-safari-streamlit-dark-inputs
description: iOS Safari paints form inputs light (ignoring CSS background) - dark-theme Streamlit needs webkit overrides or fields go white-on-white
metadata: 
  node_type: memory
  type: project
  originSessionId: bcc55f79-308c-4cce-ba53-cd2c4645b8b4
---

On the dark-themed Streamlit estimator (`sales/estimating/streamlit_app/app.py`), iOS Safari rendered the Client text fields **white-on-white / unreadable** (incident 2026-06-17). iOS Safari paints `<input>` (text/number) and especially **autofilled** fields with its OWN light background and text color that plain CSS `background` and `color` cannot override; the dark theme's white text then sits on Safari's light fill.

The fix (in the injected `<style>` block, on `.stTextInput input, .stNumberInput input`):
- opaque dark `background-color` (do not rely on translucent `rgba(...)` that can composite to white)
- `-webkit-appearance: none` (drop iOS native input chrome)
- `-webkit-text-fill-color: #fafafa` (the ONLY property that beats Safari's autofill/native text color; `color` alone loses)
- an autofill block: `input:-webkit-autofill { -webkit-box-shadow: 0 0 0 1000px #3a3c3c inset; -webkit-text-fill-color: #fafafa; }` (the box-shadow inset is the ONLY way to override Safari's autofill background)

**Why:** the symptom is iOS-only. Chromium / Playwright renders these inputs correctly no matter what, so it passes local QA and only breaks on a real iPhone. See [[feedback-real-device-mobile-testing]].

**How to apply:** any dark-themed web form Jim will open on his iPhone (Streamlit estimator, future tools) needs these webkit input overrides from the start. If fields are still unreadable when typing fresh (not just autofilled), escalate to a Streamlit native dark theme via `.streamlit/config.toml [theme] base="dark"` instead of CSS overrides. Related: [[streamlit-secrets-location]], [[estimator-app-live]].
