# Phase 2 — Home & Navigation

**Status:** ✅ Complete
**Goal:** Turn the placeholder into the real product surface — a live Home
screen and the floating glass bottom navigation with the center scan FAB —
backed by a proper document model and Riverpod state.

## What shipped

### Domain & state
| File | Purpose |
|------|---------|
| `features/home/domain/document.dart` | `Document` model + `DocTag` enum (PDF / ID / Signed / Import) with label, color, size label, and subtitle helpers. |
| `features/home/application/documents_provider.dart` | `documentsProvider` (`NotifierProvider`) with add / remove / rename + seeded sample data; `recentDocumentsProvider` (sorted, capped at 5). |
| `core/utils/date_format.dart` | Dependency-free relative dates ("Today", "Yesterday", weekday, "Sep 12"). |

### UI
| File | Purpose |
|------|---------|
| `shared/widgets/glass_bottom_nav.dart` | Floating frosted-glass nav: 4 destinations + raised gradient scan FAB. Accessible (`Semantics`, selected state). |
| `features/shell/presentation/main_shell.dart` | Hosts the 4 tabs in an `IndexedStack` behind `HoloBackground`; wires nav + FAB. Non-Home tabs are on-brand "coming soon" placeholders. |
| `features/home/presentation/home_screen.dart` | Full Home: greeting header (avatar, bell, Pro crown), glass search field, 2×2 quick actions, "Recent Documents" list. `ConsumerWidget` reading `recentDocumentsProvider`. |
| `features/home/presentation/widgets/document_tile.dart` | Reusable document row (page-stack thumbnail, name, meta, tag pill) — also used by Files later. |
| `features/home/presentation/widgets/quick_action_card.dart` | Quick-action tile (gradient icon chip + title + subtitle). |

### Routing
- `/home` now renders `MainShell` (was the placeholder `HomeScreen`).

## Behavior
- Splash → `MainShell`. Home tab is fully interactive.
- Bottom nav switches tabs; **Scan FAB** and the **Scan** quick action both call
  the same handler (a snackbar placeholder → wired to the camera in Phase 3).
- Other quick actions (Import / PDF Tools / Sign), Search, See-all and opening a
  document show "coming in a later phase" snackbars — real targets land in their
  phases.

## Verification
- `flutter analyze` → **No issues found.**
- `flutter build apk --debug` → compiles to a binary.

## Design fidelity
Matches Screen 02 of the mockup: greeting row with dual action buttons, glass
search, four gradient quick actions, recent list with colored tags, and the
floating glass nav bar with the poked-up center FAB.

## Assets (optional, from `docs/IMAGE_PROMPTS.md`)
- `empty_documents.png`, `empty_search.png` for empty states (not yet triggered
  since sample data seeds the list).

## Next (Phase 3)
Scanner & Edit: integrate `cunning_document_scanner` (native VisionKit / ML Kit)
for the FAB, then the crop + magic-color enhance screen, multi-page handling,
and "Save as PDF" writing into `documentsProvider`.
