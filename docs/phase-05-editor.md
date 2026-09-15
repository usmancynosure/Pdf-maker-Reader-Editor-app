# Phase 5 — PDF Editor

**Status:** ✅ Complete (code + build verified)
**Goal:** Turn any saved PDF into an editable document — organize pages, merge,
split and watermark — then export a new file.

## What shipped

### PDF manipulation
- Added `syncfusion_flutter_pdf` (pure-Dart; loads & rewrites existing PDFs).

| File | Purpose |
|------|---------|
| `features/editor/domain/editor_page.dart` | `EditorPage` — a reference to a source file + page index + rotation + selection. Pages can come from multiple files (after merge). |
| `features/editor/data/pdf_editor_service.dart` | `export()` rebuilds a PDF from an ordered `EditorPage` list via page templates. **One path covers reorder, delete, rotate, merge and split.** Optional diagonal watermark stamped per page (transparency + rotate + centered text). |
| `features/editor/application/editor_providers.dart` | `pdfEditorServiceProvider`. |

### UI
| File | Purpose |
|------|---------|
| `features/editor/presentation/editor_screen.dart` | Screen 06 — `ReorderableListView` of page tiles (drag handle, thumbnail with live rotation, multi-select, rotate, delete). Toolbar + Export button. Saving overlay. |
| `.../widgets/editor_toolbar.dart` | Merge · Split · Text · Sign · Mark row. |
| `features/editor/presentation/tools_screen.dart` | The **Tools tab** — lists real PDFs; tap to open the editor. |

### Operations (all working)
- **Reorder** — drag handle reorders pages.
- **Rotate** — per-page 90° steps (preview rotates live; baked in on export).
- **Delete** — removes a page (auto-exits if none remain).
- **Merge** — pick another saved PDF from a sheet; its pages append to the session.
- **Split** — select pages → Export produces a new PDF of just those pages.
- **Watermark** — dialog sets diagonal watermark text, applied to every page on export; shown as a chip.
- **Export** — names & writes a new PDF to `appDocs/scans/`, adds a `Document`, returns to the previous screen. It appears on Home / Files.

### Wiring
- Reader's bottom toolbar 4th action is now **Edit** → opens the editor for the
  open document.
- `MainShell` Tools tab renders `ToolsScreen` (was a placeholder).

### Deferred (honest stubs, snackbar)
- **Add Text** and **e-Signature** — both need an on-page placement gesture layer;
  scheduled as a fast-follow (Phase 5b). The plumbing (per-page graphics via
  Syncfusion) is already proven by the watermark path.

## Design note
The mockup shows a 3-column page grid; we use a **reorderable vertical list** of
page cards because it gives reliable drag-to-reorder without an extra dependency.
Same information, better editing UX.

## Verification
- `flutter analyze` → **No issues found.**
- `flutter build apk --debug` → compiles with Syncfusion.
- Device tap-test: open a multi-page PDF (scan a few pages first) → drag to
  reorder, rotate & delete a page, Merge another PDF, select 2 pages and Split,
  set a Watermark, Export — confirm the new PDF opens with the changes applied.

## Next (Phase 6)
Files: full document library (all docs, filter segments, storage meter,
rename / share / delete), replacing the Files placeholder tab.
