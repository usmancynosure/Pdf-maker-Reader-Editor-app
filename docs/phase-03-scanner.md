# Phase 3 — Scanner & Edit

**Status:** ✅ Complete (code + build verified; live camera needs a device — see below)
**Goal:** Make the scan FAB real — capture with native edge-detection, enhance
pages with filters, and export a genuine PDF that shows up on Home.

## What shipped

### Native scanning
| File | Purpose |
|------|---------|
| `features/scanner/data/scanner_service.dart` | Wraps `cunning_document_scanner` (VisionKit on iOS, ML Kit Document Scanner on Android). Returns edge-detected, perspective-corrected image paths; `[]` on cancel. |
| `features/scanner/application/scanner_providers.dart` | `scannerServiceProvider`, `pdfExporterProvider` (injectable for tests). |

### Enhance & export
| File | Purpose |
|------|---------|
| `features/scanner/domain/scan_page.dart` | `ScanPage` (image path + filter + rotation) and `ScanFilter` enum (Magic / Original / Grayscale / B&W) with fast `ColorFilter` **preview** matrices. |
| `features/scanner/data/pdf_exporter.dart` | Processes pages (rotate + accurate filter via `image` pkg) and builds an A4 PDF **in a background isolate** (`compute`), then writes it to `<appDocs>/scans/`. |

### UI
| File | Purpose |
|------|---------|
| `features/scanner/presentation/edit_screen.dart` | Screen 04 — preview with live filter + rotation, filter chips, tools (Crop*/Rotate/Adjust*/Delete), page filmstrip with add, "Save as PDF" (name dialog + saving overlay). |
| `.../widgets/filter_chips.dart` | Horizontal filter selector. |
| `.../widgets/page_filmstrip.dart` | Page thumbnails + add-page tile. |

\* Crop & Adjust are stubbed (snackbar) — the native scanner already crops each
page; fine-grained manual crop/brightness is a fast-follow.

### Flow & wiring
- `MainShell` is now a `ConsumerStatefulWidget`. The **scan FAB** and Home's
  **Scan** quick action call `_startScan()` → native scanner → `EditScreen`.
- On save: PDF written to disk → a real `Document` (with `filePath`) is added via
  `documentsProvider`, so the scan appears in **Recent Documents** immediately.
- `Document` gained an optional `filePath` (+ `hasFile`).

### Permissions
- **iOS** (`Info.plist`): `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`,
  `NSPhotoLibraryAddUsageDescription`.
- **Android** (`AndroidManifest.xml`): `CAMERA` permission, optional camera feature;
  app label set to "Prisma Scan".

## Verification
- `flutter analyze` → **No issues found.**
- `flutter build apk --debug` → compiles with the native plugin.
- ⚠️ **Live capture requires a physical device / camera-enabled emulator** — the
  native scanner UI can't be exercised headless here. Tap-test on device:
  1. Tap the scan FAB → grant camera permission → capture 2–3 pages.
  2. In Edit, switch filters (Magic/Grayscale/B&W), rotate, delete, add a page.
  3. Save as PDF → confirm it appears in Recent Documents with the right page count/size.

## Notes / follow-ups
- First `image`-package processing of large photos can take a moment; it runs off
  the UI thread, and a saving overlay is shown.
- Android ML Kit scanner downloads a small module on first use (needs network once).
- `cunning_document_scanner` deprecation: `scannerSource` supersedes
  `isGalleryImportAllowed` (removed our usage; default source is fine).

## Next (Phase 4)
PDF Reader: open a saved `Document` by `filePath`, render pages (`pdfx` or
Syncfusion), thumbnails, search, bookmark, share.
