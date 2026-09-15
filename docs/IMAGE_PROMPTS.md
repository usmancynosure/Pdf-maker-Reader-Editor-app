# Image Generation Prompts — Prisma Scan

Prompts for every raster asset the app uses, ready to paste into an image
generator (Midjourney, DALL·E 3, Ideogram, Firefly, SDXL). Keep the **shared
style block** in every prompt so all assets read as one system.

Save generated files into `assets/images/` using the **filename** noted per
asset, then register the folder in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

---

## Shared style block (prepend to every prompt)

> Holographic glassmorphism aesthetic. Iridescent gradient of soft pink
> (#F8A5E0), lavender (#B98CFF), periwinkle (#8AA8FF) and aqua-cyan (#7EE8FA).
> Frosted translucent glass, soft inner glow, gentle 3D, smooth rounded forms,
> subtle depth and highlights, clean and premium, Apple-like. Studio lighting,
> no harsh shadows. Minimal, modern, high detail.

Global rules:
- **Transparent background** (PNG) for logos, icons, illustrations, badges —
  except the App Store icon and store screenshots.
- No text/lettering baked into the image (except where a wordmark is requested).
- Export **@1x/@2x/@3x** or a single large PNG you downscale in Flutter.

---

## Phase 1 — Brand

### 1. App logo mark — `logo.png`
Use: splash screen, home header. Square, **1024×1024**, transparent.
> [style block] A single minimalist app logo mark: an abstract hexagonal prism
> shaped from layered translucent iridescent glass, catching a rainbow refraction
> like a light prism. Centered, generous padding, no text, no background.
> Flat-friendly, crisp, symmetrical, vector-clean silhouette.

### 2. App launcher icon — `app_icon.png`
Use: `flutter_launcher_icons`. Square, **1024×1024**, **filled background** (no transparency).
> [style block] iOS/Android app icon: the Prisma prism hexagon mark centered on a
> smooth holographic gradient background (pink→lavender→periwinkle→cyan, diagonal).
> Soft glass sheen, rounded-square safe area, no text. Premium, tappable, glossy.

### 3. Wordmark (optional) — `wordmark.png`
Use: marketing / about. **1600×500**, transparent.
> [style block] The word "Prisma Scan" as a clean rounded geometric sans-serif
> wordmark, deep violet ink, with the small prism hexagon mark to the left. Crisp,
> balanced spacing, transparent background, no extra decoration.

---

## Phase 2 — Home & empty states

### 4. Empty home / no documents — `empty_documents.png`
Use: home when the library is empty. **1000×1000**, transparent.
> [style block] A friendly 3D illustration of a translucent glass document with a
> soft holographic sheen and a subtle dashed "add" glow, floating with tiny
> sparkles. Optimistic, roomy negative space, no text, transparent background.

### 5. Search — no results — `empty_search.png`
Use: search with zero matches. **1000×1000**, transparent.
> [style block] A glass magnifying lens over a faint translucent document,
> iridescent rim light, gently tilted, floating. Calm, minimal, no text,
> transparent background.

---

## Phase 3 — Scanner & edit

### 6. Scanner permission / onboarding — `scan_onboarding.png`
Use: camera-permission priming sheet. **1200×900**, transparent.
> [style block] A 3D translucent glass smartphone capturing a floating paper
> document, glowing cyan edge-detection frame with bright corner brackets around
> the page, light rays. Modern, clean, no text, transparent background.

### 7. Processing / enhancing — `processing.png`
Use: "enhancing pages" loader. **800×800**, transparent.
> [style block] An abstract holographic glass orb with swirling iridescent light
> and tiny document sparkles, sense of motion and processing. No text, centered,
> transparent background.

---

## Phase 4 — Reader

### 8. Empty reader / no PDFs — `empty_pdf.png`
Use: reader with nothing open. **1000×1000**, transparent.
> [style block] A translucent glass PDF booklet, slightly open, iridescent pages,
> soft floating shadow, calm. Minimal, no text, transparent background.

---

## Phase 6 — Files

### 9. Empty files / folder — `empty_folder.png`
Use: empty Files tab. **1000×1000**, transparent.
> [style block] An open translucent glass folder with a soft holographic interior
> glow and a couple of faint floating document cards. Friendly, minimal, no text,
> transparent background.

---

## Phase 7 — Settings & Paywall

### 10. Pro paywall hero — `pro_planet.png`  ⭐ key asset
Use: Pro paywall (matches the reference "planet"). **1200×1200**, transparent.
> [style block] A gorgeous 3D iridescent glass planet/orb with a thin holographic
> ring tilted around it, radial pink-to-blue gradient surface, glossy highlights,
> soft rim glow, premium and aspirational. Centered, floating, no text,
> transparent background.

### 11. Pro crown badge — `pro_crown.png`
Use: "Go Pro" chip / header crown. **512×512**, transparent.
> [style block] A small glossy 3D crown icon made of translucent iridescent glass
> with a warm pink-violet-amber gradient, soft glow. Simple, centered, no text,
> transparent background.

### 12. Purchase success — `success.png`
Use: post-subscribe confirmation. **900×900**, transparent.
> [style block] A translucent glass checkmark inside a soft holographic circle,
> gentle confetti sparkles in pink/cyan, celebratory but refined. No text,
> centered, transparent background.

---

## App Store / marketing (later)

### 13. Feature graphic / hero — `store_hero.png`
**Filled background**, e.g. 1290×2796 (iPhone) or 1200×630 (web OG).
> [style block] A premium hero scene: two floating glass smartphones showing a
> document-scanner app UI, iridescent gradient studio background, soft god-rays,
> a scanned paper turning into a glowing PDF. Cinematic, clean, lots of space for
> headline text on the left. High-end product marketing render.

---

## Tips
- Generate the **logo (#1)** first and keep its seed; reuse it visually to keep
  the mark consistent across icon, wordmark, splash.
- For icons that must stay crisp at small sizes, prefer **Ideogram/Firefly** or
  vectorize the winner (e.g. with an SVG tracer) and re-export.
- Request 3–4 variations per asset, pick one, then upscale to the target size.
