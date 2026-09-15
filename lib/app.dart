import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class PrismaScanApp extends StatelessWidget {
  const PrismaScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The Prisma design is a committed light holographic look, so we force the
    // light theme regardless of the device's system setting. This keeps custom
    // widgets (glass cards, bottom sheets, dialogs) legible everywhere.
    return MaterialApp.router(
      title: 'Prisma Scan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
