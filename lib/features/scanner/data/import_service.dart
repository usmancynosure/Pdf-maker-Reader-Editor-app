import 'package:image_picker/image_picker.dart';

/// Imports images from the device gallery to feed the PDF pipeline.
class ImportService {
  const ImportService();

  Future<List<String>> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    return files.map((f) => f.path).toList(growable: false);
  }
}
