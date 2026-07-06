"""
CWDB Staining Work Order PDF Generator (interim, staining-only)
Central Wisconsin Deck Builders, LLC

Renders docs/legal/templates/staining-work-order-interim.md as a signable PDF
from the same estimate JSON that feeds generate_estimate_pdf.py. Includes the
ATCP 110.05(2) required contents, the conspicuous 3-day right-to-cancel block
(Wis. Stat. 423.202-.203 + 16 CFR 429), the Wis. Stat. 779.02(2) Notice to
Owner, and TWO copies of the Notice of Cancellation on separate pages.

Scope guard: staining/sealing/refinishing of an existing structurally sound
deck ONLY. Build/structural jobs use the full Home Improvement Contract and
wait for the DSPS/insurance gate.

Usage:
    python generate_work_order_pdf.py _data/2026-06-03-overbeck-stain.json \
        --job-number CWDB-2026-001 \
        --effective-date 2026-06-10 \
        [--co-owner "Name"] [--salesperson "James Slogar"]

Generate this ON the signing day (or pass the planned signing date): the
cancellation deadline is computed from --effective-date and printed on the
Notice of Cancellation. A wrong date understates the buyer's rights.

The PDF is written next to sales/estimates/ as <stem>-work-order.pdf.
"""

import argparse
import datetime as dt
import json
from pathlib import Path

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.enums import TA_LEFT, TA_CENTER
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, KeepTogether, PageBreak)

from generate_estimate_pdf import (ORANGE, SLATE, GREY, LIGHT_BG, ROW_ALT,
                                   _logo_flowable, _hr, _money, _footer,
                                   body, h2, bullet, note, nap, small, meta,
                                   client_h, client_b, sig,
                                   table_h, table_h_r, table_c, table_c_r,
                                   total, total_r)

# Conspicuous type: bold and LARGER than the 10.5pt body, per ATCP 110 /
# Wis. Stat. ch. 423 / 16 CFR 429 conspicuousness requirements.
consp = ParagraphStyle('consp', fontName='Helvetica-Bold', fontSize=11.5,
                       leading=16, textColor=SLATE, spaceAfter=6,
                       alignment=TA_LEFT)
consp_c = ParagraphStyle('consp_c', parent=consp, alignment=TA_CENTER)
sec_h = ParagraphStyle('sec_h', parent=h2, fontSize=12.5, spaceBefore=12)
title_h = ParagraphStyle('title_h', fontName='Helvetica-Bold', fontSize=15,
                         leading=19, textColor=SLATE, spaceAfter=4,
                         alignment=TA_CENTER)


def federal_holidays(year):
    """Actual-date US federal holidays (observed shifts not applied; the
    cancellation clock skips Sundays and holidays per 16 CFR 429 / ch. 423)."""
    def nth_weekday(month, weekday, n):
        d = dt.date(year, month, 1)
        offset = (weekday - d.weekday()) % 7
        return d + dt.timedelta(days=offset + 7 * (n - 1))

    def last_weekday(month, weekday):
        d = (dt.date(year, month + 1, 1) - dt.timedelta(days=1)
             if month < 12 else dt.date(year, 12, 31))
        return d - dt.timedelta(days=(d.weekday() - weekday) % 7)

    return {
        dt.date(year, 1, 1),            # New Year's Day
        nth_weekday(1, 0, 3),           # MLK Day
        nth_weekday(2, 0, 3),           # Washington's Birthday
        last_weekday(5, 0),             # Memorial Day
        dt.date(year, 6, 19),           # Juneteenth
        dt.date(year, 7, 4),            # Independence Day
        nth_weekday(9, 0, 1),           # Labor Day
        nth_weekday(10, 0, 2),          # Columbus Day
        dt.date(year, 11, 11),          # Veterans Day
        nth_weekday(11, 3, 4),          # Thanksgiving
        dt.date(year, 12, 25),          # Christmas
    }


def cancellation_deadline(effective):
    """Midnight of the 3rd business day after the transaction date.
    Business day = any day except Sundays and federal holidays (Saturdays
    count, per the FTC Cooling-Off Rule)."""
    holidays = federal_holidays(effective.year) | federal_holidays(effective.year + 1)
    d, counted = effective, 0
    while counted < 3:
        d += dt.timedelta(days=1)
        if d.weekday() == 6 or d in holidays:
            continue
        counted += 1
    return d


def long_date(d):
    return f'{d:%A}, {d:%B} {d.day}, {d.year}'


def _sig_line(label, name_line):
    rows = [
        [Paragraph(label, client_h), Paragraph('Date', client_h)],
        [Paragraph('_' * 50, sig), Paragraph('_' * 18, sig)],
        [Paragraph(name_line, client_b), Paragraph('', client_b)],
    ]
    t = Table(rows, colWidths=[4.2 * inch, 2.0 * inch])
    t.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'BOTTOM'),
        ('TOPPADDING', (0, 0), (-1, -1), 1),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ('LEFTPADDING', (0, 0), (-1, -1), 0),
        ('RIGHTPADDING', (0, 0), (-1, -1), 0),
    ]))
    return t


def _payment_table(deposit, balance, total_amount, deposit_pct):
    rows = [
        [Paragraph('Payment', table_h), Paragraph('Amount', table_h_r),
         Paragraph('When due', table_h)],
        [Paragraph('Deposit at signing', table_c),
         Paragraph(_money(deposit), table_c_r),
         Paragraph(f'({deposit_pct}% of Total Price) Held, not deposited or '
                   'spent, until the three-business-day cancellation period '
                   'in Section 7 expires', table_c)],
        [Paragraph('Final payment', table_c),
         Paragraph(_money(balance), table_c_r),
         Paragraph('Remaining balance, upon completion of the Work and your '
                   'walkthrough', table_c)],
        [Paragraph('Total Price', total), Paragraph(_money(total_amount), total_r),
         Paragraph('', table_c)],
    ]
    t = Table(rows, colWidths=[1.4 * inch, 1.1 * inch, 3.7 * inch])
    t.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('BACKGROUND', (0, 0), (-1, 0), LIGHT_BG),
        ('LINEBELOW', (0, 0), (-1, 0), 0.6, GREY),
        ('BACKGROUND', (0, 2), (-1, 2), ROW_ALT),
        ('LINEABOVE', (0, -1), (-1, -1), 1.2, ORANGE),
        ('BACKGROUND', (0, -1), (-1, -1), LIGHT_BG),
    ]))
    return t


def _notice_of_cancellation(estimate, effective, deadline, copy_label):
    """One full Notice of Cancellation (16 CFR 429 / Wis. Stat. 423.203)."""
    s = [
        Paragraph(f'NOTICE OF CANCELLATION: {copy_label}', title_h),
        Paragraph('(Keep this copy for your records)' if 'COPY 1' in copy_label
                  else '(Sign and return this copy only if you wish to cancel)',
                  small),
        _hr(color=ORANGE, thickness=2, space_after=10, space_before=6),
        Paragraph(f'<b>Date of Transaction:</b> {long_date(effective)}', consp),
        Spacer(1, 0.08 * inch),
        Paragraph('YOU MAY CANCEL THIS TRANSACTION, WITHOUT ANY PENALTY OR '
                  'OBLIGATION, WITHIN THREE BUSINESS DAYS FROM THE ABOVE DATE.',
                  consp),
        Paragraph('If you cancel, any payments made by you under this Agreement, '
                  'and any negotiable instrument executed by you, will be returned '
                  'within TEN (10) DAYS following CWDB\'s receipt of your '
                  'cancellation notice, and any security interest arising out of '
                  'the transaction will be cancelled.', body),
        Paragraph('If CWDB has delivered any goods or materials to you under this '
                  'Agreement, you must make them available to CWDB at your '
                  'residence in substantially as good condition as when received; '
                  'or you may comply with CWDB\'s instructions regarding return at '
                  'CWDB\'s expense and risk. If CWDB does not pick them up within '
                  'twenty (20) days of the date of your Notice of Cancellation, '
                  'you may keep or dispose of them without further obligation.',
                  body),
        Paragraph('TO CANCEL THIS TRANSACTION, mail or deliver a signed and dated '
                  'copy of this Notice of Cancellation, or any other written '
                  'notice, to:', body),
        Paragraph('Central Wisconsin Deck Builders, LLC, 906 N 16th Ave, '
                  'Wausau, WI 54401', consp_c),
        Paragraph(f'NOT LATER THAN MIDNIGHT OF <u>{long_date(deadline).upper()}</u> '
                  '(the third business day after the date of the transaction, not '
                  'counting Sundays and federal holidays).', consp),
        Spacer(1, 0.15 * inch),
        Paragraph('I HEREBY CANCEL THIS TRANSACTION.', consp),
        Spacer(1, 0.1 * inch),
        _sig_line('Buyer signature', 'Printed name: ' + '_' * 40),
        Spacer(1, 0.08 * inch),
        Paragraph('Date of this Cancellation: ' + '_' * 24, body),
    ]
    return s


def generate_work_order(estimate, output_path, job_number, effective,
                        co_owner=None, salesperson='James Slogar'):
    total_amount = (estimate.get('_meta', {}).get('computed_sell_price')
                    or sum(amt for _, amt in estimate['line_items']))
    deposit_pct = estimate['payment']['deposit_pct']
    deposit = round(total_amount * deposit_pct / 100)
    balance = total_amount - deposit
    deadline = cancellation_deadline(effective)
    client = estimate['client']
    proj = estimate['project']

    doc = SimpleDocTemplate(
        str(output_path), pagesize=letter,
        leftMargin=0.85 * inch, rightMargin=0.85 * inch,
        topMargin=0.55 * inch, bottomMargin=0.75 * inch,
        title=f"Deck Staining Work Order, {client['name']}, {job_number}",
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
    s.append(Paragraph('DECK STAINING WORK ORDER AND<br/>HOME IMPROVEMENT AGREEMENT',
                       title_h))
    s.append(Paragraph(
        f"Job No. {job_number}  ·  Effective Date {long_date(effective)}  ·  "
        f"Ref. Estimate #{estimate['estimate_number']}", meta))
    s.append(sp(0.08))

    # ── PARTIES ─────────────────────────────────────────────────────────────
    owner_names = client['name'] + (f' and {co_owner}' if co_owner else '')
    s.append(Paragraph(
        f"<b>This Agreement</b> is entered into as of the Effective Date above "
        f"between:", body))
    s.append(Paragraph(
        '<b>Seller / Contractor:</b> Central Wisconsin Deck Builders, LLC, a '
        'Wisconsin limited liability company, 906 N 16th Ave, Wausau, WI 54401, '
        'phone (715) 544-7941, email info@cwdeckbuilders.com ("CWDB," "we," or '
        f'"us"). <b>Salesperson / Representative:</b> {salesperson}.', body))
    s.append(Paragraph(
        f"<b>Buyer / Owner:</b> {owner_names}, mailing address "
        f"{client['address_line']}, phone {client['phone']}, email "
        f"{client['email']} (\"you\" or \"Owner\").", body))

    # ── 1. THE WORK ─────────────────────────────────────────────────────────
    s.append(Paragraph('1. The Work (Description of work and materials)', sec_h))
    s.append(Paragraph(
        'CWDB will furnish the labor, materials, equipment, and supervision to '
        'perform the following <b>deck staining / refinishing work</b> at the '
        'Property described in Section 2:', body))
    s.append(Paragraph(proj['overview'], body))
    s.append(Paragraph('<b>Scope of work (what we will do):</b>', body))
    for item in proj['scope']:
        s.append(Paragraph(f'• {item}', bullet))
    materials = estimate['included'][0] if estimate.get('included') else (
        'all premium finish product, sandpaper, brushes, pads, rollers, drop '
        'cloths, and masking')
    s.append(Paragraph(
        f'<b>Materials.</b> CWDB will supply: {materials}. The finish product '
        'and color are as stated in the referenced Estimate.', body))
    s.append(Paragraph(
        '<b>Not included.</b> The following are not part of this Agreement and, '
        'if needed, will be handled only by a signed written change order under '
        'Section 8 or quoted separately:', body))
    for item in estimate.get('not_included', []):
        s.append(Paragraph(f'• {item}', bullet))
    s.append(Paragraph(
        '<b>Surface-finish only / no structural work.</b> This Agreement covers '
        'cosmetic surface finishing of an existing, structurally sound deck. It '
        'does not include and CWDB is not performing any structural construction, '
        'repair, board replacement beyond cosmetic, framing, footing, ledger, or '
        'railing-rebuild work. If CWDB discovers rot, structural defects, or '
        'other concealed conditions during preparation, CWDB will stop affected '
        'work and notify you, and any such repair will be addressed only by a '
        'separate signed agreement.', body))

    # ── 2. THE PROPERTY ─────────────────────────────────────────────────────
    s.append(Paragraph('2. The Property', sec_h))
    s.append(Paragraph(
        f"CWDB will perform the Work at: <b>{client['address_line']}</b> (the "
        '"Property"). You represent that you own the Property or are otherwise '
        'authorized to contract for this Work.', body))

    # ── 3. TOTAL PRICE ──────────────────────────────────────────────────────
    s.append(Paragraph('3. Total Price', sec_h))
    s.append(Paragraph(
        f'The total price for the Work is <b>{_money(total_amount)}</b> (the '
        '"Total Price"). This is a fixed price subject only to signed change '
        'orders under Section 8. Payment methods accepted: '
        f"{estimate['payment']['methods']}.", body))

    # ── 4. DEPOSIT AND PAYMENT SCHEDULE ─────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('4. Deposit and Payment Schedule', sec_h),
        _payment_table(deposit, balance, total_amount, deposit_pct),
    ]))
    s.append(sp(0.05))
    s.append(Paragraph(
        '<b>4.1 Deposit-use restriction.</b> CWDB will not deposit, spend, or '
        'apply your deposit, and will not order job-specific materials against '
        'it, until your three-business-day right to cancel under Section 7 has '
        'expired. If you cancel within that period, your deposit is fully '
        'refundable as stated in Section 7.', body))
    s.append(Paragraph(
        '<b>4.2 No advance beyond deposit.</b> CWDB will not require any payment '
        'beyond the deposit before the Work is complete, except by signed change '
        'order.', body))

    # ── 5. SCHEDULE ─────────────────────────────────────────────────────────
    sched = estimate['schedule']
    s.append(Paragraph('5. Schedule (Start and completion)', sec_h))
    s.append(Paragraph(
        f"<b>5.1 Start date.</b> CWDB will begin the Work on or about "
        f"<b>{sched['start']}</b>, after the cancellation period in Section 7 "
        'has expired, weather permitting.', body))
    s.append(Paragraph(
        f"<b>5.2 Completion date.</b> CWDB estimates the Work will be complete "
        f"within approximately <b>{sched['duration']}</b> of the start date, "
        'subject to weather and proper finish cure. '
        f"{sched.get('weather', '')}", body))

    # ── 6. SECURITY INTEREST ────────────────────────────────────────────────
    s.append(Paragraph('6. Security Interest', sec_h))
    s.append(Paragraph(
        '<b>None.</b> CWDB takes <b>no</b> security interest, mortgage, or lien '
        'on the Property or on any of your property as part of this Agreement. '
        '(This does not affect the statutory construction-lien rights described '
        'in the Notice to Owner in Section 11, which arise by operation of law '
        'for unpaid labor and materials.)', body))

    # ── 7. RIGHT TO CANCEL (CONSPICUOUS) ────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('7. Your Right to Cancel', sec_h),
        Paragraph('YOU, THE BUYER, MAY CANCEL THIS TRANSACTION AT ANY TIME PRIOR '
                  'TO MIDNIGHT OF THE THIRD BUSINESS DAY AFTER THE DATE OF THIS '
                  'TRANSACTION.', consp),
        Paragraph('This right is provided under the Wisconsin Consumer Act, '
                  'Wis. Stat. 423.202 and 423.203, and the federal Cooling-Off '
                  'Rule, 16 CFR Part 429.', consp),
    ]))
    s.append(Paragraph(
        '<b>7.1 Two copies provided.</b> CWDB has given you <b>two (2) completed '
        'copies of the attached Notice of Cancellation</b> and has informed you '
        'of your right to cancel.', body))
    s.append(Paragraph(
        '<b>7.2 How to cancel.</b> To cancel, sign and date one copy of the '
        'attached Notice of Cancellation and mail or deliver it, or send any '
        'other written notice of cancellation, to Central Wisconsin Deck '
        'Builders, LLC, 906 N 16th Ave, Wausau, WI 54401, not later than '
        f'midnight of <b>{long_date(deadline)}</b> (the third business day after '
        'the Effective Date).', body))
    s.append(Paragraph(
        '<b>7.3 Refund of deposit.</b> If you cancel within the cancellation '
        'period, CWDB will return your deposit and any other payments in full '
        'within <b>ten (10) days</b> after receiving your cancellation notice, '
        'and any security interest arising out of the transaction will be '
        'cancelled. As stated in Section 4.1, your deposit will not be spent '
        'during the cancellation period.', body))

    # ── 8. CHANGE ORDERS ────────────────────────────────────────────────────
    s.append(Paragraph('8. Change Orders', sec_h))
    s.append(Paragraph(
        '<b>8.1 Written changes only.</b> Any change to the scope, materials, '
        'price, or schedule must be in a written change order signed by both '
        'CWDB and you before the changed work proceeds.', body))
    s.append(Paragraph(
        '<b>8.2 No verbal changes.</b> CWDB is not obligated to perform, and you '
        'are not obligated to pay for, any extra or changed work that is not '
        'covered by a signed change order. Verbal requests do not bind either '
        'party.', body))

    # ── 9. WARRANTY ─────────────────────────────────────────────────────────
    s.append(Paragraph('9. Warranty', sec_h))
    s.append(Paragraph(
        '<b>9.1 Workmanship warranty.</b> CWDB warrants the Work will be free '
        'from defects in workmanship for <b>one (1) year</b> from the date of '
        'completion. If a covered workmanship defect appears within that period '
        'and you give CWDB written notice within the period, CWDB will, at its '
        'option and at no charge, correct the defect.', body))
    s.append(Paragraph(
        '<b>9.2 Exclusions.</b> This warranty does not cover normal weathering, '
        'fading, or wear; failure to maintain or re-coat on a normal schedule; '
        'movement, splitting, or grain shadow of natural wood consistent with '
        'industry norms; a single-coat application showing grain shadow through '
        'the finish where a single coat was specified; damage from storms, '
        'floods, or other events beyond CWDB\'s control; or any pre-existing '
        'structural condition. Manufacturer warranties on the finish product, if '
        'any, pass through to you to the extent transferable.', body))

    # ── 10. INCORPORATED DOCUMENTS ──────────────────────────────────────────
    s.append(Paragraph('10. Incorporated Documents and Entire Agreement', sec_h))
    s.append(Paragraph(
        'This Agreement incorporates and includes: (a) the referenced '
        f"<b>Estimate #{estimate['estimate_number']} (Job No. {job_number})</b>; "
        '(b) the attached <b>Notice of Cancellation</b> (two copies); and (c) '
        'the <b>Notice to Owner</b> in Section 11. Together these are the entire '
        'agreement between the parties for this Work and supersede all prior '
        'estimates, discussions, and representations. This Agreement may be '
        'amended only by a signed writing or signed change order. This Agreement '
        'is governed by the laws of the State of Wisconsin, and venue for any '
        'dispute lies in Marathon County, Wisconsin. CWDB has made no false, '
        'deceptive, or misleading representation regarding the Work, and you are '
        'not relying on any promise not written here.', body))

    # ── 11. NOTICE TO OWNER (CONSPICUOUS) ───────────────────────────────────
    s.append(Paragraph('11. Notice to Owner (Wis. Stat. 779.02(2))', sec_h))
    s.append(Paragraph(
        'NOTICE TO OWNER. As required by the Wisconsin construction lien law, '
        'Wis. Stat. 779.02(2): "PLEASE READ THIS NOTICE. As a result of '
        'receiving labor or materials for the improvement of your property, '
        'those who provide labor or materials for the work may have a right '
        'under Wisconsin law to claim a construction lien against your property '
        'if they are not paid. Central Wisconsin Deck Builders, LLC, and any '
        'subcontractors and material suppliers, may have lien rights on your '
        'land and buildings if not paid. Those entitled to lien rights, in '
        'addition to Central Wisconsin Deck Builders, LLC, are those who '
        'contract directly with you or those who give you notice within 60 days '
        'after they first furnish labor or materials for the work. Accordingly, '
        'you may receive notices from those who furnish labor or materials for '
        'the work, and you should give a copy of each notice you receive to '
        'your mortgage lender, if any. Central Wisconsin Deck Builders, LLC, '
        'agrees to cooperate with you and your lender, if any, to see that all '
        'potential lien claimants are duly paid. IF YOU DO NOT UNDERSTAND THESE '
        'REQUIREMENTS OR THE STEPS TO PROTECT YOURSELF FROM CONSTRUCTION LIENS, '
        'PLEASE CONSULT YOUR ATTORNEY."', consp))
    s.append(Paragraph(
        'You acknowledge receiving this Notice to Owner as part of this '
        'Agreement.', body))

    # ── SIGNATURES ──────────────────────────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('Signatures', sec_h),
        Paragraph(
            'By signing, you acknowledge that you have read this Agreement, '
            'received two completed copies of the Notice of Cancellation, and '
            'received the Notice to Owner.', body),
        sp(0.12),
        _sig_line('Contractor: Central Wisconsin Deck Builders, LLC',
                  'By: James Slogar, Member'),
        sp(0.18),
        _sig_line('Owner', f"Printed name: {client['name']}"),
        sp(0.18),
        _sig_line('Owner (all titleholders must sign)',
                  f"Printed name: {co_owner if co_owner else '_' * 40}"),
    ]))

    # ── NOTICE OF CANCELLATION x2 (separate pages) ──────────────────────────
    for copy_label in ('BUYER COPY 1', 'BUYER COPY 2'):
        s.append(PageBreak())
        s.extend(_notice_of_cancellation(estimate, effective, deadline,
                                         copy_label))

    doc.build(s, onFirstPage=_footer, onLaterPages=_footer)
    return str(output_path)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('json_path', help='estimate JSON in _data/')
    p.add_argument('--job-number', required=True,
                   help='e.g. CWDB-2026-001 (allocate from the job registry)')
    p.add_argument('--effective-date', default=None,
                   help='YYYY-MM-DD signing date; defaults to today. The '
                        'cancellation deadline is computed from this.')
    p.add_argument('--co-owner', default=None,
                   help='co-titleholder name (all titleholders must sign)')
    p.add_argument('--salesperson', default='James Slogar')
    args = p.parse_args()

    data_path = Path(args.json_path).resolve()
    estimate = json.loads(data_path.read_text(encoding='utf-8'))
    effective = (dt.date.fromisoformat(args.effective_date)
                 if args.effective_date else dt.date.today())
    out = data_path.parent.parent / f'{data_path.stem}-work-order.pdf'
    path = generate_work_order(estimate, out, args.job_number, effective,
                               co_owner=args.co_owner,
                               salesperson=args.salesperson)
    deadline = cancellation_deadline(effective)
    print(f'Work order written: {path}')
    print(f'Effective date: {long_date(effective)}')
    print(f'Cancellation deadline (midnight of): {long_date(deadline)}')
    print('REMINDER: generate this on (or for) the actual signing date; hand '
          'the buyer BOTH Notice of Cancellation copies; hold the deposit '
          'until the deadline passes.')
