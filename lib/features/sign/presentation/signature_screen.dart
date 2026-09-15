import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../editor/application/editor_providers.dart';
import '../../home/application/documents_provider.dart';
import '../../home/domain/document.dart';

/// Draw a signature and stamp it onto the last page of [doc], saving a new
/// signed PDF.
class SignatureScreen extends ConsumerStatefulWidget {
  const SignatureScreen({super.key, required this.doc});
  final Document doc;

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen> {
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black87,
    exportBackgroundColor: Colors.transparent,
  );
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color color = AppColors.inkSoft}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(msg),
    ));
  }

  Future<void> _apply() async {
    if (_controller.isEmpty) {
      _snack('Draw your signature first');
      return;
    }
    final png = await _controller.toPngBytes();
    if (png == null || !mounted) return;

    setState(() => _saving = true);
    try {
      final base = widget.doc.name.replaceAll('.pdf', '');
      final file = await ref.read(pdfEditorServiceProvider).signPdf(
            srcPath: widget.doc.filePath!,
            signaturePng: png,
            fileName: '${base}_signed',
          );
      final len = await file.length();
      ref.read(documentsProvider.notifier).add(Document(
            id: const Uuid().v4(),
            name: file.uri.pathSegments.last,
            pageCount: widget.doc.pageCount,
            sizeBytes: len,
            createdAt: DateTime.now(),
            tag: DocTag.signed,
            filePath: file.path,
          ));
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Signed ${file.uri.pathSegments.last}', color: AppColors.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not sign: $e', color: AppColors.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
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
                        Text('Sign Document',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                    child: Text('Draw your signature below',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Container(color: Colors.white),
                            Signature(
                              controller: _controller,
                              backgroundColor: Colors.white,
                            ),
                            const Positioned(
                              left: 20,
                              right: 20,
                              bottom: 26,
                              child: Divider(color: Color(0xFFD7CFE6), thickness: 1.5),
                            ),
                            const Positioned(
                              left: 20,
                              bottom: 6,
                              child: Text('Sign here',
                                  style: TextStyle(
                                      color: Color(0xFFB6AECB), fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _controller.clear(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.muted),
                        ),
                        const Spacer(),
                        Text('Signs the last page of “${widget.doc.name}”',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: GradientButton(
                      label: 'Apply Signature',
                      icon: Icons.draw_rounded,
                      onPressed: _saving ? null : _apply,
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
