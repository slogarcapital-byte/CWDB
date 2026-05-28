"""
CWDB Deck Estimator — Streamlit web app
Central Wisconsin Deck Builders, LLC

Thin web shell over the existing Python engine. Mobile-first for iOS Safari.
Inputs mirror the workbook's Quote Input sheet. On submit, generates a
branded PDF + populated .xlsx and emails both to the configured recipient.

Run locally:
    streamlit run app.py

Deploy:
    Push to GitHub, connect repo on share.streamlit.io,
    set secrets (gmail_address, gmail_app_password, recipient) in dashboard.
"""

from __future__ import annotations

import sys
import tempfile
from datetime import date
from pathlib import Path

import streamlit as st

SCRIPT_DIR = Path(__file__).resolve().parent
ESTIMATING_DIR = SCRIPT_DIR.parent
ESTIMATES_DIR = ESTIMATING_DIR.parent / "estimates"

for p in (ESTIMATING_DIR, ESTIMATES_DIR):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from deck_calculator import (  # noqa: E402
    build_estimate_json,
    compute_engine,
    find_project_type,
    load_pricing,
    make_estimate_filename,
    round_money,
)
from generate_estimate_pdf import generate_pdf  # noqa: E402

from email_send import send_estimate_email  # noqa: E402
from populate_workbook import populate as populate_workbook  # noqa: E402


# ---------------------------------------------------------------------------
# Page setup + brand styling
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="CWDB Estimator",
    page_icon="🔨",
    layout="centered",
    initial_sidebar_state="collapsed",
)

ORANGE = "#e54c00"
SLATE = "#323434"
GREY = "#646760"
SKY = "#83b2cf"

st.markdown(
    f"""
    <style>
      .block-container {{ padding-top: 1.2rem; padding-bottom: 4rem; max-width: 720px; }}
      h1, h2, h3 {{ color: {SLATE}; }}
      .stButton > button[kind="primary"] {{
        background-color: {ORANGE}; color: white; border: 0;
        font-weight: 600; padding: 0.75rem 1.25rem; width: 100%;
      }}
      .stButton > button[kind="primary"]:hover {{ background-color: #c63e00; color: white; }}
      .price-card {{
        background: #f7f4f1; border-left: 4px solid {ORANGE};
        padding: 1rem 1.25rem; margin: 0.5rem 0; border-radius: 6px;
      }}
      .price-card .label {{ color: {GREY}; font-size: 0.85rem; font-weight: 600;
        text-transform: uppercase; letter-spacing: 0.05em; }}
      .price-card .value {{ color: {ORANGE}; font-size: 2rem; font-weight: 700; line-height: 1.1; }}
      .price-card .range {{ color: {SLATE}; font-size: 0.95rem; margin-top: 0.3rem; }}
      .stExpander {{ border-color: #e5e0d9; }}
    </style>
    """,
    unsafe_allow_html=True,
)

st.title("CWDB Deck Estimator")
st.caption("Central Wisconsin Deck Builders, LLC · Field quote tool")


# ---------------------------------------------------------------------------
# Load pricing DB (cached so we don't re-read on every input change)
# ---------------------------------------------------------------------------
@st.cache_data
def cached_pricing() -> dict:
    return load_pricing()


db = cached_pricing()


# ---------------------------------------------------------------------------
# Input form (mirror of Quote Input sheet)
# ---------------------------------------------------------------------------
st.subheader("Client")
col1, col2 = st.columns(2)
with col1:
    client_name = st.text_input("Name", value="")
    client_phone = st.text_input("Phone", value="")
with col2:
    client_address = st.text_input("Address", value="")
    client_email = st.text_input("Email", value="")

st.subheader("Project")
project_type = st.selectbox(
    "Project type",
    [pt["name"] for pt in db["project_types"]],
    index=4,  # Full Tear-Out + New Build
)
pt_obj = find_project_type(db, project_type)
matrix = pt_obj["matrix"]

col1, col2 = st.columns(2)
with col1:
    length = st.number_input("Deck length (ft)", min_value=1, value=20, step=1)
with col2:
    depth = st.number_input("Deck depth (ft)", min_value=1, value=15, step=1)

st.caption(f"Deck SF: **{length * depth}**")

st.subheader("Materials")
decking_material = st.selectbox(
    "Decking",
    [m["name"] for m in db["decking_materials"]],
    index=3,  # Trex Select
)
railing_material = st.selectbox(
    "Railing",
    [m["name"] for m in db["railing_materials"]],
    index=2,  # Trex Aluminum
)
framing_material = st.selectbox(
    "Framing",
    [m["name"] for m in db["framing_materials"]],
    index=0,  # KDAT
)

st.subheader("Site conditions")
height = st.selectbox(
    "Height",
    [m["value"] for m in db["condition_multipliers"]["height"]],
    index=0,
)
grade = st.selectbox(
    "Grade",
    [m["value"] for m in db["condition_multipliers"]["grade"]],
    index=0,
)
complexity = st.selectbox(
    "Complexity",
    [m["value"] for m in db["condition_multipliers"]["complexity"]],
    index=0,
)
market = st.selectbox(
    "Market load",
    [m["value"] for m in db["condition_multipliers"]["market_load"]],
    index=0,
)

# Sensible defaults that get overridden below based on project type
border_style = "Pencil Border"
fascia_lf = 0
railing_lf = 0
stair_runs = 0
stair_treads = 0
stair_landings = 0
wraparound = "No"
stain_sf = 0
stain_type = "Solid / Paint-and-Sealer"
stain_coats = 1
board_repairs = 0
joist_repair_lf = 0
hardware_inc = "No"

if matrix["deck"] == "Y":
    st.subheader("Scope detail")
    border_style = st.selectbox("Border style", ["Pencil Border", "Double Border"], index=0)
    fascia_lf = st.number_input("Fascia LF", min_value=0, value=70, step=1)

if matrix["rail"] != "N":
    st.subheader("Railing")
    railing_lf = st.number_input("Railing LF", min_value=0, value=40, step=1)

if matrix["stair"] != "N":
    st.subheader("Stairs")
    col1, col2 = st.columns(2)
    with col1:
        stair_runs = st.number_input("Runs", min_value=0, value=1, step=1)
    with col2:
        stair_treads = st.number_input("Total treads", min_value=0, value=6, step=1) if stair_runs > 0 else 0
    if stair_runs > 0:
        col3, col4 = st.columns(2)
        with col3:
            stair_landings = st.number_input("Landings", min_value=0, value=0, step=1)
        with col4:
            wraparound = st.selectbox("Wraparound?", ["No", "Yes"], index=0)

if matrix["stain"] == "Y":
    st.subheader("Stain")
    stain_sf = st.number_input(
        "Stain SF (deck + railing/stair SF blended)", min_value=0, value=0, step=10
    )
    if stain_sf > 0:
        stain_types = sorted({sr["type"] for sr in db["stain_rates_per_sf"]})
        stain_type = st.selectbox(
            "Stain type",
            stain_types,
            index=stain_types.index("Solid / Paint-and-Sealer")
            if "Solid / Paint-and-Sealer" in stain_types else 0,
        )
        stain_coats = int(st.selectbox("Coats", ["1", "2"], index=0))

if project_type in ("Stain + Minor Repairs", "Resurface (Boards Only)"):
    st.subheader("Repair bucket")
    col1, col2 = st.columns(2)
    with col1:
        board_repairs = st.number_input("Board replacements", min_value=0, value=0, step=1)
    with col2:
        joist_repair_lf = st.number_input("Joist repair LF", min_value=0, value=0, step=1)
    hardware_inc = st.selectbox("Hardware allowance?", ["No", "Yes"], index=0)

with st.expander("Optional adders"):
    col1, col2 = st.columns(2)
    with col1:
        skirting_sf = st.number_input("Skirting / privacy wall SF", min_value=0, value=0, step=1)
        lighting_fix = st.number_input("Lighting fixtures", min_value=0, value=0, step=1)
    with col2:
        bench_count = st.number_input("Built-in benches", min_value=0, value=0, step=1)
        privacy_screen_lf = st.number_input("Privacy screen LF", min_value=0, value=0, step=1)
    hot_tub = st.selectbox("Hot tub structural upgrade?", ["No", "Yes"], index=0)


# ---------------------------------------------------------------------------
# Build inputs dict (matches deck_calculator.compute_engine signature)
# ---------------------------------------------------------------------------
inputs = {
    "project_type": project_type,
    "length": length,
    "depth": depth,
    "decking_material": decking_material,
    "railing_material": railing_material,
    "framing_material": framing_material,
    "height": height,
    "grade": grade,
    "complexity": complexity,
    "market": market,
    "border_style": border_style,
    "fascia_lf": fascia_lf,
    "railing_lf": railing_lf,
    "stair_runs": stair_runs,
    "stair_treads": stair_treads,
    "stair_landings": stair_landings,
    "wraparound": wraparound,
    "stain_sf": stain_sf,
    "stain_type": stain_type,
    "stain_coats": stain_coats,
    "board_repairs": board_repairs,
    "joist_repair_lf": joist_repair_lf,
    "hardware_inc": hardware_inc,
    "skirting_sf": skirting_sf,
    "lighting_fix": lighting_fix,
    "bench_count": bench_count,
    "privacy_screen_lf": privacy_screen_lf,
    "hot_tub": hot_tub,
}


# ---------------------------------------------------------------------------
# Live calc + render
# ---------------------------------------------------------------------------
st.divider()
st.subheader("Estimate")

try:
    eng = compute_engine(db, inputs)
except Exception as e:
    st.error(f"Calculation error: {e}")
    st.stop()

sell = round_money(eng["sell_price"])
contingency = db["margin_and_contingency"]["default_contingency"]
low = round_money(eng["sell_price"] * (1 - contingency))
high = round_money(eng["sell_price"] * (1 + contingency))
deck_sf = eng["deck_sf"]
psf = round(eng["sell_price"] / deck_sf, 2) if deck_sf else 0

st.markdown(
    f"""
    <div class="price-card">
      <div class="label">Quoted Sell Price</div>
      <div class="value">${sell:,}</div>
      <div class="range">Range: ${low:,} &nbsp;–&nbsp; ${high:,}
        &nbsp;·&nbsp; ${psf:,}/sf</div>
    </div>
    """,
    unsafe_allow_html=True,
)

with st.expander("Line-item breakdown", expanded=False):
    rows = [
        ("Base Package (framing + decking)", eng["base_package"]),
        ("Demo", eng["demo"]),
        ("Border upgrade", eng["border"]),
        ("Railing", eng["rail"]),
        ("Fascia", eng["fascia"]),
        ("Stairs", eng["stair"]),
        ("Stain", eng["stain"]),
        ("Repairs", eng["repair"]),
        ("Skirting", eng["skirting"]),
        ("Lighting", eng["lighting"]),
        ("Built-in benches", eng["benches"]),
        ("Privacy screen", eng["privacy"]),
        ("Hot tub structural", eng["hot_tub"]),
        ("Permit / engineering", eng["permit"]),
        ("Dumpster / cleanup", eng["dumpster"]),
        ("Mobilization", eng["mobilization"]),
        ("Misc", eng["misc"]),
    ]
    nonzero = [(label, round_money(v)) for label, v in rows if v]
    if nonzero:
        st.table(
            {
                "Component": [r[0] for r in nonzero],
                "Cost": [f"${v:,}" for _, v in nonzero],
            }
        )
        st.caption(
            f"Cost subtotal: **${round_money(eng['subtotal_cost']):,}** · "
            f"margin: **{int(eng['margin'] * 100)}%** · "
            f"sell price: **${sell:,}**"
        )
    else:
        st.write("No cost components yet — enter dimensions and materials.")


# ---------------------------------------------------------------------------
# Send button
# ---------------------------------------------------------------------------
st.divider()
send_disabled = not (client_name and client_address and length > 0 and depth > 0)

if send_disabled:
    st.caption("Enter client name, address, and dimensions to enable send.")

if st.button(
    "Send PDF + Excel to my inbox",
    type="primary",
    disabled=send_disabled,
    use_container_width=True,
):
    with st.spinner("Generating estimate, populating workbook, sending email..."):
        client_info = {
            "name": client_name or "Homeowner",
            "address_line": client_address or "Central Wisconsin",
            "phone": client_phone or "(715) 555-0000",
            "email": client_email or "client@example.com",
        }

        try:
            estimate = build_estimate_json(inputs, client_info, db)
            stem = make_estimate_filename(client_info["name"], project_type).removesuffix(".json")

            with tempfile.TemporaryDirectory() as tmpdir:
                tmp = Path(tmpdir)
                pdf_path = tmp / f"{stem}.pdf"
                xlsx_path = tmp / f"{stem}.xlsx"

                generate_pdf(estimate, pdf_path)
                populate_workbook(inputs, client_info, xlsx_path)

                send_estimate_email(
                    gmail_address=st.secrets["gmail_address"],
                    gmail_app_password=st.secrets["gmail_app_password"],
                    recipient=st.secrets["recipient"],
                    subject=(
                        f"CWDB Estimate — {client_info['name']} — "
                        f"{project_type} — ${sell:,}"
                    ),
                    body=(
                        f"Estimate generated {date.today().isoformat()}.\n\n"
                        f"Client: {client_info['name']}\n"
                        f"Address: {client_info['address_line']}\n"
                        f"Project type: {project_type}\n"
                        f"Deck: {length} ft x {depth} ft = {deck_sf} sf\n"
                        f"Decking: {decking_material}\n"
                        f"Railing: {railing_material}\n\n"
                        f"Quoted sell price: ${sell:,}\n"
                        f"Range: ${low:,} – ${high:,}\n\n"
                        f"PDF and populated workbook attached."
                    ),
                    attachments=[pdf_path, xlsx_path],
                )
            st.success(
                f"Sent to {st.secrets['recipient']} — ${sell:,} for "
                f"{client_info['name']} ({project_type})."
            )
        except Exception as e:
            st.error(f"Failed to send: {e}")
            st.exception(e)
