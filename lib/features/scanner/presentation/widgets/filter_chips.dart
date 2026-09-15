import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/scan_page.dart';

/// Horizontal row of enhancement-filter chips.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key, required this.selected, required this.onSelect});

  final ScanFilter selected;
  final ValueChanged<ScanFilter> onSelect;

  // Display order: Magic first (default), then the rest.
  static const _order = [
    ScanFilter.magic,
    ScanFilter.original,
    ScanFilter.grayscale,
    ScanFilter.blackWhite,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _order.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _order[i];
          final on = f == selected;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: on ? AppColors.accent : const Color(0x99FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x99FFFFFF)),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: on ? Colors.white : const Color(0xFF4A4165),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
