"""
CWDB Project Estimate PDF Generator
Central Wisconsin Deck Builders, LLC

Mirrors the Google Docs visual layout: horizontal logo, orange section
headers, slate body, light-grey alternating table rows, orange divider rules.

Usage:
    python generate_estimate_pdf.py _data/2026-05-13-overbeck-deck-repair.json

The PDF is written next to sales/estimates/ (one level up from _data/) with
the same stem and a .pdf extension.
"""

from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.lib.utils import ImageReader
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, HRFlowable, Image, KeepTogether)
from reportlab.lib.enums import TA_LEFT, TA_RIGHT, TA_CENTER

ORANGE   = colors.HexColor('#e54c00')
SLATE    = colors.HexColor('#323434')
GREY     = colors.HexColor('#646760')
LIGHT_BG = colors.HexColor('#f7f4f1')
ROW_ALT  = colors.HexColor('#fafafa')

REPO_ROOT = Path(__file__).resolve().parents[2]
LOGO_PATH = REPO_ROOT / 'branding' / 'logos' / '1.2-horizontal-logo-high-res.png'

body      = ParagraphStyle('body', fontName='Helvetica', fontSize=10.5, leading=15,
                           textColor=SLATE, spaceAfter=5, alignment=TA_LEFT)
body_b    = ParagraphStyle('body_b', parent=body, fontName='Helvetica-Bold')
h2        = ParagraphStyle('h2', fontName='Helvetica-Bold', fontSize=13.5, leading=18,
                           textColor=ORANGE, spaceAfter=6, spaceBefore=14, alignment=TA_LEFT)
small     = ParagraphStyle('small', fontName='Helvetica', fontSize=9, leading=12,
                           textColor=GREY, spaceAfter=2, alignment=TA_CENTER)
nap       = ParagraphStyle('nap', fontName='Helvetica', fontSize=9.5, leading=13,
                           textColor=SLATE, spaceAfter=2, alignment=TA_CENTER)
meta      = ParagraphStyle('meta', fontName='Helvetica-Bold', fontSize=10, leading=13,
                           textColor=SLATE, spaceAfter=4, alignment=TA_CENTER)
client_h  = ParagraphStyle('client_h', fontName='Helvetica-Bold', fontSize=11, leading=14,
                           textColor=ORANGE, spaceAfter=3, alignment=TA_LEFT)
client_b  = ParagraphStyle('client_b', fontName='Helvetica', fontSize=10.5, leading=14,
                           textColor=SLATE, spaceAfter=2, alignment=TA_LEFT)
overview  = ParagraphStyle('overview', fontName='Helvetica', fontSize=10.5, leading=15.5,
                           textColor=SLATE, spaceAfter=8, alignment=TA_LEFT)
bullet    = ParagraphStyle('bullet', fontName='Helvetica', fontSize=10.5, leading=14.5,
                           textColor=SLATE, spaceAfter=3, leftIndent=14, bulletIndent=2)
note      = ParagraphStyle('note', fontName='Helvetica-Oblique', fontSize=10, leading=14,
                           textColor=GREY, spaceAfter=6, leftIndent=0, alignment=TA_LEFT)
table_h   = ParagraphStyle('table_h', fontName='Helvetica-Bold', fontSize=10.5, leading=13,
                           textColor=SLATE, alignment=TA_LEFT)
table_h_r = ParagraphStyle('table_h_r', fontName='Helvetica-Bold', fontSize=10.5, leading=13,
                           textColor=SLATE, alignment=TA_RIGHT)
table_c   = ParagraphStyle('table_c', fontName='Helvetica', fontSize=10.5, leading=13,
                           textColor=SLATE, alignment=TA_LEFT)
table_c_r = ParagraphStyle('table_c_r', fontName='Helvetica', fontSize=10.5, leading=13,
                           textColor=SLATE, alignment=TA_RIGHT)
total     = ParagraphStyle('total', fontName='Helvetica-Bold', fontSize=12, leading=15,
                           textColor=ORANGE, alignment=TA_LEFT)
total_r   = ParagraphStyle('total_r', fontName='Helvetica-Bold', fontSize=12, leading=15,
                           textColor=ORANGE, alignment=TA_RIGHT)
sig       = ParagraphStyle('sig', fontName='Helvetica', fontSize=10.5, leading=18,
                           textColor=SLATE, spaceAfter=2, alignment=TA_LEFT)
lien      = ParagraphStyle('lien', fontName='Helvetica', fontSize=9.5, leading=13,
                           textColor=GREY, spaceAfter=4, alignment=TA_LEFT)


def _logo_flowable(target_width_in=2.8):
    if not LOGO_PATH.exists():
        return Spacer(1, 0.1 * inch)
    ir = ImageReader(str(LOGO_PATH))
    nw, nh = ir.getSize()
    w = target_width_in * inch
    h = w * (nh / nw)
    img = Image(str(LOGO_PATH), width=w, height=h)
    img.hAlign = 'CENTER'
    return img


def _hr(color=ORANGE, thickness=1.5, space_after=8, space_before=4):
    return HRFlowable(width='100%', thickness=thickness, color=color,
                      spaceAfter=space_after, spaceBefore=space_before)


def _money(n):
    return '${:,}'.format(n)


def _itemized_table(line_items, total_amount):
    rows = [[Paragraph('Item', table_h), Paragraph('Price', table_h_r)]]
    for label, amount in line_items:
        rows.append([Paragraph(label, table_c), Paragraph(_money(amount), table_c_r)])
    rows.append([Paragraph('TOTAL FIXED PRICE', total),
                 Paragraph(_money(total_amount), total_r)])

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
    return t


def _payment_table(deposit, balance, total_amount):
    rows = [
        [Paragraph('Stage', table_h), Paragraph('Amount', table_h_r)],
        [Paragraph('Deposit due on signed acceptance (30%)', table_c),
         Paragraph(_money(deposit), table_c_r)],
        [Paragraph('Balance due on completion and walkthrough (70%)', table_c),
         Paragraph(_money(balance), table_c_r)],
        [Paragraph('Total', total), Paragraph(_money(total_amount), total_r)],
    ]
    t = Table(rows, colWidths=[4.5 * inch, 1.7 * inch])
    style = [
        ('VALIGN',        (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING',    (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('LEFTPADDING',   (0, 0), (-1, -1), 10),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 10),
        ('BACKGROUND',    (0, 0), (-1, 0),  LIGHT_BG),
        ('LINEBELOW',     (0, 0), (-1, 0),  0.6, GREY),
        ('BACKGROUND',    (0, 2), (-1, 2),  ROW_ALT),
        ('LINEABOVE',     (0, -1), (-1, -1), 1.2, ORANGE),
        ('BACKGROUND',    (0, -1), (-1, -1), LIGHT_BG),
    ]
    t.setStyle(TableStyle(style))
    return t


def _client_block(client):
    rows = [
        [Paragraph('PREPARED FOR', client_h), Paragraph('ESTIMATOR', client_h)],
        [Paragraph(f"<b>{client['name']}</b>", client_b),
         Paragraph('<b>James Slogar</b>, Owner', client_b)],
        [Paragraph(client['address_line'], client_b),
         Paragraph('Central Wisconsin Deck Builders, LLC', client_b)],
        [Paragraph(client['phone'], client_b),
         Paragraph('(715) 544-7941', client_b)],
        [Paragraph(client['email'], client_b),
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


def _signature_block():
    line = '_' * 50
    rows = [
        [Paragraph('Homeowner signature', client_h), Paragraph('Date', client_h)],
        [Paragraph(line, sig), Paragraph('_' * 18, sig)],
        [Paragraph('Printed name:', client_h), Paragraph('', client_h)],
        [Paragraph(line, sig), Paragraph('', sig)],
        [Spacer(1, 0.15 * inch), Spacer(1, 0.15 * inch)],
        [Paragraph('Central Wisconsin Deck Builders, LLC', client_h),
         Paragraph('Date', client_h)],
        [Paragraph('By: James Slogar, Owner', client_b), Paragraph('', client_b)],
        [Paragraph(line, sig), Paragraph('_' * 18, sig)],
    ]
    t = Table(rows, colWidths=[4.2 * inch, 2.0 * inch])
    t.setStyle(TableStyle([
        ('VALIGN',        (0, 0), (-1, -1), 'BOTTOM'),
        ('TOPPADDING',    (0, 0), (-1, -1), 1),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 1),
        ('LEFTPADDING',   (0, 0), (-1, -1), 0),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 0),
    ]))
    return t


def _footer(canvas, doc):
    canvas.saveState()
    canvas.setFont('Helvetica', 8.5)
    canvas.setFillColor(GREY)
    txt = ('Central Wisconsin Deck Builders, LLC  ·  Wausau, Wisconsin  ·  '
           'cwdeckbuilders.com  ·  Locally owned')
    canvas.drawCentredString(letter[0] / 2.0, 0.45 * inch, txt)
    page_num = canvas.getPageNumber()
    canvas.drawRightString(letter[0] - 0.6 * inch, 0.45 * inch, f'Page {page_num}')
    canvas.restoreState()


def generate_pdf(estimate, output_path):
    doc = SimpleDocTemplate(
        str(output_path), pagesize=letter,
        leftMargin=0.85 * inch, rightMargin=0.85 * inch,
        topMargin=0.55 * inch, bottomMargin=0.75 * inch,
        title=f"Project Estimate for {estimate['client']['name']}",
        author='Central Wisconsin Deck Builders, LLC',
    )

    s = []
    sp = lambda n=0.1: Spacer(1, n * inch)

    # ── HEADER: logo + NAP ──────────────────────────────────────────────────
    s.append(_logo_flowable(target_width_in=2.8))
    s.append(sp(0.06))
    s.append(Paragraph(
        'cwdeckbuilders.com  ·  (715) 544-7941  ·  info@cwdeckbuilders.com',
        nap))
    s.append(Paragraph(
        '906 N 16th Ave, Wausau, WI 54401  ·  Entity ID C138564  ·  EIN 41-5355234',
        small))
    s.append(_hr(color=ORANGE, thickness=2, space_after=8, space_before=8))

    # ── ESTIMATE META BAR ───────────────────────────────────────────────────
    s.append(Paragraph(
        f"PROJECT ESTIMATE  ·  #{estimate['estimate_number']}  ·  "
        f"Issued {estimate['date_issued']}  ·  Valid {estimate['valid_days']} days",
        meta))
    s.append(sp(0.1))

    # ── CLIENT BLOCK ────────────────────────────────────────────────────────
    s.append(_client_block(estimate['client']))
    s.append(_hr(color=GREY, thickness=0.5, space_after=10, space_before=12))

    # ── PROJECT OVERVIEW ────────────────────────────────────────────────────
    s.append(Paragraph('Project Overview', h2))
    s.append(Paragraph(estimate['project']['overview'], overview))

    # ── SCOPE OF WORK ───────────────────────────────────────────────────────
    s.append(Paragraph('Scope of Work', h2))
    for item in estimate['project']['scope']:
        s.append(Paragraph(f'• {item}', bullet))
    if estimate['project'].get('scope_note'):
        s.append(sp(0.05))
        s.append(Paragraph(
            f"<i><b>Scope boundary:</b> {estimate['project']['scope_note']}</i>",
            note))

    # ── ITEMIZED PRICING ────────────────────────────────────────────────────
    total_amount = sum(amt for _, amt in estimate['line_items'])
    s.append(KeepTogether([
        Paragraph('Itemized Pricing', h2),
        _itemized_table(estimate['line_items'], total_amount),
    ]))

    # ── INCLUDED ────────────────────────────────────────────────────────────
    s.append(Paragraph("What's Included", h2))
    for item in estimate['included']:
        s.append(Paragraph(f'• {item}', bullet))

    # ── NOT INCLUDED ────────────────────────────────────────────────────────
    s.append(Paragraph("What's Not Included", h2))
    for item in estimate['not_included']:
        s.append(Paragraph(f'• {item}', bullet))

    # ── SCHEDULE ────────────────────────────────────────────────────────────
    s.append(Paragraph('Schedule', h2))
    sched = estimate['schedule']
    s.append(Paragraph(f"<b>Estimated start:</b> {sched['start']}", body))
    s.append(Paragraph(f"<b>Estimated duration:</b> {sched['duration']}", body))
    s.append(Paragraph(f"<b>Weather contingency:</b> {sched['weather']}", body))

    # ── PAYMENT TERMS ───────────────────────────────────────────────────────
    deposit = round(total_amount * estimate['payment']['deposit_pct'] / 100)
    balance = total_amount - deposit
    s.append(KeepTogether([
        Paragraph('Payment Terms', h2),
        _payment_table(deposit, balance, total_amount),
        sp(0.05),
        Paragraph(
            f"<i>Accepted forms of payment: {estimate['payment']['methods']}</i>",
            note),
    ]))

    # ── ACCEPTANCE ──────────────────────────────────────────────────────────
    s.append(KeepTogether([
        Paragraph('Acceptance', h2),
        Paragraph(
            f"This estimate becomes a binding work order upon homeowner "
            f"signature and receipt of the {estimate['payment']['deposit_pct']}% "
            f"deposit. Estimate is valid for <b>{estimate['valid_days']} days</b> "
            f"from the date issued ({estimate['date_issued']}).", body),
        sp(0.15),
        _signature_block(),
    ]))

    # ── LIEN NOTICE ─────────────────────────────────────────────────────────
    s.append(_hr(color=GREY, thickness=0.5, space_after=8, space_before=14))
    s.append(Paragraph('Notice to Owner: Wisconsin Construction Lien Notice', h2))
    s.append(Paragraph(
        "As required by Wisconsin construction lien law (Wis. Stat. §779.02), "
        "the builder hereby notifies the owner that persons or companies "
        "furnishing labor or materials for construction work on the owner's "
        "land may have lien rights on the owner's land and buildings if they "
        "are not paid. The builder agrees to provide a list of all such "
        "persons supplying labor or materials upon request.",
        lien))

    doc.build(s, onFirstPage=_footer, onLaterPages=_footer)
    return str(output_path)


# ─────────────────────────────────────────────────────────────────────────────
# CLI: render an estimate PDF from a JSON data file
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import sys
    import json

    if len(sys.argv) != 2:
        print('usage: python generate_estimate_pdf.py <path-to-estimate.json>',
              file=sys.stderr)
        sys.exit(1)

    data_path = Path(sys.argv[1]).resolve()
    estimate = json.loads(data_path.read_text(encoding='utf-8'))
    out = data_path.parent.parent / f'{data_path.stem}.pdf'
    print(f'PDF written: {generate_pdf(estimate, out)}')
