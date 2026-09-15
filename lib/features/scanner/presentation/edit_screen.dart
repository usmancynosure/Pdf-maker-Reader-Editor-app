import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../home/application/documents_provider.dart';
import '../../home/domain/document.dart';
import '../application/scanner_providers.dart';
import '../domain/scan_page.dart';
import 'widgets/filter_chips.dart';
import 'widgets/page_filmstrip.dart';

/// Screen 04 — Edit & Enhance.
/// Receives freshly-scanned image paths, lets the user pick a filter, rotate,
/// reorder/delete/add pages, then exports a PDF and stores it.
class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key, required this.imagePaths, required this.onRescan});

  final List<String> imagePaths;

  /// Returns additional image paths when the user taps "add page".
  final Future<List<String>> Function() onRescan;

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late List<ScanPage> _pages;
  int _selected = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pages = widget.imagePaths.map((p) => ScanPage(imagePath: p)).toList();
  }

  ScanPage get _current => _pages[_selected];

  void _setFilter(ScanFilter f) => setState(() => _current.filter = f);

  void _rotate() => setState(() => _current.quarterTurns += 1);

  void _deletePage() {
    if (_pages.length == 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _pages.removeAt(_selected);
      _selected = _selected.clamp(0, _pages.length - 1);
    });
  }

  Future<void> _addPages() async {
    final more = await widget.onRescan();
    if (more.isEmpty) return;
    setState(() {
      _pages.addAll(more.map((p) => ScanPage(imagePath: p)));
      _selected = _pages.length - 1;
    });
  }

  void _todo(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inkSoft,
        content: Text('$what — coming soon'),
      ),
    );
  }

  Future<void> _save() async {
    final name = await _askFileName();
    if (name == null || name.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      final file = await ref
          .read(pdfExporterProvider)
          .export(pages: _pages, fileName: name.trim());
      final len = await file.length();

      ref.read(documentsProvider.notifier).add(Document(
            id: const Uuid().v4(),
            name: file.uri.pathSegments.last,
            pageCount: _pages.length,
            sizeBytes: len,
            createdAt: DateTime.now(),
            tag: DocTag.pdf,
            filePath: file.path,
          ));

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          content: Text('Saved ${file.uri.pathSegments.last}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text('Could not save PDF: $e'),
        ),
      );
    }
  }

  Future<String?> _askFileName() {
    final controller = TextEditingController(text: _defaultName());
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as PDF'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'File name',
            suffixText: '.pdf',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  String _defaultName() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'Scan_${n.year}-${two(n.month)}-${two(n.day)}_${two(n.hour)}${two(n.minute)}';
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
                  _TopBar(onBack: () => Navigator.of(context).pop(), onAdd: _addPages),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Column(
                        children: [
                          _Preview(page: _current),
                          const SizedBox(height: 14),
                          FilterChipsRow(
                            selected: _current.filter,
                            onSelect: _setFilter,
                          ),
                          const SizedBox(height: 16),
                          _ToolsRow(
                            onCrop: () => _todo('Crop'),
                            onRotate: _rotate,
                            onAdjust: () => _todo('Adjust'),
                            onDelete: _deletePage,
                          ),
                          const SizedBox(height: 16),
                          PageFilmstrip(
                            pages: _pages,
                            selected: _selected,
                            onSelect: (i) => setState(() => _selected = i),
                            onAdd: _addPages,
                          ),
                          const SizedBox(height: 18),
                          GradientButton(
                            label: 'Save as PDF',
                            icon: Icons.picture_as_pdf_outlined,
                            onPressed: _saving ? null : _save,
                          ),
                        ],
                      ),
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
  const _TopBar({required this.onBack, required this.onAdd});
  final VoidCallback onBack, onAdd;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          _RoundBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const Spacer(),
          Text('Edit & Enhance', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          _RoundBtn(icon: Icons.add_rounded, onTap: onAdd),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x99FFFFFF),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0x99FFFFFF)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF3A3155)),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.page});
  final ScanPage page;
  @override
  Widget build(BuildContext context) {
    Widget image = Image.file(File(page.imagePath), fit: BoxFit.contain);
    final cf = page.filter.previewFilter;
    if (cf != null) image = ColorFiltered(colorFilter: cf, child: image);

    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A3CA0).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: Colors.white,
        child: RotatedBox(quarterTurns: page.quarterTurns, child: image),
      ),
    );
  }
}

class _ToolsRow extends StatelessWidget {
  const _ToolsRow({
    required this.onCrop,
    required this.onRotate,
    required this.onAdjust,
    required this.onDelete,
  });
  final VoidCallback onCrop, onRotate, onAdjust, onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Tool(icon: Icons.crop_rounded, label: 'Crop', onTap: onCrop),
        _Tool(icon: Icons.rotate_right_rounded, label: 'Rotate', onTap: onRotate),
        _Tool(icon: Icons.tune_rounded, label: 'Adjust', onTap: onAdjust),
        _Tool(icon: Icons.delete_outline_rounded, label: 'Delete', onTap: onDelete),
      ],
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xB3FFFFFF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x99FFFFFF)),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF5A4D7D)),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF4A4165))),
        ],
      ),
    );
  }
}
