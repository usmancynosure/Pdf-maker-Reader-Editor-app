# Phase 6 — Files

**Status:** ✅ Complete (code + build verified)
**Goal:** A real document library — find, filter and manage every saved PDF.

## What shipped

| File | Purpose |
|------|---------|
| `features/files/presentation/files_screen.dart` | Screen 07 — the Files tab: header with doc count, live **search**, **storage meter**, tag **filter segments**, and the document list with per-item actions. |
| `features/home/application/documents_provider.dart` | Added `delete(id)` — removes the entry **and** best-effort deletes the file from disk. |
| `features/home/presentation/widgets/document_tile.dart` | Added `onLongPress` so tiles can open the actions sheet. |

### Features
- **Search** — filters the list by name as you type.
- **Storage meter** — sums the real byte size of all documents and shows it
  against a 1 GB on-device reference with a gradient progress bar.
- **Filter segments** — All / PDF / ID / Signed / Import (scrollable), filtering by `DocTag`.
- **Open** — tap a real document → PDF reader; samples show a hint.
- **Actions** (long-press → bottom sheet):
  - **Rename** — dialog updates the document name.
  - **Share** — system share sheet with the actual file (`share_plus`).
  - **Delete** — confirm dialog → removes the entry and deletes the file on disk.
- List is sorted newest-first and reacts live to Riverpod state (a delete or new
  scan updates instantly).

### Wiring
- `MainShell` Files tab now renders `FilesScreen` (was a placeholder).

## Verification
- `flutter analyze` → **No issues found.**
- `flutter build apk --debug` → compiles.
- Device tap-test: scan/create a few PDFs → open **Files** → search, switch
  segments, long-press a doc → Rename / Share / Delete; confirm the storage meter
  and count update.

## Notes / follow-ups
- Storage quota (1 GB) is a display reference, not an enforced limit.
- Folders/collections and multi-select bulk actions are a future enhancement;
  Phase 6 covers the single-document lifecycle end to end.

## Next (Phase 7)
Settings & Paywall: appearance (theme), biometric app lock, cloud sync toggle,
export quality, default folder; plus the **Prisma Pro** paywall (feature list +
price tiers) with RevenueCat hooks.
