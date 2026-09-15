import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pdf_editor_service.dart';

final pdfEditorServiceProvider =
    Provider<PdfEditorService>((_) => const PdfEditorService());
