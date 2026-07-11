"""
Golden-file + invariant tests for the v2 explicit-labor estimator engine.

Run:  python -m pytest sales/estimating/test_engine_v2.py -q

Covers:
  - v1 frozen audit path: exact current numbers (locks pre-cutover pricing)
  - v2 reference deck (the worked example Jim approved 2026-07-09)
  - structural invariants: buckets sum to cost; line items sum to the chosen
    price at every rung; per-line materials + labor == amount;
    investment_summary reconciles
  - fence + stain branches; market-load applies to price not cost
  - takeoff reconciliation against the engine materials subtotal
  - legacy estimate JSONs still render through generate_estimate_pdf
  - v2 estimate JSON (4-element line items + summary block) renders
"""

import json
import math
import sys
from pathlib import Path

import pytest

HERE = Path(__file__).resolve().parent
ESTIMATES_DIR = HERE.parent / "estimates"
sys.path.insert(0, str(ESTIMATES_DIR))

from deck_calculator import (  # noqa: E402
    build_estimate_json,
    build_line_items,
    build_takeoff,
    compute_engine,
    load_pricing_v1,
    load_pricing_v2,
    round_money,
)

REFERENCE_DECK = {
    "project_type": "Full Tear-Out + New Build",
    "length": 20, "depth": 16,  # 320 sf
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

CLIENT = {"name": "Test Homeowner", "address_line": "123 Test St, Wausau WI",
          "phone": "(715) 555-0000", "email": "test@example.com"}


@pytest.fixture(scope="module")
def db1():
    return load_pricing_v1()


@pytest.fixture(scope="module")
def db2():
    return load_pricing_v2()


# ---------------------------------------------------------------------------
# v1 frozen audit path - exact current numbers
# ---------------------------------------------------------------------------
def test_v1_reference_deck_frozen(db1):
    eng = compute_engine(db1, REFERENCE_DECK)
    assert not eng.get("v2")
    # base = 320 x (38 framing + 38 x 1.08 decking) x (1.22 x 1.10)
    assert round(eng["combined_multiplier"], 4) == round(1.22 * 1.10, 4)
    assert round_money(eng["base_package"]) == round_money(
        320 * (38 + 38 * 1.08) * 1.22 * 1.10)
    assert round_money(eng["demo"]) == 320 * 8
    assert round_money(eng["rail"]) == 36 * 110
    assert round_money(eng["fascia"]) == 36 * 38
    assert round_money(eng["stair"]) == 1800 + 5 * 275
    assert round_money(eng["subtotal_cost"]) == 49206
    assert round_money(eng["sell_price"]) == 61507


def test_v1_line_items_sum(db1):
    eng = compute_engine(db1, REFERENCE_DECK)
    for target in (24537, 49206, 61507):
        items = build_line_items(eng, REFERENCE_DECK, sell_override=target)
        assert sum(it[1] for it in items) == target


# ---------------------------------------------------------------------------
# v2 reference deck - the worked example Jim approved
# ---------------------------------------------------------------------------
def test_v2_reference_deck(db2):
    eng = compute_engine(db2, REFERENCE_DECK)
    assert eng.get("v2")
    b = eng["buckets"]

    # Footings: max(4, ceil(320/32)) = 10 Diamond Piers @ $150
    assert eng["footing_count"] == 10
    assert b["footings"]["materials"] == 10 * 150

    # Materials: decking (cost x waste + fasteners), framing, rail, stair, fascia
    assert round(b["decking"]["materials"], 2) == round(
        320 * 13.93 * 1.08 + 320 * 1.66, 2)
    assert b["framing"]["materials"] == 320 * 4.75
    assert b["rail"]["materials"] == 36 * 50
    assert b["stair"]["materials"] == 5 * 65 + 150
    assert round(b["fascia"]["materials"], 2) == round(36 * 10.70, 2)
    assert round(eng["materials_subtotal"], 2) == round(
        320 * 13.93 * 1.08 + 320 * 1.66 + 320 * 4.75 + 1500
        + 36 * 50 + 475 + 36 * 10.70, 2)

    # Labor: SIMPLE CREW-DAYS model (Jim 2026-07-11):
    # (base 0.75 + 3.2 x 0.35 + stair 0.25 + rail 36/50 x 0.25) x Lm(1.342)
    # = 2.30 x 1.342 = 3.087; +1 contingency = 4.087 -> rounds to 4.0 days
    lm = 1.22 * 1.10
    base_days = 0.75 + 3.2 * 0.35 + 0.25 + 36 / 50 * 0.25
    assert round(eng["labor_days_calculated"], 4) == round(base_days * lm, 4)
    assert eng["contingency_days"] == 1.0
    assert eng["crew_days"] == 4.0
    # THE printed math: 4 days x 3 people x 8 hrs x $125 = $12,000
    assert eng["labor_subtotal"] == 4 * 3 * 8 * 125 == 12000

    # Allowances at face; true cost; sell = materials/0.70 + labor
    # + allowances, rounded to $50 (margin on materials ONLY)
    assert eng["allowances_subtotal"] == 750 + 950 + 2500
    assert round_money(eng["subtotal_cost"]) == round_money(
        eng["materials_subtotal"] + 12000 + 4200)
    expected_sell = round(
        (eng["materials_subtotal"] / 0.70 + 12000 + 4200) / 50) * 50
    assert eng["sell_price"] == expected_sell == 31950


def test_v2_buckets_sum_to_cost(db2):
    eng = compute_engine(db2, REFERENCE_DECK)
    bucket_total = sum(x["materials"] for x in eng["buckets"].values())
    assert round(bucket_total + eng["labor_subtotal"]
                 + eng["allowances_subtotal"], 6) == round(
        eng["subtotal_cost"], 6)


def test_v2_line_items_invariants(db2):
    from deck_calculator import round_client
    eng = compute_engine(db2, REFERENCE_DECK)
    rungs = [round_client(eng["subtotal_cost"]),                   # breakeven
             round_client(eng["materials_subtotal"] / 0.85
                          + eng["labor_subtotal"]
                          + eng["allowances_subtotal"]),           # floor 15%
             eng["sell_price"],                                    # target 30%
             round_client(34 * 320)]                               # market-ish
    for target in rungs:
        items = build_line_items(eng, REFERENCE_DECK, sell_override=target)
        assert sum(it[1] for it in items) == target
        # every figure is a $50 multiple
        for it in items:
            assert it[1] % 50 == 0, f"non-$50 figure on {it[0]}: {it[1]}"
    # Labor line prints the day math and rides at face on every rung
    items = build_line_items(eng, REFERENCE_DECK, sell_override=eng["sell_price"])
    labor_lines = [it for it in items if "Professional labor" in it[0]]
    assert len(labor_lines) == 1
    assert labor_lines[0][1] == 12000
    assert "4 crew-days x 3-person crew x 8 hrs @ $125/hr" in labor_lines[0][0]
    # Allowance line rides at face
    assert items[-1][1] == 4200


def test_v2_reference_deck_line_amounts(db2):
    """The exact reference-deck quote Jim approved 2026-07-11."""
    eng = compute_engine(db2, REFERENCE_DECK)
    items = build_line_items(eng, REFERENCE_DECK, sell_override=eng["sell_price"])
    amounts = {it[0].split(":")[0].split(" including")[0]: it[1] for it in items}
    assert eng["sell_price"] == 31950
    assert amounts["Diamond Pier engineered foundation system (10 piers)"] == 2150
    assert amounts["Deck materials"] == 10350
    assert amounts["TimberTech Impression Rail Express (Aluminum) railing system (36 LF)"] == 2550
    assert amounts["Staircase materials"] == 700
    assert amounts["Professional labor & installation (site prep, demolition, construction, and cleanup)"] == 12000
    assert amounts["Permits, dumpster, mobilization, and final cleanup"] == 4200


def test_v2_estimate_json_and_summary(db2):
    eng = compute_engine(db2, REFERENCE_DECK)
    price = eng["sell_price"]
    est = build_estimate_json(REFERENCE_DECK, CLIENT, db2,
                              final_price=price, pricing_basis="30% margin (target)")
    assert est["_meta"]["engine_version"] == "v2.0"
    summary = est["investment_summary"]
    assert summary["total"] == price == sum(it[1] for it in est["line_items"])
    assert summary["materials"] + summary["labor"] + summary["site_and_admin"] \
        == summary["total"]
    assert summary["crew_days"] == 4.0
    assert summary["labor"] == 12000
    assert summary["site_and_admin"] == 4200
    assert est["_meta"]["crew_days"] == 4.0


# ---------------------------------------------------------------------------
# Stain + fence branches (uniform math across project types)
# ---------------------------------------------------------------------------
def test_v2_stain_job(db2):
    inputs = {
        "project_type": "Stain Only", "length": 26, "depth": 16,
        "decking_material": "Pressure-Treated Pine",
        "railing_material": "Pressure-Treated Wood Rail",
        "framing_material": "KDAT Pressure-Treated",
        "height": "1 Story / Low", "grade": "Flat / Normal Access",
        "complexity": "Simple Rectangle", "market": "Normal Schedule",
        "stain_sf": 416, "stain_type": "Solid / Paint-and-Sealer",
        "stain_coats": 2,
    }
    eng = compute_engine(db2, inputs)
    b = eng["buckets"]["stain"]
    assert b["gallons"] == math.ceil(416 * 2 / 250) == 4
    assert b["materials"] == 4 * 55 + 75
    # days: base 0.25 + 4.16 x 0.125 + extra coat 416/400 x 0.25 = 1.03;
    # +1 contingency = 2.03 -> rounds to 2.0 crew-days
    assert round(eng["labor_days_calculated"], 4) == round(
        0.25 + 4.16 * 0.125 + 416 / 400 * 0.25, 4)
    assert eng["crew_days"] == 2.0
    assert eng["labor_subtotal"] == 2 * 3 * 8 * 125 == 6000
    assert eng["allowances_subtotal"] == 0 + 250 + 500
    items = build_line_items(eng, inputs, sell_override=eng["sell_price"])
    assert sum(it[1] for it in items) == eng["sell_price"]
    assert eng["sell_price"] % 50 == 0


def test_v2_fence_job(db2):
    inputs = {
        "project_type": "Fence", "length": 1, "depth": 1,
        "fence_material": "Wood Privacy (Cedar / PT)", "fence_height": "6",
        "fence_color": None, "fence_lf": 150, "walk_gates": 1,
        "drive_gates": 0, "tearout_lf": 0,
        "height": "1 Story / Low", "grade": "Flat / Normal Access",
        "complexity": "Simple Rectangle", "market": "Normal Schedule",
    }
    eng = compute_engine(db2, inputs)
    assert eng["buckets"]["fence_run"]["materials"] == 150 * 10.60
    assert eng["buckets"]["fence_gates"]["materials"] == 180
    # days: base 0.25 + 1.5 x 1.0 + walk gate 0.25 = 2.0; +1 = 3.0 crew-days
    assert eng["crew_days"] == 3.0
    assert eng["labor_subtotal"] == 3 * 3 * 8 * 125 == 9000
    items = build_line_items(eng, inputs, sell_override=eng["sell_price"])
    assert sum(it[1] for it in items) == eng["sell_price"]


def test_v2_market_load_hits_price_not_cost(db2):
    busy = dict(REFERENCE_DECK, market="Busy Season")
    normal = compute_engine(db2, REFERENCE_DECK)
    eng = compute_engine(db2, busy)
    assert round(eng["subtotal_cost"], 6) == round(normal["subtotal_cost"], 6)
    # market load multiplies the MATERIALS component only; labor and
    # allowances stay at face
    expected = round((normal["materials_subtotal"] / 0.70 * 1.08
                      + normal["labor_subtotal"]
                      + normal["allowances_subtotal"]) / 50) * 50
    assert eng["sell_price"] == expected


def test_v2_color_cost_override(db2):
    import copy
    db = copy.deepcopy(db2)
    mat = db["decking_materials"][0]
    mat["colors"][0]["cost_per_sf"] = mat["cost_per_sf"] + 5
    inputs = dict(REFERENCE_DECK,
                  decking_material=mat["name"],
                  decking_color=mat["colors"][0]["name"])
    base_inputs = dict(inputs, decking_color=None)
    base = compute_engine(db, base_inputs)
    over = compute_engine(db, inputs)
    delta = (over["buckets"]["decking"]["materials"]
             - base["buckets"]["decking"]["materials"])
    waste = mat["waste_pct"]
    assert round(delta, 2) == round(320 * 5 * (1 + waste), 2)  # waste applies to cost
    # Only decking moved
    assert over["buckets"]["framing"]["materials"] == base["buckets"]["framing"]["materials"]


# ---------------------------------------------------------------------------
# Takeoff
# ---------------------------------------------------------------------------
def test_takeoff_reference_deck(db2):
    eng = compute_engine(db2, REFERENCE_DECK)
    tk = build_takeoff(db2, REFERENCE_DECK, eng)
    assert tk["rows"], "takeoff produced no rows"
    cats = {r["category"] for r in tk["rows"]}
    assert {"Framing", "Footings", "Decking", "Railing", "Stairs",
            "Fascia"} <= cats
    piers = [r for r in tk["rows"] if "Diamond Pier" in r["item"]]
    assert piers and piers[0]["qty"] == 10
    concealoc = [r for r in tk["rows"] if "CONCEALoc" in r["item"]]
    assert concealoc and concealoc[0]["qty"] == math.ceil(320 / 100)
    # Reconciliation: whole-piece rounding only - keep drift under 15%
    assert abs(tk["drift"]) < 0.15 * tk["engine_materials"], (
        f"takeoff drift {tk['drift']} too large vs engine "
        f"{tk['engine_materials']}")


# ---------------------------------------------------------------------------
# PDF rendering - legacy regression + v2
# ---------------------------------------------------------------------------
def test_legacy_estimates_still_render(tmp_path):
    from generate_estimate_pdf import generate_pdf
    data_dir = ESTIMATES_DIR / "_data"
    rendered = 0
    for jf in sorted(data_dir.glob("*.json")):
        est = json.loads(jf.read_text(encoding="utf-8"))
        if "line_items" not in est:
            continue
        # renderings reference temp paths that no longer exist; strip them
        est.pop("renderings", None)
        out = tmp_path / (jf.stem + ".pdf")
        generate_pdf(est, out)
        assert out.exists() and out.stat().st_size > 5000
        assert sum(it[1] for it in est["line_items"]) > 0
        rendered += 1
    assert rendered >= 10, f"only {rendered} legacy estimates rendered"


def test_v2_estimate_renders_pdf(tmp_path, db2):
    from generate_estimate_pdf import generate_pdf
    eng = compute_engine(db2, REFERENCE_DECK)
    price = round_money(eng["sell_price"])
    est = build_estimate_json(REFERENCE_DECK, CLIENT, db2, final_price=price,
                              pricing_basis="30% margin (target)")
    out = tmp_path / "v2-reference.pdf"
    generate_pdf(est, out)
    assert out.exists() and out.stat().st_size > 5000


def test_v2_materials_pdf_renders(tmp_path, db2):
    from generate_materials_pdf import generate_materials_pdf
    eng = compute_engine(db2, REFERENCE_DECK)
    tk = build_takeoff(db2, REFERENCE_DECK, eng)
    out = tmp_path / "v2-materials.pdf"
    generate_materials_pdf(tk, CLIENT, "Full Tear-Out + New Build", out)
    assert out.exists() and out.stat().st_size > 2000


# ---------------------------------------------------------------------------
# The cutover gate
# ---------------------------------------------------------------------------
def test_draft_status_keeps_v1_live():
    from deck_calculator import load_pricing
    db2 = load_pricing_v2()
    live = load_pricing()
    if db2.get("status") == "active":
        assert live["schema_version"].startswith("2")
    else:
        assert live["schema_version"].startswith("1"), (
            "v2 DB is draft but load_pricing returned it")
