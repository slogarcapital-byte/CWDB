"""
CWDB Deck Estimator - Workbook Test Runner

Loads CWDB_Deck_Estimator_v1.xlsx, runs 10 scenarios (2 per project type) through
the REAL Excel formulas (not a Python mirror), reports the sell price + line-item
breakdown for each scenario.

Uses the `formulas` package to evaluate the workbook's formulas headlessly.

Run:
    python test_workbook.py
"""

import warnings
import random
from pathlib import Path

warnings.filterwarnings("ignore")

import formulas

SCRIPT_DIR = Path(__file__).resolve().parent
WORKBOOK = SCRIPT_DIR / "CWDB_Deck_Estimator_v1.xlsx"
SHEET_PREFIX = f"'[{WORKBOOK.name}]QUOTE INPUT'!"

# Cells we'll override (inputs)
INPUT_CELLS = {
    "client": "B7", "address": "B8", "estimator": "B9", "date": "B10",
    "project_type": "B13",
    "length": "B16", "depth": "B17",
    "decking": "B21", "railing": "B22", "framing": "B23",
    "height": "B26", "grade": "B27", "complexity": "B28", "market": "B29",
    "border": "B32", "railing_lf": "B33", "fascia_lf": "B34",
    "stair_runs": "B35", "stair_treads": "B36", "stair_landings": "B37",
    "wraparound": "B38",
    "stain_sf": "B41", "stain_type": "B42", "stain_coats": "B43",
    "board_repairs": "B46", "joist_lf": "B47", "hardware_inc": "B48",
    "skirting_sf": "B51", "lighting": "B52", "benches": "B53",
    "privacy_lf": "B54", "hot_tub": "B55",
    "permit": "B58", "dumpster": "B59", "mobilization": "B60", "misc": "B61",
    "margin": "B64", "contingency": "B65",
}

# Cells we'll read (outputs)
OUTPUT_CELLS = {
    "deck_sf": "B18",
    "combined_mult": "E17",
    "base_package": "E20",
    "demo": "E21",
    "border": "E22",
    "railing": "E23",
    "fascia": "E24",
    "stairs": "E25",
    "stain": "E26",
    "repairs": "E27",
    "skirting": "E28",
    "lighting": "E29",
    "benches": "E30",
    "privacy": "E31",
    "hot_tub": "E32",
    "permit": "E33",
    "dumpster": "E34",
    "mobilization": "E35",
    "misc": "E36",
    "subtotal": "E37",
    "sell_price": "E40",
    "low_range": "E41",
    "high_range": "E42",
    "per_sf": "E43",
}


def addr(local):
    return SHEET_PREFIX + local


def unwrap(v):
    """Unwrap nested numpy arrays / lists into scalars."""
    if hasattr(v, "tolist"):
        v = v.tolist()
    while isinstance(v, list) and len(v) == 1:
        v = v[0]
    return v


def run_scenario(xl_model, scenario_inputs):
    """Apply scenario inputs to the workbook and return computed outputs."""
    # Build the input overrides
    inputs = {}
    for key, value in scenario_inputs.items():
        if key in INPUT_CELLS:
            inputs[addr(INPUT_CELLS[key])] = value

    # Output addresses we want
    outputs = [addr(c) for c in OUTPUT_CELLS.values()]

    sol = xl_model.calculate(inputs=inputs, outputs=outputs)

    # Read outputs back
    result = {}
    for name, cell in OUTPUT_CELLS.items():
        v = sol.get(addr(cell))
        if v is None:
            result[name] = None
        else:
            result[name] = unwrap(v.value)
    return result


def fmt_money(v):
    if v is None:
        return "       n/a"
    try:
        return f"${float(v):>10,.0f}"
    except (TypeError, ValueError):
        return "       n/a"


def fmt_per_sf(v):
    if v is None:
        return "  n/a"
    try:
        return f"${float(v):>5.2f}"
    except (TypeError, ValueError):
        return "  n/a"


def print_scenario_report(label, inputs, result):
    print(f"\n{'='*78}")
    print(f"  {label}")
    print(f"{'='*78}")
    print(f"  Project Type:    {inputs['project_type']}")
    print(f"  Dimensions:      {inputs['length']} x {inputs['depth']} "
          f"= {inputs['length'] * inputs['depth']} SF")
    print(f"  Decking:         {inputs['decking']}")
    print(f"  Railing:         {inputs['railing']}")
    print(f"  Framing:         {inputs['framing']}")
    print(f"  Conditions:      {inputs['height']} / {inputs['grade']} / "
          f"{inputs['complexity']} / {inputs['market']}")
    print(f"  Scope detail:    Rail {inputs['railing_lf']} LF · "
          f"Fascia {inputs['fascia_lf']} LF · Stairs {inputs['stair_runs']}/"
          f"{inputs['stair_treads']} treads")
    if inputs.get("stain_sf", 0) > 0:
        print(f"  Stain:           {inputs['stain_sf']} SF "
              f"{inputs['stain_type']} ({inputs['stain_coats']} coat)")
    if inputs.get("board_repairs", 0) > 0 or inputs.get("joist_lf", 0) > 0:
        print(f"  Repairs:         {inputs['board_repairs']} boards · "
              f"{inputs['joist_lf']} LF joists · "
              f"Hardware {inputs['hardware_inc']}")
    print(f"  --- Line items ---")
    print(f"    Base Package:        {fmt_money(result['base_package'])}")
    print(f"    Demo:                {fmt_money(result['demo'])}")
    print(f"    Border:              {fmt_money(result['border'])}")
    print(f"    Railing:             {fmt_money(result['railing'])}")
    print(f"    Fascia:              {fmt_money(result['fascia'])}")
    print(f"    Stairs:              {fmt_money(result['stairs'])}")
    print(f"    Stain:               {fmt_money(result['stain'])}")
    print(f"    Repairs:             {fmt_money(result['repairs'])}")
    print(f"    Skirting:            {fmt_money(result['skirting'])}")
    print(f"    Lighting:            {fmt_money(result['lighting'])}")
    print(f"    Benches:             {fmt_money(result['benches'])}")
    print(f"    Privacy:             {fmt_money(result['privacy'])}")
    print(f"    Hot Tub:             {fmt_money(result['hot_tub'])}")
    print(f"    Permit:              {fmt_money(result['permit'])}")
    print(f"    Dumpster:            {fmt_money(result['dumpster'])}")
    print(f"    Mobilization:        {fmt_money(result['mobilization'])}")
    print(f"    Misc:                {fmt_money(result['misc'])}")
    print(f"  --- ---")
    print(f"  SUBTOTAL (cost):       {fmt_money(result['subtotal'])}")
    print(f"  SELL PRICE:            {fmt_money(result['sell_price'])}  "
          f"<-- quote this")
    print(f"  Range:    {fmt_money(result['low_range'])} - "
          f"{fmt_money(result['high_range'])}")
    print(f"  Combined mult:  {result['combined_mult']:.3f}x   "
          f"Per SF:  {fmt_per_sf(result['per_sf'])}")


# -----------------------------------------------------------------------------
# Scenarios: 2 per project type, realistic random variation
# -----------------------------------------------------------------------------

BASE_INPUTS = {
    "client": "Test Customer",
    "address": "Wausau, WI",
    "estimator": "James Slogar",
    "date": "2026-05-28",
    "border": "Pencil Border",
    "wraparound": "No",
    "stain_sf": 0, "stain_type": "Solid / Paint-and-Sealer", "stain_coats": 1,
    "board_repairs": 0, "joist_lf": 0, "hardware_inc": "No",
    "skirting_sf": 0, "lighting": 0, "benches": 0, "privacy_lf": 0,
    "hot_tub": "No",
    "misc": 0,
    "margin": 0.20, "contingency": 0.08,
}


def make_scenario(**overrides):
    s = dict(BASE_INPUTS)
    s.update(overrides)
    # Project-type-aware allowance defaults (mirror the workbook formula)
    allowances = {
        "Stain Only":                            (0, 250, 500),
        "Stain + Minor Repairs":                 (0, 350, 750),
        "Resurface (Boards Only)":               (250, 600, 1500),
        "Frame + Deck Rebuild (Keep Footings)":  (500, 950, 2500),
        "Full Tear-Out + New Build":             (750, 950, 2500),
    }
    permit, dump, mob = allowances[s["project_type"]]
    s.setdefault("permit", permit)
    s.setdefault("dumpster", dump)
    s.setdefault("mobilization", mob)
    return s


SCENARIOS = [
    # ----- STAIN ONLY -----
    ("Stain Only · Mrs. Henderson's small backyard refinish (250 SF)",
     make_scenario(
        client="Mrs. Henderson", project_type="Stain Only",
        length=25, depth=10,
        decking="Trex Select", railing="Trex Aluminum", framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Flat / Normal Access",
        complexity="Simple Rectangle", market="Normal Schedule",
        railing_lf=0, fascia_lf=0, stair_runs=0, stair_treads=0, stair_landings=0,
        stain_sf=250, stain_type="Semi-Transparent", stain_coats=2,
     )),
    ("Stain Only · 2-story deck with stairs, premium solid stain (400 SF)",
     make_scenario(
        client="Bob & Carol Anderson", project_type="Stain Only",
        length=20, depth=20,
        decking="Trex Select", railing="Trex Aluminum", framing="KDAT Pressure-Treated",
        height="2 Story / Elevated", grade="Flat / Normal Access",
        complexity="Simple Rectangle", market="Busy Season",
        railing_lf=0, fascia_lf=0, stair_runs=0, stair_treads=0, stair_landings=0,
        stain_sf=400, stain_type="Solid / Paint-and-Sealer", stain_coats=2,
     )),

    # ----- STAIN + MINOR REPAIRS -----
    ("Stain + Repairs · 8 rotted boards swapped, hardware refresh (300 SF)",
     make_scenario(
        client="Jim's neighbor", project_type="Stain + Minor Repairs",
        length=20, depth=15,
        decking="Pressure-Treated Pine", railing="Pressure-Treated Wood Rail",
        framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Mild Slope",
        complexity="Simple Rectangle", market="Normal Schedule",
        railing_lf=0, fascia_lf=0, stair_runs=0, stair_treads=0, stair_landings=0,
        stain_sf=300, stain_type="Semi-Transparent", stain_coats=1,
        board_repairs=8, joist_lf=0, hardware_inc="Yes",
     )),
    ("Stain + Repairs · 5 boards + joist sister + 2-story (350 SF)",
     make_scenario(
        client="Patel family", project_type="Stain + Minor Repairs",
        length=25, depth=14,
        decking="Cedar", railing="Cedar Wood Rail", framing="KDAT Pressure-Treated",
        height="2 Story / Elevated", grade="Steep Slope",
        complexity="Bump Outs / Angles", market="Busy Season",
        railing_lf=0, fascia_lf=0, stair_runs=0, stair_treads=0, stair_landings=0,
        stain_sf=350, stain_type="Transparent", stain_coats=2,
        board_repairs=5, joist_lf=12, hardware_inc="Yes",
     )),

    # ----- RESURFACE (BOARDS ONLY) -----
    ("Resurface · Composite over existing PT frame, no new rails (320 SF)",
     make_scenario(
        client="Sarah K.", project_type="Resurface (Boards Only)",
        length=20, depth=16,
        decking="Trex Select", railing="Trex Aluminum",  # railing N/A since LF=0
        framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Flat / Normal Access",
        complexity="Simple Rectangle", market="Normal Schedule",
        railing_lf=0, fascia_lf=72, stair_runs=1, stair_treads=4,
        stair_landings=0,
     )),
    ("Resurface · Cedar boards + new aluminum railing system (450 SF)",
     make_scenario(
        client="Wagner residence", project_type="Resurface (Boards Only)",
        length=25, depth=18,
        decking="Cedar", railing="Trex Aluminum", framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Mild Slope",
        complexity="Bump Outs / Angles", market="Normal Schedule",
        railing_lf=50, fascia_lf=86, stair_runs=1, stair_treads=5,
        stair_landings=0,
        lighting=4,
     )),

    # ----- FRAME + DECK REBUILD -----
    ("Frame Rebuild · PT deck on existing footings, simple rectangle (280 SF)",
     make_scenario(
        client="Olson cabin", project_type="Frame + Deck Rebuild (Keep Footings)",
        length=20, depth=14,
        decking="Pressure-Treated Pine", railing="Pressure-Treated Wood Rail",
        framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Flat / Normal Access",
        complexity="Simple Rectangle", market="Normal Schedule",
        railing_lf=40, fascia_lf=68, stair_runs=1, stair_treads=4,
        stair_landings=0,
     )),
    ("Frame Rebuild · Trex Transcend, complex multi-level, glass rail (480 SF)",
     make_scenario(
        client="Lakefront upgrade", project_type="Frame + Deck Rebuild (Keep Footings)",
        length=30, depth=16,
        decking="Trex Transcend", railing="Glass Panel",
        framing="Steel (Fortress Evolution)",
        height="2 Story / Elevated", grade="Steep Slope",
        complexity="Multi-Level / Complex", market="Busy Season",
        border="Double Border",
        railing_lf=60, fascia_lf=92, stair_runs=2, stair_treads=12,
        stair_landings=1,
        lighting=8, benches=2,
     )),

    # ----- FULL TEAR-OUT + NEW BUILD -----
    ("Full Tear-Out · Mid-tier composite, Aluminum rail, simple (300 SF)",
     make_scenario(
        client="The Schmidts", project_type="Full Tear-Out + New Build",
        length=20, depth=15,
        decking="Trex Select", railing="Trex Aluminum", framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Flat / Normal Access",
        complexity="Simple Rectangle", market="Normal Schedule",
        railing_lf=40, fascia_lf=70, stair_runs=1, stair_treads=6,
        stair_landings=0,
     )),
    ("Full Tear-Out · John Garcia parity sample - 270 SF Transcend",
     make_scenario(
        client="Parity Test - John's Sample",
        project_type="Full Tear-Out + New Build",
        length=18, depth=15,
        decking="Trex Transcend", railing="Trex Aluminum",
        framing="KDAT Pressure-Treated",
        height="1 Story / Low", grade="Flat / Normal Access",
        complexity="Bump Outs / Angles", market="Busy Season",
        railing_lf=40, fascia_lf=70, stair_runs=1, stair_treads=6,
        stair_landings=0,
     )),
]


def main():
    print("=" * 78)
    print("  CWDB DECK ESTIMATOR v1 - REAL WORKBOOK TESTING")
    print("  Evaluating CWDB_Deck_Estimator_v1.xlsx formulas via `formulas` package")
    print("=" * 78)

    print("\nLoading workbook...")
    xl_model = formulas.ExcelModel().loads(str(WORKBOOK)).finish()
    print("Workbook loaded. Running 10 scenarios.")

    summary = []
    for label, inputs in SCENARIOS:
        result = run_scenario(xl_model, inputs)
        print_scenario_report(label, inputs, result)
        summary.append((label, inputs, result))

    # ---- Summary table ----
    print("\n\n" + "=" * 78)
    print("  SUMMARY - All 10 Scenarios")
    print("=" * 78)
    print(f"\n  {'Project Type':<40} {'SF':>6} {'Sell':>10} {'Per SF':>10}")
    print("  " + "-" * 70)
    for label, inputs, result in summary:
        pt_short = inputs["project_type"][:38]
        sf = inputs["length"] * inputs["depth"]
        sell = fmt_money(result["sell_price"]).strip()
        per = fmt_per_sf(result["per_sf"]).strip()
        print(f"  {pt_short:<40} {sf:>6} {sell:>10} {per:>10}")


if __name__ == "__main__":
    main()
