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
REPO_ROOT = SCRIPT_DIR.parents[2]
LOGO_PATH = REPO_ROOT / "branding" / "logos" / "1.2-horizontal-logo-inverse.png"

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
from render_mockup import generate_mockups  # noqa: E402


def _next_months(n: int = 12, start: date | None = None) -> list[str]:
    """Return n rolling month labels starting at `start` (defaults to today)."""
    start = (start or date.today()).replace(day=1)
    out = []
    for i in range(n):
        m = ((start.month - 1 + i) % 12) + 1
        y = start.year + (start.month - 1 + i) // 12
        out.append(date(y, m, 1).strftime("%B %Y"))
    return out


# ---------------------------------------------------------------------------
# Page setup
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="CWDB Estimator",
    page_icon="🔨",
    layout="centered",
    initial_sidebar_state="collapsed",
)

# Slate body + frosted-glass panels + orange ribbon header
st.markdown(
    """
    <style>
      [data-testid="stAppViewContainer"] { background: #323434; }
      [data-testid="stHeader"] { background: transparent; }

      .cwdb-ribbon {
        position: fixed; top: 0; left: 0; right: 0; height: 6px;
        background: linear-gradient(90deg, #e54c00, #c63e00);
        z-index: 1000;
      }

      h1, h2, h3, p, label, .stMarkdown,
      [data-testid="stWidgetLabel"] p { color: #fafafa !important; }
      .stCaption, [data-testid="stCaptionContainer"] p,
      [data-testid="stCaption"] { color: #b6b8b3 !important; }

      [data-testid="stVerticalBlockBorderWrapper"] {
        background: rgba(255, 255, 255, 0.05);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(255, 255, 255, 0.12) !important;
        border-radius: 14px;
        padding: 0.75rem 1rem !important;
        margin-bottom: 0.5rem;
      }

      .stTextInput input, .stNumberInput input,
      .stSelectbox div[data-baseweb="select"] > div {
        background: rgba(255, 255, 255, 0.08) !important;
        border: 1px solid rgba(255, 255, 255, 0.18) !important;
        color: #fafafa !important;
        border-radius: 10px !important;
        backdrop-filter: blur(8px);
        -webkit-backdrop-filter: blur(8px);
      }
      .stTextInput input::placeholder,
      .stNumberInput input::placeholder { color: rgba(255,255,255,0.45) !important; }

      [data-baseweb="select"] svg { fill: #fafafa !important; }

      .stButton > button[kind="primary"] {
        background-color: #e54c00; color: white; border: 0;
        font-weight: 600; padding: 0.85rem 1.25rem; width: 100%;
        border-radius: 10px;
      }
      .stButton > button[kind="primary"]:hover { background-color: #c63e00; color: white; }
      .stButton > button[kind="primary"]:disabled {
        background-color: rgba(229, 76, 0, 0.35); color: rgba(255,255,255,0.6);
      }

      .stExpander, [data-testid="stExpander"] {
        background: rgba(255, 255, 255, 0.04);
        border: 1px solid rgba(255, 255, 255, 0.10) !important;
        border-radius: 12px;
      }
      [data-testid="stExpander"] summary p { color: #fafafa !important; }

      .price-card {
        background: rgba(255, 255, 255, 0.06);
        backdrop-filter: blur(14px);
        -webkit-backdrop-filter: blur(14px);
        border-left: 4px solid #e54c00;
        border-top: 1px solid rgba(255, 255, 255, 0.08);
        border-right: 1px solid rgba(255, 255, 255, 0.08);
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        padding: 1.25rem 1.5rem;
        border-radius: 14px;
        margin: 0.5rem 0 0.75rem;
      }
      .price-card .label { color: #b6b8b3; font-size: 0.85rem; font-weight: 600;
        text-transform: uppercase; letter-spacing: 0.05em; }
      .price-card .value { color: #ffffff; font-size: 2rem; font-weight: 700; line-height: 1.1; }
      .price-card .range { color: #d8dad6; font-size: 0.95rem; margin-top: 0.3rem; }

      hr { border-color: rgba(255,255,255,0.10) !important; }

      .block-container {
        padding-top: 1.6rem !important;
        padding-bottom: 4rem;
        max-width: 720px;
      }
    </style>
    """,
    unsafe_allow_html=True,
)

# Orange ribbon at the very top
st.markdown('<div class="cwdb-ribbon"></div>', unsafe_allow_html=True)

# Centered horizontal logo (white/inverse variant for the slate background)
_left, _mid, _right = st.columns([1, 2, 1])
with _mid:
    st.image(str(LOGO_PATH), use_container_width=True)

st.title("CWDB Deck Estimator")
st.caption("Central Wisconsin Deck Builders, LLC · Field quote tool")


# ---------------------------------------------------------------------------
# Load pricing DB (cached so we don't re-read on every input change)
# ---------------------------------------------------------------------------
@st.cache_data
def cached_pricing() -> dict:
    return load_pricing()


db = cached_pricing()


def _material_by_name(items, name):
    for m in items:
        if m["name"] == name:
            return m
    return None


def colors_for(material):
    """Color names for a decking/railing/fence material (for the dropdown)."""
    if not material:
        return ["(standard)"]
    names = [c["name"] for c in material.get("colors", [])]
    return names or ["(standard)"]


# ---------------------------------------------------------------------------
# Input form (mirror of Quote Input sheet) — each section in a glass panel
# ---------------------------------------------------------------------------
with st.container(border=True):
    st.subheader("Client")
    col1, col2 = st.columns(2)
    with col1:
        client_name = st.text_input("Name", value="")
        client_phone = st.text_input("Phone", value="")
    with col2:
        client_address = st.text_input("Address", value="")
        client_email = st.text_input("Email", value="")

with st.container(border=True):
    st.subheader("Project")
    project_type = st.selectbox(
        "Project type",
        [pt["name"] for pt in db["project_types"]],
        index=4,  # Full Tear-Out + New Build
    )
    start_month = st.selectbox(
        "Targeted start",
        _next_months(12),
        index=0,
        help="Month you're targeting to begin work. The PDF appends "
             "'pending signed acceptance and deposit'.",
    )
    pt_obj = find_project_type(db, project_type)
    matrix = pt_obj["matrix"]
    is_fence = matrix.get("fence") == "Y"

    if not is_fence:
        col1, col2 = st.columns(2)
        with col1:
            length = st.number_input("Deck length (ft)", min_value=1, value=20, step=1)
        with col2:
            depth = st.number_input("Deck depth (ft)", min_value=1, value=15, step=1)
        st.caption(f"Deck SF: **{length * depth}**")
    else:
        length, depth = 1, 1  # not read by the fence engine

# Defaults so the inputs dict is always complete (overridden per branch below)
decking_material = db["decking_materials"][3]["name"]   # Trex Select
railing_material = db["railing_materials"][2]["name"]    # Trex Aluminum
framing_material = db["framing_materials"][0]["name"]    # KDAT
decking_color = None
railing_color = None
stain_color = None
height = db["condition_multipliers"]["height"][0]["value"]
grade = db["condition_multipliers"]["grade"][0]["value"]
complexity = db["condition_multipliers"]["complexity"][0]["value"]
market = db["condition_multipliers"]["market_load"][0]["value"]
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
skirting_sf = 0
lighting_fix = 0
bench_count = 0
privacy_screen_lf = 0
hot_tub = "No"
# Fence defaults
fence_material = db["fence_materials"][0]["name"]
fence_height = "6"
fence_color = None
fence_lf = 0
walk_gates = 0
drive_gates = 0
tearout_lf = 0

if is_fence:
    with st.container(border=True):
        st.subheader("Fence")
        fence_material = st.selectbox(
            "Fence type", [m["name"] for m in db["fence_materials"]], index=0)
        fmat_obj = _material_by_name(db["fence_materials"], fence_material)
        heights = list(fmat_obj["cost_per_lf_by_height"].keys())
        fence_height = st.selectbox(
            "Height (ft)", heights, index=heights.index("6") if "6" in heights else 0)
        fence_color = st.selectbox("Color / finish", colors_for(fmat_obj), index=0)
        fence_lf = st.number_input("Fence length (LF)", min_value=0, value=150, step=1)
        col1, col2 = st.columns(2)
        with col1:
            walk_gates = st.number_input("Walk gates", min_value=0, value=1, step=1)
        with col2:
            drive_gates = st.number_input("Drive / double gates", min_value=0, value=0, step=1)
        tearout_lf = st.number_input(
            "Existing fence to remove (LF)", min_value=0, value=0, step=1)
else:
    with st.container(border=True):
        st.subheader("Materials")
        decking_material = st.selectbox(
            "Decking", [m["name"] for m in db["decking_materials"]], index=3)  # Trex Select
        decking_color = st.selectbox(
            "Decking color", colors_for(_material_by_name(db["decking_materials"], decking_material)),
            index=0)
        railing_material = st.selectbox(
            "Railing", [m["name"] for m in db["railing_materials"]], index=2)  # Trex Aluminum
        railing_color = st.selectbox(
            "Railing color", colors_for(_material_by_name(db["railing_materials"], railing_material)),
            index=0)
        framing_material = st.selectbox(
            "Framing", [m["name"] for m in db["framing_materials"]], index=0)  # KDAT

    with st.container(border=True):
        st.subheader("Site conditions")
        height = st.selectbox(
            "Height", [m["value"] for m in db["condition_multipliers"]["height"]], index=0)
        grade = st.selectbox(
            "Grade", [m["value"] for m in db["condition_multipliers"]["grade"]], index=0)
        complexity = st.selectbox(
            "Complexity", [m["value"] for m in db["condition_multipliers"]["complexity"]], index=0)
        market = st.selectbox(
            "Market load", [m["value"] for m in db["condition_multipliers"]["market_load"]], index=0)

    if matrix["deck"] == "Y":
        with st.container(border=True):
            st.subheader("Scope detail")
            border_style = st.selectbox("Border style", ["Pencil Border", "Double Border"], index=0)
            fascia_lf = st.number_input("Fascia LF", min_value=0, value=70, step=1)

    if matrix["rail"] != "N":
        with st.container(border=True):
            st.subheader("Railing")
            railing_lf = st.number_input("Railing LF", min_value=0, value=40, step=1)

    if matrix["stair"] != "N":
        with st.container(border=True):
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
        with st.container(border=True):
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
                stain_color = st.selectbox(
                    "Stain color", db.get("stain_colors", ["Natural / Clear"]), index=0)

    if project_type in ("Stain + Minor Repairs", "Resurface (Boards Only)"):
        with st.container(border=True):
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
# Walk-through photos -> AI mock-up renderings (all project types)
# ---------------------------------------------------------------------------
with st.container(border=True):
    st.subheader("Walk-through photos")
    st.caption(
        "Upload site photos from the walk-through. Two AI mock-up renderings "
        "(wide + detail) of the finished project in the selected materials and "
        "colors are generated automatically and added to the PDF, each labeled "
        "as an illustration only."
    )
    uploaded_photos = st.file_uploader(
        "Photos (JPG / PNG / HEIC)",
        type=["jpg", "jpeg", "png", "heic"],
        accept_multiple_files=True,
    )


# ---------------------------------------------------------------------------
# Build inputs dict (matches deck_calculator.compute_engine signature)
# ---------------------------------------------------------------------------
inputs = {
    "project_type": project_type,
    "length": length,
    "depth": depth,
    "decking_material": decking_material,
    "decking_color": decking_color,
    "railing_material": railing_material,
    "railing_color": railing_color,
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
    "stain_color": stain_color,
    "board_repairs": board_repairs,
    "joist_repair_lf": joist_repair_lf,
    "hardware_inc": hardware_inc,
    "skirting_sf": skirting_sf,
    "lighting_fix": lighting_fix,
    "bench_count": bench_count,
    "privacy_screen_lf": privacy_screen_lf,
    "hot_tub": hot_tub,
    # fence
    "fence_material": fence_material,
    "fence_height": fence_height,
    "fence_color": fence_color,
    "fence_lf": fence_lf,
    "walk_gates": walk_gates,
    "drive_gates": drive_gates,
    "tearout_lf": tearout_lf,
}


# ---------------------------------------------------------------------------
# Live calc + render
# ---------------------------------------------------------------------------
with st.container(border=True):
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
    if is_fence:
        flf = eng.get("fence_lf", 0)
        unit = round(eng["sell_price"] / flf, 2) if flf else 0
        unit_label = f"${unit:,}/LF"
    else:
        psf = round(eng["sell_price"] / deck_sf, 2) if deck_sf else 0
        unit_label = f"${psf:,}/sf"

    st.markdown(
        f"""
        <div class="price-card">
          <div class="label">Quoted Sell Price</div>
          <div class="value">${sell:,}</div>
          <div class="range">Range: ${low:,} &nbsp;&ndash;&nbsp; ${high:,}
            &nbsp;&middot;&nbsp; {unit_label}</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

    with st.expander("Line-item breakdown", expanded=False):
        if is_fence:
            rows = [
                ("Fence run", eng.get("fence_run", 0)),
                ("Gates", eng.get("fence_gates", 0)),
                ("Tear-out / disposal", eng.get("fence_tearout", 0)),
                ("Permit / engineering", eng["permit"]),
                ("Dumpster / cleanup", eng["dumpster"]),
                ("Mobilization", eng["mobilization"]),
                ("Misc", eng["misc"]),
            ]
        else:
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
            st.write("No cost components yet. Enter dimensions and materials.")


# ---------------------------------------------------------------------------
# Send button
# ---------------------------------------------------------------------------
st.divider()
if is_fence:
    send_disabled = not (client_name and client_address and fence_lf > 0)
else:
    send_disabled = not (client_name and client_address and length > 0 and depth > 0)

if send_disabled:
    st.caption("Enter client name, address, and "
               + ("fence length" if is_fence else "dimensions")
               + " to enable send.")

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

            # Override the auto-generated schedule with Jim's chosen target month
            estimate["schedule"]["start"] = (
                f"{start_month}, pending signed acceptance and deposit"
            )
            estimate["schedule"]["start_label"] = "Targeted start"

            stem = make_estimate_filename(client_info["name"], project_type).removesuffix(".json")

            with tempfile.TemporaryDirectory() as tmpdir:
                tmp = Path(tmpdir)
                pdf_path = tmp / f"{stem}.pdf"
                xlsx_path = tmp / f"{stem}.xlsx"

                # Save walk-through photos and auto-generate AI mock-up renderings.
                if uploaded_photos:
                    photo_dir = tmp / "photos"
                    photo_dir.mkdir(exist_ok=True)
                    saved = []
                    for up in uploaded_photos:
                        dest = photo_dir / up.name
                        dest.write_bytes(up.getbuffer())
                        saved.append(dest)
                    selections = {
                        "is_fence": is_fence,
                        "decking_material": decking_material,
                        "decking_color": decking_color,
                        "railing_material": railing_material,
                        "railing_color": railing_color,
                        "fence_material": fence_material,
                        "fence_height": fence_height,
                        "fence_color": fence_color,
                    }
                    api_key = st.secrets.get("gemini_api_key", "")
                    renderings = generate_mockups(saved, selections, tmp / "renders", api_key)
                    if renderings:
                        estimate["renderings"] = [
                            {"path": str(r["path"]), "caption": r["caption"]}
                            for r in renderings
                        ]
                    else:
                        st.warning(
                            "Mock-up rendering was skipped (no Gemini API key set, or "
                            "rendering failed). The estimate is sent without renderings."
                        )

                generate_pdf(estimate, pdf_path)
                populate_workbook(inputs, client_info, xlsx_path)

                send_estimate_email(
                    gmail_address=st.secrets["gmail_address"],
                    gmail_app_password=st.secrets["gmail_app_password"],
                    recipient=st.secrets["recipient"],
                    subject=(
                        f"CWDB Estimate - {client_info['name']} - "
                        f"{project_type} - ${sell:,}"
                    ),
                    body=(
                        f"Estimate generated {date.today().isoformat()}.\n\n"
                        f"Client: {client_info['name']}\n"
                        f"Address: {client_info['address_line']}\n"
                        f"Project type: {project_type}\n"
                        f"Targeted start: {start_month}\n"
                        + (
                            f"Fence: {fence_height} ft {fence_material}, {fence_lf} LF\n"
                            if is_fence else
                            f"Deck: {length} ft x {depth} ft = {deck_sf} sf\n"
                            f"Decking: {decking_material}\n"
                            f"Railing: {railing_material}\n"
                        )
                        + f"\nQuoted sell price: ${sell:,}\n"
                        f"Range: ${low:,} - ${high:,}\n\n"
                        f"PDF and populated workbook attached."
                    ),
                    attachments=[pdf_path, xlsx_path],
                )
            st.success(
                f"Sent to {st.secrets['recipient']} - ${sell:,} for "
                f"{client_info['name']} ({project_type})."
            )
        except Exception as e:
            st.error(f"Failed to send: {e}")
            st.exception(e)
