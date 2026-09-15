import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../home/application/documents_provider.dart';
import '../../home/domain/document.dart';
import '../../sign/presentation/signature_screen.dart';
import '../application/editor_providers.dart';
import '../domain/editor_page.dart';
import 'widgets/editor_toolbar.dart';

/// Screen 06 — PDF Editor / Organize Pages.
/// Reorder (drag), rotate, delete and multi-select pages; merge another PDF,
/// split the selection, add a watermark, then export a new document.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.doc});
  final Document doc;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _pages = <EditorPage>[];
  final _docs = <String, Future<pdfx.PdfDocument>>{};
  final _thumbs = <String, Uint8List?>{};
  String? _watermark;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final path = widget.doc.filePath!;
    final doc = await _openDoc(path);
    if (!mounted) return;
    setState(() {
      _pages.addAll(
        List.generate(doc.pagesCount, (i) => EditorPage(filePath: path, pageIndex: i)),
      );
      _loading = false;
    });
  }

  Future<pdfx.PdfDocument> _openDoc(String path) =>
      _docs.putIfAbsent(path, () => pdfx.PdfDocument.openFile(path));

  @override
  void dispose() {
    for (final f in _docs.values) {
      f.then((d) => d.close()).catchError((_) {});
    }
    super.dispose();
  }

  Future<Uint8List?> _thumb(EditorPage ep) async {
    if (_thumbs.containsKey(ep.key)) return _thumbs[ep.key];
    final doc = await _openDoc(ep.filePath);
    final p = await doc.getPage(ep.pageIndex + 1);
    final scale = 240 / p.width;
    final img = await p.render(
      width: p.width * scale,
      height: p.height * scale,
      format: pdfx.PdfPageImageFormat.jpeg,
      backgroundColor: '#FFFFFF',
    );
    await p.close();
    _thumbs[ep.key] = img?.bytes;
    return img?.bytes;
  }

  int get _selectedCount => _pages.where((p) => p.selected).length;

  void _snack(String msg, {Color color = AppColors.inkSoft}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(msg),
    ));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      _pages.insert(newIndex, _pages.removeAt(oldIndex));
    });
  }

  void _rotate(int i) => setState(() => _pages[i].rotationTurns += 1);

  void _delete(int i) {
    setState(() => _pages.removeAt(i));
    if (_pages.isEmpty && mounted) Navigator.of(context).pop();
  }

  Future<void> _merge() async {
    final others = ref
        .read(documentsProvider)
        .where((d) => d.hasFile && d.filePath != widget.doc.filePath)
        .toList();
    if (others.isEmpty) {
      _snack('No other PDFs to merge — scan or create another first');
      return;
    }
    final picked = await showModalBottomSheet<Document>(
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
              child: Text('Merge which PDF?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            for (final d in others)
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
    if (picked == null) return;
    final doc = await _openDoc(picked.filePath!);
    if (!mounted) return;
    setState(() {
      _pages.addAll(List.generate(
          doc.pagesCount, (i) => EditorPage(filePath: picked.filePath!, pageIndex: i)));
    });
    _snack('Added ${doc.pagesCount} pages from ${picked.name}',
        color: AppColors.success);
  }

  Future<void> _split() async {
    final selected = _pages.where((p) => p.selected).toList();
    if (selected.isEmpty) {
      _snack('Select the pages to split out first');
      return;
    }
    await _runExport(selected, defaultName: 'Split_${_defaultStamp()}');
  }

  Future<void> _watermarkDialog() async {
    final controller = TextEditingController(text: _watermark ?? 'CONFIDENTIAL');
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Watermark'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Watermark text'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text('Remove')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Apply')),
        ],
      ),
    );
    if (text == null) return;
    setState(() => _watermark = text.trim().isEmpty ? null : text.trim());
    _snack(_watermark == null ? 'Watermark removed' : 'Watermark set — applied on export');
  }

  Future<void> _sign() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignatureScreen(doc: widget.doc)),
    );
  }

  Future<void> _addText() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Text (top of page 1)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Add')),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      final base = widget.doc.name.replaceAll('.pdf', '');
      final file = await ref.read(pdfEditorServiceProvider).addText(
            srcPath: widget.doc.filePath!,
            text: text.trim(),
            fileName: '${base}_text',
          );
      final len = await file.length();
      ref.read(documentsProvider.notifier).add(Document(
            id: const Uuid().v4(),
            name: file.uri.pathSegments.last,
            pageCount: widget.doc.pageCount,
            sizeBytes: len,
            createdAt: DateTime.now(),
            tag: DocTag.pdf,
            filePath: file.path,
          ));
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Saved ${file.uri.pathSegments.last}', color: AppColors.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not add text: $e', color: AppColors.danger);
    }
  }

  Future<void> _export() => _runExport(_pages, defaultName: _suggestedName());

  Future<void> _runExport(List<EditorPage> pages, {required String defaultName}) async {
    final name = await _askName(defaultName);
    if (name == null || name.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      final file = await ref.read(pdfEditorServiceProvider).export(
            pages: pages,
            fileName: name.trim(),
            watermark: _watermark,
          );
      final len = await file.length();
      ref.read(documentsProvider.notifier).add(Document(
            id: const Uuid().v4(),
            name: file.uri.pathSegments.last,
            pageCount: pages.length,
            sizeBytes: len,
            createdAt: DateTime.now(),
            tag: DocTag.pdf,
            filePath: file.path,
          ));
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Saved ${file.uri.pathSegments.last}', color: AppColors.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Export failed: $e', color: AppColors.danger);
    }
  }

  Future<String?> _askName(String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export PDF'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'File name', suffixText: '.pdf'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Export')),
        ],
      ),
    );
  }

  String _defaultStamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}-${two(n.month)}-${two(n.day)}_${two(n.hour)}${two(n.minute)}';
  }

  String _suggestedName() {
    final base = widget.doc.name.replaceAll('.pdf', '');
    return '${base}_edited';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _TopBar(
                    selectedCount: _selectedCount,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  if (_watermark != null) _WatermarkChip(text: _watermark!),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                            itemCount: _pages.length,
                            onReorder: _reorder,
                            itemBuilder: (context, i) {
                              final ep = _pages[i];
                              return _PageTile(
                                key: ValueKey('${ep.key}@$i'),
                                index: i,
                                page: ep,
                                thumb: _thumb(ep),
                                onToggle: () =>
                                    setState(() => ep.selected = !ep.selected),
                                onRotate: () => _rotate(i),
                                onDelete: () => _delete(i),
                              );
                            },
                          ),
                  ),
                  EditorToolbar(
                    onMerge: _merge,
                    onSplit: _split,
                    onText: _addText,
                    onSign: _sign,
                    onWatermark: _watermarkDialog,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: GradientButton(
                      label: _selectedCount > 0
                          ? 'Export ($_selectedCount selected → Split)'
                          : 'Export PDF',
                      icon: Icons.file_download_outlined,
                      onPressed: _saving
                          ? null
                          : (_selectedCount > 0 ? _split : _export),
                    ),
                  ),
                ],
              ),
              if (_saving)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.selectedCount, required this.onBack});
  final int selectedCount;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x99FFFFFF),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0x99FFFFFF)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF3A3155)),
            ),
          ),
          const Spacer(),
          Text('Organize Pages', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          SizedBox(
            width: 56,
            child: Text(
              selectedCount > 0 ? '$selectedCount sel' : '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatermarkChip extends StatelessWidget {
  const _WatermarkChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.branding_watermark_outlined,
                    size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Text('Watermark: $text',
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    super.key,
    required this.index,
    required this.page,
    required this.thumb,
    required this.onToggle,
    required this.onRotate,
    required this.onDelete,
  });

  final int index;
  final EditorPage page;
  final Future<Uint8List?> thumb;
  final VoidCallback onToggle, onRotate, onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: page.selected ? AppColors.accent.withValues(alpha: 0.10) : const Color(0xB3FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: page.selected ? AppColors.accent : const Color(0x99FFFFFF),
            width: page.selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                page.selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: page.selected ? AppColors.accent : const Color(0xFFB6AECB),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 46,
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE6E0F2)),
              ),
              child: RotatedBox(
                quarterTurns: page.rotationTurns,
                child: FutureBuilder<Uint8List?>(
                  future: thumb,
                  builder: (context, snap) => snap.data == null
                      ? const Center(
                          child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : Image.memory(snap.data!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Page ${index + 1}',
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkSoft)),
            ),
            IconButton(
              onPressed: onRotate,
              icon: const Icon(Icons.rotate_right_rounded,
                  size: 20, color: Color(0xFF5A4D7D)),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: AppColors.danger),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(left: 2, right: 4),
                child: Icon(Icons.drag_handle_rounded, color: Color(0xFFB6AECB)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
