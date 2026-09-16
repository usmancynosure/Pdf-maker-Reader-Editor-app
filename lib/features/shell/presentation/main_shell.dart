import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/glass_bottom_nav.dart';
import '../../home/application/documents_provider.dart';
import '../../home/domain/document.dart';
import '../../home/presentation/home_screen.dart';
import '../../scanner/application/scanner_providers.dart';
import '../../scanner/presentation/edit_screen.dart';
import '../../editor/presentation/tools_screen.dart';
import '../../files/presentation/files_screen.dart';
import '../../reader/presentation/reader_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../sign/presentation/signature_screen.dart';

/// Root shell after splash: holds the four primary tabs behind the holographic
/// background and the floating glass bottom nav with the center scan FAB.
///
/// Tabs beyond Home are on-brand placeholders until their phases land
/// (Files = Phase 6, Tools = Phase 3–5, Settings = Phase 7).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _destinations = [
    NavDestination(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavDestination(Icons.folder_outlined, Icons.folder_rounded, 'Files'),
    NavDestination(
        Icons.picture_as_pdf_outlined, Icons.picture_as_pdf_rounded, 'Tools'),
    NavDestination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  /// Launch the native scanner; on capture, open the Edit & Enhance screen.
  Future<void> _startScan() async {
    final scanner = ref.read(scannerServiceProvider);
    try {
      final paths = await scanner.scan();
      if (paths.isEmpty || !mounted) return; // cancelled
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditScreen(
            imagePaths: paths,
            onRescan: () => scanner.scan(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final s = e.toString().toLowerCase();
      final noCamera = s.contains('11800') ||
          s.contains('camera') ||
          s.contains('avfoundation');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.inkSoft,
          content: Text(noCamera
              ? 'No camera on this device — try Import from Photos, or use a real phone.'
              : "Couldn't open the scanner. Please try again."),
        ),
      );
    }
  }

  /// Import: choose photos (-> edit -> PDF) or an existing PDF file (-> reader).
  Future<void> _import() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Import from',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.accent),
              title: const Text('Photos'),
              subtitle: const Text('Turn images into a PDF'),
              onTap: () => Navigator.pop(ctx, 'photos'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined,
                  color: AppColors.accent),
              title: const Text('PDF file'),
              subtitle: const Text('Open an existing PDF to read & edit'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == 'photos') {
      await _importPhotos();
    } else if (choice == 'pdf') {
      await _importPdf();
    }
  }

  Future<void> _importPhotos() async {
    try {
      final paths = await ref.read(importServiceProvider).pickImages();
      if (paths.isEmpty || !mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditScreen(
            imagePaths: paths,
            onRescan: () => ref.read(importServiceProvider).pickImages(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _snack("Couldn't import images: $e", danger: true);
    }
  }

  Future<void> _importPdf() async {
    try {
      final file = await ref.read(importServiceProvider).pickPdf();
      if (file == null || !mounted) return;

      // Count pages for the document metadata.
      var pageCount = 1;
      try {
        final d = await pdfx.PdfDocument.openFile(file.path);
        pageCount = d.pagesCount;
        await d.close();
      } catch (_) {/* keep default */}

      final len = await file.length();
      final doc = Document(
        id: const Uuid().v4(),
        name: file.uri.pathSegments.last,
        pageCount: pageCount,
        sizeBytes: len,
        createdAt: DateTime.now(),
        tag: DocTag.imported,
        filePath: file.path,
      );
      ref.read(documentsProvider.notifier).add(doc);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReaderScreen(doc: doc)),
      );
    } catch (e) {
      if (!mounted) return;
      _snack("Couldn't import PDF: $e", danger: true);
    }
  }

  /// Pick a PDF, then draw a signature to stamp onto it.
  Future<void> _sign() async {
    final doc = await _pickPdf('Sign which PDF?');
    if (doc == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignatureScreen(doc: doc)),
    );
  }

  /// Bottom-sheet picker over the user's real PDFs.
  Future<Document?> _pickPdf(String title) {
    final docs =
        ref.read(documentsProvider).where((d) => d.hasFile).toList();
    if (docs.isEmpty) {
      _snack('No PDFs yet — scan or import one first');
      return Future.value();
    }
    return showModalBottomSheet<Document>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            for (final d in docs)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined,
                    color: AppColors.accent),
                title: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${d.pageCount} pages'),
                onTap: () => Navigator.pop(ctx, d),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _snack(String msg, {bool danger = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: danger ? AppColors.danger : AppColors.inkSoft,
      content: Text(msg),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HoloBackground(
        child: Stack(
          children: [
            // Inset the body so its bottom edge aligns with the nav pill's
            // bottom — content scrolls under the frosted pill, but nothing
            // bleeds into the safe-area gap below it.
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 12),
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(
                    onScan: _startScan,
                    onImport: _import,
                    onTools: () => setState(() => _index = 2),
                    onSign: _sign,
                  ),
                  const FilesScreen(),
                  const ToolsScreen(),
                  const SettingsScreen(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: GlassBottomNav(
                  destinations: _destinations,
                  currentIndex: _index,
                  onSelect: (i) => setState(() => _index = i),
                  onFabPressed: _startScan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
