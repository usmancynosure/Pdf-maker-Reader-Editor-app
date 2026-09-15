import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Per-document page bookmarks, keyed by document id. In-memory for now;
/// Phase 7 can persist these via shared_preferences.
class BookmarksNotifier extends Notifier<Map<String, Set<int>>> {
  @override
  Map<String, Set<int>> build() => {};

  void toggle(String docId, int page) {
    final next = {...state};
    final pages = {...(next[docId] ?? const <int>{})};
    if (!pages.remove(page)) pages.add(page);
    next[docId] = pages;
    state = next;
  }

  bool isBookmarked(String docId, int page) =>
      state[docId]?.contains(page) ?? false;
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, Map<String, Set<int>>>(
        BookmarksNotifier.new);
