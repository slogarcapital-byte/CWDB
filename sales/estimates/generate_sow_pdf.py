"""
CWDB Home Improvement Contract (SOW) PDF Generator
Central Wisconsin Deck Builders, LLC

Renders docs/legal/templates/home-improvement-contract-template.md as a
signable PDF from the same estimate JSON that feeds generate_estimate_pdf.py.
This is the BINDING instrument for CWDB direct-build jobs: the quote's scope,
price, and schedule are merged into the contract body (ATCP 110.05(2)), the
original estimate PDF is appended as Exhibit A, and the package bundles TWO
copies of the Notice of Cancellation plus the Wis. Stat. 779.02(2) Notice to
Owner.

GATE: do not send this for signature until CWDB's GL insurance is bound and
the DSPS Dwelling Contractor Certification + Qualifier are filed (Wis. Stat.
101.654). Section 11 represents that insurance is active. For staining-only
jobs before the gate clears, use generate_work_order_pdf.py instead.

Usage:
    python generate_sow_pdf.py _data/2026-05-28-henderson-deck-build.json \
        --job-number CWDB-2026-002 \
        --effective-date 2026-06-15 \
        [--start-date "July 6, 2026"] [--completion-date "July 24, 2026"] \
        [--co-owner "Name"] [--warranty "ten (10) years"] \
        [--permits included|billed|homeowner] [--no-exhibit]

The PDF is written next to sales/estimates/ as <stem>-contract.pdf. If a
sibling <stem>.pdf estimate exists it is appended as Exhibit A via pypdf.
"""

import argparse
import datetime as dt
import json
from pathlib import Path

from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, KeepTogether, PageBreak)

from generate_estimate_pdf import (ORANGE, SLATE, GREY, LIGHT_BG, ROW_ALT,
                                   _logo_flowable, _hr, _money,
                                   body, bullet, nap, small, meta,
                                   table_h, table_h_r, table_c, table_c_r,
                                   total, total_r)
from generate_work_order_pdf import (consp, consp_c, sec_h, title_h,
                                     federal_holidays, cancellation_deadline,
                                     long_date, _sig_line,
                                     _notice_of_cancellation)

PERMIT_CLAUSES = {
    'included': ('CWDB will obtain and pay for the building permit(s) required '
                 'for the Work and the cost is included in the Contract Price.'),
    'billed': ('CWDB will obtain the building permit(s) and the permit fees '
               'will be billed to the Homeowner at cost.'),
    'homeowner': 'The Homeowner will obtain the required permit(s).',
}


def _job_footer(job_number):
    def footer(canvas, doc):
        canvas.saveState()
        canvas.setFont('Helvetica', 8.5)
        canvas.setFillColor(GREY)
        txt = (f'Central Wisconsin Deck Builders, LLC  ·  Job No. {job_number}'
               '  ·  cwdeckbuilders.com')
        canvas.drawCentredString(letter[0] / 2.0, 0.45 * inch, txt)
        canvas.drawRightString(letter[0] - 0.6 * inch, 0.45 * inch,
                               f'Page {canvas.getPageNumber()}')
        canvas.restoreState()
    return footer


def _milestone_table(milestones, total_amount):
    rows = [[Paragraph('Milestone', table_h), Paragraph('Amount', table_h_r),
             Paragraph('When due', table_h)]]
    for label, amount, when in milestones:
        rows.append([Paragraph(label, table_c),
                     Paragraph(_money(amount), table_c_r),
                     Paragraph(when, table_c)])
    rows.append([Paragraph('Contract Price', total),
                 Paragraph(_money(total_amount), total_r),
                 Paragraph('', table_c)])
    t = Table(rows, colWidths=[2.3 * inch, 1.1 * inch, 2.8 * inch])
    style = [
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('BACKGROUND', (0, 0), (-1, 0), LIGHT_BG),
        ('LINEBELOW', (0, 0), (-1, 0), 0.6, GREY),
        ('LINEABOVE', (0, -1), (-1, -1), 1.2, ORANGE),
        ('BACKGROUND', (0, -1), (-1, -1), LIGHT_BG),
    ]
    for i in range(1, len(rows) - 1):
        if i % 2 == 0:
            style.append(('BACKGROUND', (0, i), (-1, i), ROW_ALT))
    t.setStyle(TableStyle(style))
    return t


def build_milestones(estimate, total_amount):
    """payment.milestones (list of [label, amount, when]) if present, else a
    deposit/balance two-stage schedule from deposit_pct."""
    custom = estimate['payment'].get('milestones')
    if custom:
        return [tuple(m) for m in custom]
    pct = estimate['payment']['deposit_pct']
    deposit = round(total_amount * pct / 100)
    return [
        (f'Deposit at signing ({pct}%)', deposit,
         'At signing, subject to the right to cancel in Section 9; held and '
         'not spent until that right expires'),
        ('Final payment', total_amount - deposit,
         'Upon final completion and walkthrough'),
    ]


def generate_sow(estimate, output_path, job_number, effective, *,
                 co_owner=None, warranty='one (1) year', permits='included',
                 start_date=None, completion_date=None, exhibit_pdf=None):
    total_amount = (estimate.get('_meta', {}).get('computed_sell_price')
                    or sum(amt for _, amt in estimate['line_items']))
    deadline = cancellation_deadline(effective)
    client = estimate['client']
    proj = estimate['project']
    sched = estimate['schedule']
    start = start_date or sched['start']
    completion = completion_date or (
        f"approximately {sched['duration']} after the start date")
    milestones = build_milestones(estimate, total_amount)
    est_no = estimate['estimate_number']

    doc = SimpleDocTemplate(
        str(output_path), pagesize=letter,
        leftMargin=0.85 * inch, rightMargin=0.85 * inch,
        topMargin=0.55 * inch, bottomMargin=0.75 * inch,
        title=f"Home Improvement Contract, {client['name']}, {job_number}",
        author='Central Wisconsin Deck Builders, LLC',
    )

    s = []
    sp = lambda n=0.1: Spacer(1, n * inch)

    # ── HEADER ──────────────────────────────────────────────────────────────
    s.append(_logo_flowable(target_width_in=2.8))
    s.append(sp(0.06))
    s.append(Paragraph(
        'cwdeckbuilders.com  ·  (715) 544-7941  ·  info@cwdeckbuilders.com', nap))
    s.append(Paragraph(
        '906 N 16th Ave, Wausau, WI 54401  ·  Entity ID C138564  ·  EIN 41-5355234',
        small))
    s.append(_hr(color=ORANGE, thickness=2, space_after=8, space_before=8))
    s.append(Paragraph('HOME IMPROVEMENT CONTRACT', title_h))
    s.append(Paragraph(
        f"Job No. {job_number}  ·  Effective Date {long_date(effective)}  ·  "
        f"Ref. Estimate #{est_no}", meta))
    s.append(sp(0.08))

    owner_names = client['name'] + (f' and {co_owner}' if co_owner else '')
    s.append(Paragraph(
        '<b>THIS HOME IMPROVEMENT CONTRACT</b> (this "Contract") is entered '
        'into as of the Effective Date above, by and between '
        '<b>Central Wisconsin Deck Builders, LLC</b>, a Wisconsin limited '
        'liability company, 906 N 16th Ave, Wausau, WI 54401, phone (715) '
        '544-7941, email info@cwdeckbuilders.com ("CWDB," "Contractor," or '
        f'"we"), and <b>{owner_names}</b>, mailing address '
        f"{client['address_line']}, phone {client['phone']}, email "
        f"{client['email']} (the \"Homeowner,\" \"Owner,\" or \"you\"). "
        'CWDB and the Homeowner are each a "Party" and together the '
        '"Parties." Salesperson / Representative: James Slogar.', body))

    # ── 1. PARTIES AND PROJECT ──────────────────────────────────────────────
    s.append(Paragraph('Section 1. Parties and Project', sec_h))
    s.append(Paragraph(
        f"<b>1.1 Project Property.</b> CWDB will perform the work described in "
        f"Section 2 at: <b>{client['address_line']}</b> (the \"Property\").", body))
    s.append(Paragraph(
        '<b>1.2 Owner Authority.</b> The Homeowner represents that the '
        'Homeowner owns the Property or is otherwise authorized to contract '
        'for the improvements described in this Contract.', body))
    s.append(Paragraph(
        '<b>1.3 Contractor Identity.</b> CWDB is the prime contractor for the '
        'Project. CWDB may perform the work itself or engage one or more '
        'subcontractors under a separate written subcontractor agreement. CWDB '
        'remains responsible to the Homeowner for the completed work '
        'regardless of who performs it.', body))

    # ── 2. SCOPE OF WORK ────────────────────────────────────────────────────
    s.append(Paragraph('Section 2. Scope of Work and Specifications', sec_h))
    s.append(Paragraph(
        '<b>2.1 Description of Work.</b> CWDB will furnish the labor, '
        'materials, equipment, and supervision to perform the following work '
        'at the Property (the "Work"):', body))
    s.append(Paragraph(proj['overview'], body))
    s.append(Paragraph('<b>2.2 Scope of Work.</b>', body))
    for item in proj['scope']:
        s.append(Paragraph(f'• {item}', bullet))
    if proj.get('scope_note'):
        s.append(Paragraph(
            f"<i><b>Scope boundary:</b> {proj['scope_note']}</i>", body))
    s.append(Paragraph(
        '<b>2.3 Detailed Specifications.</b> The dimensions, configuration, '
        'materials, and finish specifications of the Work are as stated in '
        f'<b>Exhibit A (Estimate #{est_no})</b>, attached to and incorporated '
        'into this Contract.', body))
    s.append(Paragraph('<b>2.4 Included in the Price.</b>', body))
    for item in estimate.get('included', []):
        s.append(Paragraph(f'• {item}', bullet))
    s.append(Paragraph(
        '<b>2.5 NOT Included in the Price.</b> The following are not included '
        'and, if needed, will be handled by a signed change order under '
        'Section 5 or by others:', body))
    for item in estimate.get('not_included', []):
        s.append(Paragraph(f'• {item}', bullet))
    s.append(Paragraph(
        '<b>2.6 Unforeseen Conditions.</b> If CWDB discovers concealed or '
        'unforeseen conditions (for example rot, prior code violations, buried '
        'obstructions, or soil conditions requiring deeper footings) that '
        'materially affect cost or schedule, CWDB will stop affected work, '
        'notify the Homeowner, and proceed only under a signed change order.',
        body))

    # ── 3. PRICE AND PAYMENT ────────────────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('Section 3. Total Price and Payment Schedule', sec_h),
        Paragraph(
            f'<b>3.1 Total Price.</b> The total price for the Work is '
            f'<b>{_money(total_amount)}</b> (the "Contract Price"). This is a '
            'fixed price subject only to signed change orders under Section 5.',
            body),
        Paragraph('<b>3.2 Payment Schedule.</b> The Homeowner shall pay the '
                  'Contract Price in the following installments:', body),
        _milestone_table(milestones, total_amount),
    ]))
    s.append(sp(0.05))
    s.append(Paragraph(
        '<b>3.3 Deposit.</b> The deposit shall not exceed a commercially '
        'reasonable amount sufficient to cover initial materials and '
        'mobilization. CWDB will not deposit, spend, or apply the deposit, and '
        'will not order job-specific materials against it, until the buyer\'s '
        '3-day right to cancel under Section 9 has expired.', body))
    s.append(Paragraph(
        f"<b>3.4 Payment Method.</b> Payments may be made by "
        f"{estimate['payment']['methods']}.", body))
    s.append(Paragraph(
        '<b>3.5 Late Payment.</b> Past-due amounts bear interest at one and '
        'one-half percent (1.5%) per month (18% per annum) or the maximum rate '
        'permitted by Wisconsin law, whichever is less.', body))
    s.append(Paragraph(
        '<b>3.6 Lien Waivers.</b> Upon the Homeowner\'s request and upon '
        'payment, CWDB will provide a lien waiver for amounts paid, and will '
        'collect lien waivers from its subcontractors and suppliers, as '
        'described in the construction-lien package referenced in Section 12.',
        body))

    # ── 4. SCHEDULE ─────────────────────────────────────────────────────────
    s.append(Paragraph('Section 4. Schedule', sec_h))
    s.append(Paragraph(
        f'<b>4.1 Start Date.</b> CWDB estimates work will begin on or about '
        f'<b>{start}</b>, after the cancellation period in Section 9 has '
        'expired.', body))
    s.append(Paragraph(
        f'<b>4.2 Substantial Completion.</b> CWDB estimates the Work will '
        f'reach substantial completion <b>{completion}</b>, subject to '
        'weather, material availability, permit timing, change orders, and '
        'other causes beyond CWDB\'s reasonable control. '
        f"{sched.get('weather', '')}", body))
    s.append(Paragraph(
        '<b>4.3 Delays.</b> CWDB is not responsible for delays caused by '
        'weather, acts of God, permit or inspection timing, material '
        'shortages, the Homeowner, or other causes beyond CWDB\'s reasonable '
        'control. CWDB will give the Homeowner reasonable notice of any '
        'material delay and a revised estimated completion date.', body))

    # ── 5. CHANGE ORDERS ────────────────────────────────────────────────────
    s.append(Paragraph('Section 5. Change Orders', sec_h))
    s.append(Paragraph(
        '<b>5.1 Written Change Orders Only.</b> Any change to the scope, '
        'materials, price, or schedule must be documented in a written change '
        'order signed by both Parties before the changed work proceeds. Change '
        f'orders will reference this Contract\'s Job No. ({job_number}/CO-1, '
        f'{job_number}/CO-2, and so on).', body))
    s.append(Paragraph(
        '<b>5.2 No Verbal Changes.</b> CWDB is not obligated to perform, and '
        'the Homeowner is not obligated to pay for, any extra or changed work '
        'that is not covered by a signed change order. Verbal requests do not '
        'bind either Party.', body))
    s.append(Paragraph(
        '<b>5.3 Effect on Price and Schedule.</b> Each change order will state '
        'the change in scope, the increase or decrease in the Contract Price, '
        'and any change to the schedule.', body))

    # ── 6. PERMITS ──────────────────────────────────────────────────────────
    s.append(Paragraph('Section 6. Permits and Code Compliance', sec_h))
    s.append(Paragraph(
        f'<b>6.1 Permits.</b> {PERMIT_CLAUSES[permits]} The responsible Party '
        'will obtain all permits required by Marathon County and the '
        'applicable municipality before starting permitted work.', body))
    s.append(Paragraph(
        '<b>6.2 Code Compliance.</b> CWDB will perform the Work in accordance '
        'with the Wisconsin Uniform Dwelling Code (Wis. Admin. Code SPS 320 '
        'through 325), including deck-specific structural requirements for '
        'footings, ledger attachment, guardrail height, and load rating, and '
        'in accordance with applicable local building codes and ordinances.',
        body))
    s.append(Paragraph(
        '<b>6.3 Inspections.</b> CWDB will coordinate required inspections. '
        'The Homeowner will provide reasonable access to the Property for '
        'inspections and for the Work.', body))

    # ── 7. WARRANTY ─────────────────────────────────────────────────────────
    s.append(Paragraph('Section 7. Warranty', sec_h))
    s.append(Paragraph(
        f'<b>7.1 Workmanship Warranty.</b> CWDB warrants that the Work will be '
        f'free from defects in workmanship for a period of <b>{warranty}</b> '
        'from the date of substantial completion. If a covered workmanship '
        'defect appears during the warranty period, CWDB will, at its option '
        'and at no charge to the Homeowner, repair or correct the defect, '
        'provided the Homeowner gives written notice of the defect within the '
        'warranty period.', body))
    s.append(Paragraph(
        '<b>7.2 Manufacturer Warranties Pass Through.</b> Materials and '
        'products installed by CWDB may carry separate manufacturer '
        'warranties. CWDB passes through to the Homeowner all such '
        'manufacturer warranties to the extent transferable. CWDB does not '
        'separately warrant the materials beyond the workmanship warranty in '
        'Section 7.1 and the express manufacturer warranties.', body))
    s.append(Paragraph(
        '<b>7.3 Exclusions.</b> The warranty does not cover: normal '
        'weathering, fading, or wear; damage from misuse, neglect, or failure '
        'to maintain (including failure to re-stain or seal on a normal '
        'maintenance schedule); movement, settling, or splitting of natural '
        'wood that is consistent with industry norms; damage from storms, '
        'floods, or other events beyond CWDB\'s control; or work, alteration, '
        'or repair performed by anyone other than CWDB after completion.', body))
    s.append(Paragraph(
        '<b>7.4 Maintenance.</b> The Homeowner is responsible for routine '
        'maintenance, including periodic cleaning and re-staining or '
        're-sealing as recommended for the chosen product.', body))

    # ── 8. CLEANUP ──────────────────────────────────────────────────────────
    s.append(Paragraph('Section 8. Cleanup and Debris', sec_h))
    s.append(Paragraph(
        '<b>8.1 Cleanup.</b> CWDB will keep the work area reasonably clean '
        'during the Work and, upon completion, will remove its tools, '
        'equipment, surplus materials, and construction debris and leave the '
        'work area in broom-clean condition.', body))
    s.append(Paragraph(
        '<b>8.2 Disposal.</b> CWDB will lawfully dispose of construction '
        'debris generated by the Work. Disposal of pre-existing materials or '
        'hazardous materials not generated by the Work is not included unless '
        'stated in Section 2.', body))

    # ── 9. RIGHT TO CANCEL (CONSPICUOUS) ────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('Section 9. Buyer\'s Right to Cancel', sec_h),
        Paragraph('9.1 YOUR RIGHT TO CANCEL. YOU, THE BUYER, MAY CANCEL THIS '
                  'TRANSACTION AT ANY TIME PRIOR TO MIDNIGHT OF THE THIRD '
                  'BUSINESS DAY AFTER THE DATE OF THIS TRANSACTION. SEE THE '
                  'ATTACHED NOTICE OF CANCELLATION FOR AN EXPLANATION OF THIS '
                  'RIGHT.', consp),
    ]))
    s.append(Paragraph(
        '<b>9.2 When This Right Applies.</b> This 3-day right to cancel '
        'applies when this Contract is solicited or signed at the Homeowner\'s '
        'residence or at a place other than CWDB\'s regular place of business, '
        'and the transaction is above the threshold amount set by law. When '
        'this right applies, CWDB will give the Homeowner two completed copies '
        'of the Notice of Cancellation at the time the Homeowner signs this '
        'Contract, as required by the Wisconsin Consumer Act, Wis. Stat. '
        '423.201 to 423.203, and the federal Cooling-Off Rule, 16 CFR Part '
        '429.', body))
    s.append(Paragraph(
        '<b>9.3 How to Cancel.</b> To cancel, the Homeowner may sign and date '
        'the cancellation form in the attached Notice of Cancellation and mail '
        'or deliver it to CWDB at the address shown on the Notice, or send any '
        'other written notice of cancellation, by midnight of '
        f'<b>{long_date(deadline)}</b> (the third business day after signing).',
        body))
    s.append(Paragraph(
        '<b>9.4 Effect of Cancellation.</b> If the Homeowner cancels within '
        'the cancellation period, CWDB will return any payments made by the '
        'Homeowner within ten (10) days of receiving the cancellation notice, '
        'and the Homeowner will make available any materials delivered, as set '
        'out in the Notice of Cancellation.', body))

    # ── 10. ATCP 110 DISCLOSURES ────────────────────────────────────────────
    s.append(Paragraph('Section 10. Required ATCP 110 Disclosures', sec_h))
    s.append(Paragraph(
        '<b>10.1 Written Contract.</b> This Contract, including all '
        'attachments and any signed change orders, is the complete home '
        'improvement contract between the Parties. Wis. Admin. Code ATCP 110 '
        'requires home improvement contracts to be in writing and to state the '
        'agreement of the Parties.', body))
    s.append(Paragraph(
        '<b>10.2 No Misrepresentation.</b> CWDB has not made any false, '
        'deceptive, or misleading representation regarding the Work, and the '
        'Homeowner is not relying on any promise, representation, or warranty '
        'not written in this Contract.', body))
    s.append(Paragraph(
        '<b>10.3 Disclosure of Known Defects and Conditions.</b> CWDB will '
        'promptly disclose to the Homeowner any condition at the Property '
        'known to CWDB that would significantly affect the cost of the Work or '
        'the structural integrity of the improvement.', body))
    s.append(Paragraph(
        '<b>10.4 Required Notices.</b> Any notice required by law, including '
        'the notice of the right to cancel under Section 9 (Wis. Stat. 423.201 '
        'to 423.203; 16 CFR Part 429) and the construction-lien Notice to '
        'Owner under Section 12 (Wis. Stat. 779.02(2)), is incorporated into '
        'this Contract and delivered with it.', body))
    s.append(Paragraph(
        '<b>10.5 No Estimate-Only Treatment.</b> This is a binding contract '
        'for the Contract Price stated in Section 3, not an estimate. Any '
        'nonbinding estimate previously provided is superseded by this '
        'Contract (the referenced Estimate survives only as the Exhibit A '
        'specifications incorporated here).', body))
    s.append(Paragraph(
        '<b>10.6 Security Interest.</b> <b>None.</b> CWDB takes no security '
        'interest, mortgage, or lien on the Property or on any of the '
        'Homeowner\'s property as part of this Contract. (This does not affect '
        'the statutory construction-lien rights described in Section 12, which '
        'arise by operation of law for unpaid labor and materials.)', body))

    # ── 11. INSURANCE ───────────────────────────────────────────────────────
    s.append(Paragraph('Section 11. Insurance', sec_h))
    s.append(Paragraph(
        '<b>11.1 CWDB Insurance.</b> CWDB represents that it maintains '
        'commercial general liability insurance covering its operations. CWDB '
        'will provide a certificate of insurance to the Homeowner upon '
        'request.', body))
    s.append(Paragraph(
        '<b>11.2 Subcontractor Insurance.</b> Any subcontractor CWDB engages '
        'for the Work is required, under a separate subcontractor agreement, '
        'to carry its own commercial general liability insurance and workers\' '
        'compensation coverage (or a valid Wisconsin exemption) and to name '
        'CWDB as an additional insured before starting work.', body))

    # ── 12. LIEN NOTICE TO OWNER (CONSPICUOUS) ──────────────────────────────
    s.append(Paragraph('Section 12. Construction Lien Notice to Owner '
                       '(Wis. Stat. 779.02(2))', sec_h))
    s.append(Paragraph(
        'NOTICE TO OWNER. As required by the Wisconsin construction lien law, '
        'Wis. Stat. 779.02(2): "PLEASE READ THIS NOTICE. As a result of '
        'receiving labor or materials for the improvement of your property, '
        'those who provide labor or materials for the work may have a right '
        'under Wisconsin law to claim a construction lien against your '
        'property if they are not paid. Central Wisconsin Deck Builders, LLC, '
        'and any subcontractors and material suppliers, may have lien rights '
        'on your land and buildings if not paid. Those entitled to lien '
        'rights, in addition to Central Wisconsin Deck Builders, LLC, are '
        'those who contract directly with you or those who give you notice '
        'within 60 days after they first furnish labor or materials for the '
        'work. Accordingly, you may receive notices from those who furnish '
        'labor or materials for the work, and you should give a copy of each '
        'notice you receive to your mortgage lender, if any. Central Wisconsin '
        'Deck Builders, LLC, agrees to cooperate with you and your lender, if '
        'any, to see that all potential lien claimants are duly paid. IF YOU '
        'DO NOT UNDERSTAND THESE REQUIREMENTS OR THE STEPS TO PROTECT YOURSELF '
        'FROM CONSTRUCTION LIENS, PLEASE CONSULT YOUR ATTORNEY."', consp))
    s.append(Paragraph(
        '<b>12.2 Lien Waivers.</b> As the Work progresses and as payments are '
        'made, CWDB will, upon request, provide lien waivers and will collect '
        'lien waivers from its subcontractors and suppliers to protect the '
        'Homeowner\'s clear title. The Homeowner acknowledges receiving the '
        'Notice to Owner above.', body))

    # ── 13. DISCLAIMERS / LIMITATION ────────────────────────────────────────
    s.append(Paragraph('Section 13. Warranties, Disclaimers, and Limitation '
                       'of Liability', sec_h))
    s.append(Paragraph(
        '<b>13.1 Exclusive Warranty.</b> The express warranty in Section 7 is '
        'the only warranty CWDB provides. To the fullest extent permitted by '
        'Wisconsin law, and except for the express warranty in Section 7 and '
        'any nondisclaimable warranties under Wisconsin law, CWDB disclaims '
        'all other warranties, whether express or implied, including any '
        'implied warranty of merchantability or fitness for a particular '
        'purpose, beyond the express warranty stated in this Contract.', body))
    s.append(Paragraph(
        '<b>13.2 Limitation of Liability.</b> TO THE FULLEST EXTENT PERMITTED '
        'BY WISCONSIN LAW, CWDB SHALL NOT BE LIABLE TO THE HOMEOWNER FOR ANY '
        'INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, PUNITIVE, OR EXEMPLARY '
        'DAMAGES, INCLUDING DAMAGES FOR LOSS OF USE, INCONVENIENCE, OR LOST '
        'PROFITS, ARISING OUT OF OR RELATING TO THIS CONTRACT OR THE WORK. '
        'CWDB\'s total aggregate liability under this Contract shall not '
        'exceed the Contract Price actually paid by the Homeowner. Nothing in '
        'this Section limits any liability that cannot be limited under '
        'Wisconsin law, including liability for personal injury caused by '
        'CWDB\'s negligence.', body))

    # ── 14. INDEMNIFICATION ─────────────────────────────────────────────────
    s.append(Paragraph('Section 14. Indemnification', sec_h))
    s.append(Paragraph(
        '<b>14.1 CWDB Responsibility for Its Work.</b> CWDB will be '
        'responsible for property damage or bodily injury to the extent caused '
        'by the negligent acts or omissions of CWDB or its subcontractors in '
        'performing the Work, subject to the limitations in Section 13.', body))
    s.append(Paragraph(
        '<b>14.2 Homeowner Responsibility.</b> The Homeowner will hold CWDB '
        'harmless from claims arising out of conditions at the Property that '
        'the Homeowner failed to disclose, the Homeowner\'s own acts or '
        'omissions, or the acts of persons the Homeowner brings onto the '
        'Property who are not under CWDB\'s control.', body))

    # ── 15. DISPUTE RESOLUTION ──────────────────────────────────────────────
    s.append(Paragraph('Section 15. Dispute Resolution', sec_h))
    s.append(Paragraph(
        '<b>15.1 Informal Resolution.</b> Before starting any formal '
        'proceeding, the Party raising a dispute will give the other written '
        'notice, and the Parties will try in good faith to resolve the dispute '
        'through informal negotiation for thirty (30) calendar days.', body))
    s.append(Paragraph(
        '<b>15.2 Binding Arbitration.</b> If the dispute is not resolved '
        'within that thirty (30) day period, either Party may submit the '
        'dispute to binding arbitration conducted in Marathon County, '
        'Wisconsin, by a single arbitrator under the rules of the American '
        'Arbitration Association then in effect. Judgment on the award may be '
        'entered in any court of competent jurisdiction. Nothing in this '
        'Section limits the Homeowner\'s rights under Wis. Stat. ch. 100 or '
        'the right of either Party to seek relief in the small claims court of '
        'Marathon County for disputes within that court\'s jurisdictional '
        'limit.', body))
    s.append(Paragraph(
        '<b>15.3 Equitable Relief.</b> Either Party may seek injunctive relief '
        'in a court of competent jurisdiction to prevent irreparable harm '
        'without first completing the steps in this Section.', body))

    # ── 16. GENERAL PROVISIONS ──────────────────────────────────────────────
    s.append(Paragraph('Section 16. General Provisions', sec_h))
    s.append(Paragraph(
        '<b>16.1 Governing Law; Venue.</b> This Contract is governed by the '
        'laws of the State of Wisconsin. The Parties consent to the exclusive '
        'jurisdiction and venue of the state and federal courts located in '
        'Marathon County, Wisconsin, for any proceeding not subject to '
        'arbitration.', body))
    s.append(Paragraph(
        '<b>16.2 Entire Agreement.</b> This Contract, together with Exhibit A '
        f'(Estimate #{est_no}), the attached Notice of Cancellation, the '
        'construction-lien Notice to Owner, and any signed change orders, is '
        'the entire agreement between the Parties and supersedes all prior '
        'discussions, estimates, and representations.', body))
    s.append(Paragraph(
        '<b>16.3 Amendments; Severability; No Waiver.</b> This Contract may be '
        'amended only by a written instrument or signed change order executed '
        'by both Parties. If any provision is held invalid or unenforceable, '
        'it will be modified to the minimum extent necessary to make it '
        'enforceable, and the remaining provisions will remain in effect. A '
        'Party\'s failure to enforce a provision is not a waiver of the right '
        'to enforce it later.', body))
    s.append(Paragraph(
        '<b>16.4 Assignment.</b> The Homeowner may not assign this Contract '
        'without CWDB\'s written consent. CWDB may use subcontractors as '
        'provided in Section 1.3 but remains responsible for the Work.', body))
    s.append(Paragraph(
        '<b>16.5 Notices.</b> Notices must be in writing and delivered '
        'personally, by email with confirmation, or by certified mail to the '
        'addresses in this Contract.', body))
    s.append(Paragraph(
        '<b>16.6 Counterparts and Electronic Signatures.</b> This Contract may '
        'be signed in counterparts and by electronic signature, each of which '
        'is an original.', body))

    # ── SIGNATURES ──────────────────────────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('Signatures', sec_h),
        Paragraph(
            '<b>IN WITNESS WHEREOF</b>, the Parties have executed this '
            'Contract as of the Effective Date. By signing, the Homeowner '
            'acknowledges reading this Contract, receiving two completed '
            'copies of the Notice of Cancellation, and receiving the Notice to '
            'Owner in Section 12.', body),
        sp(0.12),
        _sig_line('Contractor: Central Wisconsin Deck Builders, LLC',
                  'By: James Slogar, Member'),
        sp(0.18),
        _sig_line('Homeowner', f"Printed name: {client['name']}"),
        sp(0.18),
        _sig_line('Homeowner (all titleholders must sign)',
                  f"Printed name: {co_owner if co_owner else '_' * 40}"),
    ]))

    # ── NOTICE OF CANCELLATION x2 ───────────────────────────────────────────
    for copy_label in ('BUYER COPY 1', 'BUYER COPY 2'):
        s.append(PageBreak())
        s.extend(_notice_of_cancellation(estimate, effective, deadline,
                                         copy_label))

    # ── EXHIBIT A COVER ─────────────────────────────────────────────────────
    s.append(PageBreak())
    s.append(Spacer(1, 2.5 * inch))
    s.append(Paragraph(f'EXHIBIT A', title_h))
    s.append(Paragraph(
        f'Estimate #{est_no}, incorporated into and made part of Home '
        f'Improvement Contract Job No. {job_number}', consp_c))
    if not exhibit_pdf:
        s.append(Spacer(1, 0.3 * inch))
        s.append(Paragraph(
            '(Attach the referenced estimate PDF behind this page.)', small))

    doc.build(s, onFirstPage=_job_footer(job_number),
              onLaterPages=_job_footer(job_number))

    # Append the original estimate PDF behind the Exhibit A cover page.
    if exhibit_pdf:
        from pypdf import PdfWriter
        writer = PdfWriter()
        writer.append(str(output_path))
        writer.append(str(exhibit_pdf))
        with open(output_path, 'wb') as fh:
            writer.write(fh)

    return str(output_path)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('json_path', help='estimate JSON in _data/')
    p.add_argument('--job-number', required=True,
                   help='e.g. CWDB-2026-002 (allocate from the job registry)')
    p.add_argument('--effective-date', default=None,
                   help='YYYY-MM-DD signing date; defaults to today')
    p.add_argument('--start-date', default=None,
                   help='explicit start date wording (overrides schedule.start)')
    p.add_argument('--completion-date', default=None,
                   help='explicit completion wording, e.g. "on or about July '
                        '24, 2026" (overrides duration-based default)')
    p.add_argument('--co-owner', default=None)
    p.add_argument('--warranty', default='one (1) year',
                   help='e.g. "ten (10) years" for build jobs')
    p.add_argument('--permits', choices=list(PERMIT_CLAUSES), default='included')
    p.add_argument('--no-exhibit', action='store_true',
                   help='skip appending the sibling estimate PDF')
    args = p.parse_args()

    data_path = Path(args.json_path).resolve()
    estimate = json.loads(data_path.read_text(encoding='utf-8'))
    effective = (dt.date.fromisoformat(args.effective_date)
                 if args.effective_date else dt.date.today())
    out = data_path.parent.parent / f'{data_path.stem}-contract.pdf'
    exhibit = data_path.parent.parent / f'{data_path.stem}.pdf'
    exhibit = exhibit if (exhibit.exists() and not args.no_exhibit) else None

    path = generate_sow(estimate, out, args.job_number, effective,
                        co_owner=args.co_owner, warranty=args.warranty,
                        permits=args.permits, start_date=args.start_date,
                        completion_date=args.completion_date,
                        exhibit_pdf=exhibit)
    deadline = cancellation_deadline(effective)
    print(f'Contract written: {path}')
    print(f'Exhibit A: {exhibit if exhibit else "NOT ATTACHED (attach manually)"}')
    print(f'Effective date: {long_date(effective)}')
    print(f'Cancellation deadline (midnight of): {long_date(deadline)}')
    print('GATE REMINDER: GL insurance bound + DSPS Dwelling Contractor '
          'Certification filed before sending for signature. Hand the buyer '
          'BOTH Notice of Cancellation copies; hold the deposit until the '
          'deadline passes.')
