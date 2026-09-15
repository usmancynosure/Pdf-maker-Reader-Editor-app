import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import '../domain/editor_page.dart';

/// Rebuilds a PDF from an ordered list of [EditorPage]s using Syncfusion.
///
/// One code path covers reorder, delete, rotate, merge (pages from several
/// files) and split (a subset) — the caller just passes the pages it wants,
/// in the order it wants. An optional diagonal watermark is stamped on each page.
class PdfEditorService {
  const PdfEditorService();

  Future<File> export({
    required List<EditorPage> pages,
    required String fileName,
    String? watermark,
  }) async {
    final out = sf.PdfDocument();
    out.pageSettings.margins.all = 0;
    final sources = <String, sf.PdfDocument>{};

    try {
      for (final ep in pages) {
        final src = sources.putIfAbsent(
          ep.filePath,
          () => sf.PdfDocument(inputBytes: File(ep.filePath).readAsBytesSync()),
        );
        if (ep.pageIndex < 0 || ep.pageIndex >= src.pages.count) continue;

        final loaded = src.pages[ep.pageIndex];
        final size = loaded.size;
        out.pageSettings.size = size;

        final page = out.pages.add();
        final template = loaded.createTemplate();
        page.graphics.drawPdfTemplate(template, const Offset(0, 0), size);

        final turns = ep.rotationTurns % 4;
        if (turns != 0) page.rotation = _angle(turns);

        if (watermark != null && watermark.trim().isNotEmpty) {
          _stampWatermark(page, watermark.trim(), size);
        }
      }

      final bytes = await out.save();

      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/scans');
      if (!folder.existsSync()) folder.createSync(recursive: true);
      final safe = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final file = File('${folder.path}/$safe');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } finally {
      out.dispose();
      for (final d in sources.values) {
        d.dispose();
      }
    }
  }

  /// Stamps a signature PNG onto the bottom-right of the last page and saves
  /// the result as a new PDF.
  Future<File> signPdf({
    required String srcPath,
    required List<int> signaturePng,
    required String fileName,
  }) async {
    final doc = sf.PdfDocument(inputBytes: File(srcPath).readAsBytesSync());
    try {
      final page = doc.pages[doc.pages.count - 1];
      final client = page.getClientSize();
      const w = 175.0, h = 80.0;
      page.graphics.drawImage(
        sf.PdfBitmap(signaturePng),
        Rect.fromLTWH(client.width - w - 40, client.height - h - 60, w, h),
      );
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

  sf.PdfPageRotateAngle _angle(int turns) => switch (turns) {
        1 => sf.PdfPageRotateAngle.rotateAngle90,
        2 => sf.PdfPageRotateAngle.rotateAngle180,
        3 => sf.PdfPageRotateAngle.rotateAngle270,
        _ => sf.PdfPageRotateAngle.rotateAngle0,
      };

  void _stampWatermark(sf.PdfPage page, String text, Size size) {
    final g = page.graphics;
    final state = g.save();
    g.setTransparency(0.12);
    g.translateTransform(size.width / 2, size.height / 2);
    g.rotateTransform(-40);
    final font = sf.PdfStandardFont(
      sf.PdfFontFamily.helvetica,
      42,
      style: sf.PdfFontStyle.bold,
    );
    g.drawString(
      text,
      font,
      brush: sf.PdfBrushes.gray,
      bounds: const Rect.fromLTWH(-260, -30, 520, 60),
      format: sf.PdfStringFormat(alignment: sf.PdfTextAlignment.center),
    );
    g.restore(state);
  }
}
