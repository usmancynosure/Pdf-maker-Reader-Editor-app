# Prisma Scan — Implementation Roadmap

A document scanner + PDF maker / reader / editor, built in Flutter with a
holographic-glassmorphism UI. Work ships in **phases**; each phase is
documented in `docs/phase-XX-*.md` and pushed to GitHub when complete.

| Phase | Title | Scope | Status |
|-------|-------|-------|--------|
| **1** | Foundation & Splash | Project setup, theme system, reusable glass/gradient widgets, routing, splash screen | ✅ Done |
| **2** | Home & Navigation | Full home (greeting, search, quick actions, recent docs), glass bottom nav + scan FAB, document model & providers | ✅ Done |
| **3** | Scanner & Edit | Camera + auto edge-detection (`cunning_document_scanner`), crop, magic-color filters, multi-page, save as PDF | ✅ Done |
| **4** | PDF Reader | Open & read PDFs, thumbnails, search, bookmark, share | ✅ Done |
| **5** | PDF Editor | Reorder / delete pages, merge, split, add text, e-signature, watermark, export | ✅ Done |
| **6** | Files | Document library, folders, storage meter, rename/share/delete | ⏳ Next |
| **7** | Settings & Paywall | Theme, biometric lock, cloud sync, export quality; Pro paywall + RevenueCat hooks | ⬜ Planned |

## Architecture

Feature-first structure with a shared design system:

```
lib/
  main.dart                 # entry, ProviderScope
  app.dart                  # MaterialApp.router + themes
  core/
    theme/                  # colors, gradients, typography, ThemeData
    router/                 # go_router table
    constants/
  shared/
    widgets/                # HoloBackground, GlassCard, GradientButton, ...
  features/
    <feature>/
      presentation/         # screens & widgets
      application/          # Riverpod providers (added as needed)
      data/                 # repositories / models (added as needed)
```

## Tech choices

- **State**: `flutter_riverpod`
- **Routing**: `go_router`
- **Type**: `google_fonts` — Poppins (display) + Plus Jakarta Sans (body)
- **Scanner**: `cunning_document_scanner` (native VisionKit / ML Kit) — Phase 3
- **PDF render/read**: to be added Phase 4 (`pdfx` or `syncfusion_flutter_pdfviewer`)
- **PDF write/edit**: to be added Phase 5 (`pdf` + `syncfusion_flutter_pdf`)
- **Monetization**: RevenueCat — Phase 7

## Conventions

- Every screen wraps its body in `HoloBackground` or `SoftBackground`.
- Containers use `GlassCard`; primary actions use `GradientButton`.
- Colors/gradients come from `AppColors` / `AppGradients` — no raw hex in screens.
- Each phase = one documented, analyzer-clean commit pushed to `main`.
