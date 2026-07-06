"""
SBG Construction Group - Attorney Consultation Packet - PDF Generator
Central Wisconsin Deck Builders, LLC (Jim Slogar) with AI legal/compliance counsel

Produces, into this folder:
  1-attorney-briefing-memo.pdf
  2-entity-structure-one-pager.pdf
  3-party-corporate-facts-sheet.pdf
  4-sbg-term-sheet.pdf
  5-inter-company-agreements-outline.pdf
  6-financial-model-redacted.pdf
  7-regulatory-gating-checklist.pdf
  SBG-Lawyer-Packet-Combined.pdf   (cover + all 7, continuous page numbers)

The four converted documents are rendered from the source markdown in the parent
folder. The financial model has its private Section 8 stripped before rendering.

Usage:
  python generate_sbg_packet.py --attorney "Ruffi Law Offices, S.C."
  python generate_sbg_packet.py            (uses a [Attorney Name / Firm] placeholder)

House style: no em dashes; Wisconsin statute citations; Marathon County venue; an
AI-counsel disclaimer footer on every page.
"""

import os
import re
import sys
import argparse

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, HRFlowable, PageBreak, Preformatted,
                                KeepTogether)
from reportlab.pdfgen import canvas

# ---------------------------------------------------------------- brand + geometry
ORANGE   = colors.HexColor('#e54c00')
SLATE    = colors.HexColor('#323434')
GREY     = colors.HexColor('#646760')
SKY      = colors.HexColor('#83b2cf')
WHITE    = colors.white
LIGHT_BG = colors.HexColor('#f7f4f1')
LIGHT_SKY = colors.HexColor('#eaf3f8')
ZEBRA    = colors.HexColor('#faf8f6')

L_MARGIN = 0.85 * inch
R_MARGIN = 0.85 * inch
T_MARGIN = 0.95 * inch
B_MARGIN = 0.95 * inch
TW = letter[0] - L_MARGIN - R_MARGIN          # usable text width (~6.8in)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR    = os.path.dirname(SCRIPT_DIR)       # .../construction-group
OUT_DIR    = SCRIPT_DIR

MEETING_DATE = "July 6, 2026"
PREP_DATE    = "July 5, 2026"

# ---------------------------------------------------------------- styles
_ss = getSampleStyleSheet()
def S(name, **kw):
    return ParagraphStyle(name, parent=_ss['Normal'], **kw)

body      = S('body', fontName='Times-Roman', fontSize=9.8, leading=14, textColor=SLATE, spaceAfter=6, alignment=TA_JUSTIFY)
h1        = S('h1', fontName='Helvetica-Bold', fontSize=16, leading=20, textColor=ORANGE, spaceAfter=4, spaceBefore=2, alignment=TA_LEFT)
h1c       = S('h1c', fontName='Helvetica-Bold', fontSize=16, leading=20, textColor=ORANGE, spaceAfter=4, alignment=TA_CENTER)
h2        = S('h2', fontName='Helvetica-Bold', fontSize=12, leading=15, textColor=SLATE, spaceAfter=4, spaceBefore=12)
h3        = S('h3', fontName='Helvetica-Bold', fontSize=10.5, leading=13, textColor=SLATE, spaceAfter=3, spaceBefore=8)
h4        = S('h4', fontName='Helvetica-BoldOblique', fontSize=9.8, leading=12.5, textColor=GREY, spaceAfter=3, spaceBefore=6)
subc      = S('subc', fontName='Helvetica', fontSize=10, leading=13, textColor=GREY, spaceAfter=3, alignment=TA_CENTER)
li        = S('li', fontName='Times-Roman', fontSize=9.8, leading=13.5, textColor=SLATE, spaceAfter=3, leftIndent=16, bulletIndent=4)
cell      = S('cell', fontName='Times-Roman', fontSize=8.3, leading=10.5, textColor=SLATE)
cellb     = S('cellb', fontName='Helvetica-Bold', fontSize=8.3, leading=10.5, textColor=WHITE)
code      = S('code', fontName='Courier', fontSize=8, leading=10.5, textColor=SLATE)
quote     = S('quote', fontName='Times-Roman', fontSize=9.3, leading=13, textColor=SLATE, spaceAfter=4, alignment=TA_JUSTIFY)
box_title = S('box_title', fontName='Helvetica-Bold', fontSize=9.5, leading=12, textColor=SLATE, alignment=TA_CENTER)
box_sub   = S('box_sub', fontName='Helvetica', fontSize=7.8, leading=10, textColor=SLATE, alignment=TA_CENTER)
band      = S('band', fontName='Helvetica-Bold', fontSize=9, leading=12, textColor=WHITE, alignment=TA_CENTER)
foot_note = S('foot_note', fontName='Helvetica-Oblique', fontSize=7.6, leading=10, textColor=GREY, spaceBefore=6, alignment=TA_CENTER)
banner_st = S('banner', fontName='Helvetica-Bold', fontSize=7.5, leading=9, textColor=ORANGE, spaceAfter=2)
cover_big = S('cover_big', fontName='Helvetica-Bold', fontSize=26, leading=30, textColor=ORANGE, alignment=TA_CENTER, spaceAfter=2)
cover_sub = S('cover_sub', fontName='Helvetica', fontSize=13, leading=17, textColor=SLATE, alignment=TA_CENTER, spaceAfter=2)
cover_meta= S('cover_meta', fontName='Times-Roman', fontSize=11, leading=16, textColor=SLATE, alignment=TA_CENTER)
toc_st    = S('toc', fontName='Times-Roman', fontSize=10, leading=15, textColor=SLATE, leftIndent=8)

DISCLAIMER = ("This document was prepared by AI legal counsel for informational purposes. "
              "Review by a licensed Wisconsin attorney is recommended before execution.")

# ---------------------------------------------------------------- inline markdown
def _inline(text):
    t = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    t = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', t)
    t = re.sub(r'`(.+?)`', r'<font face="Courier" size="8">\1</font>', t)
    t = re.sub(r'(?<![\w*])\*(?!\*)(.+?)(?<!\*)\*(?![\w*])', r'<i>\1</i>', t)
    t = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'\1 (\2)', t)
    t = t.replace('—', ' - ').replace('–', '-')   # em/en dash safety net
    t = t.replace('’', "'").replace('‘', "'")
    t = t.replace('“', '"').replace('”', '"')
    return t

def _is_table_sep(cells):
    return all(re.match(r'^:?-{2,}:?$', c.strip()) for c in cells if c.strip() != '') and any(cells)

def _split_row(line):
    s = line.strip()
    if s.startswith('|'):
        s = s[1:]
    if s.endswith('|'):
        s = s[:-1]
    return [c.strip() for c in s.split('|')]

def _col_widths(ncols, header):
    if ncols == 1:
        return [TW]
    first = header[0].strip()
    if len(first) <= 3:
        c0 = 0.42 * inch
        rest = (TW - c0) / (ncols - 1)
        return [c0] + [rest] * (ncols - 1)
    return [TW / ncols] * ncols

def _make_table(rows):
    header = rows[0]
    ncols = len(header)
    data = []
    for r in rows:
        r = (r + [''] * ncols)[:ncols]
        is_head = (r is rows[0])
        st = cellb if is_head else cell
        data.append([Paragraph(_inline(c), st) for c in r])
    t = Table(data, colWidths=_col_widths(ncols, header), repeatRows=1)
    style = [
        ('BACKGROUND', (0, 0), (-1, 0), SLATE),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('TOPPADDING', (0, 0), (-1, -1), 3.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#d8d3ce')),
        ('LINEBELOW', (0, 0), (-1, 0), 0.8, ORANGE),
    ]
    for i in range(2, len(data), 2):
        style.append(('BACKGROUND', (0, i), (-1, i), ZEBRA))
    t.setStyle(TableStyle(style))
    return t

def _make_quote(paras):
    inner = [Paragraph(_inline(p), quote) for p in paras]
    t = Table([[p] for p in inner], colWidths=[TW])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), LIGHT_BG),
        ('LINEBEFORE', (0, 0), (0, -1), 3, ORANGE),
        ('LEFTPADDING', (0, 0), (-1, -1), 12),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    return t

def md_to_flowables(md):
    """Render a subset of Markdown (headings, bold/italic/code, tables, blockquotes,
    code fences, lists, rules, paragraphs) into reportlab flowables."""
    lines = md.replace('\r\n', '\n').split('\n')
    flow = []
    i = 0
    n = len(lines)
    para = []

    def flush_para():
        if para:
            flow.append(Paragraph(_inline(' '.join(para).strip()), body))
            para.clear()

    while i < n:
        raw = lines[i]
        s = raw.strip()

        # code fence
        if s.startswith('```'):
            flush_para()
            i += 1
            buf = []
            while i < n and not lines[i].strip().startswith('```'):
                buf.append(lines[i])
                i += 1
            i += 1
            txt = '\n'.join(buf).replace('—', '-')
            box = Table([[Preformatted(txt, code)]], colWidths=[TW])
            box.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#f2efec')),
                ('BOX', (0, 0), (-1, -1), 0.5, GREY),
                ('LEFTPADDING', (0, 0), (-1, -1), 8),
                ('TOPPADDING', (0, 0), (-1, -1), 6),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ]))
            flow.append(box)
            flow.append(Spacer(1, 4))
            continue

        # blockquote
        if s.startswith('>'):
            flush_para()
            qbuf = []
            while i < n and lines[i].strip().startswith('>'):
                q = lines[i].strip()[1:]
                if q.startswith(' '):
                    q = q[1:]
                qbuf.append(q)
                i += 1
            paras, cur = [], []
            for q in qbuf:
                if q.strip() == '':
                    if cur:
                        paras.append(' '.join(cur)); cur = []
                else:
                    cur.append(q)
            if cur:
                paras.append(' '.join(cur))
            flow.append(_make_quote(paras))
            flow.append(Spacer(1, 4))
            continue

        # table
        if s.startswith('|'):
            flush_para()
            tbuf = []
            while i < n and lines[i].strip().startswith('|'):
                tbuf.append(lines[i])
                i += 1
            rows = [_split_row(l) for l in tbuf]
            rows = [r for r in rows if not _is_table_sep(r)]
            if rows:
                flow.append(_make_table(rows))
                flow.append(Spacer(1, 5))
            continue

        # horizontal rule
        if re.match(r'^-{3,}$', s):
            flush_para()
            flow.append(HRFlowable(width='100%', thickness=0.5, color=colors.HexColor('#d8d3ce'),
                                   spaceBefore=6, spaceAfter=8))
            i += 1
            continue

        # headings
        m = re.match(r'^(#{1,6})\s+(.*)$', s)
        if m:
            flush_para()
            level = len(m.group(1))
            txt = _inline(m.group(2))
            style = {1: h1, 2: h2, 3: h3}.get(level, h4)
            flow.append(Paragraph(txt, style))
            i += 1
            continue

        # blank line
        if s == '':
            flush_para()
            i += 1
            continue

        # list items
        mb = re.match(r'^[-*]\s+(.*)$', s)
        mn = re.match(r'^(\d+)\.\s+(.*)$', s)
        if mb:
            flush_para()
            flow.append(Paragraph(_inline(mb.group(1)), li, bulletText=u'•'))
            i += 1
            continue
        if mn:
            flush_para()
            flow.append(Paragraph('%s. %s' % (mn.group(1), _inline(mn.group(2))), li))
            i += 1
            continue

        para.append(s)
        i += 1

    flush_para()
    return flow

# ---------------------------------------------------------------- page furniture
class PacketCanvas(canvas.Canvas):
    def __init__(self, *a, **kw):
        canvas.Canvas.__init__(self, *a, **kw)
        self._saved = []

    def showPage(self):
        self._saved.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        total = len(self._saved)
        for st in self._saved:
            self.__dict__.update(st)
            self._draw(total)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def _draw(self, total):
        w, h = letter
        self.saveState()
        # header
        self.setFont('Helvetica', 6.8)
        self.setFillColor(GREY)
        self.drawCentredString(w / 2.0, h - 0.52 * inch,
                               'PRIVILEGED AND CONFIDENTIAL  -  PREPARED FOR WISCONSIN COUNSEL REVIEW  -  DRAFT')
        self.setStrokeColor(colors.HexColor('#e0dbd6'))
        self.setLineWidth(0.4)
        self.line(L_MARGIN, h - 0.58 * inch, w - R_MARGIN, h - 0.58 * inch)
        # footer disclaimer
        self.setFont('Helvetica-Oblique', 6.3)
        self.setFillColor(GREY)
        self.drawCentredString(w / 2.0, 0.56 * inch, DISCLAIMER)
        # footer line
        self.setStrokeColor(colors.HexColor('#e0dbd6'))
        self.line(L_MARGIN, 0.68 * inch, w - R_MARGIN, 0.68 * inch)
        self.setFont('Helvetica', 7)
        self.setFillColor(GREY)
        self.drawString(L_MARGIN, 0.4 * inch,
                        'SBG Construction Group  -  Attorney Consultation Packet')
        self.drawRightString(w - R_MARGIN, 0.4 * inch, 'Page %d of %d' % (self._pageNumber, total))
        self.restoreState()

def build_pdf(path, title, flowables):
    doc = SimpleDocTemplate(path, pagesize=letter,
                            leftMargin=L_MARGIN, rightMargin=R_MARGIN,
                            topMargin=T_MARGIN, bottomMargin=B_MARGIN,
                            title=title, author='Central Wisconsin Deck Builders, LLC')
    doc.build(list(flowables), canvasmaker=PacketCanvas)
    return path

def banner(n, total, name):
    return [Paragraph('DOCUMENT %d OF %d  -  %s' % (n, total, name.upper()), banner_st),
            HRFlowable(width='100%', thickness=1.5, color=ORANGE, spaceAfter=8)]

# ---------------------------------------------------------------- new-document content
def _read(name):
    with open(os.path.join(SRC_DIR, name), 'r', encoding='utf-8') as f:
        return f.read()

def memo_md(attorney):
    return MEMO.replace('%%ATTORNEY%%', attorney).replace('%%MEETING_DATE%%', MEETING_DATE).replace('%%PREP_DATE%%', PREP_DATE)

def facts_md(attorney):
    return FACTS.replace('%%ATTORNEY%%', attorney).replace('%%PREP_DATE%%', PREP_DATE)

def load_financial_redacted():
    txt = _read('financial-model.md')
    txt = txt.replace(
        "Sections 1 through 7 and 9 through 10 are for the full working session with Ben and John. "
        "**Section 8 is marked PRIVATE and is for Jim only.** Pull it out before sharing.",
        "Sections 1 through 7 and 9 through 10 cover the entity structure, the economics, and the open "
        "items. Section 8 is reserved and is omitted from this packet.")
    txt = re.sub(
        r"## 8\. .*?END PRIVATE SECTION\. EVERYTHING BELOW IS FOR THE FULL WORKING SESSION\.",
        "## 8. Reserved\n\nThis section is intentionally omitted from this consultation packet.",
        txt, flags=re.S)
    # hard safety checks: the private content must be gone
    assert 'Bridge-Income' not in txt, 'redaction failed: private heading remains'
    assert 'Jim only' not in txt, 'redaction failed: private pointer remains'
    assert '$140,000' not in txt, 'redaction failed: private salary figure remains'
    assert 'Ashley' not in txt, 'redaction failed: private personal detail remains'
    return txt

# ---------------------------------------------------------------- structure one-pager
def _box(title, subs, bg, border):
    inner = '<b>%s</b>' % title
    para = [Paragraph(inner, box_title)] + [Paragraph(s, box_sub) for s in subs]
    t = Table([[x] for x in para], colWidths=[(TW - 0.36 * inch) / 3.0])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), bg),
        ('BOX', (0, 0), (-1, -1), 1, border),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    return t

def _box_row(boxes):
    gap = 0.18 * inch
    cells = [boxes[0], '', boxes[1], '', boxes[2]]
    widths = [(TW - 0.36 * inch) / 3.0, gap, (TW - 0.36 * inch) / 3.0, gap, (TW - 0.36 * inch) / 3.0]
    t = Table([cells], colWidths=widths)
    t.setStyle(TableStyle([('VALIGN', (0, 0), (-1, -1), 'TOP'),
                           ('LEFTPADDING', (0, 0), (-1, -1), 0),
                           ('RIGHTPADDING', (0, 0), (-1, -1), 0)]))
    return t

def _full_band(text, bg, tcolor=WHITE):
    st = ParagraphStyle('b', parent=band, textColor=tcolor)
    t = Table([[Paragraph(text, st)]], colWidths=[TW])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), bg),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    return t

def onepager_flowables(with_banner=True):
    f = []
    if with_banner:
        f += banner(2, 7, 'Entity Structure One-Pager')
    f.append(Paragraph('SBG Construction Group', h1c))
    f.append(Paragraph('Entity Structure at a Glance (Phase A)', subc))
    f.append(HRFlowable(width='100%', thickness=1.5, color=ORANGE, spaceAfter=10))

    f.append(Paragraph('The three existing operating LLCs (customer-facing prime contractors)', h3))
    op = _box_row([
        _box('Central Wisconsin Deck Builders, LLC',
             ['Jim Slogar', 'Signs its own jobs, pulls its own permits, carries its own GL, keeps its own job profit'],
             LIGHT_BG, ORANGE),
        _box('Barton Builders LLC',
             ['Ben Barton', 'Signs its own jobs, pulls its own permits, carries its own GL, keeps its own job profit'],
             LIGHT_BG, ORANGE),
        _box('John Garcia Construction, LLC',
             ['John Garcia', 'Signs its own jobs, pulls its own permits, carries its own GL, keeps its own job profit'],
             LIGHT_BG, ORANGE),
    ])
    f.append(op)
    f.append(Spacer(1, 6))
    f.append(Paragraph(
        u'▲ &nbsp; SBG leases labor and equipment to the LLCs at market &nbsp;&nbsp;|&nbsp;&nbsp; '
        u'▼ &nbsp; the LLCs pay SBG market rates (plus Wisconsin sales tax on equipment)', subc))
    f.append(Paragraph('The three partners own the SBG entities one third each, as individuals, funded by equal cash', subc))
    f.append(Spacer(1, 6))

    f.append(Paragraph('The three new SBG entities (shared-services group; does not contract with homeowners)', h3))
    sbg = _box_row([
        _box('SBG-Labor, LLC  (S-corp)',
             ['Employs the W-2 crews and the three partners', 'Leases labor to the LLCs', 'Carries workers\' comp'],
             LIGHT_SKY, SLATE),
        _box('SBG-Equipment, LLC',
             ['Owns the shared equipment', 'Leases it to the LLCs', 'Registers for WI sales tax on rentals'],
             LIGHT_SKY, SLATE),
        _box('SBG-RealEstate, LLC',
             ['Formed now, dormant', 'Future shop or yard', 'Activates only by unanimous vote'],
             LIGHT_SKY, SLATE),
    ])
    f.append(sbg)
    f.append(Spacer(1, 8))

    f.append(_full_band(
        'OWNERSHIP OF EACH SBG ENTITY:&nbsp;&nbsp; Jim Slogar 1/3 &nbsp; - &nbsp; Ben Barton 1/3 &nbsp; - &nbsp; '
        'John Garcia 1/3 &nbsp;&nbsp;|&nbsp;&nbsp; funded by equal cash', SLATE))
    f.append(Spacer(1, 8))

    phase = Table([[
        Paragraph('<b>PHASE A</b> (now, 1 to 2 years)<br/>Each LLC keeps its own job profit. SBG owns the crews and '
                  'equipment, bills the LLCs at market, and reinvests its profit. Partners draw an $80/hr W-2 wage '
                  'from SBG-Labor.', box_sub),
        Paragraph(u'→', ParagraphStyle('arr', parent=band, textColor=ORANGE, fontSize=16)),
        Paragraph('<b>PHASE B</b> (1 to 2 years out, deferred)<br/>True merger. Job profit pools one third each. '
                  'The trigger and the valuation / equalization of the three unequal LLCs are decided now and executed '
                  'later.', box_sub),
    ]], colWidths=[(TW - 0.4 * inch) / 2.0, 0.4 * inch, (TW - 0.4 * inch) / 2.0])
    phase.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, 0), LIGHT_BG),
        ('BACKGROUND', (2, 0), (2, 0), LIGHT_SKY),
        ('BOX', (0, 0), (0, 0), 0.7, GREY),
        ('BOX', (2, 0), (2, 0), 0.7, GREY),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
    ]))
    f.append(phase)
    f.append(Paragraph(
        'SBG does not contract with homeowners, market, or own customer relationships. Each operating LLC stays the '
        'licensed prime on its own jobs (its own DSPS certification, qualifier, GL, and permits). Entity names are '
        'placeholders pending WI DFI clearance.', foot_note))
    return f

# ---------------------------------------------------------------- cover
def cover_flowables(attorney):
    f = [Spacer(1, 0.7 * inch)]
    f.append(Paragraph('SBG CONSTRUCTION GROUP', cover_big))
    f.append(Paragraph('Attorney Consultation Packet', cover_sub))
    f.append(Paragraph('Slogar &nbsp;-&nbsp; Barton &nbsp;-&nbsp; Garcia', cover_sub))
    f.append(Paragraph('Shared-Services / Captive-Labor Structure', cover_meta))
    f.append(Spacer(1, 0.35 * inch))
    f.append(HRFlowable(width='60%', thickness=2, color=ORANGE, spaceAfter=14, hAlign='CENTER'))
    f.append(Paragraph('<b>Prepared for:</b> %s' % attorney, cover_meta))
    f.append(Paragraph('<b>Meeting:</b> Initial consultation, %s' % MEETING_DATE, cover_meta))
    f.append(Paragraph('<b>Prepared by:</b> Central Wisconsin Deck Builders, LLC (Jim Slogar), with AI legal / compliance counsel', cover_meta))
    f.append(Paragraph('<b>Prepared:</b> %s' % PREP_DATE, cover_meta))
    f.append(Spacer(1, 0.35 * inch))
    f.append(HRFlowable(width='60%', thickness=0.6, color=GREY, spaceAfter=12, hAlign='CENTER'))
    f.append(Paragraph('Contents', h2))
    toc = [
        '1.  Attorney briefing memo (the ask, ranked questions, disclosures, agenda)',
        '2.  Entity structure one-pager',
        '3.  Party and corporate facts sheet',
        '4.  SBG term sheet',
        '5.  Inter-company agreements outline',
        '6.  Financial model, Phase A (one internal section omitted)',
        '7.  Regulatory gating and due-diligence checklist',
    ]
    for t in toc:
        f.append(Paragraph(t, toc_st))
    f.append(Spacer(1, 0.3 * inch))
    note = Table([[Paragraph(
        '<b>Confidential and privileged.</b> This packet is prepared to obtain legal advice from the '
        'attorney named above and is intended to be protected by the attorney-client privilege. It contains '
        'non-binding term sheets and planning materials, not executed agreements. Every document is drafted by '
        'AI legal counsel for the partners\' internal alignment and requires review by a licensed Wisconsin '
        'attorney before execution.', quote)]], colWidths=[TW])
    note.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), LIGHT_BG),
        ('LINEBEFORE', (0, 0), (0, -1), 3, ORANGE),
        ('LEFTPADDING', (0, 0), (-1, -1), 12), ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 8), ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
    ]))
    f.append(note)
    return f

# ---------------------------------------------------------------- assembly
DOCS = [
    (1, 'Attorney Briefing Memo', '1-attorney-briefing-memo.pdf'),
    (2, 'Entity Structure One-Pager', '2-entity-structure-one-pager.pdf'),
    (3, 'Party and Corporate Facts Sheet', '3-party-corporate-facts-sheet.pdf'),
    (4, 'SBG Term Sheet', '4-sbg-term-sheet.pdf'),
    (5, 'Inter-Company Agreements Outline', '5-inter-company-agreements-outline.pdf'),
    (6, 'Financial Model (Phase A)', '6-financial-model-redacted.pdf'),
    (7, 'Regulatory Gating and Due-Diligence Checklist', '7-regulatory-gating-checklist.pdf'),
]

def doc_flowables(idx, attorney, with_banner=True):
    name = DOCS[idx - 1][1]
    if idx == 1:
        f = (banner(1, 7, name) if with_banner else []) + md_to_flowables(memo_md(attorney))
    elif idx == 2:
        f = onepager_flowables(with_banner)
    elif idx == 3:
        f = (banner(3, 7, name) if with_banner else []) + md_to_flowables(facts_md(attorney))
    elif idx == 4:
        f = (banner(4, 7, name) if with_banner else []) + md_to_flowables(_read('legal-term-sheet.md'))
    elif idx == 5:
        f = (banner(5, 7, name) if with_banner else []) + md_to_flowables(_read('inter-company-agreements.md'))
    elif idx == 6:
        f = (banner(6, 7, name) if with_banner else []) + md_to_flowables(load_financial_redacted())
    elif idx == 7:
        f = (banner(7, 7, name) if with_banner else []) + md_to_flowables(_read('due-diligence-checklist.md'))
    return f

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--attorney', default='[Attorney Name / Firm]')
    args = ap.parse_args()
    attorney = args.attorney

    # individual PDFs
    for idx, title, fname in DOCS:
        build_pdf(os.path.join(OUT_DIR, fname), title, doc_flowables(idx, attorney))
        print('wrote', fname)

    # combined packet
    combined = cover_flowables(attorney)
    for idx, title, fname in DOCS:
        combined.append(PageBreak())
        combined += doc_flowables(idx, attorney)
    build_pdf(os.path.join(OUT_DIR, 'SBG-Lawyer-Packet-Combined.pdf'),
              'SBG Construction Group - Attorney Consultation Packet', combined)
    print('wrote SBG-Lawyer-Packet-Combined.pdf')


# ---------------------------------------------------------------- authored content
MEMO = r"""# Attorney Briefing Memo

**To:** %%ATTORNEY%%

**From:** Jim Slogar, Member and Manager, Central Wisconsin Deck Builders, LLC, on behalf of the three prospective SBG partners (Jim Slogar, Ben Barton, John Garcia)

**Re:** Formation of SBG Construction Group, a shared-services / captive-labor structure. Engagement scope, priority questions, and disclosures.

**Meeting:** Initial consultation, %%MEETING_DATE%%

**Prepared:** %%PREP_DATE%%

---

> **Purpose of this memo.** We want to use your time efficiently today. This memo states exactly what we would like you to draft, lists our priority legal and tax questions in ranked order, and discloses the facts you will need. The enclosed term sheet, structure diagram, inter-company outlines, financial model, and gating checklist carry the full detail. Everything in this packet was drafted by AI legal counsel for our internal alignment and is not a substitute for your review.

## 1. What we are asking you to do

We are three Wisconsin construction businesses that have decided to build a shared back-office group, and we want you to paper it correctly. Specifically, we would like you to:

1. Draft binding **operating agreements** for the three new SBG entities (SBG-Labor, SBG-Equipment, SBG-RealEstate), including the governance, capital, deadlock, and buy-sell terms in the enclosed term sheet.
2. Draft the three **inter-company agreements** that make the structure work: a labor / staffing agreement, an equipment lease, and a workers' comp / borrowed-servant coordination agreement (outlines enclosed).
3. Draft the **buy-sell and transfer-restriction provisions** (trigger events, valuation, and funding).
4. Advise on the **joint-representation and conflict-of-interest question** below, and prepare any conflict waivers or independent-counsel recommendations you consider necessary.
5. Give us a **written fee estimate and timeline**, and tell us the order in which these documents should be produced.
6. Give us your read on the **priority questions in Section 4**.

## 2. What SBG is (one paragraph)

Three existing, independent Wisconsin construction LLCs (Central Wisconsin Deck Builders, LLC, Jim Slogar; Barton Builders LLC, Ben Barton; John Garcia Construction, LLC, John Garcia) will stay independent and customer-facing. Each keeps signing its own jobs, pulling its own permits under its own Dwelling Contractor Certification, carrying its own general liability, and keeping its own job profit. The three of us will jointly own three new SBG entities, one third each as individuals, funded by equal cash: **SBG-Labor** (elects S-corp; employs the W-2 crews and the three of us; leases labor to the LLCs at market), **SBG-Equipment** (owns and leases equipment at market), and **SBG-RealEstate** (dormant until a shop or yard is purchased). SBG bills the LLCs at market and reinvests its profit in Phase A. Phase B, one to two years out, is a deferred true merger in which job profit pools one third each; we want the Phase B trigger and valuation method decided now. Full detail is in the enclosed term sheet.

## 3. What is already decided (so you are not re-deriving it)

- Shared-services / captive-labor group, **not a merger** in Phase A.
- Three SBG entities, owned **one third each by the three individuals** (we want your confirmation that individual ownership, rather than holding-LLC ownership, is right).
- Capital is **equal cash**; equipment a partner sells in is an arm's-length fair-market-value sale, not a contribution.
- **SBG-Labor elects S-corp** so the three of us can draw W-2 wages.
- SBG **reinvests** its Phase A profit, with no owner distributions yet beyond mandatory tax distributions.
- Each partner **keeps their own customers and lead sources**; SBG does not market or own any customer relationship.
- Governance lanes: Jim (finance), John (scheduling and estimating), Ben (field operations), with 2-of-3 and unanimous decision thresholds.
- Governing law **Wisconsin**; venue **Marathon County**.

## 4. Priority legal and tax questions (ranked)

1. **Joint representation and conflict of interest (Wis. SCR 20:1.7).** Can a single attorney represent all three of us and the SBG entities on this formation, or do one or more of us need independent counsel? What conflict waivers do you require? We put this first because it governs how the rest of the engagement proceeds.
2. **Ownership form.** Individuals versus holding-LLCs as the owners of the SBG entities. The S-corp election appears to force individual ownership of SBG-Labor. Please confirm, and advise on the liability, creditor, divorce, and estate trade-offs of individual ownership.
3. **SBG-Labor S-corp election.** Confirm the mechanics and timing (Form 2553), the reasonable-compensation posture at the planned $80/hr market wage, and whether Wisconsin follows the federal S election automatically.
4. **Wisconsin sales and use tax on the intercompany equipment leases (Wis. Stat. 77.52).** Confirm that SBG-Equipment must register with the WI DOR and collect and remit on the rental stream, and confirm the correct purchase-side treatment (resale or lease exemption) so the fleet is not taxed twice. This is separate from our position that CWDB's own revenue is not subject to sales tax.
5. **Leased-labor and workers' comp interaction.** How each operating LLC satisfies its Dwelling Contractor Certification's workers-comp-or-exemption condition while using leased crews covered under SBG-Labor, and the borrowed-servant / special-employer posture that bars a leased worker's tort suit against the operating LLC. Note the wrinkle that Wisconsin's closely-held officer workers-comp election-out is capped at two officers, while SBG-Labor has three partner-officers.
6. **DSPS licensing.** Confirm that SBG, as a labor and equipment lessor that does not contract with homeowners or pull permits, needs no Dwelling Contractor Certification (Wis. Stat. 101.654; SPS 305). Each operating LLC keeps its own certification and qualifier; Jim's individual qualifier is still pending.
7. **Buy-sell and ROFR.** Trigger events, valuation method and annual reset, installment payout, and life and disability insurance funding.
8. **Restrictive covenants (Wis. Stat. 103.465).** A tight non-compete and, most importantly, the 24-month crew anti-poaching covenant. Please draft narrowly, since Wisconsin voids an overbroad covenant entirely rather than narrowing it.
9. **Phase B trigger and equalization.** The method to value and equalize the three unequal LLCs when job profit begins to pool, decided now and executed later.
10. **Wind-down of the existing lead-purchase deal.** Central Wisconsin Deck Builders currently sells leads to Ben and John at $1,000 per accepted bid under signed agreements. We want a clean written termination and final accounting before the SBG relationships begin.
11. **Entity name clearance.** SBG-Labor, SBG-Equipment, and SBG-RealEstate are placeholders not yet cleared at WI DFI.
12. **Pre-existing entity disclosure (BartGar Investments).** See Section 5.

## 5. Disclosures you should have

- **BartGar Investments.** Jim Slogar and Ben Barton already co-own a separate entity (BartGar Investments, roughly 50/50, real-estate related, formed around 2021, with its own operating agreement). Two of the three SBG partners sharing a pre-existing joint entity may interact with the SBG buy-sell, non-compete, and capital terms. Please account for it.
- **Existing CWDB lead-purchase agreements.** Central Wisconsin Deck Builders has signed Contractor Lead Purchase Agreements with both Barton Builders LLC and John Garcia Construction, LLC (April 2026) at $1,000 per accepted bid. These are to be wound down (Question 10).
- **CWDB general liability insurance in placement.** Central Wisconsin Deck Builders is currently binding a commercial GL policy (Auto-Owners, through HUB International). Ben's and John's LLCs carry their own coverage; details are on the enclosed Facts Sheet.
- **DSPS qualifier pending for Jim.** Until Jim holds his individual Dwelling Contractor Qualifier and CWDB holds the entity certification, CWDB self-performs only cosmetic stain and resurface work and relies on a licensed builder for any build or structural job.
- **Superseded internal memos.** Some earlier internal memos in our files are superseded by the enclosed term sheet and should not be relied on.
- **Placeholder names and illustrative numbers.** The SBG entity names are unverified, and the dollar figures in the financial model are labeled assumptions to be confirmed against our books.

## 6. Enclosures

1. This briefing memo
2. Entity structure one-pager
3. Party and corporate facts sheet
4. SBG term sheet
5. Inter-company agreements outline
6. Financial model, Phase A (one internal section omitted)
7. Regulatory gating and due-diligence checklist

## 7. Suggested agenda for today (about 75 minutes)

| Time | Topic |
|---|---|
| 5 min | Introductions and confirm scope (Section 1) |
| 10 min | Joint representation and conflict of interest, and waivers (Question 1) |
| 15 min | Structure walk-through using the one-pager and term sheet: ownership form, equal cash, the three inter-company agreements (Question 2; term sheet Sections 2 and 3) |
| 15 min | Tax and regulatory gating: S-corp election, equipment-lease sales tax, workers' comp election-out, DSPS lessor status (Questions 3 to 6) |
| 10 min | Buy-sell, restrictive covenants, deadlock, and Phase B (Questions 7 to 9) |
| 10 min | Disclosures and loose ends: lead-deal wind-down, name clearance, BartGar Investments (Questions 10 to 12) |
| 10 min | Scope confirmation, drafting list, fee estimate, timeline, and next steps |

---

*This memo was prepared by AI legal counsel for informational and planning purposes only. It is not legal advice. Review by a licensed Wisconsin attorney is recommended before execution of any document referenced here.*
"""

FACTS = r"""# Party and Corporate Facts Sheet

**Prepared for:** %%ATTORNEY%%

**Re:** SBG Construction Group formation. Party identity data for drafting.

**Prepared:** %%PREP_DATE%%

> **How to use this.** Confirmed data is filled in. Items shown as `[ confirm ]` are still being collected and will be provided. Nothing here is a legal representation; please verify entity IDs against WI DFI and EINs against each party's records before drafting.

## A. The three existing operating LLCs

| Field | Central Wisconsin Deck Builders, LLC | Barton Builders LLC | John Garcia Construction, LLC |
|---|---|---|---|
| Owner / signer | James (Jim) Slogar, Sole Member and Manager | Ben Barton, Owner | John Garcia, Owner |
| Entity type | WI single-member LLC (Ch. 183) | WI LLC | WI LLC |
| Principal / registered address | 906 N 16th Ave, Wausau, WI 54401 | 233127 Silver Hill Ln, Wausau, WI 54401 | 1005 Edgewood Ave, Edgar, WI 54426 |
| Business office (if different) | same | `[ confirm ]` | 5408 Westfair Ave, Ste 3, Schofield / Weston, WI 54476 |
| Email | info@cwdeckbuilders.com | bartonbuildersllc@yahoo.com; ben@bartonbuildersllc.com | john@johngarciaconstruction.com |
| Phone | (715) 544-7941 | `[ confirm ]` | (715) 567-0269 |
| WI DFI Entity ID | C138564 | `[ confirm ]` | `[ confirm ]` |
| EIN | 41-5355234 | `[ confirm ]` | `[ confirm ]` |
| DSPS Dwelling Contractor Certification | `[ pending: Jim to obtain ]` | `[ confirm ]` | Credential #4011-DCFR |
| DSPS Qualifier (individual) | `[ pending: Jim ]` | `[ confirm ]` | `[ confirm name ]` |
| General liability insurance | Auto-Owners, placement in progress (HUB International); target $1M / $2M | `[ confirm carrier / limits / expiry ]` | On file; carrier / limits / expiry `[ confirm ]` |
| Workers' comp | None yet (no employees) | `[ confirm ]` | None (no employees) |
| Trade affiliations | n/a | `[ confirm ]` | WABA (board, Secretary), WBA (state representative), NAHB |
| Existing CWDB lead-purchase agreement | n/a (CWDB is the lead source) | Signed 4/7/2026 | Signed 4/11/2026 |

## B. The three proposed SBG entities (to form)

| Entity (placeholder name) | Purpose | Tax treatment | Ownership | Status |
|---|---|---|---|---|
| SBG-Labor, LLC | Employs the W-2 crews and the three partners; leases labor to the operating LLCs at market | S-corp election (Form 2553) | Jim / Ben / John, 1/3 each, as individuals | To form; name not yet cleared at WI DFI |
| SBG-Equipment, LLC | Owns and leases equipment to the operating LLCs at market | Partnership (default) | Jim / Ben / John, 1/3 each, as individuals | To form; name not yet cleared |
| SBG-RealEstate, LLC | Future shop or yard; dormant until a facility is purchased | Partnership (default) | Jim / Ben / John, 1/3 each, as individuals | Form now, dormant |

## C. The three principals (individuals; direct owners of the SBG entities)

| Principal | SBG governance lane | Email | Phone |
|---|---|---|---|
| Jim Slogar | Finance, sales, marketing | slogarjw@gmail.com | (715) 212-2078 |
| Ben Barton | Field operations, crews, equipment, safety | bartonbuildersllc@yahoo.com; ben@bartonbuildersllc.com | `[ confirm ]` |
| John Garcia | Customer service, estimating, scheduling | john@johngarciaconstruction.com | (715) 567-0269 |

## D. Items to collect before drafting

- **Barton Builders LLC:** WI DFI Entity ID, EIN, DSPS certification and qualifier numbers, GL carrier / limits / expiry, business phone, workers' comp status.
- **John Garcia Construction, LLC:** WI DFI Entity ID, EIN, GL carrier / limits / expiry, named qualifier.
- **Central Wisconsin Deck Builders, LLC:** finalize the GL binding; Jim's DSPS qualifier and entity certification.
- **All three SBG entities:** confirm and reserve names at WI DFI; set the equal-cash contribution amount per partner.
- **Disclosure to account for:** BartGar Investments (Jim and Ben, pre-existing joint entity). See the briefing memo, Section 5.

---

*Prepared by AI legal counsel for informational purposes. Confirm all entity IDs, EINs, and insurance details against source records before execution.*
"""


if __name__ == '__main__':
    main()
