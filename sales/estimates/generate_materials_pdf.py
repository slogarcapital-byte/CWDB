"""
CWDB Materials & Hardware List PDF (internal)
Central Wisconsin Deck Builders, LLC

Renders the v2 engine's piece-level takeoff (deck_calculator.build_takeoff)
as a branded, INTERNAL order-list PDF. This attachment replaces the emailed
Excel workbook in the estimator send flow (Jim 2026-07-09).

The footer prints the reconciliation between the takeoff's extended-cost
total and the pricing engine's materials subtotal - whole-piece rounding
means they will differ slightly; a large drift means the takeoff rules and
the pricing DB have diverged.

Usage (from code):
    from generate_materials_pdf import generate_materials_pdf
    generate_materials_pdf(takeoff, client_info, project_label, out_path)
"""

from datetime import date
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (Paragraph, SimpleDocTemplate, Spacer, Table,
                                TableStyle)

ORANGE = colors.HexColor("#e54c00")
SLATE = colors.HexColor("#323434")
GREY = colors.HexColor("#646760")
LIGHT_BG = colors.HexColor("#f4f2ef")
ROW_ALT = colors.HexColor("#faf9f7")

_h1 = ParagraphStyle("h1", fontName="Helvetica-Bold", fontSize=16,
                     textColor=SLATE, spaceAfter=2)
_meta = ParagraphStyle("meta", fontName="Helvetica", fontSize=8.5,
                       textColor=GREY, spaceAfter=10)
_cat = ParagraphStyle("cat", fontName="Helvetica-Bold", fontSize=10,
                      textColor=ORANGE, spaceBefore=10, spaceAfter=3)
_cell = ParagraphStyle("cell", fontName="Helvetica", fontSize=8.5,
                       textColor=SLATE, leading=11)
_cell_r = ParagraphStyle("cell_r", parent=_cell, alignment=2)
_cell_h = ParagraphStyle("cell_h", parent=_cell, fontName="Helvetica-Bold")
_cell_hr = ParagraphStyle("cell_hr", parent=_cell_h, alignment=2)
_note = ParagraphStyle("note", fontName="Helvetica-Oblique", fontSize=7.5,
                       textColor=GREY, leading=10)
_total = ParagraphStyle("total", parent=_cell_h, fontSize=9.5)
_total_r = ParagraphStyle("total_r", parent=_total, alignment=2)


def _money(x):
    return f"${x:,.2f}"


def _rows_table(rows):
    data = [[Paragraph("Item", _cell_h), Paragraph("SKU", _cell_h),
             Paragraph("Qty", _cell_hr), Paragraph("Unit", _cell_h),
             Paragraph("Unit cost", _cell_hr), Paragraph("Ext.", _cell_hr)]]
    for r in rows:
        item = r["item"]
        if r.get("note"):
            item += f"<br/><font size=7 color='#646760'><i>{r['note']}</i></font>"
        data.append([
            Paragraph(item, _cell),
            Paragraph(str(r.get("sku", "")), _cell),
            Paragraph(f"{r['qty']:g}" if isinstance(r["qty"], float) else str(r["qty"]),
                      _cell_r),
            Paragraph(str(r["unit"]), _cell),
            Paragraph(_money(r["unit_cost"]), _cell_r),
            Paragraph(_money(r["ext_cost"]), _cell_r),
        ])
    t = Table(data, colWidths=[2.9 * inch, 1.15 * inch, 0.5 * inch,
                               0.55 * inch, 0.75 * inch, 0.85 * inch])
    style = [
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("BACKGROUND", (0, 0), (-1, 0), LIGHT_BG),
        ("LINEBELOW", (0, 0), (-1, 0), 0.6, GREY),
    ]
    for i in range(1, len(data)):
        if i % 2 == 0:
            style.append(("BACKGROUND", (0, i), (-1, i), ROW_ALT))
    t.setStyle(TableStyle(style))
    return t


def generate_materials_pdf(takeoff, client_info, project_label, out_path,
                           job_number=None):
    """Render the takeoff dict (from deck_calculator.build_takeoff) to a
    one-or-more-page internal Materials & Hardware List PDF."""
    out_path = Path(out_path)
    doc = SimpleDocTemplate(
        str(out_path), pagesize=letter,
        leftMargin=0.7 * inch, rightMargin=0.7 * inch,
        topMargin=0.7 * inch, bottomMargin=0.7 * inch,
        title="CWDB Materials & Hardware List",
    )
    story = []
    story.append(Paragraph("MATERIALS &amp; HARDWARE LIST", _h1))
    header_bits = [
        "Central Wisconsin Deck Builders, LLC",
        f"Generated {date.today().strftime('%B %d, %Y')}",
        "INTERNAL - not for customer distribution",
    ]
    if job_number:
        header_bits.insert(1, f"Job {job_number}")
    story.append(Paragraph("  ·  ".join(header_bits), _meta))
    story.append(Paragraph(
        f"<b>{client_info.get('name', '')}</b>  ·  "
        f"{client_info.get('address_line', '')}  ·  {project_label}", _cell))
    story.append(Spacer(1, 10))

    # Group rows by category, preserving first-seen order
    by_cat = {}
    for r in takeoff["rows"]:
        by_cat.setdefault(r["category"], []).append(r)
    for cat, rows in by_cat.items():
        cat_total = sum(r["ext_cost"] for r in rows)
        story.append(Paragraph(f"{cat}  ·  {_money(cat_total)}", _cat))
        story.append(_rows_table(rows))

    story.append(Spacer(1, 14))
    totals = Table(
        [[Paragraph("MATERIALS TOTAL (takeoff)", _total),
          Paragraph(_money(takeoff["materials_total"]), _total_r)],
         [Paragraph("Pricing engine materials subtotal", _cell),
          Paragraph(_money(takeoff["engine_materials"]), _cell_r)],
         [Paragraph("Reconciliation drift (whole-piece rounding)", _cell),
          Paragraph(_money(takeoff["drift"]), _cell_r)]],
        colWidths=[4.9 * inch, 1.8 * inch])
    totals.setStyle(TableStyle([
        ("LINEABOVE", (0, 0), (-1, 0), 1.2, ORANGE),
        ("BACKGROUND", (0, 0), (-1, 0), LIGHT_BG),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    story.append(totals)
    story.append(Spacer(1, 8))
    story.append(Paragraph(
        "Quantities are order-list heuristics (whole pieces, waste rounded "
        "up). 'dealer' SKU = order through the supplier / dealer sheet. All "
        "prices are everyday shelf prices - the 11% Menards rebate is never "
        "assumed (standing rule 2026-07-09). A large reconciliation drift "
        "means the takeoff rules and pricing-db-v2.json have diverged - "
        "investigate before ordering.", _note))
    doc.build(story)
    return out_path
