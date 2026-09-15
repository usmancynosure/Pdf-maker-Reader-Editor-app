import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/glass_card.dart';
import '../application/documents_provider.dart';
import '../domain/document.dart';
import '../../reader/presentation/reader_screen.dart';
import 'widgets/document_tile.dart';
import 'widgets/quick_action_card.dart';

/// Screen 02 — Home. Greeting, search, quick actions, recent documents.
/// Hosted inside [MainShell], which supplies the bottom nav + scan FAB.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onScan});

  /// Triggered by the "Scan" quick action (same target as the shell FAB).
  final VoidCallback? onScan;

  void _todo(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inkSoft,
        content: Text('$what — coming in a later phase'),
      ),
    );
  }

  void _open(BuildContext context, Document doc) {
    if (!doc.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.inkSoft,
          content: Text('Sample document — scan one to create a real PDF'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReaderScreen(doc: doc)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentDocumentsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
        children: [
          const _Header(),
          const SizedBox(height: 14),
          _SearchField(onTap: () => _todo(context, 'Search')),
          const SizedBox(height: 14),
          _QuickActions(
            onScan: () => onScan?.call(),
            onImport: () => _todo(context, 'Import'),
            onTools: () => _todo(context, 'PDF Tools'),
            onSign: () => _todo(context, 'Sign'),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Documents',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2A2140))),
                GestureDetector(
                  onTap: () => _todo(context, 'All files'),
                  child: const Text('See all',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent)),
                ),
              ],
            ),
          ),
          for (final doc in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: DocumentTile(
                doc: doc,
                onTap: () => _open(context, doc),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppGradients.holoSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xB3FFFFFF)),
          ),
          alignment: Alignment.center,
          child: const Text('UW',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: Color(0xFF3A2A55))),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, Usman',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A4A7A))),
              Text('Welcome back',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Color(0xFF241A3A))),
            ],
          ),
        ),
        const _RoundIconButton(icon: Icons.notifications_none_rounded),
        const SizedBox(width: 8),
        const _RoundIconButton(icon: Icons.workspace_premium_rounded, cta: true),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.cta = false});
  final IconData icon;
  final bool cta;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: cta ? AppGradients.cta : null,
        color: cta ? null : const Color(0x8CFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x99FFFFFF)),
      ),
      child: Icon(icon,
          size: 20, color: cta ? Colors.white : const Color(0xFF3A3155)),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      radius: 18,
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: Color(0xFF6A5F88)),
          SizedBox(width: 9),
          Text('Search documents…',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF7A7092))),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onScan,
    required this.onImport,
    required this.onTools,
    required this.onSign,
  });
  final VoidCallback onScan, onImport, onTools, onSign;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        QuickActionCard(
          icon: Icons.crop_free_rounded,
          gradient: AppGradients.pink,
          title: 'Scan',
          subtitle: 'Camera + edges',
          onTap: onScan,
        ),
        QuickActionCard(
          icon: Icons.file_upload_outlined,
          gradient: AppGradients.violet,
          title: 'Import',
          subtitle: 'Photos & files',
          onTap: onImport,
        ),
        QuickActionCard(
          icon: Icons.picture_as_pdf_outlined,
          gradient: AppGradients.blue,
          title: 'PDF Tools',
          subtitle: 'Merge · split',
          onTap: onTools,
        ),
        QuickActionCard(
          icon: Icons.draw_outlined,
          gradient: AppGradients.teal,
          title: 'Sign',
          subtitle: 'e-Signature',
          onTap: onSign,
        ),
      ],
    );
  }
}
