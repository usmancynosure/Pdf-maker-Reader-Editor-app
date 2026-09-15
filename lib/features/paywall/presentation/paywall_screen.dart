import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../settings/application/settings_controller.dart';
import '../data/purchase_service.dart';

/// Screen 09 — Prisma Pro paywall. Feature list + price tiers + Continue.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selected = 1; // weekly highlighted, like the reference
  bool _busy = false;

  static const _features = [
    (Icons.bolt_rounded, 'Unlimited Scanning', 'No daily page limits'),
    (Icons.verified_rounded, 'Remove Watermark', 'Clean, professional exports'),
    (Icons.text_fields_rounded, 'OCR & Text Export', 'Searchable PDF, Word & TXT'),
    (Icons.cloud_done_rounded, 'Cloud Backup', 'Sync across all devices'),
  ];

  Future<void> _continue() async {
    final service = ref.read(purchaseServiceProvider);
    final plan = service.plans()[_selected];
    setState(() => _busy = true);
    final ok = await service.purchase(plan);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.read(settingsProvider.notifier).setPro(true);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        content: Text('Welcome to Prisma Pro 🎉'),
      ));
    }
  }

  Future<void> _restore() async {
    final restored = await ref.read(purchaseServiceProvider).restore();
    if (!mounted) return;
    if (restored) ref.read(settingsProvider.notifier).setPro(true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.inkSoft,
      content: Text(restored ? 'Purchases restored' : 'Nothing to restore'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.read(purchaseServiceProvider).plans();
    return Scaffold(
      body: HoloBackground(
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).pop()),
                      GestureDetector(
                        onTap: _restore,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Restore',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Center(child: _Planet()),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text('Unlock Prisma Pro',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Color(0xFF221A35))),
                  ),
                  const SizedBox(height: 2),
                  const Center(
                    child: Text('Unlimited scans, no watermark',
                        style: TextStyle(fontSize: 13, color: Color(0xFF5A4A7A))),
                  ),
                  const SizedBox(height: 18),
                  for (final f in _features)
                    _FeatureRow(icon: f.$1, title: f.$2, subtitle: f.$3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var i = 0; i < plans.length; i++) ...[
                        Expanded(
                          child: _PlanCard(
                            plan: plans[i],
                            selected: i == _selected,
                            onTap: () => setState(() => _selected = i),
                          ),
                        ),
                        if (i != plans.length - 1) const SizedBox(width: 9),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: 'Continue',
                    onPressed: _busy ? null : _continue,
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Auto-renewable · cancel anytime · Terms & Privacy',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF6A5F88))),
                  ),
                ],
              ),
              if (_busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Planet extends StatelessWidget {
  const _Planet();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.32,
            child: Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                    colors: [AppColors.pink, AppColors.periwinkle]),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.lavender.withValues(alpha: 0.6),
                      blurRadius: 18),
                ],
              ),
            ),
          ),
          Container(
            width: 116,
            height: 116,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [Color(0xFFEABBF5), Color(0xFF9AA6FF), Color(0xFF6E7BF2)],
                stops: [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(color: Color(0x73785AF0), blurRadius: 40, offset: Offset(0, 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.violet,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF241C38))),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF6A6280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard(
      {required this.plan, required this.selected, required this.onTap});
  final ProPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.cta : null,
          color: selected ? null : const Color(0xB8FFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xB3FFFFFF)),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: AppColors.ctaPink.withValues(alpha: 0.4),
                      blurRadius: 22,
                      offset: const Offset(0, 10))
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(plan.title,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF241C38))),
            const SizedBox(height: 2),
            Text(plan.caption,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9.5,
                    color: selected ? Colors.white70 : const Color(0xFF8A82A0))),
            const SizedBox(height: 8),
            Text(plan.price,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : const Color(0xFF241C38))),
          ],
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x99FFFFFF),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0x99FFFFFF)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF3A3155)),
      ),
    );
  }
}
