/// A single overlay placed on a PDF page. Coordinates are normalized (0..1),
/// top-left origin — the same convention Syncfusion uses for drawing bounds,
/// so mapping to page points at export time is a plain multiply.
enum AnnoType { text, whiteout }

class Annotation {
  Annotation({
    required this.type,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.text = '',
    this.fontSize = 14,
  });

  final AnnoType type;
  double left, top, width, height; // normalized 0..1
  String text;
  double fontSize; // in PDF points

  bool get isText => type == AnnoType.text;
}
