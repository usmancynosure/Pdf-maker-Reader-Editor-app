import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/application/documents_provider.dart';
import '../../home/presentation/widgets/document_tile.dart';
import 'editor_screen.dart';

/// Tools tab — pick a PDF to organize/edit. Lists documents backed by a real
/// file; tapping one opens the PDF editor.
class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs =
        ref.watch(documentsProvider).where((d) => d.hasFile).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
            child: Text('PDF Tools',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: Text('Pick a PDF to organize, merge, split or watermark.',
                style: TextStyle(fontSize: 13, color: Color(0xFF5A4A7A))),
          ),
          if (docs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text('No PDFs yet — scan one to get started',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
          for (final doc in docs)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: DocumentTile(
                doc: doc,
                trailing: const Icon(Icons.tune_rounded,
                    color: AppColors.accent, size: 20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditorScreen(doc: doc)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
