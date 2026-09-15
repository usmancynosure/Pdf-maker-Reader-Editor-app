import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/holo_background.dart';
import '../../home/domain/document.dart';
import '../../editor/presentation/editor_screen.dart';
import '../application/reader_providers.dart';
import 'widgets/thumbnail_grid_sheet.dart';

/// Screen 05 — PDF Reader. Renders a saved document with pinch-zoom paging,
/// page indicator, thumbnails, bookmark and share.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.doc});
  final Document doc;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final PdfControllerPinch _controller;
  int _page = 1;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.doc.filePath!),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openThumbnails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThumbnailGridSheet(
        filePath: widget.doc.filePath!,
        pageCount: _pageCount,
        current: _page,
        onJump: (p) => _controller.animateToPage(
          pageNumber: p,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(widget.doc.filePath!)],
        subject: widget.doc.name,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bookmarked =
        ref.watch(bookmarksProvider)[widget.doc.id]?.contains(_page) ?? false;

    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                title: widget.doc.name,
                bookmarked: bookmarked,
                onBack: () => Navigator.of(context).pop(),
                onBookmark: () => ref
                    .read(bookmarksProvider.notifier)
                    .toggle(widget.doc.id, _page),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PdfViewPinch(
                      controller: _controller,
                      onDocumentLoaded: (doc) =>
                          setState(() => _pageCount = doc.pagesCount),
                      onPageChanged: (p) => setState(() => _page = p),
                    ),
                  ),
                ),
              ),
              _BottomBar(
                indicator: _pageCount == 0 ? '—' : 'Page $_page of $_pageCount',
                onSearch: () => _todo('Text search'),
                onThumbnails: _pageCount == 0 ? null : _openThumbnails,
                onShare: _share,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditorScreen(doc: widget.doc)),
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
  const _TopBar({
    required this.title,
    required this.bookmarked,
    required this.onBack,
    required this.onBookmark,
  });
  final String title;
  final bool bookmarked;
  final VoidCallback onBack, onBookmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          _RoundBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(width: 8),
          _RoundBtn(
            icon: bookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            active: bookmarked,
            onTap: onBookmark,
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap, this.active = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
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
        child: Icon(icon,
            size: 18,
            color: active ? AppColors.accent : const Color(0xFF3A3155)),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.indicator,
    required this.onSearch,
    required this.onThumbnails,
    required this.onShare,
    required this.onEdit,
  });
  final String indicator;
  final VoidCallback onSearch, onShare, onEdit;
  final VoidCallback? onThumbnails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xB81E1237),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(indicator,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xC7FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xB3FFFFFF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BarIcon(icon: Icons.search_rounded, onTap: onSearch),
                    _BarIcon(
                        icon: Icons.grid_view_rounded, onTap: onThumbnails),
                    _BarIcon(icon: Icons.ios_share_rounded, onTap: onShare),
                    _BarIcon(icon: Icons.edit_document, onTap: onEdit),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          size: 22,
          color: enabled ? const Color(0xFF6A6280) : const Color(0xFFBEB8CE)),
    );
  }
}

