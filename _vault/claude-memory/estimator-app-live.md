---
name: estimator-app-live
description: "CWDB Deck Estimator Streamlit app is live at https://cwdb-estimator.streamlit.app/, deployed from test-branch, Gmail SMTP secrets in Streamlit Cloud dashboard"
metadata: 
  node_type: memory
  type: project
  originSessionId: 97bfa923-959c-4239-8ac7-c3ac10da3288
---

CWDB Deck Estimator Streamlit app is **LIVE** at https://cwdb-estimator.streamlit.app/ as of 2026-05-31. Internal tool — only Jim uses it; emails PDF + populated .xlsx to slogarjw@gmail.com.

**Why:** Mobile/tablet-friendly web shell over the existing Python estimator engine for use in the field (iPhone 11, iPad on iOS Safari). Replaces opening the .xlsx on a phone, which is friction at a customer's driveway. Jim reviews the PDF in his inbox and forwards to the customer himself.

**How to apply:** When Jim mentions "the estimator app," "the Streamlit app," "the field estimator," or wants to update pricing, scope copy, or input fields visible in the web form, this is the artifact in scope. Code lives in `sales/estimating/streamlit_app/`. Engine + workbook template + pricing data live in `sales/estimates/` and `sales/estimating/` and are imported via sys.path manipulation.

**Deploy config (Streamlit Cloud, free tier):**
- Repo: `slogarcapital-byte/CWDB` (private)
- Branch: `test-branch`
- Main file: `sales/estimating/streamlit_app/app.py`
- Subdomain: `cwdb-estimator` (custom)
- Secrets (in Streamlit Cloud dashboard, NOT in repo): `gmail_address`, `gmail_app_password`, `recipient` — all point to slogarjw@gmail.com

**Pushing updates:** any commit to `test-branch` on origin triggers a Streamlit Cloud rebuild automatically. No manual redeploy step needed.

**v1.1 shipped 2026-06-02 (commit `c103225`):** Targeted start month dropdown (rolling 12 months, stdlib date math) under Project type. PDF Schedule section now reads "Targeted start: <Month YYYY>, pending signed acceptance and deposit" via `estimate["schedule"]["start_label"]` override. `generate_estimate_pdf.py` reads `sched.get("start_label", "Estimated start")` so CLI bid skill is unchanged. Slate (#323434) body + 6px orange ribbon + inverse horizontal logo + `st.container(border=True)` glass panels per section + `backdrop-filter: blur` on all inputs.

**v1.2 still deferred:** Material-swap three-tier (Good/Better/Best decking/railing combos — current three-tier is low/quoted/high contingency range, faithful to workbook). Customer-facing email. Workbook QI.START_DATE cell (xlsx attachment doesn't currently carry the targeted start month).

**Cold-start gotcha:** free-tier apps sleep after ~7 days inactivity. First visit after sleep takes 30-60s to wake. Daily use keeps it warm.

Related: [[user-name]] (Jim is the sole user), [[business-contact]] (the recipient email matches the canonical NAP record).
