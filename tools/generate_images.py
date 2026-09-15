#!/usr/bin/env python3
"""
Prisma Scan — asset generator.

Generates every image the app uses (see docs/IMAGE_PROMPTS.md) with Google's
Gemini image model ("Nano Banana", gemini-2.5-flash-image) and writes each file
into assets/images/ with the exact filename the app expects.

Setup
-----
    python3 -m venv .venv && source .venv/bin/activate
    pip install -r tools/requirements.txt          # google-genai (+ Pillow for --transparent)
    export GEMINI_API_KEY="your_key_here"          # or pass --api-key

Usage
-----
    python3 tools/generate_images.py --list                 # show all assets
    python3 tools/generate_images.py                        # generate all (skips existing)
    python3 tools/generate_images.py --only logo pro_planet # just these
    python3 tools/generate_images.py --force                # overwrite existing
    python3 tools/generate_images.py --transparent          # knock out flat bg on flagged assets

Get a free API key at https://aistudio.google.com/apikey
"""

from __future__ import annotations

import argparse
import os
import sys
import time
from dataclasses import dataclass, field

# --- Shared style block prepended to every prompt (keeps assets consistent) ---
SHARED_STYLE = (
    "Holographic glassmorphism aesthetic. Iridescent gradient of soft pink "
    "(#F8A5E0), lavender (#B98CFF), periwinkle (#8AA8FF) and aqua-cyan (#7EE8FA). "
    "Frosted translucent glass, soft inner glow, gentle 3D, smooth rounded forms, "
    "subtle depth and highlights, clean and premium, Apple-like. Studio lighting, "
    "no harsh shadows. Minimal, modern, high detail. No text or lettering in the image."
)


@dataclass
class Asset:
    key: str          # --only selector
    filename: str     # output file in assets/images/
    aspect: str       # aspect ratio hint, e.g. "1:1"
    prompt: str       # subject prompt (style block is prepended automatically)
    transparent: bool = False   # knock out flat background with --transparent
    solid_bg: bool = False      # filled background (app icon / store art)

    @property
    def full_prompt(self) -> str:
        bg = (
            "Fill the entire frame with the holographic gradient background."
            if self.solid_bg
            else "Place the subject on a perfectly flat, uniform pure white #FFFFFF "
            "background with absolutely no gradient, no vignette and no drop "
            "shadow — the background must be a single solid white so the subject "
            "can be cleanly cut out. Centered with generous padding."
        )
        return (
            f"{SHARED_STYLE} {bg} Aspect ratio {self.aspect}. "
            f"Subject: {self.prompt}"
        )


# --- The catalog (mirrors docs/IMAGE_PROMPTS.md) ------------------------------
ASSETS: list[Asset] = [
    Asset("logo", "logo.png", "1:1", transparent=True, prompt=(
        "A single minimalist app logo mark: an abstract hexagonal prism made of "
        "layered translucent iridescent glass catching a rainbow light refraction. "
        "Centered, symmetrical, crisp, vector-clean silhouette, generous padding.")),
    Asset("app_icon", "app_icon.png", "1:1", solid_bg=True, prompt=(
        "An iOS/Android app icon: the Prisma prism hexagon mark centered on a smooth "
        "holographic gradient, soft glass sheen, rounded-square safe area, glossy and premium.")),
    Asset("wordmark", "wordmark.png", "21:9", transparent=True, prompt=(
        "The wordmark 'Prisma Scan' in a clean rounded geometric sans-serif, deep violet "
        "ink, with a small prism hexagon mark to the left. Balanced spacing, crisp.")),
    Asset("empty_documents", "empty_documents.png", "1:1", transparent=True, prompt=(
        "A friendly 3D translucent glass document with a soft holographic sheen and a "
        "subtle dashed 'add' glow, floating with tiny sparkles, optimistic, roomy space.")),
    Asset("empty_search", "empty_search.png", "1:1", transparent=True, prompt=(
        "A glass magnifying lens over a faint translucent document, iridescent rim light, "
        "gently tilted, floating, calm and minimal.")),
    Asset("scan_onboarding", "scan_onboarding.png", "4:3", transparent=True, prompt=(
        "A 3D translucent glass smartphone capturing a floating paper document, glowing cyan "
        "edge-detection frame with bright corner brackets around the page, light rays.")),
    Asset("processing", "processing.png", "1:1", transparent=True, prompt=(
        "An abstract holographic glass orb with swirling iridescent light and tiny document "
        "sparkles, a sense of motion and processing, centered.")),
    Asset("empty_pdf", "empty_pdf.png", "1:1", transparent=True, prompt=(
        "A translucent glass PDF booklet, slightly open, iridescent pages, soft floating "
        "shadow, calm and minimal.")),
    Asset("empty_folder", "empty_folder.png", "1:1", transparent=True, prompt=(
        "An open translucent glass folder with a soft holographic interior glow and a couple "
        "of faint floating document cards, friendly and minimal.")),
    Asset("pro_planet", "pro_planet.png", "1:1", transparent=True, prompt=(
        "A gorgeous 3D iridescent glass planet/orb with a thin holographic ring tilted around "
        "it, radial pink-to-blue gradient surface, glossy highlights, soft rim glow, premium "
        "and aspirational, centered and floating.")),
    Asset("pro_crown", "pro_crown.png", "1:1", transparent=True, prompt=(
        "A small glossy 3D crown icon made of translucent iridescent glass with a warm "
        "pink-violet-amber gradient and soft glow, simple and centered.")),
    Asset("success", "success.png", "1:1", transparent=True, prompt=(
        "A translucent glass checkmark inside a soft holographic circle, gentle confetti "
        "sparkles in pink and cyan, celebratory but refined, centered.")),
    Asset("store_hero", "store_hero.png", "9:16", solid_bg=True, prompt=(
        "A premium hero scene: two floating glass smartphones showing a document-scanner app "
        "UI, iridescent gradient studio background, soft god-rays, a scanned paper turning into "
        "a glowing PDF, cinematic and clean with space on the left for a headline.")),
]


def build_client(api_key: str):
    try:
        from google import genai  # type: ignore
    except ImportError:
        sys.exit("Missing dependency. Run:  pip install -r tools/requirements.txt")
    return genai.Client(api_key=api_key)


def generate_one(client, model: str, asset: Asset, out_dir: str,
                 retries: int = 3) -> str | None:
    """Generate a single asset; returns the saved path or None on failure."""
    from google.genai import types  # type: ignore

    # Ask for an image response; aspect ratio via image_config when supported.
    try:
        cfg = types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(aspect_ratio=asset.aspect),
        )
    except (AttributeError, TypeError):
        cfg = types.GenerateContentConfig(response_modalities=["IMAGE"])

    for attempt in range(1, retries + 1):
        try:
            resp = client.models.generate_content(
                model=model, contents=asset.full_prompt, config=cfg,
            )
        except Exception as exc:  # network / quota / transient
            wait = 2 ** attempt
            print(f"    ! {asset.key}: {exc} (retry in {wait}s)")
            time.sleep(wait)
            continue

        img_bytes, mime = _first_image(resp)
        if img_bytes is None:
            note = _first_text(resp) or "no image returned"
            print(f"    ! {asset.key}: {note} (attempt {attempt}/{retries})")
            time.sleep(2)
            continue

        path = os.path.join(out_dir, asset.filename)
        with open(path, "wb") as fh:
            fh.write(img_bytes)
        if asset.transparent:
            _maybe_transparent(path)
        return path
    return None


def _first_image(resp):
    for cand in getattr(resp, "candidates", None) or []:
        content = getattr(cand, "content", None)
        for part in getattr(content, "parts", None) or []:
            inline = getattr(part, "inline_data", None)
            if inline and getattr(inline, "data", None):
                return inline.data, getattr(inline, "mime_type", "image/png")
    return None, None


def _first_text(resp):
    for cand in getattr(resp, "candidates", None) or []:
        content = getattr(cand, "content", None)
        for part in getattr(content, "parts", None) or []:
            if getattr(part, "text", None):
                return part.text.strip()
    return None


# --- Optional: knock out a flat (white) background to transparency ------------
_TRANSPARENT_ENABLED = False


def _maybe_transparent(path: str) -> None:
    if not _TRANSPARENT_ENABLED:
        return
    try:
        from PIL import Image
    except ImportError:
        print("    (skip transparency: pip install Pillow)")
        return

    img = Image.open(path).convert("RGBA")
    px = img.load()
    w, h = img.size
    # Border flood-fill: treat near-white pixels reachable from the edges as bg.
    thresh = 238
    seen = [[False] * w for _ in range(h)]
    stack = [(x, 0) for x in range(w)] + [(x, h - 1) for x in range(w)]
    stack += [(0, y) for y in range(h)] + [(w - 1, y) for y in range(h)]

    def is_bg(x, y):
        r, g, b, _ = px[x, y]
        return r >= thresh and g >= thresh and b >= thresh

    while stack:
        x, y = stack.pop()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y][x]:
            continue
        seen[y][x] = True
        if not is_bg(x, y):
            continue
        px[x, y] = (255, 255, 255, 0)
        stack.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    img.save(path)


def main() -> None:
    global _TRANSPARENT_ENABLED
    ap = argparse.ArgumentParser(description="Generate Prisma Scan images via Gemini.")
    ap.add_argument("-k", "--api-key", default=os.environ.get("GEMINI_API_KEY"),
                    help="Gemini API key (or set GEMINI_API_KEY).")
    ap.add_argument("--model", default="gemini-2.5-flash-image",
                    help="Image model (default: gemini-2.5-flash-image).")
    ap.add_argument("--out", default="assets/images", help="Output directory.")
    ap.add_argument("--only", nargs="*", metavar="KEY", help="Only these asset keys.")
    ap.add_argument("--force", action="store_true", help="Overwrite existing files.")
    ap.add_argument("--transparent", action="store_true",
                    help="Knock out flat background on flagged assets (needs Pillow).")
    ap.add_argument("--list", action="store_true", help="List assets and exit.")
    args = ap.parse_args()

    if args.list:
        for a in ASSETS:
            flags = " [transparent]" if a.transparent else (" [solid-bg]" if a.solid_bg else "")
            print(f"  {a.key:16} -> {a.filename:22} {a.aspect}{flags}")
        return

    if not args.api_key:
        sys.exit("No API key. Pass --api-key or set GEMINI_API_KEY "
                 "(get one at https://aistudio.google.com/apikey).")

    _TRANSPARENT_ENABLED = args.transparent
    selected = ASSETS
    if args.only:
        keys = set(args.only)
        selected = [a for a in ASSETS if a.key in keys]
        unknown = keys - {a.key for a in ASSETS}
        if unknown:
            sys.exit(f"Unknown asset key(s): {', '.join(sorted(unknown))}")

    os.makedirs(args.out, exist_ok=True)
    client = build_client(args.api_key)

    done, skipped, failed = 0, 0, 0
    print(f"Generating {len(selected)} asset(s) with {args.model} -> {args.out}/\n")
    for a in selected:
        target = os.path.join(args.out, a.filename)
        if os.path.exists(target) and not args.force:
            print(f"  = {a.filename} (exists, use --force)")
            skipped += 1
            continue
        print(f"  · {a.key} …")
        saved = generate_one(client, args.model, a, args.out)
        if saved:
            print(f"  ✓ {a.filename}")
            done += 1
        else:
            print(f"  ✗ {a.key} failed")
            failed += 1

    print(f"\nDone. {done} generated, {skipped} skipped, {failed} failed.")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
