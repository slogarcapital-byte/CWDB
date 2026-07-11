"""
CWDB Deck Estimator - Engine Verification Harness (v2 rewrite, 2026-07-09)

IMPORTS the live engine from sales/estimates/deck_calculator.py instead of
carrying its own duplicated math (the old fork drifted: it had no fence
branch and ignored per-color overrides). Runs:

  1. John's parity sample + a full 7-project-type sweep (fence included)
     through BOTH engines: v1 (frozen audit DB) and v2 (explicit labor)
  2. A per-bucket materials / labor / hours report for each v2 result
  3. A v1-vs-v2 price comparison table (the calibration report Jim reviews
     before flipping pricing-db-v2.json to active)
  4. A color-override check (per-color cost honored by the engine)
  5. A confidence audit: every pricing-db-v2 entry still tagged
     confidence='estimate' (the successor to the CONFIRM WITH JOHN markers)

Usage:
    python verify_engine.py
"""

import sys
from pathlib import Path

ESTIMATES_DIR = Path(__file__).resolve().parent.parent / "estimates"
sys.path.insert(0, str(ESTIMATES_DIR))

from deck_calculator import (  # noqa: E402
    build_line_items,
    build_takeoff,
    compute_engine,
    load_pricing_v1,
    load_pricing_v2,
    round_money,
)

# ---------------------------------------------------------------------------
# Reference inputs
# ---------------------------------------------------------------------------
JOHNS_SAMPLE = {
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

BASE_INPUTS = {
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
    # fence fields (used only by the Fence project type)
    "fence_material": "Wood Privacy (Cedar / PT)",
    "fence_height": "6",
    "fence_lf": 150,
    "walk_gates": 1,
    "drive_gates": 0,
    "tearout_lf": 0,
}

# The worked example from the v2 adoption plan (320 sf elevated tear-out)
REFERENCE_DECK = {
    "project_type": "Full Tear-Out + New Build",
    "length": 20, "depth": 16,
    "decking_material": "TimberTech PRO Reserve",
    "railing_material": "TimberTech Impression Rail Express (Aluminum)",
    "framing_material": "KDAT Pressure-Treated",
    "height": "2 Story / Elevated",
    "grade": "Mild Slope",
    "complexity": "Simple Rectangle",
    "market": "Normal Schedule",
    "border_style": "Pencil Border",
    "railing_lf": 36,
    "fascia_lf": 36,
    "stair_runs": 1,
    "stair_treads": 5,
    "stair_landings": 0,
    "wraparound": "No",
}


def v2_report(title, eng):
    print(f"\n=== {title} " + "=" * max(0, 60 - len(title)))
    print(f"{'Materials bucket (at cost)':<34} {'Cost':>10}")
    print("-" * 46)
    for name, b in eng["buckets"].items():
        print(f"{name:<34} {b['materials']:>10,.0f}")
    print("-" * 46)
    print(f"{'materials subtotal':<34} {eng['materials_subtotal']:>10,.0f}")
    print(f"{'labor (day math)':<34} {eng['labor_subtotal']:>10,.0f}")
    print(f"  ({eng['labor_days_calculated']:.2f} calc + "
          f"{eng['contingency_days']:g} contingency -> "
          f"{eng['crew_days']:g} crew-days x {eng['crew_size']} crew x "
          f"{eng['hours_per_day']} hrs @ ${eng['labor_rate']}/hr)")
    print(f"{'allowances (at face)':<34} {eng['allowances_subtotal']:>10,.0f}")
    print(f"{'TRUE COST':<34} {eng['subtotal_cost']:>10,.0f}")
    print(f"{'sell (30% on materials, $50 rnd)':<34} {eng['sell_price']:>10,.0f}")


def line_items_check(eng, inputs, label):
    """Assert the sum-to-price invariant at three price points (v2 targets
    snap to the $50 client rounding)."""
    from deck_calculator import round_client
    for raw in (eng["subtotal_cost"], eng["sell_price"],
                eng["sell_price"] * 0.9):
        target = round_client(raw) if eng.get("v2") else round_money(raw)
        items = build_line_items(eng, inputs, sell_override=target)
        s = sum(it[1] for it in items)
        status = "OK" if s == target else f"FAIL (sum={s})"
        print(f"  line-items sum to {target:>8,}: {status}")
        if eng.get("v2"):
            for it in items:
                assert it[1] % 50 == 0 or it is items[-1], \
                    f"non-$50 figure on {it[0]}"


def confidence_audit(db2):
    print("\n" + "#" * 70)
    print("# CONFIDENCE AUDIT - entries still at confidence='estimate'")
    print("# (successor to CONFIRM WITH JOHN; retire via dealer sheet)")
    print("#" * 70)
    flagged = []

    def walk(node, path):
        if isinstance(node, dict):
            if node.get("confidence") == "estimate":
                label = node.get("name") or node.get("key") or node.get("description") or path
                flagged.append(f"{path}: {label}")
            for k, v in node.items():
                walk(v, f"{path}.{k}" if path else k)
        elif isinstance(node, list):
            for i, v in enumerate(node):
                walk(v, f"{path}[{i}]")

    walk(db2, "")
    for f in flagged:
        print(f"  - {f}")
    print(f"  TOTAL: {len(flagged)} entries pending confirmation")


def main():
    db1 = load_pricing_v1()
    db2 = load_pricing_v2()

    print("#" * 70)
    print("# CWDB DECK ESTIMATOR - ENGINE VERIFICATION (v1 audit vs v2 labor)")
    print(f"# v1 as-of {db1['as_of']}  |  v2 as-of {db2['as_of']} "
          f"(status: {db2['status']})")
    print("#" * 70)

    # ---- v1-vs-v2 calibration table across all 7 project types + samples --
    scenarios = [("JOHN'S SAMPLE", JOHNS_SAMPLE),
                 ("REFERENCE DECK (plan example)", REFERENCE_DECK)]
    for pt in db2["project_types"]:
        inputs = dict(BASE_INPUTS)
        inputs["project_type"] = pt["name"]
        scenarios.append((f"SWEEP: {pt['name']}", inputs))

    print(f"\n{'Scenario':<42} {'v1 sell':>10} {'v2 sell':>10} {'delta':>8}")
    print("-" * 74)
    v2_results = []
    for label, inputs in scenarios:
        e1 = compute_engine(db1, inputs)
        e2 = compute_engine(db2, inputs)
        d = (e2["sell_price"] / e1["sell_price"] - 1) * 100 if e1["sell_price"] else 0
        print(f"{label:<42} {e1['sell_price']:>10,.0f} {e2['sell_price']:>10,.0f} "
              f"{d:>+7.0f}%")
        v2_results.append((label, inputs, e2))

    # ---- Per-bucket v2 reports + invariants --------------------------------
    for label, inputs, e2 in v2_results:
        v2_report(label, e2)
        line_items_check(e2, inputs, label)

    # ---- Color override check ---------------------------------------------
    print("\n" + "#" * 70)
    print("# COLOR OVERRIDE CHECK")
    print("#" * 70)
    test_db = load_pricing_v2()
    mat = test_db["decking_materials"][0]
    mat["colors"][0]["cost_per_sf"] = mat["cost_per_sf"] + 5
    inputs = dict(REFERENCE_DECK)
    inputs["decking_material"] = mat["name"]
    inputs["decking_color"] = mat["colors"][0]["name"]
    base = compute_engine(load_pricing_v2(), inputs)
    over = compute_engine(test_db, inputs)
    diff = over["buckets"]["decking"]["materials"] - base["buckets"]["decking"]["materials"]
    print(f"  decking materials delta with +$5/sf color override: {diff:,.0f} "
          f"({'OK' if diff > 0 else 'FAIL'})")

    # ---- Takeoff reconciliation --------------------------------------------
    print("\n" + "#" * 70)
    print("# TAKEOFF RECONCILIATION (reference deck)")
    print("#" * 70)
    e2 = compute_engine(db2, REFERENCE_DECK)
    tk = build_takeoff(db2, REFERENCE_DECK, e2)
    print(f"  takeoff total {tk['materials_total']:,.0f} vs engine materials "
          f"{tk['engine_materials']:,.0f} (drift {tk['drift']:+,.0f})")

    confidence_audit(db2)


if __name__ == "__main__":
    main()
