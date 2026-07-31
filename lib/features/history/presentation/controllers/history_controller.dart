import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/session_history_entry.dart';

class HistoryState {
  const HistoryState({this.entries, this.hasMore = true, this.isLoadingMore = false, this.hasError = false});

  /// `null` means "not loaded yet" (or the initial load failed, see
  /// [hasError]).
  final List<SessionHistoryEntry>? entries;

  /// Whether another page exists past the currently loaded [entries].
  final bool hasMore;

  /// True only while a [HistoryController.loadMore] request is in
  /// flight — drives a small loading row at the bottom of the list.
  final bool isLoadingMore;

  /// True only when the initial [HistoryController.load] failed (not a
  /// [loadMore] page) — the screen shows a retry affordance instead of
  /// its loading skeleton.
  final bool hasError;

  HistoryState copyWith({
    List<SessionHistoryEntry>? Function()? entries,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasError,
  }) =>
      HistoryState(
        entries: entries != null ? entries() : this.entries,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasError: hasError ?? this.hasError,
      );
}

/// O'tgan solo/duel/lobby seanslari — `GET /history`, sahifalab (offset
/// asosida) yuklanadi. Ekran ochilganda [load] chaqirilishi kerak
/// (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa `state.entries`
/// eskicha (yoki `null`) qoladi.
class HistoryController extends Notifier<HistoryState> {
  static const int _pageSize = 20;

  @override
  HistoryState build() => const HistoryState();

  Future<void> load() async {
    state = const HistoryState();
    try {
      final page = await ref.read(getHistoryUseCaseProvider).call(limit: _pageSize, offset: 0);
      state = HistoryState(entries: page.entries, hasMore: page.hasMore);
    } catch (_) {
      state = const HistoryState(hasError: true);
    }
  }

  /// Appends the next page — a no-op if the list hasn't loaded yet,
  /// there's nothing more to fetch, or a fetch is already in flight
  /// (guards against a fast double-scroll firing this twice).
  Future<void> loadMore() async {
    final List<SessionHistoryEntry>? current = state.entries;
    if (current == null || !state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await ref.read(getHistoryUseCaseProvider).call(limit: _pageSize, offset: current.length);
      state = state.copyWith(
        entries: () => [...current, ...page.entries],
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final NotifierProvider<HistoryController, HistoryState> historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);
