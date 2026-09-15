import 'package:flutter/widgets.dart';

/// Enhancement filter applied to a scanned page.
enum ScanFilter { magic, original, grayscale, blackWhite }

extension ScanFilterX on ScanFilter {
  String get label => switch (this) {
        ScanFilter.magic => 'Magic Color',
        ScanFilter.original => 'Original',
        ScanFilter.grayscale => 'Grayscale',
        ScanFilter.blackWhite => 'B&W',
      };

  /// Fast, GPU-side approximation for live preview. Accurate pixel processing
  /// happens at export time (see `image_processor.dart`).
  ColorFilter? get previewFilter => switch (this) {
        ScanFilter.original => null,
        ScanFilter.magic => _saturation(1.4),
        ScanFilter.grayscale => _grayscale(1.0),
        ScanFilter.blackWhite => _grayscale(1.8),
      };
}

ColorFilter _grayscale(double contrast) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final t = 128.0 * (1 - contrast);
  return ColorFilter.matrix([
    r * contrast, g * contrast, b * contrast, 0, t,
    r * contrast, g * contrast, b * contrast, 0, t,
    r * contrast, g * contrast, b * contrast, 0, t,
    0, 0, 0, 1, 0,
  ]);
}

ColorFilter _saturation(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final sr = (1 - s) * r, sg = (1 - s) * g, sb = (1 - s) * b;
  return ColorFilter.matrix([
    sr + s, sg, sb, 0, 0,
    sr, sg + s, sb, 0, 0,
    sr, sg, sb + s, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}

/// One page captured in a scan session: its source image, chosen filter,
/// and rotation (in 90° steps).
class ScanPage {
  ScanPage({required this.imagePath, this.filter = ScanFilter.magic, this.quarterTurns = 0});

  final String imagePath;
  ScanFilter filter;
  int quarterTurns;

  ScanPage copyWith({ScanFilter? filter, int? quarterTurns}) => ScanPage(
        imagePath: imagePath,
        filter: filter ?? this.filter,
        quarterTurns: quarterTurns ?? this.quarterTurns,
      );
}
