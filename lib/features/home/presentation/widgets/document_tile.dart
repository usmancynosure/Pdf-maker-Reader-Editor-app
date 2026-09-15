import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../domain/document.dart';

/// A single document row: page-stack thumbnail, name + meta, colored tag pill.
/// Reused on Home (recent) and, later, on the Files screen.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.doc,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final Document doc;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
            _PageThumb(filePath: doc.hasFile ? doc.filePath : null),
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
  const _PageThumb({this.filePath});
  final String? filePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 56,
      clipBehavior: Clip.antiAlias,
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
      child: filePath == null
          ? const _LinesPlaceholder()
          : FutureBuilder<Uint8List?>(
              future: _PdfThumbCache.firstPage(filePath!),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const _LinesPlaceholder();
                }
                final data = snap.data;
                if (data == null) return const _LinesPlaceholder();
                return Image.memory(data, fit: BoxFit.cover);
              },
            ),
    );
  }
}

class _LinesPlaceholder extends StatelessWidget {
  const _LinesPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

/// Renders & caches the first-page bitmap of a PDF for list thumbnails.
class _PdfThumbCache {
  static final _cache = <String, Uint8List?>{};
  static final _pending = <String, Future<Uint8List?>>{};

  static Future<Uint8List?> firstPage(String path) {
    if (_cache.containsKey(path)) return Future.value(_cache[path]);
    return _pending.putIfAbsent(path, () async {
      try {
        final doc = await pdfx.PdfDocument.openFile(path);
        final page = await doc.getPage(1);
        final scale = 132 / page.width;
        final img = await page.render(
          width: page.width * scale,
          height: page.height * scale,
          format: pdfx.PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
        );
        await page.close();
        await doc.close();
        return _cache[path] = img?.bytes;
      } catch (_) {
        return _cache[path] = null;
      } finally {
        _pending.remove(path);
      }
    });
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
