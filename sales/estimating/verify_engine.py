"""
CWDB Deck Estimator - Engine Verification

Pure-Python mirror of the Excel engine. Used to:
  1. Self-verify that the math behind the workbook produces sensible numbers
     across all 5 project types and 5 material combinations
  2. Provide a head-start for the Phase 2 Python calculator (deck_calculator.py)

Run:
  python verify_engine.py
"""

import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
DB_PATH = SCRIPT_DIR / "pricing-db.json"


def load_db():
    with open(DB_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def find_by_name(items, name, name_key="name"):
    for it in items:
        if it[name_key] == name:
            return it
    raise KeyError(name)


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


def compute(db, inputs):
    """Mirror the Excel engine. Returns dict with all line items + totals."""

    pt = find_project_type(db, inputs["project_type"])
    matrix = pt["matrix"]

    deck_sf = inputs["length"] * inputs["depth"]
    decking = find_by_name(db["decking_materials"], inputs["decking_material"])
    railing = find_by_name(db["railing_materials"], inputs["railing_material"])
    framing = find_by_name(db["framing_materials"], inputs["framing_material"])

    height_m = find_multiplier(db["condition_multipliers"]["height"], inputs["height"])
    grade_m = find_multiplier(db["condition_multipliers"]["grade"], inputs["grade"])
    complex_m = find_multiplier(db["condition_multipliers"]["complexity"], inputs["complexity"])
    market_m = find_multiplier(db["condition_multipliers"]["market_load"], inputs["market"])

    # Combined multiplier respects matrix.Multipliers (N / Light / Y)
    if matrix["multipliers"] == "N":
        combined_m = 1.0
    elif matrix["multipliers"] == "Light":
        combined_m = height_m * grade_m
    else:  # "Y"
        combined_m = height_m * grade_m * complex_m * market_m

    # Base Package - matrix-aware framing + decking
    frame_include = matrix["frame"] == "Y"
    deck_include = matrix["deck"] == "Y"

    base_package = deck_sf * (
        (framing["sell_per_sf"] if frame_include else 0)
        + (decking["sell_per_sf"] * (1 + decking["waste_pct"]) if deck_include else 0)
    ) * combined_m

    # Demo - project-type-specific rate
    demo_rate = db["demo_rates_per_sf"].get(pt["key"], 0)
    demo = deck_sf * demo_rate if matrix["demo"] != "N" else 0

    # Border (only when deck=Y)
    border = 0
    if deck_include and inputs.get("border_style") == "Double Border":
        border = deck_sf * db["border_pricing"]["double_per_sf"]

    # Railing (skip if matrix.rail = N)
    rail = 0
    if matrix["rail"] != "N":
        rail = inputs.get("railing_lf", 0) * railing["sell_per_lf"]

    # Fascia (only when deck=Y)
    fascia = 0
    if deck_include:
        fascia = inputs.get("fascia_lf", 0) * db["fascia_per_lf"]

    # Stairs
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

    # Stain
    stain = 0
    if matrix["stain"] == "Y" and inputs.get("stain_sf", 0) > 0:
        rate = find_stain_rate(db, inputs["stain_type"], inputs["stain_coats"])
        stain = inputs["stain_sf"] * rate

    # Repairs (stain+repairs OR resurface)
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

    # Skirting (only when deck=Y)
    skirt = 0
    if deck_include:
        skirt = inputs.get("skirting_sf", 0) * db["skirting_per_sf"]

    # Adders
    lighting = inputs.get("lighting_fix", 0) * find_adder(db, "lighting")
    benches = inputs.get("bench_count", 0) * find_adder(db, "bench")
    privacy = inputs.get("privacy_screen_lf", 0) * find_adder(db, "privacy_screen")
    hot_tub = find_adder(db, "hot_tub") if inputs.get("hot_tub") == "Yes" else 0

    # Allowances - project-type-specific defaults (user can override)
    pt_allowances = next(
        (a for a in db["allowances_by_project_type"] if a["name"] == pt["name"]),
        None)
    if pt_allowances:
        default_permit = pt_allowances["permit"]
        default_dump = pt_allowances["dumpster"]
        default_mobil = pt_allowances["mobilization"]
    else:
        default_permit = db["allowances"]["permit_engineering_default"]
        default_dump = db["allowances"]["dumpster_cleanup_default"]
        default_mobil = db["allowances"]["mobilization_minimum_default"]

    permit = inputs.get("permit_alw", default_permit)
    dumpster = inputs.get("dumpster_alw", default_dump)
    mobil = inputs.get("mobil_alw", default_mobil)
    misc = inputs.get("misc_alw", db["allowances"]["misc_default"])

    subtotal = (base_package + demo + border + rail + fascia + stair + stain + repair
                + skirt + lighting + benches + privacy + hot_tub
                + permit + dumpster + mobil + misc)

    margin = inputs.get("margin", db["margin_and_contingency"]["default_margin"])
    contingency = inputs.get("contingency",
                             db["margin_and_contingency"]["default_contingency"])

    sell = subtotal / (1 - margin) if margin < 1 else 0
    low = sell * (1 - contingency)
    high = sell * (1 + contingency)
    per_sf = sell / deck_sf if deck_sf > 0 else 0

    return {
        "deck_sf": deck_sf,
        "combined_multiplier": combined_m,
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
        "subtotal": subtotal,
        "sell_price": sell,
        "low_range": low,
        "high_range": high,
        "per_sf": per_sf,
    }


def fmt(n):
    return f"${n:>10,.0f}"


def pct(n):
    return f"{n*100:>5.1f}%"


def print_report(label, result):
    print(f"\n{'='*70}")
    print(f"  {label}")
    print(f"{'='*70}")
    print(f"  Deck SF:           {result['deck_sf']:>10,}")
    print(f"  Combined mult:     {result['combined_multiplier']:>10.3f}x")
    print(f"  ---")
    print(f"  Base Package:       {fmt(result['base_package'])}")
    print(f"  Demo:               {fmt(result['demo'])}")
    print(f"  Border:             {fmt(result['border'])}")
    print(f"  Railing:            {fmt(result['rail'])}")
    print(f"  Fascia:             {fmt(result['fascia'])}")
    print(f"  Stairs:             {fmt(result['stair'])}")
    print(f"  Stain:              {fmt(result['stain'])}")
    print(f"  Repairs:            {fmt(result['repair'])}")
    print(f"  Skirting:           {fmt(result['skirting'])}")
    print(f"  Lighting:           {fmt(result['lighting'])}")
    print(f"  Benches:            {fmt(result['benches'])}")
    print(f"  Privacy:            {fmt(result['privacy'])}")
    print(f"  Hot Tub:            {fmt(result['hot_tub'])}")
    print(f"  Permit:             {fmt(result['permit'])}")
    print(f"  Dumpster:           {fmt(result['dumpster'])}")
    print(f"  Mobilization:       {fmt(result['mobilization'])}")
    print(f"  Misc:               {fmt(result['misc'])}")
    print(f"  ---")
    print(f"  SUBTOTAL:           {fmt(result['subtotal'])}")
    print(f"  SELL PRICE:         {fmt(result['sell_price'])}  <-- quote this")
    print(f"  Range:              {fmt(result['low_range'])} - {fmt(result['high_range'])}")
    print(f"  Per SF:             ${result['per_sf']:.2f}")


def main():
    db = load_db()

    print("\n" + "#" * 70)
    print("# CWDB DECK ESTIMATOR - ENGINE VERIFICATION")
    print(f"# Pricing as-of: {db['as_of']}")
    print("#" * 70)

    # ------------------------------------------------------------------
    # PARITY CHECK: John Garcia's sample
    # 270 SF Trex Transcend, Full Tear-Out, 1-story flat, bump-outs, busy season
    # ------------------------------------------------------------------
    johns_sample = {
        "project_type": "Full Tear-Out + New Build",
        "length": 18, "depth": 15,  # = 270 SF (matches John's sample)
        "decking_material": "Trex Transcend",
        "railing_material": "Trex Aluminum",
        "framing_material": "KDAT Pressure-Treated",
        "height": "1 Story / Low",
        "grade": "Flat / Normal Access",
        "complexity": "Bump Outs / Angles",
        "market": "Busy Season",
        "border_style": "Pencil Border",
        "railing_lf": 40,
        "fascia_lf": 70,
        "stair_runs": 1,
        "stair_treads": 6,
        "stair_landings": 0,
        "wraparound": "No",
    }
    print_report("JOHN'S SAMPLE (parity check - expect ~$57K-$60K)",
                 compute(db, johns_sample))

    # ------------------------------------------------------------------
    # 5-PROJECT-TYPE SWEEP at 270 SF
    # ------------------------------------------------------------------
    base_inputs = {
        "length": 18, "depth": 15,
        "decking_material": "Trex Select",
        "railing_material": "Trex Aluminum",
        "framing_material": "KDAT Pressure-Treated",
        "height": "1 Story / Low",
        "grade": "Flat / Normal Access",
        "complexity": "Simple Rectangle",
        "market": "Normal Schedule",
        "border_style": "Pencil Border",
        "railing_lf": 40,
        "fascia_lf": 70,
        "stair_runs": 1,
        "stair_treads": 6,
        "stair_landings": 0,
        "wraparound": "No",
        "stain_sf": 270,
        "stain_type": "Solid / Paint-and-Sealer",
        "stain_coats": 1,
        "board_repairs": 5,
        "joist_repair_lf": 0,
        "hardware_inc": "Yes",
    }

    for pt in db["project_types"]:
        inputs = dict(base_inputs)
        inputs["project_type"] = pt["name"]
        print_report(f"PROJECT TYPE SWEEP: {pt['name']}", compute(db, inputs))

    # ------------------------------------------------------------------
    # MATERIAL SWEEP: Full Tear-Out with each decking material
    # ------------------------------------------------------------------
    print("\n\n" + "#" * 70)
    print("# MATERIAL SWEEP - Full Tear-Out, 270 SF, default conditions")
    print("#" * 70)
    print(f"\n{'Decking':<32} {'Sell Price':>12} {'$/SF':>10}")
    print("-" * 56)
    for dm in db["decking_materials"]:
        inputs = dict(base_inputs)
        inputs["project_type"] = "Full Tear-Out + New Build"
        inputs["decking_material"] = dm["name"]
        r = compute(db, inputs)
        print(f"{dm['name']:<32} {fmt(r['sell_price']):>12} "
              f"${r['per_sf']:>8.2f}")


if __name__ == "__main__":
    main()
