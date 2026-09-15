import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../home/application/documents_provider.dart';
import '../../home/domain/document.dart';
import '../../home/presentation/widgets/document_tile.dart';
import '../../reader/presentation/reader_screen.dart';

/// Screen 07 — Files. The full document library with a storage meter,
/// tag filter segments, search, and per-document actions (open/share/rename/delete).
class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  DocTag? _filter; // null = All
  String _query = '';

  static const _nominalQuotaBytes = 1024 * 1024 * 1024; // 1 GB reference

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(documentsProvider);
    final usedBytes = all.fold<int>(0, (sum, d) => sum + d.sizeBytes);

    final filtered = all
        .where((d) => _filter == null || d.tag == _filter)
        .where((d) => _query.isEmpty ||
            d.name.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Row(
            children: [
              Text('My Files', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              Text('${all.length} docs',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A4A7A))),
            ],
          ),
          const SizedBox(height: 12),
          _SearchField(onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 12),
          _StorageCard(usedBytes: usedBytes, quotaBytes: _nominalQuotaBytes),
          const SizedBox(height: 12),
          _SegmentBar(
            selected: _filter,
            onSelect: (t) => setState(() => _filter = t),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: Text('Nothing here yet',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
          for (final doc in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: DocumentTile(
                doc: doc,
                onTap: () => _open(doc),
                onLongPress: () => _actions(doc),
              ),
            ),
        ],
      ),
    );
  }

  void _open(Document doc) {
    if (!doc.hasFile) {
      _snack('Sample document — scan one to create a real PDF');
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ReaderScreen(doc: doc)));
  }

  void _snack(String msg, {Color color = AppColors.inkSoft}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(msg),
    ));
  }

  Future<void> _actions(Document doc) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            _sheetTile(ctx, Icons.drive_file_rename_outline_rounded, 'Rename', 'rename'),
            if (doc.hasFile)
              _sheetTile(ctx, Icons.ios_share_rounded, 'Share', 'share'),
            _sheetTile(ctx, Icons.delete_outline_rounded, 'Delete', 'delete',
                danger: true),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'rename':
        await _rename(doc);
      case 'share':
        await SharePlus.instance.share(
          ShareParams(files: [XFile(doc.filePath!)], subject: doc.name),
        );
      case 'delete':
        await _confirmDelete(doc);
    }
  }

  Widget _sheetTile(BuildContext ctx, IconData icon, String label, String value,
      {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.inkSoft;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  Future<void> _rename(Document doc) async {
    final base = doc.name.replaceAll('.pdf', '');
    final controller = TextEditingController(text: base);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name', suffixText: '.pdf'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final safe = name.trim().endsWith('.pdf') ? name.trim() : '${name.trim()}.pdf';
    ref.read(documentsProvider.notifier).rename(doc.id, safe);
  }

  Future<void> _confirmDelete(Document doc) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('“${doc.name}” will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await ref.read(documentsProvider.notifier).delete(doc.id);
    if (mounted) _snack('Deleted ${doc.name}');
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      radius: 18,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF6A5F88)),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search files…',
                border: InputBorder.none,
                isCollapsed: true,
                hintStyle: TextStyle(color: Color(0xFF7A7092), fontSize: 13.5),
              ),
              style: const TextStyle(fontSize: 13.5, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.usedBytes, required this.quotaBytes});
  final int usedBytes;
  final int quotaBytes;

  String _fmt(int b) {
    if (b < 1024) return '$b B';
    final kb = b / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final frac = (usedBytes / quotaBytes).clamp(0.02, 1.0);
    return GlassCard(
      strong: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Storage · ${_fmt(usedBytes)} of ${_fmt(quotaBytes)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A3155))),
              const Text('On device',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 8,
              backgroundColor: AppColors.accent.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.selected, required this.onSelect});
  final DocTag? selected;
  final ValueChanged<DocTag?> onSelect;

  @override
  Widget build(BuildContext context) {
    final segments = <(String, DocTag?)>[
      ('All', null),
      ('PDF', DocTag.pdf),
      ('ID', DocTag.idCard),
      ('Signed', DocTag.signed),
      ('Import', DocTag.imported),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: segments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, tag) = segments[i];
          final on = tag == selected;
          return GestureDetector(
            onTap: () => onSelect(tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: on ? AppGradients.cta : null,
                color: on ? null : const Color(0x8CFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x99FFFFFF)),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : const Color(0xFF4A4165))),
            ),
          );
        },
      ),
    );
  }
}
