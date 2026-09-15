import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/home/application/documents_provider.dart';
import 'features/settings/application/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();
  final samplePath = await _installSamplePdf();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        samplePdfPathProvider.overrideWithValue(samplePath),
      ],
      child: const PrismaScanApp(),
    ),
  );
}

/// Copies the bundled demo PDF to the documents directory so the seeded sample
/// documents can actually be opened in the reader/editor. Returns null on failure.
Future<String?> _installSamplePdf() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/samples');
    if (!folder.existsSync()) folder.createSync(recursive: true);
    final file = File('${folder.path}/prisma_sample.pdf');
    final bytes = await rootBundle.load('assets/sample/prisma_sample.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return file.path;
  } catch (_) {
    return null;
  }
}
