import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/document.dart';

/// Absolute path to the bundled sample PDF once copied to disk (set in main()).
/// Lets the seeded demo documents open in the reader/editor.
final samplePdfPathProvider = Provider<String?>((_) => null);

/// Holds the user's documents. Phase 2 seeds sample data so the UI is alive;
/// Phase 3+ replaces the seed with real scans persisted to disk.
class DocumentsNotifier extends Notifier<List<Document>> {
  @override
  List<Document> build() => _seed(ref.watch(samplePdfPathProvider));

  void add(Document doc) => state = [doc, ...state];

  void remove(String id) =>
      state = state.where((d) => d.id != id).toList(growable: false);

  /// Removes the entry and best-effort deletes its file from disk.
  Future<void> delete(String id) async {
    final doc = state.firstWhere((d) => d.id == id);
    final path = doc.filePath;
    if (path != null) {
      try {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      } catch (_) {/* file already gone — ignore */}
    }
    remove(id);
  }

  void rename(String id, String name) => state = [
        for (final d in state) d.id == id ? d.copyWith(name: name) : d,
      ];

  static List<Document> _seed(String? samplePath) {
    final now = DateTime.now();
    return [
      Document(
        id: '1',
        name: 'Invoice_2026_Q3.pdf',
        pageCount: 4,
        sizeBytes: 820 * 1024,
        createdAt: now,
        tag: DocTag.pdf,
        filePath: samplePath,
      ),
      Document(
        id: '2',
        name: 'Passport_Scan.pdf',
        pageCount: 1,
        sizeBytes: 340 * 1024,
        createdAt: now.subtract(const Duration(days: 1)),
        tag: DocTag.idCard,
        filePath: samplePath,
      ),
      Document(
        id: '3',
        name: 'Contract_signed.pdf',
        pageCount: 7,
        sizeBytes: (1.2 * 1024 * 1024).round(),
        createdAt: now.subtract(const Duration(days: 3)),
        tag: DocTag.signed,
        filePath: samplePath,
      ),
      Document(
        id: '4',
        name: 'Lease_agreement.pdf',
        pageCount: 12,
        sizeBytes: (2.1 * 1024 * 1024).round(),
        createdAt: now.subtract(const Duration(days: 6)),
        tag: DocTag.imported,
        filePath: samplePath,
      ),
    ];
  }
}

final documentsProvider =
    NotifierProvider<DocumentsNotifier, List<Document>>(DocumentsNotifier.new);

/// Most-recent documents (sorted desc by date), capped for the home list.
final recentDocumentsProvider = Provider<List<Document>>((ref) {
  final docs = [...ref.watch(documentsProvider)]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return docs.take(5).toList(growable: false);
});
