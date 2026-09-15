import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../paywall/presentation/paywall_screen.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';
import 'widgets/settings_row.dart';

/// Screen 08 — Settings. Profile + Go Pro, appearance, security, sync,
/// export quality and about. All changes persist via SharedPreferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
            child:
                Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          ),
          _ProfileCard(
            isPro: settings.isPro,
            onGoPro: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('Appearance'),
          GlassCard(
            strong: true,
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Theme',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkSoft)),
                      ),
                      _ThemeSelector(
                        mode: settings.themeMode,
                        onSelect: controller.setThemeMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('Security & Sync'),
          GlassCard(
            strong: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SettingsRow(
                  icon: Icons.lock_outline_rounded,
                  gradient: AppGradients.pink,
                  title: 'App Lock',
                  subtitle: 'Face ID / PIN on launch',
                  trailing: Switch.adaptive(
                    value: settings.appLock,
                    activeTrackColor: AppColors.accent,
                    onChanged: controller.setAppLock,
                  ),
                ),
                const _Divider(),
                SettingsRow(
                  icon: Icons.cloud_outlined,
                  gradient: AppGradients.blue,
                  title: 'Cloud Sync',
                  subtitle: 'iCloud · Google Drive',
                  trailing: Switch.adaptive(
                    value: settings.cloudSync,
                    activeTrackColor: AppColors.accent,
                    onChanged: controller.setCloudSync,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('Documents'),
          GlassCard(
            strong: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SettingsRow(
                  icon: Icons.high_quality_outlined,
                  gradient: AppGradients.teal,
                  title: 'Export Quality',
                  subtitle: settings.quality.label,
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFB3AAC8)),
                  onTap: () => _pickQuality(context, ref, settings.quality),
                ),
                const _Divider(),
                SettingsRow(
                  icon: Icons.folder_outlined,
                  gradient: AppGradients.amber,
                  title: 'Default Save Folder',
                  subtitle: 'Prisma Scans',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFB3AAC8)),
                  onTap: () {},
                ),
                const _Divider(),
                SettingsRow(
                  icon: Icons.info_outline_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF94A3B8), Color(0xFF64748B)]),
                  title: 'About & Help',
                  subtitle: 'v1.0.0',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFB3AAC8)),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Prisma Scan',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Scan · Create · Sign',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickQuality(BuildContext context, WidgetRef ref, ExportQuality current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Export Quality',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            for (final q in ExportQuality.values)
              ListTile(
                title: Text(q.label),
                trailing: q == current
                    ? const Icon(Icons.check_rounded, color: AppColors.accent)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setQuality(q);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF8A82A0))),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        indent: 60,
        color: AppColors.accent.withValues(alpha: 0.08),
      );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.isPro, required this.onGoPro});
  final bool isPro;
  final VoidCallback onGoPro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppGradients.holoSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x80FFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: const Text('UW',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: Color(0xFF3A2A55))),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Usman Waris',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF241A3A))),
                Text(isPro ? 'Prisma Pro member' : 'Free plan',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF5A4A7A))),
              ],
            ),
          ),
          if (isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      size: 15, color: Color(0xFF7C4DFF)),
                  SizedBox(width: 4),
                  Text('PRO',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C4DFF))),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: onGoPro,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.cta,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Go Pro',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onSelect});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    const options = [
      (ThemeMode.system, 'Auto'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x66FFFFFF),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (m, label) in options)
            GestureDetector(
              onTap: () => onSelect(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: m == mode ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: m == mode ? Colors.white : const Color(0xFF5A4D7D))),
              ),
            ),
        ],
      ),
    );
  }
}
