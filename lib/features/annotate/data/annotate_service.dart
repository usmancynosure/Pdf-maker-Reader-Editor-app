import 'dart:io';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import '../domain/annotation.dart';

/// Flattens page annotations (text + white-out) onto a PDF and saves a new file.
class AnnotateService {
  const AnnotateService();

  Future<File> apply({
    required String srcPath,
    required Map<int, List<Annotation>> byPage,
    required String fileName,
  }) async {
    final doc = sf.PdfDocument(inputBytes: File(srcPath).readAsBytesSync());
    try {
      byPage.forEach((pageIndex, annos) {
        if (pageIndex < 0 || pageIndex >= doc.pages.count) return;
        final page = doc.pages[pageIndex];
        final size = page.getClientSize();
        for (final a in annos) {
          final rect = Rect.fromLTWH(a.left * size.width, a.top * size.height,
              a.width * size.width, a.height * size.height);
          if (a.type == AnnoType.whiteout) {
            page.graphics.drawRectangle(
              brush: sf.PdfSolidBrush(sf.PdfColor(255, 255, 255)),
              bounds: rect,
            );
          } else if (a.text.trim().isNotEmpty) {
            page.graphics.drawString(
              a.text,
              sf.PdfStandardFont(sf.PdfFontFamily.helvetica, a.fontSize),
              brush: sf.PdfSolidBrush(sf.PdfColor(20, 20, 30)),
              bounds: rect,
            );
          }
        }
      });

      final bytes = await doc.save();
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/scans');
      if (!folder.existsSync()) folder.createSync(recursive: true);
      final safe = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final file = File('${folder.path}/$safe');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } finally {
      doc.dispose();
    }
  }
}

final annotateServiceProvider =
    Provider<AnnotateService>((_) => const AnnotateService());
