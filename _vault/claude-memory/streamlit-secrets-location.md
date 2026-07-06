---
name: streamlit-secrets-location
description: "Streamlit reads secrets from <CWD>/.streamlit/secrets.toml (relative to where you run it, not the script) - real key never goes in the committed .example"
metadata: 
  node_type: memory
  type: project
  originSessionId: bcc55f79-308c-4cce-ba53-cd2c4645b8b4
---

Streamlit resolves its project secrets file as **`<current-working-dir>/.streamlit/secrets.toml`** (relative to the directory you run `streamlit run` from, NOT the script's directory) plus the global `~/.streamlit/secrets.toml`. Confirmed via `config.get_option("secrets.files")` on Streamlit 1.57.

For the estimator, the `.streamlit/` folder + `.gitignore` live in `sales/estimating/streamlit_app/`, so launch from there: `cd sales/estimating/streamlit_app && streamlit run app.py`. Running from the repo root makes Streamlit look at `<repo>/.streamlit/secrets.toml` and miss the app's secrets.

Three files, do not confuse them:
- **`.streamlit/secrets.toml.example`** = COMMITTED placeholder template. NEVER put a real key here; it leaks on push. (`gmail_api_key`/`gemini_api_key` placeholders only.)
- **`.streamlit/secrets.toml`** = the REAL local file, gitignored (`.gitignore:1`). Real keys go here for local/Codespace runs.
- **Streamlit Community Cloud dashboard** = the DEPLOYED app does not read any repo file; its secrets come from share.streamlit.io -> app -> Settings -> Secrets (paste the same TOML, has a Save button).

**Why:** Jim pasted the live Gemini key into `secrets.toml.example` inside a Codespace (2026-06-17) - wrong file (Streamlit ignores it) AND a committed template (leak risk). The CWD-relative resolution also means a correct file in the wrong launch dir is silently never read.

**How to apply:** real key -> gitignored `secrets.toml` for local/Codespace, dashboard for the deployed app; scrub any real value back out of `secrets.toml.example`; rotate the key if it was ever committed. The renderer needs a PAID Gemini tier per legal. Related: [[estimator-app-live]], [[ios-safari-streamlit-dark-inputs]].
