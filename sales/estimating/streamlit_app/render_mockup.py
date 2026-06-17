"""
CWDB estimate mock-up renderer.

Uses Google Gemini 2.5 Flash Image ("nano banana") to edit a walk-through photo
into a photorealistic rendering of the finished project in the selected
materials and colors. Runs fully automatically at estimate send-time.

Design contract:
- NEVER raises. Any failure (missing key, missing deps, API error, bad image)
  returns whatever renders succeeded (possibly an empty list) so a bad or failed
  render can never block the estimate from going out.
- Every rendering carries a mandatory illustration-only DISCLAIMER caption.
"""

from __future__ import annotations

from pathlib import Path

MODEL = "gemini-2.5-flash-image"

# Disclaimer wording per legal-compliance-counsel review (Wis. Stat. 100.18,
# ATCP 110.02, FTC deception). Must stay conspicuous and immediately below
# each rendering. Do not weaken.
DISCLAIMER = (
    "COMPUTER-GENERATED SIMULATION: NOT A PHOTOGRAPH. This image was produced "
    "by AI image-editing software from a photo of your property to help you "
    "visualize a possible design. It is for illustration only and is not an "
    "architectural drawing, a measured rendering, or a promise of how the "
    "finished project will look. Materials, colors, dimensions, railing and "
    "stair styles, lighting, landscaping, and other details shown are "
    "approximations and may differ from, or may not be included in, the actual "
    "work. Only the written, itemized scope and price in this estimate (and any "
    "signed contract) control what CWDB will build. This image is not a "
    "representation, guarantee, or warranty of the finished work."
)

# Burned into every rendering so the label travels with the image even if the
# caption is cropped/screenshotted away (legal counsel: watermark = yes).
WATERMARK_TEXT = "AI SIMULATION - ILLUSTRATION ONLY"


def _watermark(img):
    """Burn a conspicuous semi-opaque banner across the bottom of the image."""
    from PIL import Image, ImageDraw, ImageFont

    base = img.convert("RGBA")
    w, h = base.size
    band_h = max(26, h // 16)
    overlay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    d.rectangle([0, h - band_h, w, h], fill=(20, 20, 20, 165))
    font = None
    for name in ("arialbd.ttf", "DejaVuSans-Bold.ttf", "Arial Bold.ttf"):
        try:
            font = ImageFont.truetype(name, int(band_h * 0.5))
            break
        except Exception:
            continue
    if font is None:
        font = ImageFont.load_default()
    tb = d.textbbox((0, 0), WATERMARK_TEXT, font=font)
    tw = tb[2] - tb[0]
    d.text(((w - tw) / 2, h - band_h + (band_h - (tb[3] - tb[1])) / 2 - tb[1]),
           WATERMARK_TEXT, fill=(255, 255, 255, 235), font=font)
    return Image.alpha_composite(base, overlay).convert("RGB")

# Long-edge cap for input photos (keeps request small + fast; well under the
# 20 MB inline limit).
_MAX_EDGE = 1568


def _open_image(path):
    """Open a photo as an RGB PIL image, registering the HEIC opener on demand."""
    from PIL import Image  # local import so the module loads without Pillow

    ext = Path(path).suffix.lower()
    if ext in (".heic", ".heif"):
        try:
            import pillow_heif

            pillow_heif.register_heif_opener()
        except Exception:
            pass  # if unavailable, Image.open will raise and the caller skips it

    img = Image.open(path).convert("RGB")
    if max(img.size) > _MAX_EDGE:
        img.thumbnail((_MAX_EDGE, _MAX_EDGE))
    return img


def _subject_phrase(sel):
    """Describe the structure to render from the form selections."""
    def _has_color(c):
        return c and not any(
            w in str(c) for w in ("Natural", "standard", "Clear", "finish via stain", "(standard)")
        )

    if sel.get("is_fence"):
        phrase = f"a new {sel.get('fence_height', '6')} ft {sel.get('fence_material', 'privacy')} fence"
        if _has_color(sel.get("fence_color")):
            phrase += f" in {sel['fence_color']}"
        return phrase

    dm = sel.get("decking_material", "composite")
    parts = [f"{dm} decking"]
    if _has_color(sel.get("decking_color")):
        parts[0] += f" in {sel['decking_color']}"
    rm = sel.get("railing_material")
    if rm:
        rail = f"{rm} railing"
        if _has_color(sel.get("railing_color")):
            rail += f" in {sel['railing_color']}"
        parts.append(rail)
    return "a newly built deck with " + " and ".join(parts)


def _prompt(sel, shot):
    subject = _subject_phrase(sel)
    framing = (
        "Show a wide, full view of the whole project in its setting."
        if shot == "wide"
        else "Show a closer detail view that emphasizes the material texture, "
        "grain, and true color of the decking and railing."
    )
    return (
        "You are an architectural visualization tool for a deck and fence "
        f"contractor. Edit the provided photo of the customer's property to show {subject}. "
        f"{framing} "
        "Keep the house, yard, landscaping, existing structures, sky, camera "
        "perspective, and lighting from the original photo intact and realistic; "
        "only add or replace the deck/fence described. Photorealistic, natural "
        "lighting, true-to-product material color and wood grain. Do not add any "
        "text, watermarks, logos, people, or furniture that was not already in the photo."
    )


def generate_mockups(photo_paths, selections, out_dir, api_key, max_renders=2):
    """Generate up to `max_renders` mock-up renderings (wide + detail).

    Returns a list of {'path': Path, 'caption': str}. Returns [] on any failure.
    """
    results = []
    photo_paths = [p for p in (photo_paths or []) if p]
    if not api_key or not photo_paths:
        return results

    try:
        from google import genai

        client = genai.Client(api_key=api_key)
    except Exception:
        return results  # SDK missing or key invalid -> skip silently

    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Shot plan: distinct source photos when we have them, else reuse the first.
    if len(photo_paths) >= 2:
        plan = [(0, "wide"), (1, "detail")]
    else:
        plan = [(0, "wide"), (0, "detail")]
    plan = plan[:max_renders]

    for i, (src_idx, shot) in enumerate(plan):
        try:
            img = _open_image(photo_paths[src_idx])
            resp = client.models.generate_content(
                model=MODEL,
                contents=[_prompt(selections, shot), img],
            )
            out_img = None
            for part in (resp.parts or []):
                if getattr(part, "inline_data", None) is not None:
                    out_img = part.as_image()
                    break
            if out_img is None:
                continue
            try:
                out_img = _watermark(out_img)
            except Exception:
                pass  # best-effort; a watermark failure must not block the render
            rpath = out_dir / f"mockup_{i + 1}_{shot}.png"
            out_img.save(rpath)
            label = "Finished-project preview" + (" (detail)" if shot == "detail" else "")
            results.append({"path": rpath, "caption": f"{label}. {DISCLAIMER}"})
        except Exception:
            continue  # one bad render never blocks the rest or the estimate

    return results
