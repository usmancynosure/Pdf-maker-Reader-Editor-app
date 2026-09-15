import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class NavDestination {
  const NavDestination(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Floating frosted-glass bottom navigation with a raised center CTA (scan FAB).
///
/// Layout: [item0] [item1] [FAB] [item2] [item3]
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    required this.onFabPressed,
  }) : assert(destinations.length == 4, 'Exactly 4 side destinations expected');

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onFabPressed;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: SizedBox(
        height: 80, // extra room so the raised FAB is not clipped
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Frosted glass bar (clipped) pinned to the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color:
                          dark ? const Color(0x33FFFFFF) : const Color(0xB8FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: dark
                              ? const Color(0x22FFFFFF)
                              : const Color(0xB3FFFFFF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5A3CA0).withValues(alpha: 0.20),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _item(0),
                        _item(1),
                        const SizedBox(width: 64), // gap for the FAB
                        _item(2),
                        _item(3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Raised scan FAB, overlaid on top and never clipped.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: _Fab(onPressed: onFabPressed)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(int i) {
    final d = destinations[i];
    final selected = currentIndex == i;
    return Expanded(
      child: _NavItem(
        destination: d,
        selected: selected,
        onTap: () => onSelect(i),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.destination, required this.selected, required this.onTap});
  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : const Color(0xFF9089A6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? destination.activeIcon : destination.icon,
                size: 22, color: color),
            const SizedBox(height: 3),
            Text(destination.label,
                style: TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.cta,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xD9FFFFFF), width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.ctaPink.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(Icons.document_scanner_outlined,
            color: Colors.white, size: 26),
      ),
    );
  }
}
