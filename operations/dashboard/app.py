"""CWDB HQ - the business dashboard for Central Wisconsin Deck Builders.

Four tabs: Command (KPIs + exec summary + board of counselors), To-Do
(canonical task list with Complete/Defer/Decline/Send-to-Claude), Diagnostics
(instrument health + audit findings), Financials (QBO P&L, position, tax
reserve, job profitability).

Run locally (full function):
    pwsh operations/dashboard/launch-dashboard.ps1
    (or: streamlit run operations/dashboard/app.py)

Cloud twin (read-only, phone): deploy this file on share.streamlit.io from
test-branch with secrets supabase_url, supabase_anon_key, app_passcode and
env CWDB_HQ_MODE=cloud (set in secrets as well; config auto-detects too).

Design doc: C:/Users/jslog/.claude/plans/brainstorm-a-dashboard-for-velvet-dragonfly.md
Data layer: operations/data-warehouse/schema/013_dashboard_hq.sql
"""

from __future__ import annotations

import sys
from pathlib import Path

import streamlit as st

APP_DIR = Path(__file__).resolve().parent
if str(APP_DIR) not in sys.path:
    sys.path.insert(0, str(APP_DIR))

from lib import config  # noqa: E402

st.set_page_config(
    page_title="CWDB HQ",
    page_icon="🏗️",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# CWDB HQ design system. The [theme] config (.streamlit/config.toml, picked up
# because the launcher sets CWD to this dir) does the heavy lifting: dark base,
# orange primary, slate surfaces, off-white text. This CSS layers brand on top:
# Staatliches + Public Sans, glass surface hierarchy, button tiers, chips.
# Glass is purposeful, not ambient: only containers keyed "glass_*" get frost.
st.markdown(
    """
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Staatliches&family=Public+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap');

      :root {
        --orange: #e54c00; --orange-deep: #c63e00;
        --slate: #323434; --slate-raised: #3d403e;
        --sky: #83b2cf;
        --ink: #f8f8f6; --ink-dim: #b9bcb6; --ink-faint: #90938d;
        --glass: rgba(255, 255, 255, 0.055);
        --glass-raised: rgba(255, 255, 255, 0.09);
        --line: rgba(255, 255, 255, 0.13);
        --line-strong: rgba(255, 255, 255, 0.22);
        --ok: #8fbf7f; --warn: #dcaf5a; --fail: #e0796a;
      }

      html, body, [data-testid="stAppViewContainer"] {
        background: var(--slate);
        font-family: 'Public Sans', -apple-system, 'Segoe UI', sans-serif;
      }
      [data-testid="stHeader"] { background: transparent; }

      .cwdb-ribbon {
        position: fixed; top: 0; left: 0; right: 0; height: 6px;
        background: linear-gradient(90deg, #e54c00, #c63e00);
        z-index: 1000;
      }

      /* ---- Type: Staatliches display over Public Sans body.
             Fixed rem scale 2.44 / 1.95 / 1.56 / 1 / 0.8 (ratio 1.25). ---- */
      h1, h2, h3 {
        font-family: 'Staatliches', 'Public Sans', sans-serif;
        font-weight: 400; text-transform: uppercase; letter-spacing: 0.5px;
        color: var(--ink) !important;
      }
      h1 { font-size: 2.44rem !important; }
      h2 { font-size: 1.95rem !important; }
      h3 { font-size: 1.56rem !important; }
      p, label, li { line-height: 1.6; }
      /* Readable measure for long-form text (counsel verdicts, findings).
         Tables, metrics, and widgets are unaffected. */
      .stMarkdown p, .stMarkdown li { max-width: 78ch; }
      [data-testid="stCaptionContainer"] p, .stCaption {
        color: var(--ink-dim) !important; font-size: 0.8rem !important;
      }
      .stMarkdown code {
        color: var(--sky); background: rgba(131, 178, 207, 0.12);
        border-radius: 5px; padding: 1px 5px; font-size: 0.78rem;
      }
      hr { border-color: var(--line) !important; }

      /* ---- Tabs: quiet uppercase labels, orange active indicator ---- */
      button[data-baseweb="tab"] { background: transparent !important; }
      button[data-baseweb="tab"] p {
        font-family: 'Public Sans', sans-serif !important;
        font-weight: 600 !important; font-size: 0.85rem !important;
        text-transform: uppercase; letter-spacing: 0.07em;
        color: var(--ink-dim) !important;
      }
      button[data-baseweb="tab"][aria-selected="true"] p { color: var(--ink) !important; }
      [data-baseweb="tab-highlight"] { background-color: var(--orange) !important; height: 3px; }
      [data-baseweb="tab-border"] { background-color: var(--line) !important; }

      /* ---- Metrics: quiet uppercase label, strong off-white numeral,
             sky informational delta (arrow icon hidden: deltas are notes,
             not up/down judgments). Orange is reserved for actions. ---- */
      [data-testid="stMetricLabel"] p {
        color: var(--ink-dim) !important; font-size: 0.8rem !important;
        font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em;
      }
      [data-testid="stMetricValue"] {
        color: var(--ink) !important; font-weight: 700;
        font-variant-numeric: tabular-nums;
      }
      [data-testid="stMetricDelta"] {
        color: var(--sky) !important; font-size: 0.85rem !important;
        background: rgba(131, 178, 207, 0.12) !important;
      }
      [data-testid="stMetricDelta"] svg { display: none; }

      /* ---- Button tiers. Primary: the one orange action per view.
             Secondary: raised glass pill. Tertiary: quiet text. ---- */
      button[data-testid="stBaseButton-primary"] {
        background: var(--orange); color: #fff7f2; border: 0;
        border-radius: 10px; font-weight: 700;
      }
      button[data-testid="stBaseButton-primary"]:hover {
        background: var(--orange-deep); color: #ffffff;
      }
      button[data-testid="stBaseButton-primary"]:disabled {
        background: rgba(229, 76, 0, 0.35); color: rgba(255, 255, 255, 0.6);
      }
      button[data-testid="stBaseButton-secondary"],
      button[data-testid="stBaseButton-secondaryFormSubmit"] {
        background: var(--glass-raised); color: var(--ink);
        border: 1px solid var(--line-strong); border-radius: 10px;
        font-weight: 600;
      }
      button[data-testid="stBaseButton-secondary"]:hover,
      button[data-testid="stBaseButton-secondaryFormSubmit"]:hover {
        background: rgba(255, 255, 255, 0.14);
        border-color: rgba(255, 255, 255, 0.34); color: #ffffff;
      }
      button[data-testid="stBaseButton-tertiary"] {
        color: var(--ink-dim); font-weight: 500;
      }
      button[data-testid="stBaseButton-tertiary"]:hover { color: var(--ink); }

      /* Semantic tints on keyed task actions: Complete confirms (green),
         the two Claude sends are informational (sky). Quiet, not neon. */
      div[class*="st-key-done_"] button {
        background: rgba(143, 191, 127, 0.12);
        border-color: rgba(143, 191, 127, 0.45); color: #cbe3c1;
      }
      div[class*="st-key-done_"] button:hover {
        background: rgba(143, 191, 127, 0.22);
        border-color: rgba(143, 191, 127, 0.7); color: #e4f1dd;
      }
      div[class*="st-key-send_"] button, div[class*="st-key-queue_"] button {
        background: rgba(131, 178, 207, 0.1);
        border-color: rgba(131, 178, 207, 0.4); color: #bdd8e9;
      }
      div[class*="st-key-send_"] button:hover, div[class*="st-key-queue_"] button:hover {
        background: rgba(131, 178, 207, 0.2);
        border-color: rgba(131, 178, 207, 0.65); color: #dcecf6;
      }

      /* ---- Glass panels: one step of frost per raised surface.
             Applied only to containers keyed glass_* (purposeful, not
             ambient). Covers both places Streamlit can park the key
             class relative to the bordered stVerticalBlock. ---- */
      .stVerticalBlock[class*="st-key-glass_"],
      [class*="st-key-glass_"] > [data-testid="stLayoutWrapper"] > .stVerticalBlock {
        background: var(--glass);
        backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);
        border: 1px solid var(--line) !important;
        border-radius: 14px !important;
        padding: 1rem 1.15rem !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
      }

      /* ---- Expanders: quiet, one step below glass panels ---- */
      [data-testid="stExpander"] details {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid var(--line) !important; border-radius: 12px;
      }
      [data-testid="stExpander"] summary { color: var(--ink) !important; }
      [data-testid="stExpander"] summary:hover { color: #ffffff !important; }

      /* ---- Inputs: opaque dark (iOS cannot composite translucent inputs
             to white), off-white text, autofill overrides. ---- */
      .stTextInput input, .stNumberInput input, .stTextArea textarea,
      .stSelectbox div[data-baseweb="select"] > div, .stDateInput input {
        background-color: #3a3d3c !important;
        color: var(--ink) !important;
        -webkit-text-fill-color: var(--ink) !important;
        -webkit-appearance: none !important; appearance: none !important;
        border: 1px solid var(--line-strong) !important;
        border-radius: 10px !important;
      }
      .stTextInput input:-webkit-autofill,
      .stTextInput input:-webkit-autofill:hover,
      .stTextInput input:-webkit-autofill:focus,
      .stNumberInput input:-webkit-autofill,
      .stNumberInput input:-webkit-autofill:focus {
        -webkit-text-fill-color: var(--ink) !important;
        -webkit-box-shadow: 0 0 0 1000px #3a3d3c inset !important;
        caret-color: var(--ink) !important;
        transition: background-color 9999s ease 0s;
      }
      .stTextInput input::placeholder, .stNumberInput input::placeholder,
      .stTextArea textarea::placeholder { color: rgba(255, 255, 255, 0.4) !important; }
      [data-baseweb="select"] svg { fill: var(--ink) !important; }

      /* ---- Priority chips: typographic badges, not emoji dots ---- */
      .cwdb-chip {
        display: inline-block;
        font: 700 0.68rem/1 'Public Sans', sans-serif;
        letter-spacing: 0.08em; text-transform: uppercase;
        padding: 3px 8px 2px; border-radius: 6px;
        border: 1px solid transparent; vertical-align: 2px;
      }
      .cwdb-chip.p0 { color: #f0a99e; background: rgba(224, 121, 106, 0.14); border-color: rgba(224, 121, 106, 0.4); }
      .cwdb-chip.p1 { color: #e8c98d; background: rgba(220, 175, 90, 0.13); border-color: rgba(220, 175, 90, 0.38); }
      .cwdb-chip.p2 { color: #b9bcb6; background: rgba(255, 255, 255, 0.07); border-color: rgba(255, 255, 255, 0.2); }

      .cwdb-task-head { display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; }
      .cwdb-task-title { font-weight: 600; font-size: 1rem; color: var(--ink); }
      .cwdb-task-effort { color: var(--ink-faint); font-size: 0.8rem; font-style: italic; }
    </style>
    <div class="cwdb-ribbon"></div>
    """,
    unsafe_allow_html=True,
)

read_only = config.is_read_only()

_logo_col, _sp_col, _btn_col = st.columns([2.4, 3.4, 2.2], vertical_alignment="center")
with _logo_col:
    if config.LOGO_PATH.exists():
        st.image(str(config.LOGO_PATH), width=280)
with _btn_col:
    _b1, _b2 = st.columns(2)
    if _b1.button("Refresh", width="stretch",
                  help="Re-query Supabase (clears caches)"):
        st.cache_data.clear()
        st.rerun()
    if not read_only:
        if _b2.button("Full re-pull", width="stretch",
                      help="Runs the full warehouse daily pull "
                           "(HubSpot + Google + Meta + GA4) in the "
                           "background (~2-5 min)"):
            from lib import events, runners
            log = runners.run_warehouse_daily()
            events.emit("refresh_run", {"scope": "warehouse_daily", "log": str(log)})
            st.info(f"Warehouse pull running. Log: {log}")

st.title("CWDB HQ")
st.caption("Central Wisconsin Deck Builders · business operating surface"
           + (" · read-only twin" if read_only else ""))


# Passcode gate (cloud only): same pattern as the estimator. Local mode is
# Jim's own laptop; no gate.
def require_passcode() -> None:
    expected = st.secrets.get("app_passcode", "") if read_only else ""
    if not expected:
        if read_only:
            st.warning("Passcode not configured (app_passcode secret).", icon="⚠️")
        return
    if st.session_state.get("_authed"):
        return
    with st.container(border=True, key="glass_passcode"):
        st.subheader("Enter passcode")
        code = st.text_input("Passcode", type="password", key="_passcode_input")
        if st.button("Enter", type="primary"):
            if code == expected:
                st.session_state["_authed"] = True
                st.rerun()
            st.error("Wrong passcode.")
    st.stop()


require_passcode()

from tabs import command, diagnostics, financials, todo  # noqa: E402

tab1, tab2, tab3, tab4 = st.tabs(
    ["Command", "To-Do", "Diagnostics", "Financials"]
)
with tab1:
    command.render(read_only)
with tab2:
    todo.render(read_only)
with tab3:
    diagnostics.render(read_only)
with tab4:
    financials.render(read_only)
