import 'package:flutter/material.dart';

/// Horizontal tool row for the PDF editor: Merge · Split · Text · Sign · Mark.
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.onMerge,
    required this.onSplit,
    required this.onText,
    required this.onSign,
    required this.onWatermark,
  });

  final VoidCallback onMerge, onSplit, onText, onSign, onWatermark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _Tool(icon: Icons.merge_rounded, label: 'Merge', onTap: onMerge),
          _Tool(icon: Icons.call_split_rounded, label: 'Split', onTap: onSplit),
          _Tool(icon: Icons.text_fields_rounded, label: 'Text', onTap: onText),
          _Tool(icon: Icons.draw_outlined, label: 'Sign', onTap: onSign),
          _Tool(
              icon: Icons.branding_watermark_outlined,
              label: 'Mark',
              onTap: onWatermark),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xB8FFFFFF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0x99FFFFFF)),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF5A4D7D)),
            ),
            const SizedBox(height: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4165))),
          ],
        ),
      ),
    );
  }
}
