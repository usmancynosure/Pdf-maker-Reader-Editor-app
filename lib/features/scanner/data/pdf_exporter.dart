import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/scan_page.dart';

/// Serializable description of one page for the isolate.
class _PageSpec {
  const _PageSpec(this.path, this.filterIndex, this.quarterTurns);
  final String path;
  final int filterIndex;
  final int quarterTurns;
}

/// Builds enhanced-image PDF bytes off the main thread and writes the file.
class PdfExporter {
  const PdfExporter();

  /// Processes each page (rotate + filter), assembles a PDF, writes it to the
  /// app documents directory, and returns the saved [File].
  Future<File> export({
    required List<ScanPage> pages,
    required String fileName,
  }) async {
    final specs = pages
        .map((p) => _PageSpec(p.imagePath, p.filter.index, p.quarterTurns % 4))
        .toList(growable: false);

    final bytes = await compute(_buildPdfBytes, specs);

    final dir = await getApplicationDocumentsDirectory();
    final scans = Directory('${dir.path}/scans');
    if (!scans.existsSync()) scans.createSync(recursive: true);

    final safe = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final file = File('${scans.path}/$safe');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

/// Top-level so it can run in a background isolate via [compute].
Future<Uint8List> _buildPdfBytes(List<_PageSpec> specs) async {
  final doc = pw.Document();

  for (final spec in specs) {
    final raw = File(spec.path).readAsBytesSync();
    var image = img.decodeImage(raw);
    if (image == null) continue;

    if (spec.quarterTurns != 0) {
      image = img.copyRotate(image, angle: spec.quarterTurns * 90);
    }
    image = _applyFilter(image, ScanFilter.values[spec.filterIndex]);

    final jpg = img.encodeJpg(image, quality: 88);
    final pdfImage = pw.MemoryImage(jpg);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Center(
          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
        ),
      ),
    );
  }

  return doc.save();
}

img.Image _applyFilter(img.Image src, ScanFilter filter) {
  switch (filter) {
    case ScanFilter.original:
      return src;
    case ScanFilter.magic:
      return img.adjustColor(src, contrast: 1.15, saturation: 1.35, brightness: 1.03);
    case ScanFilter.grayscale:
      return img.grayscale(src);
    case ScanFilter.blackWhite:
      final gray = img.grayscale(src);
      return img.adjustColor(gray, contrast: 2.4);
  }
}
