import 'package:flutter/material.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/glass_card.dart';

/// Screen 02 — Home.
///
/// Phase 1: on-brand placeholder so the app runs end-to-end (splash -> home).
/// Phase 2 replaces this with the full home (greeting, search, quick actions,
/// recent documents, and the glass bottom navigation bar).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HoloBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                strong: true,
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hexagon_outlined,
                        size: 46, color: Color(0xFF7C4DFF)),
                    const SizedBox(height: 16),
                    Text('Home',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Foundation ready. Full home screen\narrives in Phase 2.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
