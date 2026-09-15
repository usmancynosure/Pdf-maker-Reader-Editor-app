# Phase 7 — Settings & Paywall

**Status:** ✅ Complete (code + build verified) — final phase
**Goal:** Finish the app with persisted settings (real theme switching) and the
Prisma Pro paywall.

## What shipped

### Persisted settings
| File | Purpose |
|------|---------|
| `features/settings/domain/app_settings.dart` | `AppSettings` (themeMode, appLock, cloudSync, `ExportQuality`, isPro) + `copyWith`. |
| `features/settings/application/settings_controller.dart` | `settingsProvider` reads/writes `SharedPreferences`. `sharedPreferencesProvider` is overridden in `main()` so settings load synchronously. |
| `main.dart` | Preloads `SharedPreferences` and injects it via a `ProviderScope` override. |
| `app.dart` | Now a `ConsumerWidget` — watches `themeMode` so the **theme toggle works app-wide and persists** across launches. |

### Settings UI (Screen 08)
`features/settings/presentation/settings_screen.dart` + `widgets/settings_row.dart`
- **Profile card** (holo gradient) with **Go Pro** → paywall; shows a **PRO** badge when subscribed.
- **Appearance** — Auto / Light / Dark theme selector (live, persisted).
- **Security & Sync** — App Lock and Cloud Sync switches (persisted preferences).
- **Documents** — Export Quality picker (High/Medium/Low), Default Save Folder, About & Help (native about dialog).

### Paywall (Screen 09)
`features/paywall/presentation/paywall_screen.dart` + `data/purchase_service.dart`
- Holographic **planet** (gradient orb + tilted ring), feature list, three price
  tiers (Weekly highlighted like the reference), **Continue**, **Restore**.
- `PurchaseService` interface with a **`MockPurchaseService`** that unlocks locally
  so the flow is testable now. On success it flips `isPro` in settings → the
  profile card shows PRO.

### Wiring
- `MainShell` Settings tab renders `SettingsScreen` (last placeholder removed).

## RevenueCat — going live
`purchase_service.dart` documents the swap: implement `PurchaseService` with
`purchases_flutter` (`Purchases.configure` / `getOfferings` / `purchasePackage` /
`restorePurchases`) and override `purchaseServiceProvider`. The UI and the
persisted `isPro` gate need no changes.

## Verification
- `flutter analyze` → **No issues found.**
- `flutter build apk --debug` → compiles.
- Device tap-test: Settings → switch **Dark/Light/Auto** (whole app re-themes,
  survives restart) → toggle App Lock / Cloud Sync → change Export Quality →
  **Go Pro** → pick a plan → Continue → profile shows **PRO**.

## Follow-ups (post-v1)
- Enforce **App Lock** with `local_auth` (biometric gate on resume).
- Real **Cloud Sync** (iCloud / Drive) and **Add Text / e-Signature** (Phase 5b).
- Apply **Export Quality** to the scanner's JPEG compression.

## 🎉 All 7 phases complete
Splash → Home → Scan (native edge-detection) → Enhance → PDF export → Reader →
Editor → Files → Settings → Paywall. See `docs/PHASES.md` for the full map.
