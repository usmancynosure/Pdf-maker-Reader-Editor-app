import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet showing a grid of page thumbnails; tap to jump.
class ThumbnailGridSheet extends StatefulWidget {
  const ThumbnailGridSheet({
    super.key,
    required this.filePath,
    required this.pageCount,
    required this.current,
    required this.onJump,
  });

  final String filePath;
  final int pageCount;
  final int current;
  final ValueChanged<int> onJump;

  @override
  State<ThumbnailGridSheet> createState() => _ThumbnailGridSheetState();
}

class _ThumbnailGridSheetState extends State<ThumbnailGridSheet> {
  PdfDocument? _doc;
  final _cache = <int, Uint8List?>{};

  @override
  void initState() {
    super.initState();
    PdfDocument.openFile(widget.filePath).then((d) {
      if (mounted) setState(() => _doc = d);
    });
  }

  @override
  void dispose() {
    _doc?.close();
    super.dispose();
  }

  Future<Uint8List?> _thumb(int page) async {
    if (_cache.containsKey(page)) return _cache[page];
    final doc = _doc;
    if (doc == null) return null;
    final p = await doc.getPage(page);
    final scale = 220 / p.width;
    final img = await p.render(
      width: p.width * scale,
      height: p.height * scale,
      format: PdfPageImageFormat.jpeg,
      backgroundColor: '#FFFFFF',
    );
    await p.close();
    _cache[page] = img?.bytes;
    return img?.bytes;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CFE6),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text('All Pages',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSoft)),
              ),
              Expanded(
                child: _doc == null
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: widget.pageCount,
                        itemBuilder: (context, i) {
                          final page = i + 1;
                          final selected = page == widget.current;
                          return GestureDetector(
                            onTap: () {
                              widget.onJump(page);
                              Navigator.of(context).pop();
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.accent
                                            : const Color(0xFFE6E0F2),
                                        width: selected ? 2 : 1,
                                      ),
                                      color: Colors.white,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FutureBuilder<Uint8List?>(
                                      future: _thumb(page),
                                      builder: (context, snap) {
                                        if (snap.data == null) {
                                          return const Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          );
                                        }
                                        return Image.memory(snap.data!,
                                            fit: BoxFit.cover);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('$page',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? AppColors.accent
                                            : AppColors.muted)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
