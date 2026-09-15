import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/glass_bottom_nav.dart';
import '../../home/presentation/home_screen.dart';
import '../../scanner/application/scanner_providers.dart';
import '../../scanner/presentation/edit_screen.dart';
import '../../editor/presentation/tools_screen.dart';
import '../../files/presentation/files_screen.dart';

/// Root shell after splash: holds the four primary tabs behind the holographic
/// background and the floating glass bottom nav with the center scan FAB.
///
/// Tabs beyond Home are on-brand placeholders until their phases land
/// (Files = Phase 6, Tools = Phase 3–5, Settings = Phase 7).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _destinations = [
    NavDestination(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavDestination(Icons.folder_outlined, Icons.folder_rounded, 'Files'),
    NavDestination(
        Icons.picture_as_pdf_outlined, Icons.picture_as_pdf_rounded, 'Tools'),
    NavDestination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  /// Launch the native scanner; on capture, open the Edit & Enhance screen.
  Future<void> _startScan() async {
    final scanner = ref.read(scannerServiceProvider);
    try {
      final paths = await scanner.scan();
      if (paths.isEmpty || !mounted) return; // cancelled
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditScreen(
            imagePaths: paths,
            onRescan: () => scanner.scan(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text('Scanner unavailable: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HoloBackground(
        child: Stack(
          children: [
            IndexedStack(
              index: _index,
              children: [
                HomeScreen(onScan: _startScan),
                const FilesScreen(),
                const ToolsScreen(),
                const _ComingSoon(title: 'Settings', phase: 'Phase 7'),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: GlassBottomNav(
                  destinations: _destinations,
                  currentIndex: _index,
                  onSelect: (i) => setState(() => _index = i),
                  onFabPressed: _startScan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.title, required this.phase});
  final String title;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('Arriving in $phase',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
