import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scanner_service.dart';
import '../data/pdf_exporter.dart';
import '../data/import_service.dart';

/// Injectable services (swappable in tests).
final scannerServiceProvider = Provider<ScannerService>((_) => const ScannerService());
final pdfExporterProvider = Provider<PdfExporter>((_) => const PdfExporter());
final importServiceProvider = Provider<ImportService>((_) => const ImportService());
