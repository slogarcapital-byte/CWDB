"""CWDB HQ configuration: mode detection, paths, credentials.

Two modes (env var CWDB_HQ_MODE, or auto-detected):
  local  - full function. Runs on Jim's laptop, reads .env.local at repo root
           (service-role key), can write files, launch terminals, run pulls.
  cloud  - read-only twin on Streamlit Cloud. Credentials come from
           st.secrets (supabase_url + supabase_anon_key); every write surface
           is hidden. The anon key only passes RLS SELECT policies.
"""

from __future__ import annotations

import os
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent          # operations/dashboard/lib
APP_DIR = SCRIPT_DIR.parent                            # operations/dashboard
REPO_ROOT = APP_DIR.parents[1]                         # repo root
ENV_LOCAL = REPO_ROOT / ".env.local"
VAULT_DIR = REPO_ROOT / "_vault"
BOARD_DIR = VAULT_DIR / "board"
CRON_LOG = VAULT_DIR / "data" / "cron-runs.log"
COUNSEL_DIR = VAULT_DIR / "counsel"
PROMPTS_DIR = VAULT_DIR / "dashboard" / "prompts"
LOGO_PATH = REPO_ROOT / "branding" / "logos" / "1.2-horizontal-logo-inverse.png"

AUDIT_DATE = "2026-07-05"


def _load_env_local() -> dict[str, str]:
    """Parse .env.local (KEY=VALUE lines) without external deps."""
    values: dict[str, str] = {}
    if not ENV_LOCAL.exists():
        return values
    for line in ENV_LOCAL.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        values[key.strip()] = val.strip().strip('"').strip("'")
    return values


def get_mode() -> str:
    mode = os.environ.get("CWDB_HQ_MODE", "").strip().lower()
    if mode in ("local", "cloud"):
        return mode
    # Auto-detect: a repo .env.local with a service key means Jim's laptop.
    return "local" if ENV_LOCAL.exists() else "cloud"


def is_read_only() -> bool:
    return get_mode() != "local"


def get_supabase_credentials() -> tuple[str, str]:
    """Return (url, key). Local: service-role from .env.local. Cloud: anon from secrets."""
    if get_mode() == "local":
        env = _load_env_local()
        url = env.get("SUPABASE_URL") or os.environ.get("SUPABASE_URL", "")
        key = env.get("SUPABASE_SERVICE_ROLE_KEY") or os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    else:
        import streamlit as st
        url = st.secrets.get("supabase_url", "")
        key = st.secrets.get("supabase_anon_key", "")
    if not url or not key:
        raise RuntimeError(
            "Supabase credentials missing. Local: SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY "
            "in .env.local. Cloud: supabase_url + supabase_anon_key in Streamlit secrets."
        )
    # Normalize: some configs store the full REST base; we want the project root.
    url = url.rstrip("/")
    if url.endswith("/rest/v1"):
        url = url[: -len("/rest/v1")]
    return url, key
