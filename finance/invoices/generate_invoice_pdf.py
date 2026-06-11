"""
CWDB Customer Invoice PDF Generator
Central Wisconsin Deck Builders, LLC

Renders a CWDB-branded customer invoice (deposit, progress, or final) from a
JSON data file in finance/invoices/_data/. Reuses the brand styles and layout
helpers from sales/estimates/generate_estimate_pdf.py so invoices match the
estimate and work-order look (Crafted Orange #e54c00, Timber Slate #323434,
horizontal logo, orange divider rules).

Invoice number series: INV-YYYY-NNN, sequential per calendar year across all
customers. The series is owned by the accounting agent (see
~/.claude/agent-memory/accounting/billing-terms.md). Until the QuickBooks
Online API connection is live, invoices generated here must be entered into
QBO manually once connected (books of record).

Standing policies (owner decisions, Jim, 2026-06-10):
- NO sales tax on any CWDB invoice. This generator renders no tax line and
  ignores any "tax" key in the JSON.
- Payment methods, in this order: (1) card or digital payment via the
  QuickBooks invoice link, (2) check payable to Central Wisconsin Deck
  Builders, LLC. Cash is NOT accepted. If the JSON omits
  "payment_instructions", DEFAULT_PAYMENT_INSTRUCTIONS below is used.

Usage:
    python generate_invoice_pdf.py _data/INV-2026-001-overbeck-deposit.json

The PDF is written next to finance/invoices/ (one level up from _data/) with
the same stem and a .pdf extension.
"""

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / 'sales' / 'estimates'))

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.enums import TA_RIGHT
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, KeepTogether)

from generate_estimate_pdf import (ORANGE, SLATE, GREY, LIGHT_BG, ROW_ALT,
                                   _logo_flowable, _hr, _footer,
                                   body, h2, note, nap, small, meta,
                                   client_h, client_b,
                                   table_h, table_h_r, table_c, table_c_r,
                                   total, total_r)

due_style = ParagraphStyle('due_style', fontName='Helvetica-Bold', fontSize=13,
                           leading=17, textColor=ORANGE, alignment=TA_RIGHT)

# Default payment methods for ALL invoices (owner decision 2026-06-10):
# card/digital first, check second, no cash.
DEFAULT_PAYMENT_INSTRUCTIONS = [
    '<b>Card or digital payment:</b> pay online with a credit or debit card, '
    'or by bank transfer, using the secure QuickBooks payment link in the '
    'invoice email. Questions? Call (715) 544-7941 or email '
    'info@cwdeckbuilders.com.',
    '<b>Check:</b> payable to <b>Central Wisconsin Deck Builders, LLC</b>. '
    'Mail or deliver to 906 N 16th Ave, Wausau, WI 54401.',
]


def _money2(n):
    return '${:,.2f}'.format(n)


def _bill_to_block(bill_to, invoice):
    rows = [
        [Paragraph('BILL TO', client_h), Paragraph('REMIT TO', client_h)],
        [Paragraph(f"<b>{bill_to['name']}</b>", client_b),
         Paragraph('<b>Central Wisconsin Deck Builders, LLC</b>', client_b)],
        [Paragraph(bill_to['address_line'], client_b),
         Paragraph('906 N 16th Ave, Wausau, WI 54401', client_b)],
        [Paragraph(bill_to['phone'], client_b),
         Paragraph('(715) 544-7941', client_b)],
        [Paragraph(bill_to['email'], client_b),
         Paragraph('info@cwdeckbuilders.com', client_b)],
    ]
    t = Table(rows, colWidths=[3.1 * inch, 3.1 * inch])
    t.setStyle(TableStyle([
        ('VALIGN',        (0, 0), (-1, -1), 'TOP'),
        ('TOPPADDING',    (0, 0), (-1, -1), 1),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ('LEFTPADDING',   (0, 0), (-1, -1), 0),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 0),
    ]))
    return t


def _amount_due_table(invoice):
    # No tax line, ever: owner decision 2026-06-10 (no sales tax on any CWDB
    # invoice). Any "tax" key in the JSON is intentionally ignored.
    line_items = invoice['line_items']
    amount_due = sum(amt for _, amt in line_items)

    rows = [[Paragraph('Description', table_h), Paragraph('Amount', table_h_r)]]
    for label, amount in line_items:
        rows.append([Paragraph(label, table_c),
                     Paragraph(_money2(amount), table_c_r)])
    rows.append([Paragraph('AMOUNT DUE', total),
                 Paragraph(_money2(amount_due), total_r)])

    t = Table(rows, colWidths=[4.5 * inch, 1.7 * inch])
    style = [
        ('VALIGN',        (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING',    (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING',   (0, 0), (-1, -1), 10),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 10),
        ('BACKGROUND',    (0, 0), (-1, 0),  LIGHT_BG),
        ('LINEBELOW',     (0, 0), (-1, 0),  0.6, GREY),
        ('LINEABOVE',     (0, -1), (-1, -1), 1.2, ORANGE),
        ('BACKGROUND',    (0, -1), (-1, -1), LIGHT_BG),
    ]
    for i in range(1, len(rows) - 1):
        if i % 2 == 0:
            style.append(('BACKGROUND', (0, i), (-1, i), ROW_ALT))
    t.setStyle(TableStyle(style))
    return t, amount_due


def _payment_schedule_table(invoice):
    rows = [[Paragraph('Payment', table_h), Paragraph('Amount', table_h_r),
             Paragraph('When due', table_h)]]
    for label, amount, when in invoice['payment_schedule']:
        rows.append([Paragraph(label, table_c),
                     Paragraph(_money2(amount), table_c_r),
                     Paragraph(when, table_c)])
    rows.append([Paragraph('Total Price', total),
                 Paragraph(_money2(invoice['contract_total']), total_r),
                 Paragraph('', table_c)])
    t = Table(rows, colWidths=[1.6 * inch, 1.1 * inch, 3.5 * inch])
    t.setStyle(TableStyle([
        ('VALIGN',        (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING',    (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING',   (0, 0), (-1, -1), 8),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 8),
        ('BACKGROUND',    (0, 0), (-1, 0),  LIGHT_BG),
        ('LINEBELOW',     (0, 0), (-1, 0),  0.6, GREY),
        ('BACKGROUND',    (0, 2), (-1, 2),  ROW_ALT),
        ('LINEABOVE',     (0, -1), (-1, -1), 1.2, ORANGE),
        ('BACKGROUND',    (0, -1), (-1, -1), LIGHT_BG),
    ]))
    return t


def generate_invoice(invoice, output_path):
    doc = SimpleDocTemplate(
        str(output_path), pagesize=letter,
        leftMargin=0.85 * inch, rightMargin=0.85 * inch,
        topMargin=0.55 * inch, bottomMargin=0.75 * inch,
        title=(f"{invoice['invoice_type'].title()} {invoice['invoice_number']}"
               f" for {invoice['bill_to']['name']}"),
        author='Central Wisconsin Deck Builders, LLC',
    )

    s = []
    sp = lambda n=0.1: Spacer(1, n * inch)

    # HEADER: logo + NAP
    s.append(_logo_flowable(target_width_in=2.8))
    s.append(sp(0.06))
    s.append(Paragraph(
        'cwdeckbuilders.com  ·  (715) 544-7941  ·  info@cwdeckbuilders.com',
        nap))
    s.append(Paragraph(
        '906 N 16th Ave, Wausau, WI 54401  ·  Entity ID C138564  ·  EIN 41-5355234',
        small))
    s.append(_hr(color=ORANGE, thickness=2, space_after=8, space_before=8))

    # INVOICE META BAR
    s.append(Paragraph(
        f"{invoice['invoice_type']}  ·  {invoice['invoice_number']}  ·  "
        f"Issued {invoice['date_issued']}  ·  Terms: {invoice['terms']}",
        meta))
    s.append(sp(0.1))

    # BILL TO / REMIT TO
    s.append(_bill_to_block(invoice['bill_to'], invoice))
    s.append(_hr(color=GREY, thickness=0.5, space_after=10, space_before=12))

    # JOB REFERENCE
    s.append(Paragraph('Job Reference', h2))
    s.append(Paragraph(
        f"<b>Job No. {invoice['job_number']}</b>  ·  "
        f"{invoice['contract_ref']}  ·  "
        f"Ref. Estimate #{invoice['estimate_number']}", body))
    s.append(Paragraph(invoice['project_summary'], body))

    # AMOUNT DUE
    amount_table, amount_due = _amount_due_table(invoice)
    s.append(KeepTogether([
        Paragraph('Amount Due', h2),
        amount_table,
        sp(0.08),
        Paragraph(f'Amount due: <b>{_money2(amount_due)}</b>  ·  '
                  f"{invoice['terms']}", due_style),
    ]))

    # CONTRACT PAYMENT SCHEDULE
    s.append(KeepTogether([
        Paragraph('Contract Payment Schedule', h2),
        Paragraph(
            f"Total Price under your signed Work Order is "
            f"<b>{_money2(invoice['contract_total'])}</b>, payable as follows:",
            body),
        _payment_schedule_table(invoice),
    ]))

    # HOW TO PAY (card/digital first, check second, no cash: policy 2026-06-10)
    s.append(Paragraph('How to Pay', h2))
    for item in invoice.get('payment_instructions',
                            DEFAULT_PAYMENT_INSTRUCTIONS):
        s.append(Paragraph(f'• {item}', body))
    s.append(sp(0.04))
    s.append(Paragraph(f"<i>{invoice['remittance_note']}</i>", note))

    # NOTES
    s.append(Paragraph('Notes', h2))
    for item in invoice['notes']:
        s.append(Paragraph(f'• {item}', body))

    s.append(sp(0.12))
    s.append(_hr(color=GREY, thickness=0.5, space_after=6, space_before=6))
    s.append(Paragraph(
        'Thank you for your business. Questions about this invoice? Call '
        '(715) 544-7941 or email info@cwdeckbuilders.com.', note))

    doc.build(s, onFirstPage=_footer, onLaterPages=_footer)
    return str(output_path)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('usage: python generate_invoice_pdf.py <path-to-invoice.json>',
              file=sys.stderr)
        sys.exit(1)

    data_path = Path(sys.argv[1]).resolve()
    invoice = json.loads(data_path.read_text(encoding='utf-8'))
    out = data_path.parent.parent / f'{data_path.stem}.pdf'
    print(f'Invoice PDF written: {generate_invoice(invoice, out)}')
    if invoice.get('_meta', {}).get('qbo_status'):
        print(f"QBO: {invoice['_meta']['qbo_status']}")
