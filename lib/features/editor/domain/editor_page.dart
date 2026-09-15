/// A page in an editing session: a reference to a source PDF file + which page,
/// plus a rotation and a transient selection flag. Pages can come from
/// different files (after a merge).
class EditorPage {
  EditorPage({
    required this.filePath,
    required this.pageIndex,
    this.rotationTurns = 0,
    this.selected = false,
  });

  final String filePath;
  final int pageIndex; // 0-based within its source file
  int rotationTurns; // 0..3, clockwise 90° steps
  bool selected;

  /// Stable key for thumbnail caching.
  String get key => '$filePath#$pageIndex';
}
