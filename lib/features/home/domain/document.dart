import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// How a document was produced / what it represents. Drives the colored pill.
enum DocTag { pdf, idCard, signed, imported }

extension DocTagX on DocTag {
  String get label => switch (this) {
        DocTag.pdf => 'PDF',
        DocTag.idCard => 'ID',
        DocTag.signed => 'Signed',
        DocTag.imported => 'Import',
      };

  Color get color => switch (this) {
        DocTag.pdf => AppColors.accent,
        DocTag.idCard => AppColors.gBlueB,
        DocTag.signed => AppColors.success,
        DocTag.imported => AppColors.ctaViolet,
      };
}

/// A scanned / imported document stored by the app.
@immutable
class Document {
  const Document({
    required this.id,
    required this.name,
    required this.pageCount,
    required this.sizeBytes,
    required this.createdAt,
    required this.tag,
  });

  final String id;
  final String name;
  final int pageCount;
  final int sizeBytes;
  final DateTime createdAt;
  final DocTag tag;

  Document copyWith({String? name, int? pageCount, int? sizeBytes, DocTag? tag}) {
    return Document(
      id: id,
      name: name ?? this.name,
      pageCount: pageCount ?? this.pageCount,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt,
      tag: tag ?? this.tag,
    );
  }

  /// "820 KB", "1.2 MB"
  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  /// "4 pages · 820 KB · Today"
  String subtitle(String relativeDate) {
    final pages = pageCount == 1 ? '1 page' : '$pageCount pages';
    return '$pages · $sizeLabel · $relativeDate';
  }
}
