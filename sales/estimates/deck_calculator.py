"""
CWDB Deck Calculator (Phase 2)
Central Wisconsin Deck Builders, LLC

Pure-Python port of the Excel estimator engine. Takes project inputs
interactively (or via a JSON inputs file), runs the same math the workbook
runs, fills scope-copy templates per project type, and writes an
estimate JSON that `generate_estimate_pdf.py` consumes to render a PDF.

Usage:
    # Interactive prompt mode (default)
    python deck_calculator.py --interactive

    # From a saved inputs file
    python deck_calculator.py --inputs path/to/inputs.json

    # Auto-render PDF after writing JSON
    python deck_calculator.py --interactive --pdf

Output JSON lands at:
    sales/estimates/_data/<YYYY-MM-DD>-<lastname-slug>-<project-slug>.json

Then (if --pdf):
    sales/estimates/<same-stem>.pdf
"""

import argparse
import json
import math
import re
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
ESTIMATING_DIR = REPO_ROOT / "sales" / "estimating"
SCOPE_COPY_DIR = ESTIMATING_DIR / "scope-copy"
PRICING_DB_PATH = ESTIMATING_DIR / "pricing-db.json"
PDF_GENERATOR = SCRIPT_DIR / "generate_estimate_pdf.py"
DATA_DIR = SCRIPT_DIR / "_data"
DATA_DIR.mkdir(exist_ok=True)


# -----------------------------------------------------------------------------
# Pricing DB load
# -----------------------------------------------------------------------------
def load_pricing():
    with open(PRICING_DB_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def find_by_name(items, name, name_key="name"):
    for it in items:
        if it[name_key] == name:
            return it
    raise KeyError(f"{name_key}={name!r} not found")


def find_multiplier(mlist, value):
    for m in mlist:
        if m["value"] == value:
            return m["multiplier"]
    raise KeyError(value)


def find_project_type(db, name):
    for pt in db["project_types"]:
        if pt["name"] == name:
            return pt
    raise KeyError(name)


def find_stain_rate(db, stain_type, coats):
    for sr in db["stain_rates_per_sf"]:
        if sr["type"] == stain_type and sr["coats"] == coats:
            return sr["per_sf"]
    raise KeyError((stain_type, coats))


def find_adder(db, key):
    for ad in db["adders"]:
        if ad["key"] == key:
            return ad["price"]
    raise KeyError(key)


def get_project_allowances(db, project_type_name):
    for a in db["allowances_by_project_type"]:
        if a["name"] == project_type_name:
            return a["permit"], a["dumpster"], a["mobilization"]
    return (
        db["allowances"]["permit_engineering_default"],
        db["allowances"]["dumpster_cleanup_default"],
        db["allowances"]["mobilization_minimum_default"],
    )


def find_fence_material(db, name):
    for m in db.get("fence_materials", []):
        if m["name"] == name:
            return m
    raise KeyError(f"fence_material={name!r} not found")


def effective_price(material, color_name, price_key):
    """Return the per-unit sell price for a material, honoring a per-color
    override if the selected color carries one. Colors without a price inherit
    the line price (price_key = 'sell_per_sf' or 'sell_per_lf')."""
    base = material[price_key]
    if color_name:
        for c in material.get("colors", []):
            if c.get("name") == color_name and price_key in c:
                return c[price_key]
    return base


# -----------------------------------------------------------------------------
# Fence engine - linear-foot model (not the deck SF model)
# -----------------------------------------------------------------------------
def compute_fence(db, inputs, pt):
    """Price a fence: LF x rate-by-height + gates + tear-out + allowances,
    then apply margin. Returns the same result-dict shape compute_engine
    returns (deck buckets zeroed) plus fence-specific keys."""
    fmat = find_fence_material(db, inputs["fence_material"])
    height = str(inputs.get("fence_height", "6"))
    by_height = fmat["cost_per_lf_by_height"]
    rate = by_height.get(height)
    if rate is None:  # requested height unavailable for this material; use tallest
        height = sorted(by_height.keys(), key=lambda h: int(h))[-1]
        rate = by_height[height]

    fence_lf = inputs.get("fence_lf", 0) or 0
    fence_run = fence_lf * rate

    gate_costs = {g["key"]: g["cost_each"] for g in db.get("fence_gates", [])}
    walk_n = inputs.get("walk_gates", 0) or 0
    drive_n = inputs.get("drive_gates", 0) or 0
    gates_cost = walk_n * gate_costs.get("walk", 0) + drive_n * gate_costs.get("drive", 0)

    tearout_lf = inputs.get("tearout_lf", 0) or 0
    tearout = tearout_lf * db.get("fence_tearout_per_lf", 0)

    permit, dumpster, mobil = get_project_allowances(db, pt["name"])
    permit = inputs.get("permit_alw", permit)
    dumpster = inputs.get("dumpster_alw", dumpster)
    mobil = inputs.get("mobil_alw", mobil)
    misc = inputs.get("misc_alw", db["allowances"]["misc_default"])

    subtotal = fence_run + gates_cost + tearout + permit + dumpster + mobil + misc
    margin = inputs.get("margin", db["margin_and_contingency"]["default_margin"])
    sell = subtotal / (1 - margin) if margin < 1 else 0

    return {
        "project_type": pt,
        "matrix": pt["matrix"],
        "deck_sf": 0,
        "decking": None,
        "railing": None,
        "framing": None,
        "combined_multiplier": 1.0,
        # deck cost buckets (zeroed for fence)
        "base_package": 0, "demo": 0, "border": 0, "rail": 0, "fascia": 0,
        "stair": 0, "stain": 0, "repair": 0, "skirting": 0, "lighting": 0,
        "benches": 0, "privacy": 0, "hot_tub": 0,
        "permit": permit, "dumpster": dumpster, "mobilization": mobil, "misc": misc,
        # fence-specific buckets
        "fence_run": fence_run, "fence_gates": gates_cost, "fence_tearout": tearout,
        "fence_lf": fence_lf, "fence_rate": rate, "fence_height": height,
        "fence_material": fmat, "walk_gates": walk_n, "drive_gates": drive_n,
        "tearout_lf": tearout_lf,
        "subtotal_cost": subtotal,
        "sell_price": sell,
        "margin": margin,
    }


# -----------------------------------------------------------------------------
# Engine - mirror of Excel formulas (and verify_engine.py)
# -----------------------------------------------------------------------------
def compute_engine(db, inputs):
    """Run the deck estimator engine. Returns a result dict with every line
    item, subtotal, sell price, and the project-type matrix for downstream
    use."""
    pt = find_project_type(db, inputs["project_type"])
    matrix = pt["matrix"]

    if matrix.get("fence") == "Y":
        return compute_fence(db, inputs, pt)

    deck_sf = inputs["length"] * inputs["depth"]
    decking = find_by_name(db["decking_materials"], inputs["decking_material"])
    railing = find_by_name(db["railing_materials"], inputs["railing_material"])
    framing = find_by_name(db["framing_materials"], inputs["framing_material"])

    height_m = find_multiplier(db["condition_multipliers"]["height"], inputs["height"])
    grade_m = find_multiplier(db["condition_multipliers"]["grade"], inputs["grade"])
    complex_m = find_multiplier(db["condition_multipliers"]["complexity"], inputs["complexity"])
    market_m = find_multiplier(db["condition_multipliers"]["market_load"], inputs["market"])

    if matrix["multipliers"] == "N":
        combined_m = 1.0
    elif matrix["multipliers"] == "Light":
        combined_m = height_m * grade_m
    else:
        combined_m = height_m * grade_m * complex_m * market_m

    frame_include = matrix["frame"] == "Y"
    deck_include = matrix["deck"] == "Y"

    decking_sell_sf = effective_price(decking, inputs.get("decking_color"), "sell_per_sf")
    base_package = deck_sf * (
        (framing["sell_per_sf"] if frame_include else 0)
        + (decking_sell_sf * (1 + decking["waste_pct"]) if deck_include else 0)
    ) * combined_m

    demo_rate = db["demo_rates_per_sf"].get(pt["key"], 0)
    demo = deck_sf * demo_rate if matrix["demo"] != "N" else 0

    border = 0
    if deck_include and inputs.get("border_style") == "Double Border":
        border = deck_sf * db["border_pricing"]["double_per_sf"]

    rail = 0
    if matrix["rail"] != "N":
        railing_sell_lf = effective_price(railing, inputs.get("railing_color"), "sell_per_lf")
        rail = inputs.get("railing_lf", 0) * railing_sell_lf

    fascia = 0
    if deck_include:
        fascia = inputs.get("fascia_lf", 0) * db["fascia_per_lf"]

    stair = 0
    if matrix["stair"] != "N" and inputs.get("stair_runs", 0) > 0:
        sp = db["stair_pricing"]
        stair = (
            sp["base_setup"]
            + inputs.get("stair_treads", 0) * sp["per_tread"]
            + inputs.get("stair_landings", 0) * sp["per_landing"]
            + (sp["wraparound_premium"] if inputs.get("wraparound") == "Yes" else 0)
            + (inputs.get("stair_treads", 0) * sp["double_border_per_tread"]
               if inputs.get("border_style") == "Double Border" else 0)
        )

    stain = 0
    if matrix["stain"] == "Y" and inputs.get("stain_sf", 0) > 0:
        rate = find_stain_rate(db, inputs["stain_type"], inputs["stain_coats"])
        stain = inputs["stain_sf"] * rate

    repair = 0
    if pt["name"] in ("Stain + Minor Repairs", "Resurface (Boards Only)"):
        rr = db["repair_rates"]
        repair = (
            inputs.get("board_repairs", 0) * rr["board_replacement_per_board"]
            + inputs.get("joist_repair_lf", 0) * rr["joist_repair_per_lf"]
            + (rr["hardware_allowance"] if inputs.get("hardware_inc") == "Yes" else 0)
            + (rr["inspection_only_allowance"]
               if pt["name"] == "Resurface (Boards Only)" else 0)
        )

    skirt = inputs.get("skirting_sf", 0) * db["skirting_per_sf"] if deck_include else 0
    lighting = inputs.get("lighting_fix", 0) * find_adder(db, "lighting")
    benches = inputs.get("bench_count", 0) * find_adder(db, "bench")
    privacy = inputs.get("privacy_screen_lf", 0) * find_adder(db, "privacy_screen")
    hot_tub = find_adder(db, "hot_tub") if inputs.get("hot_tub") == "Yes" else 0

    default_permit, default_dump, default_mobil = get_project_allowances(db, pt["name"])
    permit = inputs.get("permit_alw", default_permit)
    dumpster = inputs.get("dumpster_alw", default_dump)
    mobil = inputs.get("mobil_alw", default_mobil)
    misc = inputs.get("misc_alw", db["allowances"]["misc_default"])

    subtotal = (base_package + demo + border + rail + fascia + stair + stain + repair
                + skirt + lighting + benches + privacy + hot_tub
                + permit + dumpster + mobil + misc)

    margin = inputs.get("margin", db["margin_and_contingency"]["default_margin"])
    sell = subtotal / (1 - margin) if margin < 1 else 0
    return {
        "project_type": pt,
        "matrix": matrix,
        "deck_sf": deck_sf,
        "decking": decking,
        "railing": railing,
        "framing": framing,
        "combined_multiplier": combined_m,
        # cost components
        "base_package": base_package,
        "demo": demo,
        "border": border,
        "rail": rail,
        "fascia": fascia,
        "stair": stair,
        "stain": stain,
        "repair": repair,
        "skirting": skirt,
        "lighting": lighting,
        "benches": benches,
        "privacy": privacy,
        "hot_tub": hot_tub,
        "permit": permit,
        "dumpster": dumpster,
        "mobilization": mobil,
        "misc": misc,
        "subtotal_cost": subtotal,
        "sell_price": sell,
        "margin": margin,
    }


# -----------------------------------------------------------------------------
# Customer-facing line item allocation
# -----------------------------------------------------------------------------
def round_money(x):
    return int(round(x))


def _with_color(name, color):
    """Append the chosen color to a material name when it is meaningful
    (skip 'Natural'/'Clear' placeholders that defer to stain)."""
    if color and not any(w in color for w in ("Natural", "Clear", "finish via stain")):
        return f"{name} in {color}"
    return name


def build_fence_line_items(eng, inputs):
    """Customer-facing line items for a fence quote (sell-side, sum to sell)."""
    cost_total = eng["subtotal_cost"]
    sell_total = eng["sell_price"]
    if cost_total <= 0:
        return [["No scope priced", 0]]
    scale = sell_total / cost_total

    fmat = _with_color(eng["fence_material"]["name"], inputs.get("fence_color"))
    items = [[
        f"{eng['fence_height']} ft {fmat} fence, {eng['fence_lf']} linear feet, "
        f"posts set in concrete",
        round_money(eng["fence_run"] * scale)]]

    if eng["fence_gates"] > 0:
        gp = []
        if eng.get("walk_gates", 0) > 0:
            gp.append(f"{eng['walk_gates']} walk gate"
                      + ("s" if eng["walk_gates"] > 1 else ""))
        if eng.get("drive_gates", 0) > 0:
            gp.append(f"{eng['drive_gates']} drive / double gate"
                      + ("s" if eng["drive_gates"] > 1 else ""))
        items.append(["Gates: " + ", ".join(gp),
                      round_money(eng["fence_gates"] * scale)])

    if eng["fence_tearout"] > 0:
        items.append([
            f"Removal and disposal of existing fence ({eng['tearout_lf']} LF)",
            round_money(eng["fence_tearout"] * scale)])

    admin = eng["permit"] + eng["dumpster"] + eng["mobilization"] + eng["misc"]
    if admin > 0:
        items.append(["Permits, layout, mobilization, and final cleanup",
                      round_money(admin * scale)])

    current_sum = sum(amt for _, amt in items)
    delta = round_money(sell_total) - current_sum
    if items and delta != 0:
        items[-1] = [items[-1][0], items[-1][1] + delta]
    return items


def build_line_items(eng, inputs):
    """Map engine cost buckets to customer-friendly sell-side line items.
    Each line item is [label, amount]. Amounts sum to sell_price (with
    rounding spread on the last line)."""
    if eng.get("matrix", {}).get("fence") == "Y":
        return build_fence_line_items(eng, inputs)

    pt_name = eng["project_type"]["name"]
    cost_total = eng["subtotal_cost"]
    sell_total = eng["sell_price"]
    if cost_total <= 0:
        return [["No scope priced", 0]]

    scale = sell_total / cost_total

    items = []

    # --- For stain-type projects: present prep / materials / application / cleanup ---
    if pt_name in ("Stain Only", "Stain + Minor Repairs"):
        stain_sf = inputs.get("stain_sf", 0)
        stain_type = inputs.get("stain_type", "stain")
        coats = inputs.get("stain_coats", 1)

        # Materials cost (estimated as ~25% of stain cost; rest is labor)
        stain_materials = eng["stain"] * 0.30
        stain_labor = eng["stain"] * 0.70

        items.append([
            f"Surface preparation: power wash, sand rough spots, set fasteners, mask landscaping",
            round_money((stain_labor * 0.30 + eng["mobilization"] * 0.5) * scale)])
        items.append([
            f"Premium materials ({stain_type.lower()} stain, brushes, pads, rollers, drop cloths, masking)",
            round_money((stain_materials + (eng["lighting"] + eng["benches"] +
                         eng["privacy"] + eng["hot_tub"]) * 0.0) * scale)])
        items.append([
            f"Application of {coats} coat{'s' if coats > 1 else ''} of "
            f"{stain_type.lower()} stain to deck floor, stairs, and railing system "
            f"(~{stain_sf} sq ft)",
            round_money(stain_labor * 0.70 * scale)])
        if eng["repair"] > 0:
            items.append([
                f"Targeted repairs: "
                f"{inputs.get('board_repairs', 0)} board replacement"
                f"{'s' if inputs.get('board_repairs', 0) != 1 else ''}"
                f"{', ' + str(inputs.get('joist_repair_lf', 0)) + ' LF joist sister' if inputs.get('joist_repair_lf', 0) > 0 else ''}"
                f"{', hardware allowance' if inputs.get('hardware_inc') == 'Yes' else ''}",
                round_money(eng["repair"] * scale)])
        items.append([
            "Job site protection, cleanup, and debris haul-off",
            round_money((eng["dumpster"] + eng["mobilization"] * 0.5
                         + eng["permit"] + eng["misc"]) * scale)])

    # --- For build-type projects (Resurface / Frame Rebuild / Full Tear-Out) ---
    else:
        deck_sf = eng["deck_sf"]
        decking_name = _with_color(eng["decking"]["name"], inputs.get("decking_color"))
        railing_name = _with_color(eng["railing"]["name"], inputs.get("railing_color"))
        framing_name = eng["framing"]["name"]

        # Demo + dumpster
        demo_total = eng["demo"] + eng["dumpster"]
        if demo_total > 0:
            label = ("Demolition and disposal of existing deck"
                     if eng["demo"] > 0 else "Site cleanup and disposal")
            items.append([label, round_money(demo_total * scale)])

        # Framing + decking (the big one)
        build_total = eng["base_package"] + eng["fascia"] + eng["border"]
        if build_total > 0:
            label_parts = []
            if eng["matrix"]["frame"] == "Y":
                label_parts.append(f"{framing_name} framing")
            if eng["matrix"]["deck"] == "Y":
                label_parts.append(f"{decking_name} decking ({deck_sf} sq ft)")
            if eng["fascia"] > 0:
                label_parts.append(f"matching fascia ({inputs.get('fascia_lf', 0)} LF)")
            if eng["border"] > 0:
                label_parts.append("double-border picture-frame detail")
            label = "Deck construction including " + ", ".join(label_parts)
            items.append([label, round_money(build_total * scale)])

        # Railing
        if eng["rail"] > 0:
            items.append([
                f"{railing_name} railing system ({inputs.get('railing_lf', 0)} LF)",
                round_money(eng["rail"] * scale)])

        # Stairs
        if eng["stair"] > 0:
            wrap = " with wraparound design" if inputs.get("wraparound") == "Yes" else ""
            items.append([
                f"Staircase: {inputs.get('stair_runs', 0)} run, "
                f"{inputs.get('stair_treads', 0)} treads{wrap}",
                round_money(eng["stair"] * scale)])

        # Repairs (for Resurface only - rebuilds use new lumber priced in base_package)
        if eng["repair"] > 0:
            items.append([
                f"Frame inspection and targeted repairs",
                round_money(eng["repair"] * scale)])

        # Adders (consolidated)
        adders = (eng["skirting"] + eng["lighting"] + eng["benches"]
                  + eng["privacy"] + eng["hot_tub"])
        if adders > 0:
            adder_parts = []
            if eng["skirting"] > 0:
                adder_parts.append(f"skirting ({inputs.get('skirting_sf', 0)} sq ft)")
            if eng["lighting"] > 0:
                adder_parts.append(f"{inputs.get('lighting_fix', 0)} deck lights")
            if eng["benches"] > 0:
                adder_parts.append(f"{inputs.get('bench_count', 0)} built-in bench"
                                   + ("es" if inputs.get('bench_count', 0) > 1 else ""))
            if eng["privacy"] > 0:
                adder_parts.append(f"privacy screen ({inputs.get('privacy_screen_lf', 0)} LF)")
            if eng["hot_tub"] > 0:
                adder_parts.append("hot tub structural upgrade")
            items.append([
                f"Upgrades: " + ", ".join(adder_parts),
                round_money(adders * scale)])

        # Permits, mobilization, cleanup, misc (combined)
        admin = eng["permit"] + eng["mobilization"] + eng["misc"]
        if admin > 0:
            items.append([
                "Permits, site protection, mobilization, and final cleanup",
                round_money(admin * scale)])

    # Reconcile rounding: adjust last line so sum matches sell price exactly
    current_sum = sum(amt for _, amt in items)
    delta = round_money(sell_total) - current_sum
    if items and delta != 0:
        items[-1] = [items[-1][0], items[-1][1] + delta]

    return items


# -----------------------------------------------------------------------------
# Scope copy loader
# -----------------------------------------------------------------------------
def parse_scope_md(path):
    """Parse a scope-copy markdown file into a section dict. Sections are
    delimited by `## NAME` headers; everything until the next `## ` or EOF is
    the section body (whitespace trimmed)."""
    text = path.read_text(encoding="utf-8")
    sections = {}
    current = None
    buf = []
    for line in text.splitlines():
        m = re.match(r"^##\s+([A-Z_]+)\s*$", line)
        if m:
            if current:
                sections[current] = "\n".join(buf).strip()
            current = m.group(1)
            buf = []
        elif current:
            buf.append(line)
    if current:
        sections[current] = "\n".join(buf).strip()
    return sections


SCOPE_FILE_MAP = {
    "Stain Only": "scope-stain.md",
    "Stain + Minor Repairs": "scope-stain.md",
    "Resurface (Boards Only)": "scope-resurface.md",
    "Frame + Deck Rebuild (Keep Footings)": "scope-build.md",
    "Full Tear-Out + New Build": "scope-build.md",
    "New Build (No Tear-Out)": "scope-new-build.md",
    "Fence": "scope-fence.md",
}


def load_scope_template(project_type_name):
    fn = SCOPE_FILE_MAP[project_type_name]
    return parse_scope_md(SCOPE_COPY_DIR / fn)


# -----------------------------------------------------------------------------
# Context building - assemble the variables for scope template substitution
# -----------------------------------------------------------------------------
def build_scope_context(inputs, eng):
    """Build the {placeholder} -> value dict used for str.format on each
    scope-copy section."""
    pt_name = eng["project_type"]["name"]
    deck_sf = eng["deck_sf"]

    decking_name = eng["decking"]["name"]
    railing_name = eng["railing"]["name"]
    framing_name = eng["framing"]["name"]

    # Friendly material phrases (with chosen color where meaningful)
    decking_phrase = _with_color(decking_name, inputs.get("decking_color"))
    framing_phrase = ("kiln-dried pressure-treated lumber"
                      if framing_name.startswith("KDAT")
                      else "Fortress Evolution galvanized steel")
    railing_phrase = _with_color(railing_name, inputs.get("railing_color"))

    # Stair/rail overview fragments
    stair_runs = inputs.get("stair_runs", 0) or 0
    stair_treads = inputs.get("stair_treads", 0) or 0
    railing_lf = inputs.get("railing_lf", 0) or 0
    fascia_lf = inputs.get("fascia_lf", 0) or 0

    if stair_runs > 0 and stair_treads > 0:
        stair_overview_phrase = (
            f", a staircase ({stair_runs} run"
            f"{'s' if stair_runs > 1 else ''}, {stair_treads} total treads)")
        stair_scope_line = (
            f"\n- Install staircase: {stair_runs} run"
            f"{'s' if stair_runs > 1 else ''}, "
            f"{stair_treads} composite or matching-material treads, code-compliant rise/run")
    else:
        stair_overview_phrase = ""
        stair_scope_line = ""

    # Demo extras for build projects
    if pt_name == "Full Tear-Out + New Build":
        demo_extras = ", footings, and concrete posts"
        footing_phrase = ("- Excavate and pour new code-compliant footings (12 in tube "
                          "forms × 48 in deep for WI frost line) at code-required spacing\n")
        footing_inclusion_phrase = ("- All new footings: concrete tube forms, "
                                    "concrete mix, rebar, and excavation\n")
    elif pt_name == "New Build (No Tear-Out)":
        demo_extras = ""
        footing_phrase = ("- Excavate and pour new code-compliant footings (12 in tube "
                          "forms × 48 in deep for WI frost line) at code-required spacing\n")
        footing_inclusion_phrase = ("- All new footings: concrete tube forms, "
                                    "concrete mix, rebar, and excavation\n")
    elif pt_name == "Frame + Deck Rebuild (Keep Footings)":
        demo_extras = " — existing footings retained"
        footing_phrase = ("- Inspect existing footings; flag any inadequate footing "
                          "for change-order replacement before framing begins\n")
        footing_inclusion_phrase = ""
    else:
        demo_extras = ""
        footing_phrase = ""
        footing_inclusion_phrase = ""

    # Schedule duration
    if pt_name == "Full Tear-Out + New Build":
        duration_range = "7-10"
        start_window_weeks = "3-4"
    elif pt_name == "New Build (No Tear-Out)":
        duration_range = "6-9"
        start_window_weeks = "2-3"
    elif pt_name == "Frame + Deck Rebuild (Keep Footings)":
        duration_range = "5-7"
        start_window_weeks = "2-3"
    else:
        duration_range = "3-5"
        start_window_weeks = "2-3"

    # Resurface-specific phrasing
    if pt_name == "Resurface (Boards Only)":
        rail_overview_phrase = (" railings" if railing_lf > 0 else "")
        rail_phrase_for_overview = (
            f" and new <b>{railing_phrase}</b> railings ({railing_lf} LF)"
            if railing_lf > 0 else "")
        stair_overview_phrase_resurface = (
            f", new staircase ({stair_runs} run, {stair_treads} treads)"
            if stair_runs > 0 else "")
        if railing_lf > 0:
            rail_scope_line = (
                f"\n- Install new {railing_phrase} railing system ({railing_lf} LF) "
                f"with code-compliant baluster spacing")
            rail_included_phrase = f", new {railing_phrase} railing"
            rail_labor_phrase = ", railing install"
        else:
            rail_scope_line = "\n- Retain existing railing system; refresh fasteners as needed"
            rail_included_phrase = ""
            rail_labor_phrase = ""

        if inputs.get("board_repairs", 0) > 0 or inputs.get("joist_repair_lf", 0) > 0:
            repair_lines = []
            if inputs.get("board_repairs", 0) > 0:
                repair_lines.append(f"- Replace {inputs['board_repairs']} damaged "
                                    f"deck or frame board{'s' if inputs['board_repairs'] > 1 else ''}")
            if inputs.get("joist_repair_lf", 0) > 0:
                repair_lines.append(f"- Sister or repair {inputs['joist_repair_lf']} "
                                    "LF of compromised joist with PT 2x10 + structural fasteners")
            if inputs.get("hardware_inc") == "Yes":
                repair_lines.append("- Replace failed hardware (joist hangers, fasteners) "
                                    "as needed during board removal")
            repair_phrase = "\n".join(repair_lines) + "\n"
        else:
            repair_phrase = ""
    else:
        rail_overview_phrase = ""
        rail_phrase_for_overview = ""
        stair_overview_phrase_resurface = ""
        rail_scope_line = ""
        rail_included_phrase = ""
        rail_labor_phrase = ""
        repair_phrase = ""

    # Stain-specific phrasing
    stain_sf = inputs.get("stain_sf", 0)
    stain_type = inputs.get("stain_type", "Semi-Transparent")
    stain_coats = inputs.get("stain_coats", 1)

    if pt_name in ("Stain Only", "Stain + Minor Repairs"):
        coats_word = "one" if stain_coats == 1 else "two"
        coats_phrase = "Single-coat" if stain_coats == 1 else "Two-coat"
        coats_plural = "s" if stain_coats > 1 else ""
        stain_type_lc = stain_type.lower().replace(" / paint-and-sealer", "")
        stain_product_phrase = (
            "premium paint-and-sealer combination product"
            if "solid" in stain_type.lower()
            else f"premium {stain_type_lc} stain")
        stain_color = inputs.get("stain_color", "")
        stain_color_phrase = (
            f" in {stain_color}"
            if stain_color and not any(w in stain_color for w in ("Natural", "Clear"))
            else "")
        deck_existing_material = inputs.get(
            "existing_deck_material", "pressure-treated wood")

        if railing_lf > 0:
            rail_stair_overview_phrase = (
                f", <b>{railing_lf} linear feet</b> of railing system")
            if stair_runs > 0:
                rail_stair_overview_phrase += (
                    f", and a {stair_treads}-step staircase")
        elif stair_runs > 0:
            rail_stair_overview_phrase = f", and a {stair_treads}-step staircase"
        else:
            rail_stair_overview_phrase = ""

        if pt_name == "Stain + Minor Repairs":
            repair_overview_phrase = " Targeted minor repairs (board replacements and hardware) are included."
            repair_lines = []
            if inputs.get("board_repairs", 0) > 0:
                repair_lines.append(f"- Replace {inputs['board_repairs']} damaged "
                                    f"deck board{'s' if inputs['board_repairs'] > 1 else ''} with matching material")
            if inputs.get("joist_repair_lf", 0) > 0:
                repair_lines.append(f"- Sister or repair {inputs['joist_repair_lf']} LF of compromised joist")
            if inputs.get("hardware_inc") == "Yes":
                repair_lines.append("- Replace failed hardware and fasteners as needed")
            repair_phrase_stain = "\n".join(repair_lines) + "\n" if repair_lines else ""
            repair_warranty_phrase = "\n- 1-year warranty extends to repaired sections"
            full_replace_not_included = (
                "- Wholesale board replacement beyond the specifically scoped repair items "
                "(if more boards are found unsound, will be quoted separately)\n")
        else:
            repair_overview_phrase = ""
            repair_phrase_stain = ""
            repair_warranty_phrase = ""
            full_replace_not_included = (
                "- Repair or replacement of damaged or rotted boards "
                "(will be quoted separately if discovered during preparation)\n")

        duration_days = 2 if stain_coats == 1 else 3
        if pt_name == "Stain + Minor Repairs":
            duration_days += 1
        if duration_days == 2:
            day_breakdown = "Day 1: preparation; Day 2: application"
        elif duration_days == 3:
            day_breakdown = "Day 1: prep; Day 2: first coat; Day 3: second coat or repairs"
        else:
            day_breakdown = "Day 1: prep + repairs; Day 2-3: coats and final cleanup"

        coat_note = (
            "This is a single-coat application; heavily weathered boards may "
            "show some grain shadow through the finish. A second coat for full "
            "uniform coverage is available as an add-on after Coat 1 is reviewed."
            if stain_coats == 1
            else "Two coats provide full uniform coverage; the second coat is "
                 "applied after the first has cured per manufacturer spec.")
        second_coat_addon = (
            "Second coat of stain for full uniform coverage "
            "(available as an add-on at additional cost after Coat 1 review)"
            if stain_coats == 1 else
            "Third coat application (rare; only needed on heavily weathered cedar)")
    else:
        coats_word = ""
        coats_phrase = ""
        coats_plural = ""
        stain_type_lc = ""
        stain_product_phrase = ""
        stain_color_phrase = ""
        deck_existing_material = ""
        rail_stair_overview_phrase = ""
        repair_overview_phrase = ""
        repair_phrase_stain = ""
        repair_warranty_phrase = ""
        full_replace_not_included = ""
        duration_days = 5
        day_breakdown = ""
        coat_note = ""
        second_coat_addon = ""

    # Project phrase for build
    if pt_name == "Full Tear-Out + New Build":
        project_phrase = "Complete tear-out and new deck build"
    elif pt_name == "New Build (No Tear-Out)":
        project_phrase = "New deck build"
    elif pt_name == "Frame + Deck Rebuild (Keep Footings)":
        project_phrase = "Frame and deck rebuild on existing footings"
    elif pt_name == "Resurface (Boards Only)":
        project_phrase = "Deck board resurface on existing frame"
    else:
        project_phrase = pt_name

    return {
        # universal
        "deck_sf": deck_sf,
        "length": inputs["length"],
        "depth": inputs["depth"],
        "decking_phrase": decking_phrase,
        "framing_phrase": framing_phrase,
        "railing_phrase": railing_phrase,
        "railing_lf": railing_lf,
        "fascia_lf": fascia_lf,
        "stair_runs": stair_runs,
        "stair_treads": stair_treads,
        "stair_overview_phrase": stair_overview_phrase,
        "stair_scope_line": stair_scope_line,
        "project_phrase": project_phrase,
        # build-specific
        "demo_extras": demo_extras,
        "footing_phrase": footing_phrase,
        "footing_inclusion_phrase": footing_inclusion_phrase,
        "duration_range": duration_range,
        "start_window_weeks": start_window_weeks,
        # resurface-specific
        "rail_overview_phrase": rail_overview_phrase,
        "rail_phrase_for_overview": rail_phrase_for_overview,
        "stair_overview_phrase_resurface": stair_overview_phrase_resurface,
        "rail_scope_line": rail_scope_line,
        "rail_included_phrase": rail_included_phrase,
        "rail_labor_phrase": rail_labor_phrase,
        "repair_phrase": repair_phrase,
        # stain-specific
        "stain_sf": stain_sf,
        "stain_type": stain_type,
        "stain_type_lc": stain_type_lc,
        "stain_coats": stain_coats,
        "coats_word": coats_word,
        "coats_phrase": coats_phrase,
        "coats_plural": coats_plural,
        "stain_product_phrase": stain_product_phrase,
        "stain_color_phrase": stain_color_phrase,
        "deck_existing_material": deck_existing_material,
        "rail_stair_overview_phrase": rail_stair_overview_phrase,
        "repair_overview_phrase": repair_overview_phrase,
        "repair_phrase_stain": repair_phrase_stain,
        "repair_warranty_phrase": repair_warranty_phrase,
        "full_replace_not_included": full_replace_not_included,
        "duration_days": duration_days,
        "day_breakdown": day_breakdown,
        "coat_note": coat_note,
        "second_coat_addon": second_coat_addon,
    }


def render_scope(template, ctx):
    """Substitute {placeholders} into each section. Returns rendered dict with
    overview (str), scope (list of bullets), scope_note (str), included (list),
    not_included (list), schedule (dict), deposit_pct (int)."""
    rendered = {}
    for key, body in template.items():
        try:
            rendered[key] = body.format_map(_DefaultDict(ctx))
        except (KeyError, IndexError) as e:
            rendered[key] = body  # fail-soft

    def split_bullets(text):
        out = []
        for line in text.splitlines():
            line = line.rstrip()
            if line.startswith("- "):
                out.append(line[2:])
        return out

    # Parse SCHEDULE section into a dict
    sched_dict = {"start": "TBD", "duration": "TBD", "weather": "TBD"}
    if "SCHEDULE" in rendered:
        for line in rendered["SCHEDULE"].splitlines():
            for key in ("duration", "weather", "start_phrase"):
                prefix = f"{key}:"
                if line.lstrip().startswith(prefix):
                    val = line.split(":", 1)[1].strip()
                    if key == "start_phrase":
                        sched_dict["start"] = val
                    else:
                        sched_dict[key] = val

    deposit_pct = 30
    if "DEPOSIT_PCT" in rendered:
        try:
            deposit_pct = int(rendered["DEPOSIT_PCT"].strip().splitlines()[0])
        except (ValueError, IndexError):
            pass

    return {
        "overview": rendered.get("OVERVIEW", "").strip(),
        "scope": split_bullets(rendered.get("SCOPE", "")),
        "scope_note": rendered.get("SCOPE_NOTE", "").strip(),
        "included": split_bullets(rendered.get("INCLUDED", "")),
        "not_included": split_bullets(rendered.get("NOT_INCLUDED", "")),
        "schedule": sched_dict,
        "deposit_pct": deposit_pct,
    }


class _DefaultDict(dict):
    """A dict that returns empty string for missing keys (so str.format_map
    doesn't choke on placeholders not in the context)."""
    def __missing__(self, key):
        return ""


# -----------------------------------------------------------------------------
# Estimate number + filename
# -----------------------------------------------------------------------------
def slugify(text):
    text = re.sub(r"[^A-Za-z0-9]+", "-", text).strip("-").lower()
    return text or "unnamed"


def make_estimate_filename(client_name, project_type_name, today=None):
    today = today or date.today()
    last = client_name.split()[-1] if client_name else "client"
    pt_short = {
        "Stain Only": "stain",
        "Stain + Minor Repairs": "stain-repairs",
        "Resurface (Boards Only)": "resurface",
        "Frame + Deck Rebuild (Keep Footings)": "frame-rebuild",
        "Full Tear-Out + New Build": "deck-build",
        "New Build (No Tear-Out)": "new-build",
        "Fence": "fence",
    }.get(project_type_name, "deck-project")
    return f"{today.isoformat()}-{slugify(last)}-{pt_short}.json"


def make_estimate_number(today=None):
    today = today or date.today()
    return f"{today.isoformat()}-001"


# -----------------------------------------------------------------------------
# Fence scope context (placeholders for scope-fence.md)
# -----------------------------------------------------------------------------
def build_fence_context(inputs, eng):
    """Build the {placeholder} -> value dict for the fence scope template."""
    fmat = eng["fence_material"]["name"]
    color = inputs.get("fence_color", "")
    color_phrase = (f", {color} finish"
                    if color and not any(w in color for w in ("Natural", "finish via stain"))
                    else "")
    gates = []
    if eng.get("walk_gates", 0) > 0:
        gates.append(f"{eng['walk_gates']} walk gate"
                     + ("s" if eng["walk_gates"] > 1 else ""))
    if eng.get("drive_gates", 0) > 0:
        gates.append(f"{eng['drive_gates']} drive / double gate"
                     + ("s" if eng["drive_gates"] > 1 else ""))
    gates_phrase = (" with " + " and ".join(gates)) if gates else ""
    gates_scope_line = (("\n- Hang " + " and ".join(gates)
                         + " on heavy-duty hinges with self-latching hardware")
                        if gates else "")
    if eng.get("tearout_lf", 0) > 0:
        tearout_scope_line = (f"\n- Remove and dispose of {eng['tearout_lf']} LF "
                              "of existing fence before layout")
        tearout_included = "- Removal and disposal of the existing fence\n"
    else:
        tearout_scope_line = ""
        tearout_included = ""
    return {
        "fence_lf": eng["fence_lf"],
        "fence_height": eng["fence_height"],
        "fence_material": fmat,
        "fence_color_phrase": color_phrase,
        "gates_phrase": gates_phrase,
        "gates_scope_line": gates_scope_line,
        "tearout_scope_line": tearout_scope_line,
        "tearout_included": tearout_included,
        "duration_range": "2-4",
        "start_window_weeks": "2-3",
    }


# -----------------------------------------------------------------------------
# Build the final estimate JSON
# -----------------------------------------------------------------------------
def build_estimate_json(inputs, client_info, db, today=None):
    eng = compute_engine(db, inputs)
    template = load_scope_template(eng["project_type"]["name"])
    if eng["matrix"].get("fence") == "Y":
        ctx = build_fence_context(inputs, eng)
    else:
        ctx = build_scope_context(inputs, eng)
    scope = render_scope(template, ctx)

    line_items = build_line_items(eng, inputs)

    today = today or date.today()
    return {
        "estimate_number": make_estimate_number(today),
        "date_issued": today.strftime("%B %d, %Y"),
        "valid_days": 14,
        "client": client_info,
        "project": {
            "overview": scope["overview"],
            "scope": scope["scope"],
            "scope_note": scope["scope_note"],
        },
        "line_items": line_items,
        "included": scope["included"],
        "not_included": scope["not_included"],
        "schedule": scope["schedule"],
        "payment": {
            "deposit_pct": scope["deposit_pct"],
            "methods": ("cash, check, credit or debit card, or digital payment "
                        "(details provided upon acceptance)"),
        },
        "_meta": {
            "computed_sell_price": round_money(eng["sell_price"]),
            "computed_subtotal_cost": round_money(eng["subtotal_cost"]),
            "computed_margin": eng["margin"],
            "engine_version": "v1.1",
        },
    }


# -----------------------------------------------------------------------------
# Interactive prompts
# -----------------------------------------------------------------------------
def prompt_choice(label, options, default=None):
    print(f"\n{label}")
    for i, opt in enumerate(options, 1):
        marker = "  *" if opt == default else "   "
        print(f"{marker}{i}. {opt}")
    while True:
        sel = input(f"Choice [1-{len(options)}]"
                    + (f", default {options.index(default)+1}: " if default
                       else ": ")).strip()
        if not sel and default is not None:
            return default
        try:
            n = int(sel)
            if 1 <= n <= len(options):
                return options[n - 1]
        except ValueError:
            if sel in options:
                return sel
        print("  Invalid choice, try again.")


def prompt_int(label, default=0, minval=0):
    while True:
        s = input(f"{label} [{default}]: ").strip()
        if not s:
            return default
        try:
            n = int(s)
            if n >= minval:
                return n
        except ValueError:
            pass
        print(f"  Enter an integer >= {minval}.")


def prompt_str(label, default=""):
    s = input(f"{label}" + (f" [{default}]: " if default else ": ")).strip()
    return s or default


def prompt_yes_no(label, default="No"):
    return prompt_choice(label, ["Yes", "No"], default=default)


def interactive_inputs(db):
    print("\n" + "=" * 60)
    print("  CWDB DECK CALCULATOR - Interactive Quote Builder")
    print("=" * 60)

    print("\n--- CLIENT INFO ---")
    client_info = {
        "name": prompt_str("Client name", "Homeowner"),
        "address_line": prompt_str("Project address (one line)",
                                   "Wausau, WI"),
        "phone": prompt_str("Client phone", "(715) 555-0000"),
        "email": prompt_str("Client email", "client@example.com"),
    }

    print("\n--- PROJECT TYPE ---")
    project_type = prompt_choice(
        "Project type:",
        [pt["name"] for pt in db["project_types"]],
        default="Full Tear-Out + New Build")

    inputs = {"project_type": project_type}

    pt = find_project_type(db, project_type)
    matrix = pt["matrix"]

    print("\n--- DIMENSIONS ---")
    inputs["length"] = prompt_int("Deck length (ft)", default=20, minval=1)
    inputs["depth"] = prompt_int("Deck depth (ft)", default=15, minval=1)

    print("\n--- MATERIALS ---")
    inputs["decking_material"] = prompt_choice(
        "Decking material:",
        [m["name"] for m in db["decking_materials"]],
        default="Trex Select")
    inputs["railing_material"] = prompt_choice(
        "Railing material:",
        [m["name"] for m in db["railing_materials"]],
        default="Trex Aluminum")
    inputs["framing_material"] = prompt_choice(
        "Framing material:",
        [m["name"] for m in db["framing_materials"]],
        default="KDAT Pressure-Treated")

    print("\n--- SITE CONDITIONS ---")
    inputs["height"] = prompt_choice(
        "Height:",
        [m["value"] for m in db["condition_multipliers"]["height"]],
        default="1 Story / Low")
    inputs["grade"] = prompt_choice(
        "Grade:",
        [m["value"] for m in db["condition_multipliers"]["grade"]],
        default="Flat / Normal Access")
    inputs["complexity"] = prompt_choice(
        "Complexity:",
        [m["value"] for m in db["condition_multipliers"]["complexity"]],
        default="Simple Rectangle")
    inputs["market"] = prompt_choice(
        "Market load:",
        [m["value"] for m in db["condition_multipliers"]["market_load"]],
        default="Normal Schedule")

    if matrix["deck"] == "Y":
        print("\n--- SCOPE DETAIL ---")
        inputs["border_style"] = prompt_choice(
            "Border style:",
            ["Pencil Border", "Double Border"],
            default="Pencil Border")
        inputs["fascia_lf"] = prompt_int("Fascia LF", default=70)
    else:
        inputs["border_style"] = "Pencil Border"
        inputs["fascia_lf"] = 0

    if matrix["rail"] != "N":
        inputs["railing_lf"] = prompt_int("Railing LF", default=40)
    else:
        inputs["railing_lf"] = 0

    if matrix["stair"] != "N":
        inputs["stair_runs"] = prompt_int("Stair runs", default=1)
        if inputs["stair_runs"] > 0:
            inputs["stair_treads"] = prompt_int("Total stair treads", default=6)
            inputs["stair_landings"] = prompt_int("Stair landings", default=0)
            inputs["wraparound"] = prompt_yes_no("Wraparound stair?", default="No")
        else:
            inputs["stair_treads"] = 0
            inputs["stair_landings"] = 0
            inputs["wraparound"] = "No"
    else:
        inputs["stair_runs"] = 0
        inputs["stair_treads"] = 0
        inputs["stair_landings"] = 0
        inputs["wraparound"] = "No"

    if matrix["stain"] == "Y":
        print("\n--- STAIN ---")
        inputs["stain_sf"] = prompt_int(
            "Stain SF (deck floor + railing/stair SF blended)", default=0)
        if inputs["stain_sf"] > 0:
            stain_types = sorted({sr["type"] for sr in db["stain_rates_per_sf"]})
            inputs["stain_type"] = prompt_choice(
                "Stain type:", stain_types, default="Solid / Paint-and-Sealer")
            inputs["stain_coats"] = int(prompt_choice(
                "Coats:", ["1", "2"], default="1"))

    if project_type in ("Stain + Minor Repairs", "Resurface (Boards Only)"):
        print("\n--- REPAIR BUCKET ---")
        inputs["board_repairs"] = prompt_int("Board replacements (count)", default=0)
        inputs["joist_repair_lf"] = prompt_int("Joist repair LF", default=0)
        inputs["hardware_inc"] = prompt_yes_no("Hardware allowance included?", default="No")

    print("\n--- ADDERS (press Enter to skip each) ---")
    inputs["skirting_sf"] = prompt_int("Skirting / Privacy Wall SF", default=0)
    inputs["lighting_fix"] = prompt_int("Lighting fixtures (count)", default=0)
    inputs["bench_count"] = prompt_int("Built-in benches (count)", default=0)
    inputs["privacy_screen_lf"] = prompt_int("Privacy screen LF", default=0)
    inputs["hot_tub"] = prompt_yes_no("Hot tub structural upgrade?", default="No")

    return client_info, inputs


# -----------------------------------------------------------------------------
# Main entry
# -----------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="CWDB Deck Calculator")
    parser.add_argument("--interactive", action="store_true",
                        help="Run interactive prompts (default if no other input)")
    parser.add_argument("--inputs", type=Path,
                        help="JSON inputs file (skip interactive)")
    parser.add_argument("--output", type=Path,
                        help="Override output JSON path")
    parser.add_argument("--pdf", action="store_true",
                        help="Generate PDF after writing JSON")
    args = parser.parse_args()

    db = load_pricing()

    if args.inputs:
        data = json.loads(args.inputs.read_text(encoding="utf-8"))
        client_info = data["client"]
        inputs = data["inputs"]
    else:
        # default to interactive
        client_info, inputs = interactive_inputs(db)

    estimate = build_estimate_json(inputs, client_info, db)

    # Determine output path
    if args.output:
        out_path = args.output
    else:
        fn = make_estimate_filename(client_info["name"],
                                    inputs["project_type"])
        out_path = DATA_DIR / fn
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(estimate, indent=2), encoding="utf-8")
    print(f"\nJSON written: {out_path}")
    print(f"Computed sell price: ${estimate['_meta']['computed_sell_price']:,}")
    print(f"Line items: {len(estimate['line_items'])} (sum to sell price)")

    if args.pdf:
        # generate_estimate_pdf.py reads only the fields it needs and ignores
        # extras like our `_meta` block, so we can pass the JSON directly.
        result = subprocess.run(
            [sys.executable, str(PDF_GENERATOR), str(out_path)],
            capture_output=True, text=True)
        if result.returncode == 0:
            print(result.stdout.strip())
        else:
            print("PDF generation failed:", result.stderr, file=sys.stderr)


if __name__ == "__main__":
    main()
