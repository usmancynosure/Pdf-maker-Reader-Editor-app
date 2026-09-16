import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Imports content from the device: photos (to feed the PDF pipeline) or an
/// existing PDF file (copied into app storage).
class ImportService {
  const ImportService();

  Future<List<String>> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    return files.map((f) => f.path).toList(growable: false);
  }

  /// Lets the user pick a .pdf, copies it into the app's documents folder, and
  /// returns the saved [File] (or null if cancelled).
  Future<File?> pickPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (files.isEmpty) return null;
    final picked = files.first;
    if (picked.path == null) return null;

    final src = File(picked.path!);
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/scans');
    if (!folder.existsSync()) folder.createSync(recursive: true);

    final name = picked.name.endsWith('.pdf') ? picked.name : '${picked.name}.pdf';
    final dest = File('${folder.path}/$name');
    return src.copy(dest.path);
  }
}
