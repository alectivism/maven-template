---
name: mma-pptx-builder
description: Generate or edit MMA PowerPoint decks — official template, slide masters, approved shapes (accent cards, callouts, tables, flow diagrams), python-pptx patterns. Use for ANY .pptx task: new decks, slide edits, recolors, layout fixes, text changes.
---

# MMA PowerPoint Builder

Generate slides that inherit MMA's real template structure, use the correct master layouts, preserve logo/header positioning, and produce visually strong shape-based slides.

> **Colors, fonts, tone, naming:** See **mma-brand-guidelines** skill. This skill covers PPTX-specific construction rules only.

---

## 1. Template — Finding It

Always start from the official MMA template. Never build from a blank Presentation().

**Canonical template (as of April 2026):** `MMA_PPT_Template_v2.1_2026.pptx` — 6 slide masters (Core Gold + 4 think tanks + Charts and Tables). Pre-converted from the POTX source so python-pptx opens it directly.

### Template discovery — try in this order

**Step 1 — Local project directory (Claude Code / Cowork only; skip on claude.ai).**

```bash
find . -maxdepth 4 -iname "MMA*Template*.pptx" -o -iname "MMA*Template*.potx" 2>/dev/null
```

If you cloned the MAVEN repo, the template also lives at `templates/MMA_PPT_Template_v2.1_2026.pptx` within that repo.

**Step 2 — Public download waterfall (primary for claude.ai and any environment without SharePoint binary access).**

The MS 365 / SharePoint connector in claude.ai **cannot return the binary** of a .pptx file — it only extracts text. Use the public download waterfall instead. Try each in order; stop at the first success.

Download destination: `/tmp/MMA_Template.pptx` (claude.ai) or `./MMA_Template.pptx` (Claude Code).

**Option A — GitHub raw (primary, public MAVEN repo):**
```bash
curl -L -o MMA_Template.pptx "https://raw.githubusercontent.com/alectivism/MAVEN/main/templates/MMA_PPT_Template_v2.1_2026.pptx"
```

**Option B — Dropbox (fallback):**
```bash
curl -L -o MMA_Template.pptx "https://www.dropbox.com/scl/fi/9ik7pgiwxzxh3bbo50sbk/MMA-PPT-Template-v2.1-2026.pptx?rlkey=w9ldavfftrs2246h9x914xtyx&dl=1"
```
`&dl=1` (not `&dl=0`) forces a direct binary download.

**Option C — Google Drive (last resort):**
```bash
curl -L -o MMA_Template.pptx "https://drive.google.com/uc?export=download&id=1KahihBYQ7AO9KpkeC__KP8afcHBg2Wa4"
```

**In claude.ai (no bash), use the Python tool:**
```python
import urllib.request
urllib.request.urlretrieve(
    "https://raw.githubusercontent.com/alectivism/MAVEN/main/templates/MMA_PPT_Template_v2.1_2026.pptx",
    "/tmp/MMA_Template.pptx",
)
```

**Verify the download is a real PPTX, not an HTML error page:**
```python
from pptx import Presentation
prs = Presentation("/tmp/MMA_Template.pptx")
assert len(prs.slide_masters) == 6, "Wrong template — should have 6 masters"
```
If this fails, delete the file and fall through to the next option.

**Step 3 — SharePoint via Microsoft connector (locates but CANNOT return binary).**
Use only to confirm version or find a newer template — not to build from. File name: `MMA PPT Template v2.1 2026.potx`. Path: `MMA Internal > Documents > General > Marketing + Media Alliance MMA Brand Kit 2025`.

**Step 4 — Synced OneDrive app (Claude Code / Cowork only, macOS).**
```
/Users/<username>/Library/CloudStorage/OneDrive-MMAGlobal/MMA Internal - Documents/General/Marketing + Media Alliance MMA Brand Kit 2025/MMA PPT Template v2.1 2026.potx
```

### POTX → PPTX conversion (legacy — usually not needed)

The public download waterfall serves a pre-converted `.pptx` directly, so most runs skip this. Only needed if starting from a raw `.potx`. python-pptx cannot open `.potx` — throws `ValueError: not a PowerPoint file`. Patch the content type:

```python
import zipfile

def potx_to_pptx(src_potx, dst_pptx):
    with zipfile.ZipFile(src_potx, "r") as zin, \
         zipfile.ZipFile(dst_pptx, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename == "[Content_Types].xml":
                data = data.replace(
                    b"presentationml.template.main+xml",
                    b"presentationml.presentation.main+xml",
                )
            zout.writestr(item, data)

from pptx import Presentation
prs = Presentation("MMA_Template.pptx")
```

New slides inherit the real masters, logo placement, slide numbers, and footer positions.

---

## 2. Slide Layout Index Map

| Index | Name | Use for |
|-------|------|---------|
| **4** | `1_Title Slide` | First slide of deck. White bg, logo top-left, gold diagonal right. |
| **7** | `1_Title and Content Black Bullets` | **Default for most content slides.** Shape-heavy, cards, charts, tables, callouts. Preserves title position + gold accent bar without unused body placeholder. |
| **8** | `Title and Content Gold Bullets` | Bullet-list slides only. Has body placeholder. |
| **1** | `Section Header` | Section dividers. |
| **9** | `Two Content` | True two-column layouts needing native placeholders. |
| **10** | `1_Blank` | Full-bleed imagery ONLY. Never for ordinary content. |

**Layout 7 is the workhorse.** It has placeholder[0] (title) and placeholder[12] (slide number) but no body placeholder. Shapes go directly on the slide.

**Layout 8** has placeholder[1] (body). Use `ph = slide.placeholders[1]; ph.text = ""` to clear it, then add shapes.

```python
# Remove all sample slides from template before adding your own
while len(prs.slides) > 0:
    rId = prs.slides._sldIdLst[0].get(qn('r:id'))
    prs.part.drop_rel(rId)
    prs.slides._sldIdLst.remove(prs.slides._sldIdLst[0])
```

---

## 3. Typography (PPTX-Specific Sizes)

| Element | Font | Size | Notes |
|---------|------|------|-------|
| Slide title | Söhne Halbfett | **36pt** (default), 28pt min | Black, left-aligned, no trailing periods |
| Subtitle | Söhne Leicht | 18-20pt | Gray (#666666), **same text box as title** (second paragraph) |
| Section header title | Söhne Halbfett | **60pt** | |
| Section header subtitle | Söhne Leicht | **36pt** | |
| Body / bullets | Söhne Leicht | 16-20pt (16pt min) | |
| Card titles | Söhne Halbfett | 18-20pt | |
| Table text | Söhne Leicht | 14-16pt (14pt min) | Headers in Halbfett |
| Footnotes / source lines | Söhne Leicht | 12pt min | Never below 12pt |
| Callout labels | Söhne Halbfett | 16pt | Gold (#FFA400), inline with body |

Leading: +10% for headlines, +20% for body. Tracking: 0.

---

## 4. Color Usage in Slides

> Full hex/RGB values are in **mma-brand-guidelines**. Key PPTX rules:

- **75% tints** for shape fills, accent bars, card backgrounds, diagram nodes. Use tints far more than full-saturation fills.
- **Full-saturation colors** for text accents, borders, small bars, emphasis, title colors on accent-bar cards.
- **NEVER same-hue text on same-hue background.** No gold text on gold card. No blue text on blue-tint card.
- **Card body text:** Black (#000000) or dark gray (#333333) on light fills. White (#FFFFFF) on dark fills.
- **Default slide bg:** White. Section dividers: Gold bg with black text.

### Quick Reference (PPTX constants)

```python
GOLD      = RGBColor(0xFF, 0xA4, 0x00)
BLACK     = RGBColor(0x00, 0x00, 0x00)
WHITE     = RGBColor(0xFF, 0xFF, 0xFF)
EMERALD   = RGBColor(0x00, 0xAB, 0x84)
SAPPHIRE  = RGBColor(0x00, 0x47, 0xBB)
TOPAZ     = RGBColor(0xE2, 0x57, 0x00)
PERIDOT   = RGBColor(0xB5, 0xC9, 0x00)

LT_GOLD     = RGBColor(0xFF, 0xBB, 0x4D)
LT_EMERALD  = RGBColor(0x66, 0xCD, 0xB7)
LT_SAPPHIRE = RGBColor(0x40, 0x79, 0xD6)
LT_TOPAZ    = RGBColor(0xE9, 0x8B, 0x4D)
LT_PERIDOT  = RGBColor(0xD6, 0xE4, 0x66)

DARK_GRAY   = RGBColor(0x33, 0x33, 0x33)
MED_GRAY    = RGBColor(0x66, 0x66, 0x66)
LIGHT_BG    = RGBColor(0xF5, 0xF5, 0xF5)
CREAM       = RGBColor(0xFF, 0xF5, 0xE0)
ALT_ROW     = RGBColor(0xEB, 0xEB, 0xEB)
BORDER_CLR  = RGBColor(0xE0, 0xE0, 0xE0)
```

---

## 5. Shape Construction Patterns

### General Rules

- Use shapes actively. Most slides should be shape-driven, not plain bullets.
- Put text inside shapes whenever possible.
- Internal margins: `margin_left=0.25"`, `margin_right=0.25"`, `margin_top=0.15"`, `margin_bottom=0.15"`.
- Keep corner radii subtle (adj=5000), not cartoonish.
- Keep card groups centered and balanced.
- Protect the MMA logo area: keep content out of the bottom-right ~1.5" x 0.8".

### Tight Corner Radius Helper

All ROUNDED_RECTANGLE shapes should use tight corners:

```python
def set_tight_corners(shape, adj=5000):
    sp = shape._element
    prstGeom = sp.find(".//" + qn("a:prstGeom"))
    if prstGeom is not None:
        avLst = prstGeom.find(qn("a:avLst"))
        if avLst is None:
            avLst = etree.SubElement(prstGeom, qn("a:avLst"))
        for gd in avLst.findall(qn("a:gd")):
            avLst.remove(gd)
        gd_el = etree.SubElement(avLst, qn("a:gd"))
        gd_el.set("name", "adj")
        gd_el.set("fmla", f"val {adj}")

def add_rounded_card(slide, left, top, width, height, fill_color=LIGHT_BG):
    s = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
    s.fill.solid(); s.fill.fore_color.rgb = fill_color
    s.line.fill.background()
    set_tight_corners(s)
    return s
```

---

## 6. Accent Bar Cards

**Top-bar cards are the canonical default.** They are more reliable than left-bar cards for correct corner geometry.

### Top Bar Card (preferred)

Sharp top corners, rounded bottom corners. Uses ROUND_2_SAME_RECTANGLE rotated 180 degrees.

**Critical:** Because the shape is rotated, text inside it renders upside-down. Always use a **separate overlaid text box** for content.

```python
def add_r2s_card(slide, left, top, width, height, fill_color=LIGHT_BG,
                 rotation=0.0, adj1=5000, adj2=0):
    """ROUND_2_SAME_RECTANGLE via preset geometry.
    rotation=180 -> sharp top, rounded bottom (for top bar cards)
    """
    s = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, left, top, width, height)
    sp = s._element
    prstGeom = sp.find(".//" + qn("a:prstGeom"))
    prstGeom.set("prst", "round2SameRect")
    avLst = prstGeom.find(qn("a:avLst"))
    if avLst is None:
        avLst = etree.SubElement(prstGeom, qn("a:avLst"))
    for gd in avLst.findall(qn("a:gd")):
        avLst.remove(gd)
    gd1 = etree.SubElement(avLst, qn("a:gd"))
    gd1.set("name", "adj1"); gd1.set("fmla", f"val {adj1}")
    gd2 = etree.SubElement(avLst, qn("a:gd"))
    gd2.set("name", "adj2"); gd2.set("fmla", f"val {adj2}")
    s.fill.solid(); s.fill.fore_color.rgb = fill_color
    s.line.fill.background()
    if rotation:
        s.rotation = rotation
    return s
```

**Usage pattern:**

```python
# 1. Card body (sharp top, rounded bottom)
card = add_r2s_card(slide, x, y, card_w, card_h,
                    fill_color=LIGHT_BG, rotation=180.0)

# 2. Accent bar flush on top (75% tint color)
add_rect(slide, x, y, card_w, Inches(0.07), LT_GOLD)

# 3. Text in SEPARATE overlaid text boxes (not inside the rotated shape)
add_textbox(slide, x + Inches(0.3), y + Inches(0.25),
            card_w - Inches(0.6), Inches(0.4),
            title, FT, Pt(20), BLACK, bold=True)
add_textbox(slide, x + Inches(0.3), y + Inches(0.8),
            card_w - Inches(0.6), Inches(1.8),
            body, FB, Pt(16), DARK_GRAY)
```

### Left Bar Card (fallback)

Use only when the design specifically calls for it. Uses standard ROUNDED_RECTANGLE with a bar rectangle overlaid on the left side (masks rounded corners). Text goes **inside** the card shape (not rotated, so text works normally).

```python
# 1. Card body with text inside
card = add_rounded_card(slide, x, y, card_w, card_h, LIGHT_BG)
tf = card.text_frame
tf.word_wrap = True
tf.margin_left = Inches(0.35)  # Extra left margin to clear the bar
tf.margin_right = Inches(0.2)
tf.margin_top = Inches(0.2)
# ... add text to tf ...

# 2. Left bar ADDED AFTER card (higher z-order masks rounded left corners)
add_rect(slide, x, y, Inches(0.07), card_h, LT_GOLD)
```

**The bar must be added AFTER the card** so it sits on top in z-order.

---

## 7. Callout Boxes

### Cream callout (default)

```python
box = add_rounded_card(slide, left, top, width, height, CREAM)
box.line.color.rgb = GOLD
box.line.width = Pt(2)
tf = box.text_frame
tf.word_wrap = True
tf.margin_left = Inches(0.3)
tf.margin_right = Inches(0.3)
tf.margin_top = Inches(0.15)
p = tf.paragraphs[0]
p.alignment = PP_ALIGN.LEFT
r1 = p.add_run()  # Label
r1.text = "Tip: "
r1.font.name = FT; r1.font.size = Pt(16)
r1.font.color.rgb = GOLD; r1.font.bold = True
r2 = p.add_run()  # Body (inline, same paragraph)
r2.text = "Your tip text here."
r2.font.name = FB; r2.font.size = Pt(14)
r2.font.color.rgb = DARK_GRAY
```

### Dark callout

Black fill (#000000), gold label, white body text. Same structure, different colors.

### Neutral callout

Light gray fill (#F5F5F5), thin gray border (#E0E0E0, 1pt), dark gray label.

---

## 8. Tables

Always use native PowerPoint table objects. Never fake tables with shapes.

```python
def style_table(table):
    """Remove default table styling for manual control."""
    tbl_el = table._tbl
    tblPr = tbl_el.find(qn("a:tblPr"))
    if tblPr is None:
        tblPr = etree.SubElement(tbl_el, qn("a:tblPr"))
    tblPr.set("bandRow", "0")
    tblPr.set("firstRow", "0")
    tblPr.set("firstCol", "0")
    for ts in tblPr.findall(qn("a:tblStyle")):
        tblPr.remove(ts)

def set_cell_border(cell, color_hex="D0D0D0", width_pt=0.5):
    tc = cell._tc
    tcPr = tc.find(qn("a:tcPr"))
    if tcPr is None:
        tcPr = etree.SubElement(tc, qn("a:tcPr"))
    for side in ["lnL", "lnR", "lnT", "lnB"]:
        ln = tcPr.find(qn(f"a:{side}"))
        if ln is not None:
            tcPr.remove(ln)
        ln = etree.SubElement(tcPr, qn(f"a:{side}"))
        ln.set("w", str(int(width_pt * 12700)))
        ln.set("cmpd", "sng")
        solidFill = etree.SubElement(ln, qn("a:solidFill"))
        srgb = etree.SubElement(solidFill, qn("a:srgbClr"))
        srgb.set("val", color_hex)
```

### Table styling rules

| Element | Style |
|---------|-------|
| Header row (option A) | Dark gray (#333333) fill, white bold Halbfett text |
| Header row (option B) | Gold (#FFA400) fill, white bold Halbfett text |
| Odd data rows | White fill |
| Even data rows | #EBEBEB fill (visible contrast) |
| First column | Bold Halbfett text (same row background, no separate fill) |
| Borders | Thin #D0D0D0, all sides + inner |
| Cell margins | 0.12" left/right, 0.08" top/bottom |
| Text | Söhne Leicht 14pt, left-aligned |

---

## 9. Flow Diagrams

```python
# Nodes: rounded rectangle with 75% tint fill
node = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, x, y, w, h)
node.fill.solid(); node.fill.fore_color.rgb = LT_GOLD
node.line.fill.background()
set_tight_corners(node, adj=5000)

# Connectors: real RIGHT_ARROW shapes (NOT line + triangle)
arrow = slide.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, ax, ay, Inches(0.3), Inches(0.2))
arrow.fill.solid(); arrow.fill.fore_color.rgb = MED_GRAY
arrow.line.fill.background()
```

- Keep ~0.15" gap between arrows and nodes on both sides.
- Labels go **inside** the nodes, centered.
- Use Halbfett 14pt for node text.
- Below-node labels in Leicht 14pt medium gray.

---

## 10. Other Elements

### Numbered circles

```python
s = slide.shapes.add_shape(MSO_SHAPE.OVAL, left, top, Inches(0.5), Inches(0.5))
s.fill.solid(); s.fill.fore_color.rgb = GOLD; s.line.fill.background()
tf = s.text_frame; tf.word_wrap = False
tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = Inches(0)
p = tf.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
r = p.add_run()
r.text = "1"; r.font.name = FT; r.font.size = Pt(18)
r.font.color.rgb = WHITE; r.font.bold = True
```

### Separator lines

Thin RECTANGLE shapes, not underscores or line objects:

```python
s = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, left, top, width, Pt(1))
s.fill.solid(); s.fill.fore_color.rgb = BORDER_CLR; s.line.fill.background()
```

### Bullet formatting

Use unicode bullet prefix with spacing for consistent indentation:

```python
r.text = "\u2022  " + item_text  # bullet + 2 spaces
```

---

## 11. Slide Number Helper

```python
def set_slide_number(slide, num):
    for ph in slide.placeholders:
        if ph.placeholder_format.idx == 12:
            ph.text = str(num)
            for r in ph.text_frame.paragraphs[0].runs:
                r.font.size = Pt(10)
            return
```

---

## 12. Logo Safe Area

The template places the MMA logo in the lower-right corner.

- Do not overlap the logo with text or shapes.
- Keep content out of the bottom-right ~1.5" x 0.8".
- For dense slides: stop content above that zone, or place a white backing rectangle behind content.

---

## 13. Design Behavior Rules

- Most slides should be shape-driven, not plain bullets.
- One idea per slide. Lead with the takeaway, not a generic topic label.
- Don't let 3+ consecutive slides feel identically templated.
- Prefer clean layouts with white space.
- Avoid overcrowding and shape overlaps.
- Keep groups visually centered: `center_x = (slide_width - total_width) / 2`.

---

## 14. Critical DO NOT Rules

| Rule | Why |
|------|-----|
| **Never use custGeom** | Renders invisible shapes in PowerPoint. Completely broken in python-pptx. |
| **Never rotate shapes 90 or 270 degrees** | Width/height swap, breaks card dimensions and bar alignment. |
| **Never use flipV/flipH on shapes with text** | Text renders upside-down/mirrored. |
| **Never put text inside a rotated R2S card** | Text is upside-down. Use overlaid text boxes instead. |
| **Never hand-build arrows from line + triangle** | Use MSO_SHAPE.RIGHT_ARROW. |
| **Never fake tables from shapes** | Use native PowerPoint tables. |
| **Never use Blank layout for content slides** | Only for full-bleed imagery. |
| **Never build from blank Presentation()** | Always use the MMA template. |

---

## 15. Practical Revision Rule

If the user says a slide or pattern is good, preserve it. Do not reopen solved problems unless later feedback supersedes them. Iterate only on parts the user says still need work.

---

## 16. Claude for PowerPoint Add-in

When generating custom instructions for the Claude PowerPoint add-in (not python-pptx), apply the same brand logic but note:

- Edit points manually for true sharp bar-side corners on left-bar cards.
- Subtitle belongs in the same text box as the title (second paragraph).
- Follow the same master-selection rules.
- The add-in can achieve geometry that python-pptx cannot (e.g., perfect left-bar corners via point editing).

---

## 17. Required Imports

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
from pptx.oxml.ns import qn
from lxml import etree
```
