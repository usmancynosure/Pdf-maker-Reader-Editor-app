import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/scan_page.dart';

/// Thumbnail strip of the pages in the current scan, plus an "add page" tile.
class PageFilmstrip extends StatelessWidget {
  const PageFilmstrip({
    super.key,
    required this.pages,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
  });

  final List<ScanPage> pages;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pages.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == pages.length) {
            return _AddTile(onTap: onAdd);
          }
          final on = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Stack(
              children: [
                Container(
                  width: 48,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: on ? AppColors.accent : const Color(0xFFE5DFF2),
                      width: on ? 2 : 1,
                    ),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(File(pages[i].imagePath), fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 2,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0x66FFFFFF),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFCFC5E4)),
        ),
        child: const Icon(Icons.add_rounded, color: Color(0xFFA99FC4)),
      ),
    );
  }
}
