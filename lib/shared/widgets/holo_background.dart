import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_colors.dart';

/// Full-screen holographic gradient background with soft light blooms.
/// Wrap a screen body in this to get the signature Prisma look.
class HoloBackground extends StatelessWidget {
  const HoloBackground({super.key, required this.child, this.soft = false});

  final Widget child;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: soft ? AppGradients.holoSoft : AppGradients.holo,
            ),
          ),
        ),
        // top-right white bloom
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.6, -1),
                radius: 1.1,
                colors: [Color(0x80FFFFFF), Color(0x00FFFFFF)],
                stops: [0.0, 0.55],
              ),
            ),
          ),
        ),
        // bottom-left cyan bloom
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1, 1),
                radius: 0.9,
                colors: [Color(0x807EE8FA), Color(0x007EE8FA)],
                stops: [0.0, 0.6],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A plain light background (used on reader/editor screens that need calm space).
class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? const [AppColors.surfaceDark, AppColors.surfaceDark2]
                    : const [AppColors.surfaceLight, AppColors.surfaceLight2],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
