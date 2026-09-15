# Phase 1 — Foundation & Splash

**Status:** ✅ Complete
**Goal:** Stand up the Flutter project with the full design system and a
working splash → home flow, so every later screen is a matter of composing
existing pieces.

## What shipped

### Project setup
- `flutter create` with package `com.prismascan`, name `prisma_scan`, iOS + Android.
- Dependencies: `flutter_riverpod`, `go_router`, `google_fonts`, `shared_preferences`.
- App bootstrapped in a `ProviderScope` (`main.dart`), transparent status bar.

### Design system (`lib/core/theme/`)
| File | Purpose |
|------|---------|
| `app_colors.dart` | Full palette: holographic wash, CTA/accent, action tints, semantic, light + dark neutrals, glass fills. |
| `app_gradients.dart` | `holo`, `holoSoft`, `cta`, plus per-action gradients (pink/violet/blue/teal/amber). |
| `app_theme.dart` | Light + dark `ThemeData`. Poppins display + Plus Jakarta Sans body via `google_fonts`. |

### Reusable widgets (`lib/shared/widgets/`)
| Widget | Role |
|--------|------|
| `HoloBackground` | Full-screen holographic gradient + white/cyan light blooms. |
| `SoftBackground` | Calm light/dark gradient for reader/editor screens. |
| `GlassCard` | Frosted-glass container (`BackdropFilter` blur), light/dark aware. |
| `GradientButton` | Pill CTA with the pink→violet→amber gradient. |
| `GradientIconChip` | Gradient-filled icon chip for quick actions / list rows. |

### Routing (`lib/core/router/app_router.dart`)
- `go_router` table with `AppRoutes.splash` (`/`) and `AppRoutes.home` (`/home`).
- New routes are added per phase.

### Screens
- **Splash** (`features/splash/`): holographic bg, frosted glass logo, wordmark,
  spaced tagline, animated loading dots; auto-routes to Home after 2.4 s.
  Fade + scale entrance; `initState` reserved for cache warming in later phases.
- **Home** (`features/home/`): on-brand **placeholder** (glass card) — replaced
  with the full home in Phase 2.

## Verification
- `flutter analyze` → **No issues found.**
- Flow runs: launch → animated splash → home placeholder.

## Assets needed (generate from `docs/IMAGE_PROMPTS.md`)
- `logo` — Phase 1 uses the built-in `Icons.hexagon_outlined` as a stand-in.
  Replace with the generated prism logo + app icon before release.

## Notes / follow-ups
- `google_fonts` fetches Poppins / Plus Jakarta Sans on first run (needs network
  once, then cached). For fully offline builds, bundle the `.ttf` files and load
  via `GoogleFonts.config.allowRuntimeFetching = false` + `pubspec` fonts.
- App launcher icon & native splash: wire up `flutter_launcher_icons` /
  `flutter_native_splash` once the logo asset exists.

## Next (Phase 2)
Full Home screen + glass bottom navigation with the center scan FAB, the
`Document` model, and Riverpod providers for the recent-documents list.
