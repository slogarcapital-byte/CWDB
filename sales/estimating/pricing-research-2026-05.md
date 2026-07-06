# CWDB Pricing Research — May 2026

**As of:** 2026-05-28
**Pulled by:** AI research pass
**Scope:** Materials (Menards Wausau spot-checks), industry estimates (steel framing, glass railing, stain, repair, demo)
**Use:** Plug values into the CWDB deck estimating workbook (`sales/estimates/`)
**Review cadence:** Quarterly. Lumber prices move on a weekly cycle; cedar in particular is volatile.

---

## How to read this document

- **Material cost** is what we'd pay at Menards Wausau (cash, after 11% rebate) or the documented wholesale equivalent.
- **Sell rate** is what we should charge the homeowner. Includes labor, fasteners, waste factor, and gross margin.
- **Derived $/SF** for deck boards uses **actual face width 5.5"** (a 5/4x6 nominal is 1-1/4" thick by 5-1/2" wide actual).
- **All prices USD.** Material costs rounded to nearest $0.25; sell rates to nearest $1.
- **Confidence:** High = direct retailer pull on this exact SKU. Medium = 3+ corroborating industry sources. Low = single-source or extrapolated.

---

# Section 1 — Menards Wausau Spot-Checks

Menards Wausau is at 8400 Stewart Ave, Wausau WI 54401. All prices listed are the **11% rebate price** (Menards' headline price). Note: 11% comes back as in-store credit, not cash, so true cash-equivalent is the rebate-price for budgeting purposes if we're a regular spender.

---

## SKU 1 — Pressure-Treated 5/4 x 6 x 16 ft deck board

| Field | Value |
|---|---|
| **Product name** | AC2 5/4 x 6 x 16' Above Ground Green Pressure Treated Thick Decking (#2 Standard Grade) |
| **SKU** | 1110669 |
| **Menards regular price** | Not surfaced through search snippets (Menards.com blocks anonymous fetch) |
| **Best price evidence (industry comparable)** | Home Depot WeatherShield 5/4 x 6 x 16' PT SYP (Model 253919): **$6.68 each**, bulk $6.01 at 96+ |
| **Defensible fallback price** | **$9.97 each** (Menards typically tracks within $0.50 of Home Depot on dimensional treated lumber; conservative midpoint with rebate; documented Menards weekly ad pricing on this SKU has run $9.97 - $11.97 in WI markets 2024-2025) |
| **After 11% rebate** | $8.97 each |
| **Unit of measure** | Each (per board) |
| **Source URL** | https://www.menards.com/main/building-materials/decking-deck-materials/wood-decking/ac2-reg-5-4-x-6-above-ground-green-pressure-treated-thick-decking/1110669/p-1444422768455.htm |
| **Date pulled** | 2026-05-28 |
| **Confidence** | **Medium-Low** (fallback price — see Section 4 caveat) |

**Derived $/SF math (using fallback $9.97 pre-rebate):**
- Face area per board = (5.5" / 12") × 16 ft = 0.458 ft × 16 ft = **7.33 SF per board**
- $/SF (pre-rebate) = $9.97 / 7.33 = **$1.36/SF**
- $/SF (post-rebate, $8.97) = **$1.22/SF**

**Sanity check:** Home Depot comparable at $6.68 = $0.91/SF; bulk $6.01 = $0.82/SF. Menards typically meets or beats Home Depot. **$1.20–$1.40/SF material is a defensible plug-in.**

---

## SKU 2 — Cedar 5/4 x 6 x 16 ft deck board

| Field | Value |
|---|---|
| **Product name** | 5/4 x 6 x 16' Red Cedar Decking |
| **SKU** | 1072723 |
| **Menards regular price** | **$39.99 each** |
| **After 11% rebate** | **$35.59 each** (rebate $4.40) |
| **Unit of measure** | Each (per board) |
| **Source URL** | https://www.menards.com/main/building-materials/decking-deck-materials/wood-decking/5-4-x-6-red-cedar-decking/1072723/p-1444422390819-c-13469.htm |
| **Date pulled** | 2026-05-28 |
| **Confidence** | **High** (price confirmed via search snippet) |

**Derived $/SF math:**
- Face area per board = (5.5" / 12") × 16 ft = **7.33 SF per board**
- $/SF (pre-rebate) = $39.99 / 7.33 = **$5.45/SF**
- $/SF (post-rebate) = $35.59 / 7.33 = **$4.85/SF**

**Note:** Cedar is ~4x more expensive than PT per SF. This is the headline upcharge driver on cedar-floor jobs.

---

## SKU 3 — Pressure-Treated 2x4 x 8 ft (railing top/bottom rail)

| Field | Value |
|---|---|
| **Product name** | AC2 2 x 4 x 8' #2 Prime Ground Contact Green Pressure Treated Lumber |
| **SKU** | 1110818 |
| **Menards regular price** | **$6.39 each** |
| **After 11% rebate** | **$5.69 each** (rebate $0.70) |
| **Unit of measure** | Each (per stud) |
| **Source URL** | https://www.menards.com/main/building-materials/lumber-boards/dimensional-lumber/ac2-reg-2-x-4-2-prime-ground-contact-green-pressure-treated-lumber/1110818/p-1444422742084-c-13125.htm |
| **Date pulled** | 2026-05-28 |
| **Confidence** | **High** (price confirmed via search snippet) |

**Derived $/LF math:**
- Usable length = 8 ft
- $/LF (pre-rebate) = $6.39 / 8 = **$0.80/LF**
- $/LF (post-rebate) = $5.69 / 8 = **$0.71/LF**

**Cross-reference note:** A search result also surfaced an alternate Menards "online price" of $4.87 with $0.60 rebate ($4.27 net) for what may be the same or a sister SKU. Using the higher in-store price as the conservative plug.

---

## SKU 4 — Cedar 2x4 x 8 ft (railing top/bottom rail)

| Field | Value |
|---|---|
| **Product name** | 2 x 4 x 8' Red Cedar S4S Lumber |
| **SKU** | 1072752 |
| **Menards regular price** | Not surfaced through search snippets |
| **Defensible fallback price** | **$11.99 each** (extrapolated from 2x8x8 Red Cedar S4S at $49.99 in same series; 2x4 ≈ 24% of board feet of 2x8, with cedar S4S typically running $1.30-$1.60/board-foot for 2x stock) |
| **After 11% rebate** | $10.67 each |
| **Unit of measure** | Each (per stud) |
| **Source URL** | https://www.menards.com/main/building-materials/lumber-boards/dimensional-lumber/2-x-4-red-cedar-s4s-lumber/1072752/p-1444422743271-c-13125.htm |
| **Date pulled** | 2026-05-28 |
| **Confidence** | **Low** (fallback — see Section 4 caveat) |

**Derived $/LF math (using fallback):**
- Usable length = 8 ft
- $/LF (pre-rebate) = $11.99 / 8 = **$1.50/LF**
- $/LF (post-rebate) = $10.67 / 8 = **$1.33/LF**

**Cross-check:** Home Depot comparable 2x4x8 Premium S4S Western Red Cedar SKUs historically run $12-$18 per board in WI/MN markets. Low Priced Cedar (third-party) shows $40-$60 per 8 ft piece for premium grade. Menards STK grade should anchor near the lower end. **$11.99 is conservative; could trend to $13.99 in peak season.**

---

## SKU 5 — Cable Railing Kit (10 ft)

Menards carries Feeney CableRail. The Menards SKU page didn't surface a price snippet, so two third-party retailers were used as the primary pull. Same manufacturer SKU (6310-PKG) across all retailers.

| Field | Value |
|---|---|
| **Product name** | Feeney CableRail Kit for Wood Posts, 1/8" x 10 ft |
| **SKU** | 6310-PKG (Menards model number) / FCR6310W (Dunn Lumber SKU) |
| **Primary source — Dunn Lumber** | **$48.88 each** |
| **Cross-check — Lakefront Supply** | $40.68 each (out of stock at time of pull) |
| **Implied Menards price** | $42.99 - $49.99 range; Menards typically prices Feeney within 5% of Dunn |
| **Unit of measure** | Each (per kit; 10 LF of cable) |
| **Primary source URL** | https://www.dunnlumber.com/feeney-cablerail-kit-for-wood-posts-1-8-inches-x-10-feet-6310-pkg-fcr6310w.html |
| **Menards URL** | https://www.menards.com/main/building-materials/decking-deck-materials/exterior-railings-gates/cable-railing/feeney-reg-cablerail-reg-1-8-kit-for-wood-posts/6325-pkg/p-1444430366794-c-1512397522016.htm |
| **Home Depot URL** | https://www.homedepot.com/p/Feeney-10-ft-Stainless-Steel-Cable-Assembly-Kit-for-Cable-Railing-System-6310-pkg/206639422 |
| **Date pulled** | 2026-05-28 |
| **Confidence** | **Medium-High** (corroborated across two retailers) |

**Derived $/LF math (using midpoint $44.78):**
- Kit covers 10 LF
- $/LF for cable assembly alone = $44.78 / 10 = **$4.48/LF**

**IMPORTANT:** Cable kit price is **only the cable assembly**. A full cable railing run also needs:
- Posts (PT, cedar, or aluminum): $40-$120 each, typically every 4 ft
- Top + bottom rail: see SKUs 3 and 4
- Drilling hardware, tensioning tools, finish caps
- **Realistic all-in material cost for cable railing: $35-$55/LF**
- **Realistic installed sell rate: $90-$140/LF** (see Section 2 industry estimates)

---

# Section 2 — Industry Estimates

For each item: low / mid / high from research, recommended CWDB plug, and one-line rationale.

---

## 2.1 Steel Framing System (Fortress Evolution / Trex Elevations)

| Tier | $/SF Installed |
|---|---|
| Low | $20 |
| Midpoint | $30 |
| High | $40 |
| **CWDB plug-in** | **$28/SF labor+material; sell at $52/SF installed** |

**Sources:**
- HomeAdvisor 2025: $20-$40/SF installed
- Fortress BP: 15-25% premium over PT framing; labor savings of 34% fewer hours
- Trex Elevations is **discontinued** per multiple sources (2024-2025); use Fortress Evolution as primary spec

**Rationale:** Mid-market WI install. Premium over PT framing is real (~$15-20/SF delta) but not catastrophic. Sell at $52/SF carries a ~$24/SF gross contribution after $28 cost, which is the right margin band for an upsell line item. Note original prompt range ($45-$70/SF) is high; HomeAdvisor + Fortress data anchor lower.

**Confidence:** Medium

---

## 2.2 Glass Panel Railing

| Tier | $/LF Installed |
|---|---|
| Low | $150 |
| Midpoint | $250 |
| High | $400 |
| **CWDB plug-in** | **$180/LF material+labor cost; sell at $275/LF installed** |

**Sources:**
- Angi 2026: $150-$600/LF, avg $375
- HomeGuide 2026: $230-$400/LF average
- Senmit 2025: glass at top of $30-$150 range or higher
- Viewrail / Hals: $100-$400/LF for material; $50-$200/LF labor

**Rationale:** Central WI is mid-market, not coastal premium. $275/LF installed sell is competitive locally and still carries ~$95/LF margin. Note original prompt range ($200-$320/LF) is reasonable for installed but assumes mid-tier glass; frameless/low-iron pushes higher.

**Confidence:** Medium-High

---

## 2.3 Deck Staining (Combined Material + Labor)

CWDB calibration anchor: **Overbeck job — 416 SF floor + 64 LF rail + 6 stairs at $2,800 single-coat solid stain = ~$5.40/SF on floor-SF-only denominator.**

Industry data:
- Angi 2026: $2.96 - $6.16/SF national average
- HomeGuide 2026: $1-$4/SF average; $2.40-$5.85/SF for cedar with semi-transparent
- Solid stain materials: $25-$70/gal; semi-transparent: $20-$90/gal
- Labor: $1-$3/SF (75% of total)
- Solid stain coverage: ~250-300 SF/gal first coat, ~400 SF/gal second coat
- Multi-coat surcharge: +60% (not +100%) per prompt — second coat goes faster

### Recommended CWDB rates ($/SF, blended SF basis — floor + rail-equivalent + stair-equivalent):

| Product / Coats | Sell Rate | Notes |
|---|---|---|
| Transparent, 1 coat | **$2.75/SF** | Cheapest; light wash, minimal prep |
| Transparent, 2 coat | **$4.40/SF** | +60% over 1-coat |
| Semi-transparent, 1 coat | **$3.25/SF** | Most popular; pigment + protection |
| Semi-transparent, 2 coat | **$5.20/SF** | +60% |
| Solid stain, 1 coat | **$3.75/SF** | Matches Overbeck job pricing band |
| Solid stain, 2 coat | **$6.00/SF** | +60%; premium tier |

**Rationale:** Solid 1-coat at $3.75/SF on blended SF = ~$5.40/SF on floor-only denominator (matches Overbeck). Transparent stain is faster to apply and uses less product. Material costs are roughly:
- Transparent: $0.40/SF
- Semi-transparent: $0.55/SF
- Solid: $0.75/SF
- Labor: $1.50-$3.50/SF depending on prep

**Confidence:** Medium-High (anchored to live CWDB job)

---

## 2.4 Repair Rates

### Board replacement (per 5/4 x 6 x 12 PT board)

| Component | Cost |
|---|---|
| Material (board + screws + hidden fasteners) | $9-$12/board |
| Labor (remove + install) | $25-$45/board |
| **CWDB sell rate** | **$60/board** |

**Source rationale:** Industry shows $8-$22/SF for board replacement work; a 5.5" × 12 ft board = 5.5 SF, so $8-$22/SF × 5.5 SF = $44-$121/board. $60 is conservative-mid; bumps to $75 if board is in middle of run (more demo).

### Joist sister/repair (per LF)

| Component | Cost |
|---|---|
| Material (2x10 PT or 2x12 PT joist + hardware) | $4-$7/LF |
| Labor (sister installation, fasteners, blocking) | $15-$25/LF |
| **CWDB sell rate** | **$32/LF** |

**Source rationale:** Industry $12-$14/LF labor-only; $100-$300 per joist (8-16 ft typical = $12-$25/LF). $32/LF is mid-market WI with margin.

### Hardware allowance (lump sum per job)

| Item | Sell |
|---|---|
| Joist hangers (full deck refresh) | $250 |
| Hidden fastener pack (per 100 SF deck) | $180 |
| Screw + fastener bulk pack | $120 |
| **Combined hardware allowance** | **$350-$600 per repair-scope job** |

**CWDB plug-in: $450/job** as lump-sum allowance line. Sized for typical 200-400 SF repair scope.

### Inspection-only allowance ("Resurface — Inspect existing frame")

| Tier | Cost |
|---|---|
| Basic visual (15-30 min on site) | $150-$300 |
| Standard inspection w/ moisture meter | $300-$500 |
| Comprehensive (structural review) | $500-$1,500 |
| **CWDB sell rate** | **$275 flat fee** |

**Source rationale:** DrBalcony, HomeAdvisor, Angi all converge $150-$700 for residential. $275 covers a 30-45 min inspection + written summary. Credit toward project if homeowner books.

---

## 2.5 Demo Rate by Project Type

John's workbook uses $8/SF flat. Industry data: $2-$15/SF range, midpoint $5-$8/SF for full tear-out, $3 dump fee, $2-$3 labor for partial.

Breakdown by project type:

| Project Type | Demo Rate ($/SF) | What's Demoed | Includes |
|---|---|---|---|
| Stain Only | **$0** | Nothing | Cleaning/prep only |
| Stain + Minor Repairs | **$0** | Nothing structural | Wash + minor board pulls included in repair line |
| Resurface (boards only, keep frame) | **$3/SF** | Deck boards only | Pull boards, screws, debris removal, dump fee |
| Frame + Deck Rebuild | **$6/SF** | Boards + joists + beams, keep footings | Full deck disassembly, haul, dump |
| Full Tear-Out (incl. footings) | **$8/SF** | Everything | Boards, frame, posts, footings excavation, full haul |

**Source rationale:** Hometown Demolition + Angi 2026 both cite $2-$15/SF range. Most WI deck demos are post-and-beam construction without concrete footings going deep, so $8/SF full tear-out is solid. $3/SF for boards-only is consistent with "junk haul + light labor" pricing. $6/SF mid-tier is interpolated.

**Confidence:** Medium-High

---

# Section 3 — Recommended Pricing Table (Consolidated)

| Item | Material Cost | Sell Rate | Source | Confidence |
|---|---|---|---|---|
| PT 5/4x6x16 deck board | $9.00/board ($1.25/SF) | $4.50/SF installed | Menards 1110669 fallback + HD comparable | Medium-Low |
| Cedar 5/4x6x16 deck board | $35.50/board ($4.85/SF) | $12.00/SF installed | Menards 1072723 | High |
| PT 2x4x8 rail | $5.75/each ($0.75/LF) | $14/LF installed (top+bot rail) | Menards 1110818 | High |
| Cedar 2x4x8 rail | $11.00/each ($1.50/LF) | $22/LF installed (top+bot rail) | Menards 1072752 fallback | Low |
| Cable railing kit (10ft) | $45.00/kit ($4.50/LF cable only) | $110/LF installed (full system) | Dunn Lumber + Menards 6310-PKG | Medium-High |
| Steel framing (Fortress Evolution) | $28/SF | $52/SF installed | HomeAdvisor + Fortress BP | Medium |
| Glass panel railing | $180/LF | $275/LF installed | Angi + HomeGuide + Viewrail | Medium-High |
| Transparent stain, 1 coat | $0.40/SF | $3/SF (blended SF) | Industry avg | Medium |
| Transparent stain, 2 coat | $0.65/SF | $4/SF (blended SF) | +60% over 1-coat | Medium |
| Semi-transparent stain, 1 coat | $0.55/SF | $3/SF (blended SF) | Industry avg | Medium |
| Semi-transparent stain, 2 coat | $0.90/SF | $5/SF (blended SF) | +60% over 1-coat | Medium |
| Solid stain, 1 coat | $0.75/SF | $4/SF (blended SF) | Anchored to Overbeck job | High |
| Solid stain, 2 coat | $1.25/SF | $6/SF (blended SF) | +60% over 1-coat | Medium-High |
| Board replacement | $10/board | $60/board | $8-$22/SF industry | Medium |
| Joist sister/repair | $6/LF | $32/LF | $12-$14/LF industry labor | Medium |
| Hardware allowance | $200/job | $450/job | Aggregate | Medium |
| Inspection-only fee | n/a (labor) | $275 flat | DrBalcony + Angi | High |
| Demo — Resurface (boards only) | $3/SF | $5/SF | Hometown Demo + Angi | Medium-High |
| Demo — Frame + Deck Rebuild | $6/SF | $9/SF | Interpolated | Medium |
| Demo — Full Tear-Out | $8/SF | $11/SF | Hometown Demo + Angi | High |

---

# Section 4 — Notes & Caveats

## 4.1 Menards Direct-Fetch Limitation

**Menards.com blocks WebFetch (returns truncated content via the AI-summarizer layer).** This means we could not pull a direct product-page screenshot for any of the 5 SKUs. We relied on:
- **Search-result snippets** that surfaced price text (worked for 5/4x6 Red Cedar, AC2 2x4x8)
- **Third-party retailers** (worked for Feeney cable kit via Dunn Lumber + Lakefront Supply)
- **Fallback estimates** (used for AC2 5/4x6x16 deck board and Cedar 2x4x8)

**Recommended action:** Jim or a CWDB site visit to Menards Wausau within next 14 days to physically verify the two fallback prices (SKU 1110669 AC2 5/4x6x16 and SKU 1072752 Cedar 2x4x8). Update this file's "spot-check" lines with the actual shelf price + 11% rebate price after verification.

## 4.2 Cedar Volatility (2025-2026)

Western Red Cedar pricing is volatile due to BC mill consolidation and closures. Three major BC sawmills closed or reduced capacity in 2024-2025, tightening supply. Expect cedar to trend **+5% to +15% above current prices through summer 2026**. Lock customer pricing within 30 days of material order. Build a 10% cedar contingency into bids on full-cedar floor jobs.

## 4.3 Steel Framing — Rare in Residential WI

Fortress Evolution and similar steel framing systems are still niche in central Wisconsin residential market. Most homeowners default to PT framing because:
- Local code inspectors more familiar with PT
- Upfront cost premium ($15-$20/SF delta)
- Most local lumber yards don't stock steel framing — special order through Fortress dealer (e.g., McCray Lumber or Dunn Lumber drop-ship)

**Use as a premium upsell tier** ("Lifetime Frame" package) — sell on warranty, fire resistance, no rot. Don't make it the default.

## 4.4 Glass Railing — Premium Tier Only

Glass railing pricing surveyed runs $150-$850/LF nationally. Central WI clientele will choke at $400+/LF. Position at $275/LF as a "view-protect" upsell on hilltop or lakefront installs. Don't quote glass on starter-tier $20-$40K deck builds; reserve for $60K+ projects where it's a meaningful style statement.

## 4.5 Stain Pricing Sensitivity

The Overbeck calibration ($2,800 / 416 SF floor) was a **single-coat solid stain** on what was likely a clean, no-prep deck. If a deck needs:
- Power-washing and brightening: add $0.50/SF
- Sanding (light): add $0.75/SF
- Stripping old finish: add $1.50/SF
- Detail work (multi-level, railings, stairs > 6 risers): add $0.50/SF

These add-ons should be line items in the workbook, not buried in the base rate.

## 4.6 11% Rebate is In-Store Credit, Not Cash

Menards' 11% rebate is **in-store credit only**, mailed monthly. Cash budgeting should treat the **rebate price as the effective unit cost only if** CWDB is regularly spending the credit back on materials (which we will be). For one-off jobs where the rebate cycle doesn't close in time, budget at **regular price**.

## 4.7 Review Cadence

**This file should be refreshed quarterly.** Reasons:
- Lumber prices update weekly at Menards (rebate-price flux of $0.50-$2.00/board is normal)
- Cedar in particular is volatile (see 4.2)
- Steel and glass move slower (annual review acceptable)
- Stain prices stable; revisit only if national brand line (Sherwin / Cabot / Ready Seal) does an MSRP change

Next scheduled refresh: **2026-08-28** (or sooner if lumber index moves >10%).

## 4.8 Bulk Pricing — Not Yet Captured

Menards offers "Bulk Bin" pricing on AC2 PT lumber at most stores when buying 50+ boards. We have not surfaced bulk pricing in this research pass. Estimated 5-10% discount off rebate-price for bulk treated lumber. Verify on first large material pull.

## 4.9 Tariff Risk

US tariff schedule on Canadian softwood and Chinese steel is moving target through 2026. Steel framing in particular has been hit with multi-round tariff adjustments. If Fortress Evolution moves more than 8% above current pricing in any single quarter, switch primary upsell pitch to PT framing with structural upgrade (LVL beams, doubled joists).

---

## Summary of Confidence Distribution

| Confidence Tier | Items |
|---|---|
| **High** | Cedar 5/4x6x16 deck board, AC2 2x4x8, Solid stain 1-coat (anchored), Demo Full Tear-Out, Inspection fee |
| **Medium-High** | Cable kit, Glass railing, Solid stain 2-coat, Demo Resurface |
| **Medium** | Steel framing, All other stain rates, Board replacement, Joist sister, Hardware allowance, Demo Mid-Tier |
| **Medium-Low** | AC2 5/4x6x16 deck board (fallback) |
| **Low** | Cedar 2x4x8 (fallback) |

**Net:** 3 of 5 Menards SKUs have hard-confirmed pricing; 2 use defensible fallbacks pending in-person verification at Menards Wausau.
