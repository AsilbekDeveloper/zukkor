import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../domain/entities/category_leaderboard_data.dart';
import '../../domain/entities/leaderboard_scope.dart';

class CategoryLeaderboardState {
  const CategoryLeaderboardState({
    this.data,
    this.scope = LeaderboardScope.allTime,
    this.isLoadingMore = false,
    this.hasError = false,
  });

  final CategoryLeaderboardData? data;
  final LeaderboardScope scope;
  final bool isLoadingMore;
  final bool hasError;

  CategoryLeaderboardState copyWith({
    CategoryLeaderboardData? Function()? data,
    bool? isLoadingMore,
    bool? hasError,
  }) => CategoryLeaderboardState(
    data: data != null ? data() : this.data,
    scope: scope,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasError: hasError ?? this.hasError,
  );
}

/// `GET /leaderboard/category/{id}` — [LeaderboardController] bilan bir
/// xil naqsh (sahifalab yuklash, segment almashtirilganda qayta so'rov),
/// faqat bitta qo'shimcha parametr bilan: qaysi kategoriya. Ekran har
/// ochilganda shu kategoriya uchun [load] chaqiriladi — natija
/// keshlanmaydi, chunki foydalanuvchi turli kategoriyalar orasida
/// almashishi mumkin.
class CategoryLeaderboardController extends Notifier<CategoryLeaderboardState> {
  static const int _pageSize = 20;

  @override
  CategoryLeaderboardState build() => const CategoryLeaderboardState();

  Future<void> load({
    required int categoryId,
    LeaderboardScope scope = LeaderboardScope.allTime,
  }) async {
    state = CategoryLeaderboardState(scope: scope);
    try {
      final data = await ref
          .read(getCategoryLeaderboardUseCaseProvider)
          .call(categoryId: categoryId, scope: scope, limit: _pageSize, offset: 0);
      state = CategoryLeaderboardState(data: data, scope: scope);
    } catch (_) {
      state = CategoryLeaderboardState(scope: scope, hasError: true);
    }
  }

  Future<void> loadMore() async {
    final CategoryLeaderboardData? current = state.data;
    if (current == null || !current.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = await ref
          .read(getCategoryLeaderboardUseCaseProvider)
          .call(
            categoryId: current.categoryId,
            scope: state.scope,
            limit: _pageSize,
            offset: current.entries.length,
          );
      state = state.copyWith(
        data: () => CategoryLeaderboardData(
          categoryId: current.categoryId,
          categoryName: current.categoryName,
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

final NotifierProvider<CategoryLeaderboardController, CategoryLeaderboardState>
categoryLeaderboardControllerProvider =
    NotifierProvider<CategoryLeaderboardController, CategoryLeaderboardState>(
      CategoryLeaderboardController.new,
    );
