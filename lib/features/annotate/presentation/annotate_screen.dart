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
import '../data/annotate_service.dart';
import '../domain/annotation.dart';

/// Edit an existing PDF by overlaying editable text boxes and white-out
/// rectangles (cover old text, type new). Flattened onto the PDF on export.
class AnnotateScreen extends ConsumerStatefulWidget {
  const AnnotateScreen({super.key, required this.doc});
  final Document doc;

  @override
  ConsumerState<AnnotateScreen> createState() => _AnnotateScreenState();
}

class _PageData {
  _PageData(this.image, this.pointSize);
  final Uint8List? image;
  final Size pointSize; // PDF page size in points
}

class _AnnotateScreenState extends ConsumerState<AnnotateScreen> {
  pdfx.PdfDocument? _pdf;
  final _byPage = <int, List<Annotation>>{};
  final _pageCache = <int, _PageData>{};
  int _page = 0;
  int _pageCount = 0;
  Annotation? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    pdfx.PdfDocument.openFile(widget.doc.filePath!).then((d) {
      if (!mounted) return;
      setState(() {
        _pdf = d;
        _pageCount = d.pagesCount;
      });
    });
  }

  @override
  void dispose() {
    _pdf?.close();
    super.dispose();
  }

  List<Annotation> get _annos => _byPage.putIfAbsent(_page, () => []);

  Future<_PageData> _loadPage(int i) async {
    if (_pageCache.containsKey(i)) return _pageCache[i]!;
    final page = await _pdf!.getPage(i + 1);
    final ptW = page.width, ptH = page.height;
    final scale = 1100 / ptW;
    final img = await page.render(
      width: ptW * scale,
      height: ptH * scale,
      format: pdfx.PdfPageImageFormat.jpeg,
      backgroundColor: '#FFFFFF',
    );
    await page.close();
    return _pageCache[i] = _PageData(img?.bytes, Size(ptW, ptH));
  }

  void _addText() {
    final a = Annotation(
        type: AnnoType.text, left: .18, top: .4, width: .5, height: .06, text: 'Text');
    setState(() {
      _annos.add(a);
      _selected = a;
    });
    _editText(a);
  }

  void _addWhiteout() {
    final a = Annotation(
        type: AnnoType.whiteout, left: .2, top: .42, width: .45, height: .045);
    setState(() {
      _annos.add(a);
      _selected = a;
    });
  }

  Future<void> _editText(Annotation a) async {
    final controller = TextEditingController(text: a.text);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Type here…'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('OK')),
        ],
      ),
    );
    if (result != null) setState(() => a.text = result);
  }

  void _deleteSelected() {
    if (_selected == null) return;
    setState(() {
      _annos.remove(_selected);
      _selected = null;
    });
  }

  int get _totalAnnos =>
      _byPage.values.fold(0, (s, l) => s + l.length);

  Future<void> _export() async {
    if (_totalAnnos == 0) {
      _snack('Add some text or white-out first');
      return;
    }
    final base = widget.doc.name.replaceAll('.pdf', '');
    setState(() => _saving = true);
    try {
      final file = await ref.read(annotateServiceProvider).apply(
            srcPath: widget.doc.filePath!,
            byPage: _byPage,
            fileName: '${base}_edited',
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
      _snack('Export failed: $e', color: AppColors.danger);
    }
  }

  void _snack(String m, {Color color = AppColors.inkSoft}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Text(m),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: _pdf == null
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            onTap: () => setState(() => _selected = null),
                            child: FutureBuilder<_PageData>(
                              future: _loadPage(_page),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return _PageCanvas(
                                  data: snap.data!,
                                  annos: _annos,
                                  selected: _selected,
                                  onSelect: (a) => setState(() => _selected = a),
                                  onChanged: () => setState(() {}),
                                  onEditText: _editText,
                                );
                              },
                            ),
                          ),
                  ),
                  _toolbar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: GradientButton(
                      label: 'Export PDF',
                      icon: Icons.file_download_outlined,
                      onPressed: _saving ? null : _export,
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

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          _roundBtn(Icons.arrow_back_ios_new_rounded,
              () => Navigator.of(context).pop()),
          const Spacer(),
          Text('Edit PDF', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (_selected != null)
            _roundBtn(Icons.delete_outline_rounded, _deleteSelected,
                color: AppColors.danger)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
      child: Row(
        children: [
          _tool(Icons.text_fields_rounded, 'Text', _addText),
          const SizedBox(width: 10),
          _tool(Icons.format_color_reset_outlined, 'White-out', _addWhiteout),
          const Spacer(),
          _roundBtn(Icons.chevron_left_rounded,
              _page > 0 ? () => setState(() { _page--; _selected = null; }) : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('${_page + 1}/$_pageCount',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
          ),
          _roundBtn(Icons.chevron_right_rounded,
              _page < _pageCount - 1 ? () => setState(() { _page++; _selected = null; }) : null),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xC7FFFFFF),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0x99FFFFFF)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft)),
        ]),
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback? onTap, {Color? color}) {
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
        child: Icon(icon,
            size: 20,
            color: onTap == null
                ? const Color(0xFFC5BEDA)
                : (color ?? const Color(0xFF3A3155))),
      ),
    );
  }
}

/// Renders the page image and positions/moves/resizes annotations on top.
class _PageCanvas extends StatelessWidget {
  const _PageCanvas({
    required this.data,
    required this.annos,
    required this.selected,
    required this.onSelect,
    required this.onChanged,
    required this.onEditText,
  });

  final _PageData data;
  final List<Annotation> annos;
  final Annotation? selected;
  final ValueChanged<Annotation> onSelect;
  final VoidCallback onChanged;
  final ValueChanged<Annotation> onEditText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, c) {
          final aspect = data.pointSize.width / data.pointSize.height;
          double dw = c.maxWidth, dh = c.maxWidth / aspect;
          if (dh > c.maxHeight) {
            dh = c.maxHeight;
            dw = c.maxHeight * aspect;
          }
          final dx = (c.maxWidth - dw) / 2, dy = (c.maxHeight - dh) / 2;

          return Stack(
            children: [
              Positioned(
                left: dx,
                top: dy,
                width: dw,
                height: dh,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF5A3CA0).withValues(alpha: 0.16),
                          blurRadius: 22,
                          offset: const Offset(0, 10)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: data.image == null
                      ? const SizedBox()
                      : Image.memory(data.image!, fit: BoxFit.fill),
                ),
              ),
              for (final a in annos)
                _AnnoWidget(
                  a: a,
                  selected: identical(a, selected),
                  dx: dx,
                  dy: dy,
                  dw: dw,
                  dh: dh,
                  pagePtH: data.pointSize.height,
                  onSelect: () => onSelect(a),
                  onChanged: onChanged,
                  onEditText: () => onEditText(a),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AnnoWidget extends StatelessWidget {
  const _AnnoWidget({
    required this.a,
    required this.selected,
    required this.dx,
    required this.dy,
    required this.dw,
    required this.dh,
    required this.pagePtH,
    required this.onSelect,
    required this.onChanged,
    required this.onEditText,
  });

  final Annotation a;
  final bool selected;
  final double dx, dy, dw, dh, pagePtH;
  final VoidCallback onSelect, onChanged, onEditText;

  @override
  Widget build(BuildContext context) {
    final left = dx + a.left * dw;
    final top = dy + a.top * dh;
    final w = a.width * dw;
    final h = a.height * dh;
    final screenFont = a.fontSize * dh / pagePtH;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onSelect,
        onDoubleTap: a.isText ? onEditText : null,
        onPanStart: (_) => onSelect(),
        onPanUpdate: (d) {
          a.left = (a.left + d.delta.dx / dw).clamp(0.0, 1 - a.width);
          a.top = (a.top + d.delta.dy / dh).clamp(0.0, 1 - a.height);
          onChanged();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: w,
              height: h,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: a.isText
                    ? (selected ? const Color(0x22000000) : Colors.transparent)
                    : Colors.white,
                border: Border.all(
                  color: selected
                      ? AppColors.accent
                      : (a.isText ? const Color(0x33000000) : const Color(0x22000000)),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: a.isText
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        a.text,
                        maxLines: null,
                        style: TextStyle(
                            fontSize: screenFont.clamp(8, 60),
                            color: const Color(0xFF14141E),
                            height: 1.15),
                      ),
                    )
                  : null,
            ),
            if (selected)
              Positioned(
                right: -9,
                bottom: -9,
                child: GestureDetector(
                  onPanUpdate: (d) {
                    a.width = (a.width + d.delta.dx / dw).clamp(0.06, 1 - a.left);
                    a.height = (a.height + d.delta.dy / dh).clamp(0.02, 1 - a.top);
                    onChanged();
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.open_in_full_rounded,
                        size: 11, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
