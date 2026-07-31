import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../../domain/entities/leaderboard_scope.dart';

class LeaderboardState {
  const LeaderboardState({
    this.data,
    this.scope = LeaderboardScope.allTime,
    this.isLoadingMore = false,
    this.hasError = false,
  });

  /// `null` means "not loaded yet" (or the initial load failed, see
  /// [hasError]).
  final LeaderboardData? data;

  /// The scope [data] was fetched with (or, before the first load, the
  /// default) — screens that keep their own segment-control selection in
  /// local `State` read this on mount to stay in sync with whatever's
  /// already cached, instead of always defaulting back to "all time".
  final LeaderboardScope scope;

  /// True only while a [LeaderboardController.loadMore] request is in
  /// flight — drives a small loading row at the bottom of the list.
  final bool isLoadingMore;

  /// True only when the initial [LeaderboardController.load] failed (not
  /// a [loadMore] page) — the screen shows a retry affordance instead of
  /// its loading skeleton.
  final bool hasError;

  LeaderboardState copyWith({LeaderboardData? Function()? data, bool? isLoadingMore, bool? hasError}) =>
      LeaderboardState(
        data: data != null ? data() : this.data,
        scope: scope,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasError: hasError ?? this.hasError,
      );
}

/// Ranked list — `GET /leaderboard`, sahifalab (offset asosida) yuklanadi.
/// Boshqa "bir marta yukla" ekranlari (Friends, Categories, Home) bilan
/// bir xil naqsh: birinchi ochilganda [load] chaqiriladi, keyingi
/// tashriflarda `state.data` allaqachon borligi tekshirilib, qayta
/// so'ralmaydi — chaqiruvchi shuni o'zi tekshirishi kerak. Segment
/// almashtirilganda [load] qayta chaqiriladi (natija keshlanmaydi — har
/// bir kesim uchun alohida so'rov).
class LeaderboardController extends Notifier<LeaderboardState> {
  static const int _pageSize = 20;

  @override
  LeaderboardState build() => const LeaderboardState();

  Future<void> load({LeaderboardScope scope = LeaderboardScope.allTime}) async {
    state = LeaderboardState(scope: scope);
    try {
      final data = await ref.read(getLeaderboardUseCaseProvider).call(scope: scope, limit: _pageSize, offset: 0);
      state = LeaderboardState(data: data, scope: scope);
    } catch (_) {
      state = LeaderboardState(scope: scope, hasError: true);
    }
  }

  /// Appends the next page — a no-op if the list hasn't loaded yet,
  /// there's nothing more to fetch, or a fetch is already in flight
  /// (guards against a fast double-scroll firing this twice).
  Future<void> loadMore() async {
    final LeaderboardData? current = state.data;
    if (current == null || !current.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = await ref.read(getLeaderboardUseCaseProvider).call(
            scope: state.scope,
            limit: _pageSize,
            offset: current.entries.length,
          );
      state = state.copyWith(
        data: () => LeaderboardData(
          entries: [...current.entries, ...next.entries],
          me: next.me,
          hasMore: next.hasMore,
        ),
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final NotifierProvider<LeaderboardController, LeaderboardState> leaderboardControllerProvider =
    NotifierProvider<LeaderboardController, LeaderboardState>(LeaderboardController.new);
