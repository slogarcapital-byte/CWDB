# SBG Construction Group: Financial Model (Phase A Shared-Services Structure)

**Prepared for:** Jim Slogar (CPA), for the shared-services build-out discussion with Ben Barton and John Garcia
**Prepared by:** CWDB Accounting (acting CPA / controller)
**Date:** 2026-06-17
**Working group name:** SBG Construction Group (Slogar, Barton, Garcia). Individual entity names below are PLACEHOLDERS, none reserved or formed yet.
**Status:** Planning support. Illustrative figures with labeled assumptions. Not filed tax advice. Confirm every number against the partners' actual books before anything is signed.

---

## The structure in brief

**The structure is a SHARED-SERVICES / CAPTIVE-LABOR group, not a merger.** The three existing LLCs stay as the real, customer-facing contractors. Each signs its own jobs, pulls its own permits under its own Dwelling Contractor Certification and Qualifier, carries its own general liability policy, and **keeps its own job profit.** SBG is a shared-services and asset-holding group that the three LLCs buy labor and equipment from. Whoever books more work keeps more money. The thirds do NOT pool the job profit in Phase A.

This is a conservative, reversible structure. It lets the three operators share crews, equipment, and (later) a building without first having to value three unequal companies. Those hard valuation questions get deferred to Phase B.

### The two phases

- **Phase A (now, roughly the next 1 to 2 years), modeled in detail below.** Shared-services co-op. Job profit stays siloed in each LLC. SBG owns the W-2 crews, the equipment, and (later) the real estate, and bills the three LLCs at market rates to use them. SBG reinvests its profit rather than distributing it. Each partner's income is their own LLC's job profit plus a W-2 hourly wage from SBG for hours actually worked.
- **Phase B (roughly 1 to 2 years out), described at a high level in Section 10.** Transition to a true merger where job profit pools and splits one third each. This needs a defined trigger and a valuation and equalization of the three unequal LLCs. We do not model Phase B's dollars here; we only flag its tax and valuation considerations.

---

## How to read this document

Sections 1 through 7 and 9 through 10 are for the full working session with Ben and John. **Section 8 is marked PRIVATE and is for Jim only.** Pull it out before sharing.

Every dollar figure that is not pulled from a verified government source is an **ASSUMPTION** and is labeled as such. Section 9 is the list of what we cannot finalize until the partners' real numbers and the WI DOR answer are on the table.

Verified tax inputs used throughout (so nobody has to take them on faith):

- **Self-employment tax 2026:** 15.3% total. 12.4% Social Security on net SE earnings up to the $184,500 wage base, plus 2.9% Medicare with no cap. (VERIFIED 2026-06-17, irs.gov "Self-employment tax" + ssa.gov Contribution and Benefit Base.)
- **SE tax mechanics:** you pay SE tax on 92.35% of net self-employment profit, and you deduct half of the SE tax above the line for income tax. (VERIFIED 2026-06-17, irs.gov Schedule SE rules.)
- **Partners are not employees of their own partnership.** A bona fide partner who works in the partnership is a self-employed person, not a W-2 employee. Pay for that work is a guaranteed payment under IRC 707(c) and stays subject to self-employment tax. (VERIFIED 2026-06-17, Rev. Rul. 69-184; irs.gov LB&I Concept Unit "Self-Employment Tax and Partners"; IRS Pub. 541 Partnerships.) This single rule drives the entity recommendation in Section 1.
- **Wisconsin sales tax on leases and rentals of tangible personal property:** Wis. Stat. 77.52(1) imposes sales tax on the sale, lease, OR rental of tangible personal property at the 5% state rate (plus any county rate, 0.5% in Marathon County). (VERIFIED 2026-06-17, revenue.wi.gov "What Is Taxable" + DOR Pub. 207.) This drives the new equipment-lease exposure in Section 3.
- **Wisconsin contractor-as-consumer rule:** a contractor improving real property is the consumer of the materials it installs and pays sales/use tax on those materials at purchase; the labor charge to improve real property is generally not taxable to the homeowner. (VERIFIED framework, revenue.wi.gov DOR Pub. 207; consistent with `docs/legal/construction-setup/tax-treatment-memo.md`.)
- **FICA (Social Security + Medicare) employer half:** 7.65% of wages (6.2% Social Security up to the wage base plus 1.45% Medicare, no cap). The employee pays a matching 7.65% withheld from the wage. (VERIFIED 2026-06-18, irs.gov "Topic No. 751" + ssa.gov Contribution and Benefit Base.) This is the FICA split that the S-corp/W-2 structure creates and is central to the rate build-up in Section 6.
- **FUTA (federal unemployment) 2026:** 6.0% gross on the first $7,000 of each worker's wages, reduced by a 5.4% credit for timely state UI payments to a net **0.6% on the first $7,000** (max $42/yr per worker). The $7,000 base is unchanged since 1983. Wisconsin is NOT a 2026 credit-reduction state, so the full 0.6% applies. (VERIFIED 2026-06-18, irs.gov Topic No. 759 / Form 940; dol.gov ETA FUTA credit-reduction list.)
- **Wisconsin UI (SUTA) 2026:** taxable wage base **$14,000** per worker. New-employer rate for the **construction industry is 2.50%** (payroll under $500,000) or 2.70% (payroll $500,000 and over). New-employer non-construction is 3.05% under $500,000. Schedule D is in effect for 2026. Construction's new-employer rate is set higher than non-construction by statute. (VERIFIED 2026-06-18, dwd.wisconsin.gov "2026 Tax Rate Schedule for Employers"; corroborated by Bloomberg Tax 2026-01 WI UI announcement.) Construction new-employer SUTA max is 2.50% x $14,000 = $350/yr per worker.
- **Wisconsin workers' compensation, residential carpentry:** WCRB class code **5645 "Carpentry, Construction of Residential Dwellings Not Exceeding Three Stories in Height" carries a rate of $8.53 per $100 of payroll, effective 10/01/2025**, $900 minimum premium. Wisconsin is a state-rate (non-NCCI) jurisdiction: the Wisconsin Compensation Rating Bureau sets the manual rate with the Commissioner of Insurance, so the same class code carries the same rate at every carrier (carriers compete on dividends/scheduling, not base rate). (VERIFIED 2026-06-18, wcrb.org Class Code Lookup, code 5645.) The deck-construction work falls under 5645; an experience-modified or differently classified figure is an ASSUMPTION and is labeled where used.
- **Wisconsin WC owner/officer election-out:** members of an LLC are not counted as employees and a policy generally excludes them unless specifically endorsed in; in a closely held corporation (fewer than 10 shareholders) up to **two** corporate officers may exclude themselves by policy endorsement and a filed Corporate Officer Option Notice (WKC-7602). Excluded officers still count toward the employee count that triggers the coverage requirement. (VERIFIED 2026-06-18, dwd.wisconsin.gov WKC-13441 "Corporate Officers and Worker's Compensation" + WKC-13333 coverage exceptions.) NOTE the two-officer cap is a real wrinkle for a three-partner S-corp, flagged in Section 6.
- **Wisconsin income tax 2025 brackets (latest published, used as the 2026 proxy):** married filing jointly is 3.50% to $19,580, then 4.40% to $67,300, then 5.30% to $431,060. Single is 3.50% to $14,680, 4.40% to $50,480, 5.30% to $323,290. (VERIFIED 2026-06-17, revenue.wi.gov Tax Rates.)
- **Federal ordinary rates** referenced at the household level are 22% and 24% marginal; this is standard published structure but the exact 2026 bracket dollars are NEEDS VERIFICATION and do not change the conclusions here.

---

## 1. Entity and Tax Structure

### LEAD WITH THIS: SBG-Labor should be taxed as an S-CORP, not a partnership

The partners want each of the three of them to draw an **hourly W-2 wage from SBG** for the hours they personally work. That single requirement decides the tax election for the labor company, and it cuts against the obvious default.

Here is the trap. If SBG-Labor is a normal multi-member LLC taxed as a **partnership**, then a partner **cannot be a W-2 employee of it.** A bona fide partner who works in the partnership is self-employed as a matter of law, and pay for that work is a **guaranteed payment** under IRC 707(c), which is still hit with the full 15.3% self-employment tax and cannot go on a W-2. (VERIFIED 2026-06-17, Rev. Rul. 69-184; irs.gov LB&I Concept Unit "Self-Employment Tax and Partners"; IRS Pub. 541.) So a partnership literally cannot deliver the "hourly W-2 wage" the partners asked for. It would deliver a guaranteed payment instead, taxed worse and reported on a K-1, not a W-2.

**An S-corporation can.** An S-corp's owner-employees ARE employees. They go on a real W-2, the company runs payroll, and only the W-2 wage carries payroll tax. Any profit above the reasonable wage can come out as a distribution that is not subject to self-employment or payroll tax. That is exactly the mechanism the partners described (hourly W-2 wage now, reinvest the rest), and it also helps manage payroll and SE tax going forward.

**Recommendation: elect S-corp treatment for SBG-Labor** so the three partners can be W-2 owner-employees. (Mechanics: form the LLC, then file Form 2553 to elect S-corp; Form 8832 may be relevant depending on path. Confirm timing with the CPA. The election can be made effective for a chosen tax year within the IRS window.)

### The other two SBG entities can stay partnership-taxed

- **SBG-Equipment:** owns the equipment bought with the equal cash and leases it to the three LLCs. There is no W-2-wage requirement here (it holds assets and bills rent), so a plain **multi-member LLC taxed as a partnership** is the simple, flexible choice. Partnership taxation also handles depreciation and asset basis cleanly across three owners.
- **SBG-RealEstate:** formed but **DORMANT for now.** No facility purchased yet; the partners use their own space. When it does buy real estate, a **partnership-taxed multi-member LLC** is the standard, correct holding vehicle for appreciating real property (you generally do NOT want real estate inside an S-corp, because pulling appreciated property out of an S-corp triggers gain, whereas a partnership can distribute property far more flexibly). Form it now if the partners want the name reserved, but it does nothing and files nothing until it holds an asset or opens a bank account.

### Who owns the SBG entities (FLAG FOR THE ATTORNEY)

Recommend the **three individuals own the SBG entities directly**, one third each, NOT through their existing LLCs. Two reasons:

1. **S-corp eligibility.** An S-corp may only be owned by individuals and certain trusts. It cannot be owned by another LLC or partnership. (VERIFIED principle, IRC 1361(b) eligible-shareholder rules; confirm current text at irs.gov before filing.) If the partners tried to own SBG-Labor through Barton Builders LLC and John Garcia Construction LLC, the S-election would be impossible. Direct individual ownership keeps the S-election available.
2. **Clean separation of the operating LLCs from the shared-services group.** The existing LLCs are the customer-facing contractors that carry the construction liability and keep the job profit. Keeping SBG owned at the individual level, beside the LLCs rather than under them, keeps the asset-holding and labor functions in their own boxes. (Confirm the final ownership chain with the WI attorney.)

A wrinkle to raise with the attorney: for the equipment and real-estate partnerships, individual ownership versus LLC ownership is a liability-and-basis question, not a tax-eligibility one (partnerships can have either as partners). The S-corp eligibility constraint only forces individual ownership for SBG-Labor. The attorney may still recommend individual ownership across all three for consistency, or may prefer holding-LLC ownership of the two partnerships for an extra liability layer. That is a legal call.

### Reasonable salary for the partner-employees of SBG-Labor

Because SBG-Labor is an S-corp and the partners are owner-employees, the IRS reasonable-compensation rule applies: an S-corp owner who works in the business must pay themselves **reasonable compensation** for the work actually done before taking any tax-favored distribution. You cannot pay a $5,000 wage and distribute the rest to dodge payroll tax.

For SBG-Labor this is actually straightforward, and it lines up with how the company already has to price labor. The partners are doing skilled field construction. The partners have decided to pay themselves the **market wage of $80.00/hr** for the hours they personally work (Section 6). That is a genuinely defensible "reasonable compensation" figure for a skilled, working construction owner, and paying it actually STRENGTHENS the S-corp reasonable-salary position: nobody can argue the owner-employees are understating wages to dodge payroll tax when the wage is set at full market. In Phase A this is doubly safe because SBG is **reinvesting its profit, not distributing it**, so there is little or no distribution sitting next to the wage. When there is little distribution, there is little reasonable-comp risk: nearly all of what a partner takes out of SBG-Labor IS the W-2 wage. The reasonable-comp pressure only sharpens later, in Phase B, if SBG starts making large distributions on top of the wage. Clean payroll records at the $80 market wage now make the position defensible later.

The trade-off the partners should hear plainly (also flagged in Section 6 and Section 8): a rich $80/hr W-2 wage is their choice and is fully defensible, but a HIGHER wage MAXIMIZES payroll tax and shifts income out of siloed, LLC-level job profit and into payroll-taxed wages. That partially offsets the S-corp distribution benefit, because the S-corp savings come precisely from money that leaves as distribution rather than wage. Setting the wage at market is the cautious, audit-proof choice; setting it lower would save payroll tax but weaken the reasonable-comp position. Present both sides; the $80 figure is the partners' call.

### Filing and setup checklist for SBG (CONFIRM with WI attorney and CPA before filing)

1. Reserve the names and file Articles of Organization for SBG-Labor, SBG-Equipment, and SBG-RealEstate with the Wisconsin Department of Financial Institutions (Wis. Stat. ch. 183).
2. New EIN for each entity.
3. **SBG-Labor: file Form 2553 to elect S-corp** treatment; set up payroll (withholding, payroll filings, W-2s, WI unemployment registration, workers' comp on the crews). Owner-employees go on W-2.
4. SBG-Equipment and SBG-RealEstate: multi-member operating agreements, one third each, partnership taxation (default, no election needed).
5. Written intercompany agreements: a labor-services agreement and an equipment-lease agreement between each LLC and the relevant SBG entity, at market rates (Section 4).
6. **SBG-Equipment registers for a WI seller's permit and starts charging/remitting sales tax on the equipment lease invoices** once the DOR position in Section 3 is confirmed.
7. The three existing LLCs keep their own GL policies, Dwelling Contractor Certifications, and Qualifiers, and keep signing their own jobs and pulling their own permits. Nothing about SBG changes that.

---

## 2. Phase A Compensation Model

In the shared-services structure, job profit does not pool, so there is nothing to split into thirds, and there are no management draws or sales credits out of a shared pool.

The Phase A pay stack is just two layers, plus deliberate reinvestment:

### The Phase A pay stack

1. **Own-LLC job profit (siloed).** Each partner's primary income is the profit their OWN LLC makes on the jobs it signs and delivers. Whoever books and completes more work keeps more. This profit never touches SBG. It is reported on that partner's own LLC return (disregarded Schedule C today, or that LLC's own election later).
2. **SBG W-2 hourly wage for hours worked.** When a partner personally works field hours on a crew, SBG-Labor pays them a **W-2 wage of $80.00/hr (market)** for those hours (Section 6). This is real payroll: withholding, payroll tax, a W-2 at year-end. SBG then bills the LLC a HIGHER loaded rate for that labor (the $80 wage plus employer payroll tax, WC, overhead, and margin, built up in Section 6), so the wage is the partner's take and the loaded difference funds SBG's burden and reinvestment.
3. **SBG reinvests its profit (no distribution yet).** SBG bills the LLCs at market rates (above its own cost), so SBG runs a profit. In Phase A, that profit is **retained and reinvested** into more equipment and an operating reserve, NOT distributed one third to the partners. So no partner takes an SBG profit distribution in Phase A. Their SBG income is only the W-2 wage.

### What this means for each partner's total Phase A income

> Partner total income (Phase A) = (their own LLC's job profit) + (their SBG W-2 wage for hours they personally worked).

There is no third "distribution" line yet. The thirds matter only for **ownership of SBG's growing asset base** (the equipment, the reserve, and later the building), which the partners own one third each and which they monetize later, in Phase B or on a future sale.

### Each partner keeps their own customers and lead sources

Each LLC keeps its own customers, brand, and way of finding work. None of it is contributed to SBG, which does not market or own any customer relationship; it only supplies labor and equipment. Whatever each LLC brings in, that LLC keeps in Phase A. Any prior lead-sharing arrangement among the partners is being wound down, so each LLC runs its own customer acquisition. How each partner's pre-existing marketing or customer assets get valued if they are ever brought into the merged pool is a Phase B question (Section 10), not a Phase A one.

### Why this is fair without pooling

| Scenario | What happens in Phase A |
|---|---|
| Ben books 6 jobs this month, Jim books 2 | Ben's LLC keeps Ben's 6-job profit; Jim's LLC keeps Jim's 2-job profit. Nobody subsidizes anybody. |
| Jim works 50 field hours on Ben's crew | Jim earns the $80/hr W-2 wage from SBG for those 50 hours; SBG bills Ben's LLC the loaded rate for that labor. Jim's hours are paid, Ben's job bears the cost. |
| SBG buys a $30,000 trailer-mounted setup | All three own a third of that asset, funded from the equal cash and retained SBG profit, regardless of who used it most. |

Equity in SBG governs the shared assets. Income comes from each partner's own book of work plus paid hours. The two are kept separate on purpose.

---

## 3. Wisconsin Sales/Use Tax on the Equipment Leases (CRITICAL NEW EXPOSURE)

This is the most important new tax item in the whole restructure, and it is NOT covered by any prior decision.

### The exposure

Jim previously decided that **no Wisconsin sales tax applies to CWDB revenue** (lead fees and construction/staining/resurfacing). That decision is correct for those items and is not being reopened. It rests on two things: lead referral is not an enumerated taxable service, and construction labor that improves real property is nontaxable to the homeowner under the **contractor-as-consumer rule** (the contractor pays tax on materials at purchase instead). (VERIFIED framework, revenue.wi.gov DOR Pub. 207.)

**That decision does not reach the new SBG structure, because renting equipment is a different kind of transaction.** When SBG-Equipment rents tangible equipment to the three LLCs, that is a **lease or rental of tangible personal property**, which Wisconsin taxes directly. Wis. Stat. 77.52(1) imposes sales tax on the sale, **lease, or rental** of tangible personal property at the 5% state rate, plus the county rate (0.5% in Marathon County, for a 5.5% combined rate). (VERIFIED 2026-06-17, revenue.wi.gov "What Is Taxable"; DOR Pub. 207.) There is no contractor-as-consumer shelter here, because SBG-Equipment is not improving anyone's real property. It is renting out machines.

### What this means operationally

- **SBG-Equipment likely must register for a Wisconsin seller's permit and charge/remit WI sales tax on the equipment-lease payments it bills the three LLCs.** The lease invoices to each LLC would carry a separate 5.5% sales-tax line, collected from the LLC and remitted to the DOR.
- This is a real new compliance task: a seller's permit, periodic sales-tax returns, and tax collected on every intercompany equipment invoice. It is not optional if the rentals are taxable, and related-party rentals are not exempt just because the parties are commonly owned.
- **There may be a planning angle worth a DOR/CPA look:** how SBG-Equipment bought the equipment (did it pay sales tax at purchase, or buy under a resale/lease exemption because it intends to re-lease), and whether a sale-for-resale or lease-for-lease treatment changes who bears the tax. Generally, property bought to be re-leased can be purchased exempt, with tax then collected on the lease stream. Confirm the correct mechanism with the CPA so SBG-Equipment is not double-taxed (once at purchase and again on the lease).
- **CONFIRM WITH THE WI DOR before SBG-Equipment issues its first lease invoice.** This is a written-determination-worthy question precisely because it is an intercompany, commonly-owned rental, and getting the registration and rate right from invoice one avoids back-tax and penalty exposure. NEEDS VERIFICATION: the exact taxability of THIS related-party rental and the correct purchase-side treatment, confirmed with the DOR.

### What about the leased LABOR (SBG-Labor billing the LLCs)?

Different answer, and generally the better one. Supplying labor / personnel is **not** a lease of tangible personal property, so the 77.52(1) TPP-rental tax does not apply to SBG-Labor's charges the way it applies to equipment. Wisconsin taxes only specifically enumerated services, and a contractor supplying construction labor to another contractor for real-property work is generally outside the enumerated taxable services. So SBG-Labor's labor billings to the LLCs are **most likely not subject to sales tax.** That said: (a) make sure SBG-Labor is billing for labor/personnel and not bundling taxable equipment into the same line, because a mixed invoice can pull the whole charge into tax, and (b) **confirm with the DOR** that the specific labor-supply arrangement is not characterized as a taxable service. NEEDS VERIFICATION, but the expected answer is not taxable.

### Bottom line for Section 3

Equipment lease: **probably taxable, register and charge, confirm with DOR.** Labor supply: **probably not taxable, confirm with DOR.** Construction to homeowners and lead fees: unchanged, not taxable per Jim's standing decision. Keep the three invoice types clean and separate so the taxable equipment rent never gets blended with the nontaxable labor or the nontaxable construction revenue.

---

## 4. Transfer Pricing and Related-Party Documentation

Because the three LLCs and the SBG entities are commonly owned, every dollar SBG bills an LLC is a **related-party transaction.** The IRS and the WI DOR can both look through related-party pricing that is off-market. The defense is simple: charge real market rates and document them in writing. This protects the tax positions AND the liability veil (an asset-holding entity that does not charge market rent looks like an alter ego).

### The labor billing rate must be fully loaded

SBG-Labor cannot bill the LLCs at bare wage cost. The labor rate it charges must cover, at minimum:

- the W-2 wages paid to the worker,
- the employer payroll taxes (employer half of Social Security and Medicare, FUTA, WI unemployment),
- workers' compensation insurance on the crews,
- SBG-Labor's own overhead (payroll admin, supervision, small tools, software), and
- a margin, so SBG-Labor runs the intended profit it reinvests.

This is the loaded rate built up in Section 6. Billing at cost would defeat the whole structure (SBG would never accumulate the reinvestment capital) and would also look non-arm's-length.

### The equipment lease rate must be at market

SBG-Equipment should lease each piece of equipment to the LLCs at a **market rental rate**, benchmarked to what a third-party equipment-rental house would charge for the same machine, prorated to the usage period. Market rate, not cost recovery, is what makes the lease defensible to the IRS and the DOR, and it is the rate the 5.5% sales tax then applies to.

### Written agreements are mandatory

- A **labor-services agreement** between SBG-Labor and each LLC: rate, billing cadence, who supervises, who carries WC.
- An **equipment-lease agreement** between SBG-Equipment and each LLC: per-item or per-day rates, who insures, who maintains, sales-tax handling.
- (Future) a **lease agreement** between SBG-RealEstate and the users once it holds property.

These agreements do three jobs at once: they set defensible transfer prices, they document the entities as genuinely separate (veil protection), and they give the bookkeeper a clean basis for the intercompany invoices. Without them, the whole structure is just money moving between commonly-owned pockets, which is the weakest possible position in an audit or a lawsuit.

---

## 5. Illustrative SBG Billing Model (Phase A)

There is no combined-company P&L in Phase A, because the job profit lives in three separate LLCs, not in SBG. SBG is a **cost-and-asset center**, not a profit pool. What follows is SBG's own internal economics: what it bills the LLCs, what that costs SBG, and what the retained margin funds.

All figures are ASSUMPTION until real crew size, wages, and equipment lists replace them.

### 5.1 SBG-Labor economics (the markup on labor)

Assume a starting crew plus the three partners working billable field hours. SBG-Labor bills the LLCs the loaded rate from Section 6 and pays out wages plus employer burden. This rerun uses the **partner** rate (the $80 market wage is specifically the partners' wage). The crew rate is built up the same way from the lower crew wage and produces a lower loaded number per Section 6.

The single most important thing to get right here is the **denominator.** SBG pays the partner for every PAID hour, but it can only bill the LLCs for the BILLABLE hours that actually land on a job. The cost figures from Section 6 ($105.16 WITH WC, $98.34 NO WC) are cost per PAID hour. The billing rate ($145) is per BILLABLE hour. You cannot subtract one from the other directly, or you double-count the non-billable paid time as if it were free. The correct comparison converts the paid-hour cost up to a billable-hour cost at the ~85% utilization assumption (Policy A, Section 6), then subtracts.

Assumptions (partner labor, WC loaded, the rate the LLCs realistically pay since the crews always carry WC; Policy A, ~85% billable utilization):
- Loaded billing rate to the LLCs: **$145/hr** (Section 6, recommended WITH WC).
- Direct W-2 wage paid to the partner: **$80/hr (market)** (Section 6).
- SBG-Labor cost per PAID hour (employer FICA 7.65% = $6.12, UI FUTA+WI SUTA ~$0.22, WC code 5645 8.53% = ~$6.82, plus ~$12/hr overhead, on top of the $80 wage): **~$105.16/hr** (VERIFIED component rates, Section 6; the per-hour UI and overhead figures are assumptions on annual hours).
- SBG-Labor cost per BILLABLE hour (the $105.16 paid-hour cost spread over 85% billable utilization, $105.16 / 0.85): **~$123.72/hr** (Section 6 utilization step). This is the figure that compares to the $145 billing rate, because both are now per billable hour.
- **SBG-Labor margin per billable hour: about $21/hr** (bill $145, cost ~$123.72; ~17% on the billable-hour cost basis). The margin is taken on the per-BILLABLE-hour cost (~$123.72), not the per-PAID-hour cost (~$105), so the two denominators are not mixed.

| Annual billable field hours (all workers) | SBG-Labor billings to LLCs ($145/hr) | SBG-Labor cost (~$123.72/billable hr) | **SBG-Labor retained margin** |
|---:|---:|---:|---:|
| 3,000 (slow Phase A) | $435,000 | ($371,000) | **~$64,000** |
| 5,000 (base Phase A) | $725,000 | ($619,000) | **~$106,000** |
| 7,000 (busy Phase A) | $1,015,000 | ($866,000) | **~$149,000** |

Read this carefully: those billings are an **expense to the LLCs** (they pay SBG to staff their jobs) and **revenue to SBG-Labor.** The margin row is what SBG-Labor keeps to reinvest. It is NOT distributed to the partners in Phase A. The partners' SBG income is the $80/hr W-2 wage already inside the cost line, not this margin. The cost column uses the **billable-hour** cost of ~$123.72 (not the ~$105.16 paid-hour cost), because the billings are billable hours times $145, so the cost has to be on the same billable-hour basis or the margin is overstated. A crew billed at the lower crew rate pulls the blended billings down, so treat these as the all-partner-hours ceiling.

### 5.2 SBG-Equipment economics (the lease income)

SBG-Equipment buys equipment with the equal cash and leases it to the LLCs at market rates.

Assumptions:
- Equipment fleet funded at roughly **$60,000 to $120,000** of purchases (Section 7).
- Blended market lease yield: **~30% of equipment value per year** in rental billings (ASSUMPTION; third-party rental houses commonly recover the machine's value in roughly 3 to 4 years of rental, plus they sell the used machine after).
- So on, say, a $90,000 fleet: **~$27,000/yr in lease billings** to the LLCs, before the 5.5% sales tax that SBG-Equipment collects on top and remits to the DOR.
- Against that, SBG-Equipment carries depreciation, maintenance, and insurance on the fleet (ASSUMPTION ~$10,000 to $14,000/yr combined), leaving a modest retained margin that also reinvests.

| Equipment fleet value | Annual lease billings (~30%) | + 5.5% WI sales tax collected (remitted to DOR) | SBG-Equipment carrying cost (ASSUMPTION) | **Retained margin** |
|---:|---:|---:|---:|---:|
| $60,000 | $18,000 | $990 | ($8,000) | **~$10,000** |
| $90,000 | $27,000 | $1,485 | ($12,000) | **~$15,000** |
| $120,000 | $36,000 | $1,980 | ($16,000) | **~$20,000** |

The sales-tax column is **not SBG income**; it is collected from the LLCs and paid straight to the DOR. It is shown only so nobody forgets it has to be billed and remitted (Section 3).

### 5.3 What the reinvested profit funds

In Phase A, the combined SBG retained margin (labor margin + equipment margin) is deliberately **not distributed.** It funds:

1. **More equipment**, so the fleet grows and the LLCs stop renting from outside houses.
2. **The operating reserve / payroll float** (Section 7), so SBG can make weekly payroll before the LLCs pay their invoices.
3. **The eventual real-estate down payment**, when SBG-RealEstate wakes up and buys a shop/yard.

So in base Phase A, SBG-Labor throwing off ~$106,000 of margin (corrected to the billable-hour cost basis, Section 5.1) and SBG-Equipment ~$15,000 is **~$121,000 of reinvestment capacity per year** (ASSUMPTION, base case, all-partner-hours ceiling; a crew-heavy mix at the lower crew rate reduces both the billings and this margin), all retained inside SBG and owned one third each. That is the engine that builds the shared asset base the partners co-own, without any of them having to write a big check beyond the equal cash. The ~$106,000 labor margin, computed against the per-BILLABLE-hour cost of ~$123.72, is the number to plan reserves and equipment purchases against.

### 5.4 The key point to say out loud

**Each LLC keeps its own job profit.** SBG does not have the job margins. If Ben's LLC runs a $25,000 deck at 35% gross, that ~$8,750 of gross margin is Ben's LLC's, minus what Ben's LLC pays SBG for the labor and equipment it used. SBG only ever earns the markup on labor and the rent on equipment. In Phase A, SBG is a shared cost-and-asset center that happens to run a reinvested surplus, not a profit pool. The pooling is Phase B.

---

## 6. The Loaded Labor Rate (rebuilt from the $80 market wage)

The partners decided that all three of them (Jim, Ben, John) draw a **W-2 wage of $80.00/hr (market)** from SBG-Labor for the hours they personally work. That is the wage INPUT. This section derives the **billable rate** SBG-Labor must charge the operating LLCs for that partner labor, built up from the $80 wage with employer payroll tax, unemployment, workers' comp, overhead, and a reinvestment margin. Two layers now run on separate numbers: the wage ($80, paid to the partner on a W-2) and the billing rate (higher, charged to the LLC). Getting the billing rate right matters because it sets the intercompany transfer price AND has to cover real employer burden so SBG is not billing below cost.

### The W-2/S-corp split changes the payroll-tax math (read this before the table)

A working owner taxed as self-employed pays the full **15.3% self-employment tax** on their labor earnings. Going W-2 through SBG-Labor (the S-corp) splits that 15.3% into two halves:

- **7.65% EMPLOYER FICA** (6.2% Social Security up to the wage base + 1.45% Medicare). SBG pays this on top of the wage, so it **loads the billable rate.**
- **7.65% EMPLOYEE FICA**, withheld from the partner's $80 wage. The partner bears it out of the wage. It is the worker's cost, **NOT a billable-rate cost**, so it does NOT appear in the build-up below.

So only the employer 7.65% enters the rate. (VERIFIED 2026-06-18, irs.gov Topic No. 751.) This split, plus a market wage, is exactly why the S-corp election is worth the payroll complexity.

### Build-up from the $80 wage (per billable hour)

| Build-up component | Amount/hr | Basis |
|---|---:|---|
| Base W-2 wage (the partners' decided market wage) | $80.00 | Decided input. Market wage for a skilled working owner; this becomes the W-2 wage and anchors reasonable comp. |
| Employer FICA (7.65% of $80) | $6.12 | VERIFIED 2026-06-18, irs.gov Topic No. 751. The employer half only; the employee 7.65% is withheld from the wage and is NOT a rate cost. |
| FUTA + WI SUTA (federal + state unemployment) | $0.22 | VERIFIED rates; per-hour is an ASSUMPTION on ~1,800 paid hrs/yr. FUTA 0.6% x $7,000 = $42/yr; WI construction new-employer SUTA 2.50% x $14,000 = $350/yr; both capped, so ~$392/yr / 1,800 hrs = ~$0.22/hr. Falls toward zero once a worker passes the wage caps. |
| Workers' comp, residential carpentry code 5645 (8.53% of $80) | $6.82 | VERIFIED 2026-06-18, WCRB code 5645 = $8.53/$100 payroll, eff. 10/01/2025. State-set rate. ASSUMPTION: no experience-mod yet (new entity starts near manual). |
| SBG overhead (supervision, admin, payroll + S-corp compliance, software, small tools) | $12.00 | ASSUMPTION; loaded over paid hours. |
| **Loaded cost per PAID hour (WITH WC)** | **~$105.16** | Sum of the above. This is SBG's true cost for ONE PAID hour of partner time, whether or not that hour is billable. |
| Utilization step: cost per BILLABLE hour ($105.16 / 0.85) | **~$123.72** | Policy A: SBG pays the partner for ALL clocked hours but bills only the ~85% that land on a job, so the paid-hour cost must be recovered over fewer billable hours. This is the cost that the billing rate has to beat. (ASSUMPTION: 85% billable utilization; see the sensitivity table below.) |
| Reinvestment margin (~$21, ~17% on the billable-hour cost) | ~$21 | ASSUMPTION. SBG must earn a return to build the shared asset base it owns one third each. Margin is taken on the ~$123.72 billable-hour cost, not the ~$105.16 paid-hour cost. |
| **= Recommended billable rate, WITH WC** | **~$145/hr** | $123.72 + ~$21 = ~$145. Round, clean, defensible. The number the LLCs budget into job cost for partner labor. The rate now foots: paid-hour cost, up to billable-hour cost at 85% utilization, plus margin. |

### The WC election-out alternative (partners only)

In Wisconsin, LLC members are not counted as employees and corporate officers of a closely held corporation can **elect out of WC coverage on themselves** by policy endorsement and a filed Corporate Officer Option Notice (WKC-7602). (VERIFIED 2026-06-18, dwd.wisconsin.gov WKC-13441.) If the partners elect out, the $6.82/hr WC line drops OFF the partner rate (the partner is choosing to carry their own injury risk personally). Rebuilding without WC:

| Build-up component | Amount/hr |
|---|---:|
| Base W-2 wage | $80.00 |
| Employer FICA (7.65%) | $6.12 |
| FUTA + WI SUTA | $0.22 |
| Workers' comp | $0.00 (elected out) |
| SBG overhead | $12.00 |
| **Loaded cost per PAID hour (NO WC)** | **~$98.34** |
| Utilization step: cost per BILLABLE hour ($98.34 / 0.85) | **~$115.69** |
| Reinvestment margin (~$19, ~17% on the billable-hour cost) | ~$19 |
| **= Recommended billable rate, partners elected out of WC** | **~$135/hr** |

Same logic as the WITH-WC table: $98.34 paid-hour cost, divided by 0.85 to ~$115.69 per billable hour, plus ~$19 margin, foots to ~$135. The margin is taken on the billable-hour cost, not the paid-hour cost.

**Two real wrinkles on electing out.** (1) The closely held exclusion is capped at **two** corporate officers, and SBG-Labor has **three** partner-officers, so all three cannot exclude under that provision as written; confirm the mechanism (the LLC-member exclusion may reach the third, or the structure may need a different path) with the WC carrier and the attorney before relying on a three-way election-out. (2) **The crews (non-owners) ALWAYS carry WC**; election-out is a partner-only choice and never applies to employees. So even in the elected-out scenario, crew labor is billed at the WC-loaded build-up (Section's crew note below).

### Recommendations

- **SBG-Labor bills the LLCs ~$145/hr for partner field labor (WITH WC), or ~$135/hr if the partners elect out of WC on themselves.** This is the transfer price and the number the LLCs budget into their job costs. Recommend the **$145 WITH-WC rate as the primary** unless and until the three-officer election-out is confirmed workable, because it is the conservative, fully-covered number and keeps the partners insured.
- **The partner W-2 WAGE is $80/hr (market)**, run through real payroll, with 7.65% employee FICA and income tax withheld from it.
- **The wage is $80 and the derived billing rate is ~$145 (or ~$135 if partners elect out of WC).** The full 15.3% SE tax is replaced by the 7.65%/7.65% employer/employee FICA split.
- **Get all three partners on this math before the first intercompany invoice.** If Ben and John see "$145/hr vs an $80 wage" and think it is a huge markup, walk them through the full ~$65 gap on a per-billable-hour basis: ~$13 is real employer burden (FICA + UI + WC), ~$12 is overhead, ~$19 is the non-billable paid time (the utilization load, i.e. SBG pays the partner for drive/shop/weather/quoting hours that no LLC is billed for, so those costs get recovered across the billable hours), and only ~$21 is the reinvested margin they each own a third of. Most of the gap is cost, not profit.

### Utilization sensitivity (the real break-even)

The recommended ~$145 (or ~$135) **already bakes in ~85% billable utilization** (Policy A, the build-up tables above). It does NOT assume every paid hour is billable. Drive time, shop/loading time, weather days, quoting, and PTO are PAID but not billable to a job, and the $123.72 billable-hour cost already spreads that non-billable paid time across the 85% of hours that do land on a job. This table shows what happens if real utilization comes in above or below the 85% assumption: above 85% the same paid-hour cost spreads over MORE billable hours, so the cost per billable hour falls and the margin at $145 WIDENS; below 85% the cost per billable hour rises and the margin THINS. It shows Jim the sensitivity so he can see how much the margin moves with the season, not a claim that $145 only earns margin near 100%.

The "break-even billable rate" column is the PAID-hour cost (~$105.16 WITH WC, ~$98.34 NO WC) spread over the billable share, i.e. paid-hour cost / utilization. The 85% row is the basis for the recommended rates.

| Billable utilization | Break-even billable rate, WITH WC (paid-hour cost ~$105.16 spread over billable share) | At 20% margin | Break-even, NO WC (paid-hour cost ~$98.34 spread) | At 20% margin |
|---|---:|---:|---:|---:|
| 100% (every paid hr billable) | $105.16 | ~$126 | $98.34 | ~$118 |
| 85% billable (the recommended-rate basis) | $123.72 | ~$148 | $115.69 | ~$139 |
| 75% billable | $140.21 | ~$168 | $131.12 | ~$157 |

Read this way: at the **85% utilization** the recommended rate is built on, the WITH-WC cost per billable hour is ~$123.72 and **$145 earns its intended ~$21 (~17%) margin.** A round $148 would lift that to a full 20% margin at 85%, which is why $145 is best read as a slightly conservative, ~17%-margin rate at the planned utilization, not a break-even one. If real utilization runs ABOVE 85% (a busy stretch with little drive/shop/weather drag), the cost per billable hour drops below $123.72 and the margin at $145 WIDENS past ~17%. If SBG runs at only 75% billable (a real risk in a Wisconsin season with weather and winter gaps), the cost per billable hour climbs to ~$140.21 and $145 leaves almost no margin, so the rate would need to climb to ~$168 to hold a 20% margin, OR SBG accepts the thinner margin, OR SBG pays the partners only for billable hours (Policy B, below). Decide the utilization policy explicitly; it is the difference between $145 being a healthy ~17%-margin rate and a near-break-even one.

### Two pay policies (Jim's choice), and why $145 is the conservative default

The whole utilization question reduces to one policy decision: **does SBG pay the partners for all clocked hours, or only for hours billed to a job?**

- **Policy A (recommended, the basis for the $145/$135 rates above): SBG pays the partners for ALL clocked hours.** Drive, shop, weather, quoting, and PTO are all on the SBG payroll. Because SBG eats that non-billable paid time, the paid-hour cost (~$105.16 WITH WC) has to be recovered over only the ~85% of hours that are billable, which lifts the cost to ~$123.72 per billable hour and lands the rate at ~$145 at a ~17% margin. This is realistic (working owners do not clock out for drive time), conservative (it assumes SBG carries the unbillable hours), and it produces the higher, fully-loaded transfer price.
- **Policy B (alternative): SBG pays the partners only for BILLABLE hours.** If the partners absorb their own non-billable time and SBG only puts billable hours on payroll, then every paid hour IS a billable hour, the utilization step disappears, and the cost per billable hour is just the ~$105.16 paid-hour cost. At a ~20% margin that rate would be about **~$126/hr (WITH WC)**, not $145, at roughly the same ~$21 of margin per billable hour. The rate is lower because SBG is no longer carrying (and therefore no longer recovering) the unbillable paid time.

**Recommend Policy A and the ~$145 rate as the realistic, conservative default.** Paying working owners for all clocked hours is how real field crews run, it keeps the W-2 wage clean for the reasonable-comp position, and it produces the more defensible (higher, fully-burdened) transfer price. Policy B is legitimate and lands a lower ~$126 rate, but it pushes the non-billable-time risk onto the partners personally and makes payroll messier (you would have to track and exclude every non-billable hour). **Jim picks the pay policy**; the model recommends A. Whichever is chosen, keep the margin per billable hour at ~$21 (~17%).

### The same build-up sets the CREW billable rate

The $80 is specifically the **partners'** wage. The crews (the non-owner W-2 employees) earn a **lower crew wage** (planning placeholder, confirm with the partners, e.g. ~$25 to $40/hr depending on skill). Run that lower wage through the exact same columns: employer FICA at 7.65% of the crew wage, the same capped FUTA + WI SUTA, WC code 5645 at 8.53% (crews always carry WC, no election-out), the same ~$12 overhead, and the ~20% margin. Because the wage is lower, the crew billable rate lands well below $145. The structure is identical; only the wage input changes. Build the crew rate the same way once the crew wage is set.

---

## 7. Sizing the Equal Cash Contribution

The three partners put in **equal cash.** That cash funds two things in Phase A: SBG-Equipment's purchases, and SBG-Labor's payroll float. Real estate is dormant, so there is no real-estate capital in this round.

### Driver 1: the equipment fleet

What SBG-Equipment buys with the cash. A starting deck-and-fence fleet (ASSUMPTION list, to be replaced by the partners' actual needs and whatever equipment they already own and might contribute instead of buy):

| Equipment category | Rough cost (ASSUMPTION) |
|---|---:|
| Work truck(s) / trailer (if not contributed) | $20,000 to $45,000 |
| Compact track loader / mini-skid + attachments | $15,000 to $40,000 |
| Augers, compactors, generators, saws, smaller power tools | $8,000 to $18,000 |
| Staging, scaffolding, ladders, safety | $4,000 to $9,000 |
| Trailer-mounted setups, misc | $3,000 to $8,000 |
| **Equipment subtotal** | **~$50,000 to $120,000** |

If the partners contribute equipment they already own (likely, since both Ben and John already run crews), the cash needed for purchases drops accordingly, but then the **contribution values must be equalized** (a partner who contributes a $30,000 loader has effectively put in more than one who contributes nothing, which breaks the equal-thirds story unless it is trued up). Flag this for Section 9 and the attorney.

### Driver 2: the SBG-Labor payroll float

This is the cash hole most people miss. **SBG-Labor pays the crews weekly, but it bills the LLCs and collects later** (the LLCs in turn collect from homeowners on deposit/progress/final terms). So SBG-Labor must front several weeks of payroll before the cash comes back.

Float math (ASSUMPTION):
- Base-case billable hours ~5,000/yr is roughly **~$96/week of payroll per worker times the crew**; figure a crew where weekly gross payroll plus burden runs **~$8,000 to $14,000/week.**
- Carry **4 to 6 weeks** of that as float (weekly pay-out, but invoices to LLCs collected on a ~30-day cycle).
- Payroll float target: **~$35,000 to $70,000.**

### Putting it together: the equal cash range

| Component | Low | High |
|---|---:|---:|
| Equipment purchases (net of contributed gear) | $30,000 | $120,000 |
| Payroll float | $35,000 | $70,000 |
| Small first-winter buffer | $10,000 | $20,000 |
| **Total SBG seed capital** | **~$75,000** | **~$210,000** |
| **Per partner (one third), equal cash** | **~$25,000** | **~$70,000** |

**Defensible planning range: roughly $25,000 to $70,000 of equal cash per partner**, most likely landing around **$30,000 to $45,000 each** if the partners contribute some equipment they already own and SBG leans on retained margin (Section 5.3) to grow the fleet over time rather than buying everything on day one. The two drivers are the equipment list and the payroll float; nail those two with real numbers and the cash figure firms up immediately. No real-estate capital is needed this round because SBG-RealEstate stays dormant.

---

## 8. Jim's Personal Bridge-Income Model

> ## PRIVATE: JIM ONLY. NOT FOR THE BEN/JOHN MEETING. REMOVE THIS SECTION BEFORE SENDING OR PRESENTING.

### Why the new structure is MORE protective for Jim than the merger was

This matters, so it leads. Under the dead merger, Jim would have folded CWDB's job profit into a shared pool and split it one third, AND faced the open question of whether the lead engine was just his "deemed-equal contribution" (i.e., given away). **Under the new shared-services structure, Jim keeps three things the merger would have diluted:**

1. **CWDB stays his, 100%.** The LLC, the brand, the entity.
2. **The lead engine stays his, 100%,** feeding only CWDB jobs. It is not contributed, not pooled, not valued-away. Its eventual valuation is a Phase B negotiation he controls.
3. **CWDB's own job profit stays his (siloed).** He keeps the full margin on the jobs CWDB signs and delivers, not one third of a pool.

On top of those three, he adds an SBG W-2 wage for hours he personally works. The trade-off is that SBG **reinvests** its margin in Phase A, so there is thinner near-term SBG cash flowing to Jim than a distribution model would give. But that reinvested margin is building an asset he owns a third of. Net: this structure is strictly more protective of Jim's downside than the merger, at the cost of slightly less near-term SBG cash. Good trade.

### The situation in numbers (unchanged)

- Leaving a W-2 paying **$140,000/yr** (about $11,667/mo gross) that the household depends on.
- Ashley carries family health insurance, so **no benefits cost is added** on Jim's exit. Major de-risker. Do not understate it.
- **3 months of personal reserve.**
- **Success floor: $8,000/mo take-home ($96,000/yr).**
- It is **June.** Season runs to mid-November, then a ~4.5-month winter trough.

### Jim's Phase A income, recomputed for the new structure

Two streams, both different from the merger model:

**Stream 1: CWDB's own job profit (siloed, Jim keeps 100%).** Jim keeps the margin on jobs CWDB signs. On a $25,000 deck at 35% gross margin that is ~$8,750 of gross margin per job, before Jim's overhead and tax. Net to Jim after overhead share and ~27% income tax plus SE tax is roughly **$5,000 to $5,800 per owned job** (ASSUMPTION). Constraint: the build/structural lane (75% of work) needs Jim's DSPS Dwelling Contractor license, which he does not yet hold; until then CWDB owns only the 25% stain/resurface lane. The lead engine sources these jobs and has produced real leads, so this is a real channel.

**Stream 2: SBG W-2 wage for hours Jim personally works.** When Jim swings a hammer on any crew, SBG-Labor pays him the **$80/hr market wage on a W-2** (the loaded ~$145 is what SBG bills the LLC; Jim's take is the $80 wage). A W-2 wage is cleaner and lower-risk than self-employment sub income: the payroll tax is split with the employer (SBG pays the employer 7.65%, Jim pays the employee 7.65% withheld), withholding is automatic, and there is no SE-tax surprise at year-end. At **120 W-2 hours/month, $80/hr grosses $9,600**, netting roughly **$6,300/mo** after the 7.65% employee FICA and ~26% combined federal + WI income tax withholding (ASSUMPTION on the income-tax bucket; the FICA split is VERIFIED). That is materially more per month than the prior $45-wage version, because the wage nearly doubled. Note: in Phase A there is **no SBG distribution** on top of this wage, by design.

### Does CWDB job profit + SBG wage clear the $8,000/mo floor?

| Month shape | CWDB owned-job net | SBG W-2 wage net ($80/hr) | **Total take-home** | Clears $8k? |
|---|---:|---:|---:|---|
| Strong summer, 2 stain/resurface jobs + 120 SBG hrs | ~$10,000 (2 x $5,000) | ~$6,300 (120 hr) | **~$16,300** | YES, clearly |
| Typical summer, 1 owned job + 120 SBG hrs | ~$5,200 | ~$6,300 | **~$11,500** | YES, comfortably |
| Shoulder, 1 owned stain job + 80 SBG hrs | ~$3,500 | ~$4,200 | **~$7,700** | NO, but close |
| Deep winter, 0 owned jobs + 40 SBG hrs | $0 | ~$2,100 | **~$2,100** | NO, badly |

(All ASSUMPTION on the income-tax bucket; net figures carry the VERIFIED 7.65% employee FICA + ~26% combined federal/WI income-tax withholding. The $80 wage roughly doubles the SBG net per hour versus the prior $45-wage version, which is what lifts the combined scenarios.)

### Verdict for Jim

**On a full-season summer month, CWDB job profit plus an SBG W-2 wage clears the $8,000/mo floor comfortably, and the $80 wage does most of the lifting.** At the $80 market wage, 120 SBG hours alone net ~$6,300, which on its own does NOT quite clear $8,000 but gets about 79% of the way there, a big change from the prior $45-wage version where the wage netted only ~$3,800. Add even one owned job (~$5,200 net) and the combined month lands ~$11,500, comfortably over. So the floor is now cleared by the COMBINATION of a meaningful W-2 wage plus owned-job margin, rather than resting almost entirely on owned-job margin as the old $45-wage analysis concluded. **The owned-job margin is still gated on (a) the lead engine sourcing 1+ closable job/month and (b) the DSPS license unlocking the 75% build lane**; until the license lands, CWDB owns only the 25% stain/resurface lane, which caps how many jobs Jim can keep. But the higher wage means Jim leans less hard on landing an owned job every single month to clear the floor in season.

**The flip side of the rich $80 wage (Jim should see this clearly):** paying himself $80/hr W-2 is the partners' choice and it is defensible, but it MAXIMIZES payroll tax on that income and moves dollars from siloed, LLC-level job profit into payroll-taxed wages, which partially offsets the S-corp distribution benefit (the S-corp savings come from money that leaves as distribution, not wage). The upside is that $80/hr is a clean "reasonable compensation" figure that strengthens the S-corp salary position. Net for Jim's bridge: the higher wage improves near-term monthly take-home and audit posture, at the cost of a bit more payroll tax and slightly less tax-favored distribution headroom later. It is a reasonable trade given that Phase A reinvests rather than distributes anyway.

**The seasonality caveat is unchanged and is still the real risk.** December through February will not clear the floor in any scenario, because there are few owned jobs and SBG field hours collapse in a Wisconsin winter. The annual picture clears $96,000 more easily now that in-season months land ~$11,500 to $16,300 (the higher wage lifts every summer month), banked against a near-zero Dec to Feb, but the monthly floor still fails every deep-winter month.

**Mitigants, in order of strength (unchanged from before, still correct):**
1. **Ashley's income and the family health insurance she carries** are the real winter bridge. Quantify Ashley's monthly net before Jim quits; it likely covers the winter floor by itself.
2. **Bank the summer surplus deliberately** as the winter fund. The strong months (June to October) must overfund so December to February can underfund. Treat the August to October surplus as untouchable.
3. **Time the resignation to bank one strong season first.** Strongest play: do not quit cold in June. Run it nights/weekends/PTO through this season, prove the owned-job channel and get the license, and resign in spring 2027 heading into a season with reserve banked and the license in hand. If that is not feasible, quit only with the explicit plan that Ashley covers December to February and the summer surplus is banked, not spent.
4. **The new structure helps the winter more than before:** Jim can draw the $80/hr SBG W-2 wage for any winter hours worked (interior/garage/basement finish work, or helping Ben/John's winter jobs), which at the higher wage is worth ~$6,300 net at 120 hrs. The catch is HOURS, not rate: deep-winter field hours collapse, so at a realistic 40 winter hours the wage nets only ~$2,100 and does not carry the floor. The higher wage helps any month Jim can actually find hours; it cannot manufacture hours that the Wisconsin winter removes.

**Bottom line for Jim:** the new structure is materially BETTER for him than the merger (he keeps CWDB, the engine, and his job profit, and adds a clean W-2 wage), and on an annual basis the base case clears the $96,000 floor. But it still fails the monthly floor in deep winter, so the exit is responsible only if (a) Ashley's income plus the banked summer surplus demonstrably covers December through February, and (b) ideally the resignation is timed to bank one season and land the license first. The $8,000/mo floor from CWDB-owned jobs is a post-license, in-season reality, not a June-2026 reality.

> ## END PRIVATE SECTION. EVERYTHING BELOW IS FOR THE FULL WORKING SESSION.

---

## 9. Open Items and Confirmations

Nothing in this model is final until these are resolved. These are the questions for the working session and the follow-ups for the CPA, attorney, and DOR.

### Tax and registration

1. **WI DOR on the equipment lease (Section 3).** Confirm that SBG-Equipment's intercompany equipment rentals are taxable, that SBG-Equipment must register for a seller's permit and charge/remit 5.5%, and confirm the correct purchase-side treatment (resale/lease exemption at purchase versus tax at purchase) so the fleet is not double-taxed. Written determination recommended. URGENT, before the first lease invoice.
2. **WI DOR on the labor supply (Section 3).** Confirm SBG-Labor's labor billings to the LLCs are not a taxable enumerated service (expected: not taxable). Keep labor and equipment on separate invoices.
3. **S-corp election mechanics for SBG-Labor (Section 1).** CPA to confirm Form 2553 timing and effective date, set up payroll, and set each partner's reasonable W-2 wage. Confirm S-corp is the right call versus the partnership default given the W-2-wage requirement (it is, per Rev. Rul. 69-184, but the CPA should bless it on the facts).
4. **Ownership chain (Section 1).** Attorney to confirm the three individuals own the SBG entities directly (required for the SBG-Labor S-election), and decide individual versus holding-LLC ownership for the two partnerships.
5. **Existing LLC tax standing.** Confirm Barton Builders LLC and John Garcia Construction LLC are current on all federal and WI filings before they start transacting with SBG.

### The money

6. **The equal cash amount (Section 7).** Pin the equipment list and the payroll float with real numbers to firm up the ~$25,000 to $70,000-per-partner range. Decide what equipment each partner contributes versus what SBG buys, and how contributed equipment is valued and equalized.
7. **The loaded labor rate (Section 6).** Confirm the **$80/hr market W-2 wage** for partners and the derived **~$145/hr billing rate (WITH WC), ~$135/hr if partners elect out of WC**, set the utilization policy (whether partners are paid for non-billable hours, which drives the real break-even up to ~$148/$168 at 85%/75% billable), confirm whether all three partner-officers can actually elect out of WC given the closely held two-officer cap, set the lower CREW wage so the crew billing rate can be built the same way, and get all three partners on the math before the first intercompany invoice.
8. **Equipment lease rates (Section 4).** Benchmark market rental rates per machine for the transfer-pricing file.
9. **Reinvestment policy (Section 5.3).** Confirm SBG reinvests 100% of its margin in Phase A with no distributions, and write the trigger for when distributions begin.

### Structure and legal

10. **Written intercompany agreements (Section 4).** Labor-services and equipment-lease agreements drafted and signed before the first intercompany invoice.
11. **Wind-down of the old lead deal.** Confirm the prior lead-purchase arrangement with Ben and John is formally wound down, so each LLC runs its own customer acquisition.
12. **Insurance and licensing unchanged.** Each LLC keeps its own GL, Dwelling Contractor Certification, and Qualifier; SBG-Labor adds workers' comp on the crews. Confirm WC coverage and the WI DWD employee thresholds.
13. **Entity names.** SBG-Labor, SBG-Equipment, SBG-RealEstate are working names. Confirm or replace, then reserve with WI DFI.
14. **Re-read the existing legal memos against this structure.** `entity-structure-and-spinout-memo.md` and `tax-treatment-memo.md` were written for the single-LLC and the dead-merger framing. They need a counsel pass for the shared-services structure.

---

## 10. Phase B (Future True Merger): High-Level Tax and Valuation Considerations

We do NOT model Phase B dollars here. We only flag what it will involve so the partners go in with eyes open. Phase B is the move from "each LLC keeps its own job profit" to "job profit pools and splits one third each."

### What triggers Phase B

A defined trigger the partners agree on now (so it is objective, not emotional): for example, two-plus full seasons of clean shared-services operation, a target combined revenue or job count, all three LLCs at comparable book size, and Jim's license in hand. Write the trigger down.

### The hard parts of Phase B

- **Valuation and equalization of three unequal LLCs.** The three LLCs are not equal today (different backlogs, different equipment, different brand and customer base). To pool profit one third each, the partners must value each LLC's contribution (backlog, equipment, customer base, goodwill) and equalize the differences, probably with a buy-in, an earn-in, or adjusted initial capital accounts. This is the single hardest negotiation in the whole plan and is exactly why it is deferred.
- **Pre-existing marketing and customer assets brought into the pool.** In Phase A each LLC's marketing and customers stay with that LLC. In a true merger, any such assets a partner brings into the pool must be valued at that time (contributed for equity, licensed for a fee, or bought outright) as part of the equalization. This is real value that should not be given away; it is decided at Phase B.
- **Choice of merger vehicle and tax treatment.** A true profit-pooling merger likely means a single operating entity taxed as a partnership (to allow the LLCs as members and to allow special allocations during the equalization period) OR a careful contribution of the three businesses into one entity. Each path has its own tax consequences (contribution of appreciated assets, built-in gain, basis, possible Section 351/721 nonrecognition treatment). All of it requires the CPA and attorney. NEEDS VERIFICATION at Phase B; do not assume tax-free.
- **SBG's role in Phase B.** SBG (the shared-services group) can survive into Phase B as the asset-and-labor holding layer beneath the merged operating company, or be folded in. Decide then.
- **Reasonable comp re-test.** Once SBG-Labor (or the merged entity) starts making real distributions on top of wages, the S-corp reasonable-comp analysis gets sharper and must be re-run.

The whole point of doing Phase A first is to operate together, build a shared asset base, and generate the real numbers that make the Phase B valuation fair, before anyone has to agree on what each company is worth.

---

## Disclaimer

These figures are illustrative planning support only. Every dollar amount not tied to a cited government source is a labeled assumption and must be confirmed against the partners' actual books before any agreement is signed. Final tax positions (the SBG-Labor S-corp election and reasonable-salary figures, the partnership treatment of SBG-Equipment and SBG-RealEstate, the Wisconsin sales/use tax treatment of the intercompany equipment leases and labor supply, the transfer-pricing rates, and the bracket math) require confirmation against current IRS and Wisconsin Department of Revenue guidance and, where material, a written DOR determination, not this document's reading. The entity structure, ownership chain, and licensing steps require review by a licensed Wisconsin attorney before filing. This is planning support, confirm against the actual books, not filed tax advice, and confirm with the WI DOR, a CPA, and a Wisconsin attorney before relying on any position here.
