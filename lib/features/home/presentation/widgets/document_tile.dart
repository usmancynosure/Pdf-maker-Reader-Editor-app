import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../domain/document.dart';

/// A single document row: page-stack thumbnail, name + meta, colored tag pill.
/// Reused on Home (recent) and, later, on the Files screen.
class DocumentTile extends StatelessWidget {
  const DocumentTile({super.key, required this.doc, this.onTap, this.trailing});

  final Document doc;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xA8FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x99FFFFFF)),
        ),
        child: Row(
          children: [
            const _PageThumb(),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.subtitle(relativeDate(doc.createdAt)),
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A7392)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ?? _TagPill(tag: doc.tag),
          ],
        ),
      ),
    );
  }
}

class _PageThumb extends StatelessWidget {
  const _PageThumb();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE7E2F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5032A0).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              height: 3,
              width: i == 2 ? 18 : double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE4DDF0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});
  final DocTag tag;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tag.color),
      ),
    );
  }
}
