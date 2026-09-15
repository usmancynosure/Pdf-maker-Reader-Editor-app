import 'package:cunning_document_scanner/cunning_document_scanner.dart';

/// Thin wrapper over the native document scanner (VisionKit on iOS,
/// ML Kit Document Scanner on Android). Returns the captured image file paths
/// (already edge-detected & perspective-corrected by the OS), or an empty list
/// if the user cancels.
class ScannerService {
  const ScannerService();

  Future<List<String>> scan({int maxPages = 24}) async {
    final pictures = await CunningDocumentScanner.getPictures(
      noOfPages: maxPages,
    );
    return pictures ?? const [];
  }
}
