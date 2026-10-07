import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/category_leaderboard_data.dart';
import '../../domain/entities/leaderboard_scope.dart';
import '../controllers/category_leaderboard_controller.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/leaderboard_segment_control.dart';
import '../widgets/rank_list.dart';

/// Bitta kategoriyadagi reyting — [LeaderboardScreen]dagi umumiy (lifetime
/// XP) reytingdan farqli, faqat shu kategoriyada to'plangan XP bo'yicha
/// saralaydi. `GET /leaderboard/category/{id}` orqali ishlaydi (2026-10-07,
/// foydalanuvchi so'rovi). Har safar ochilganda qayta so'raladi (boshqa
/// kategoriya tanlanishi mumkin, natija keshlanmaydi) — [FullLeaderboardScreen]
/// kabi bitta umumiy controller emas, maxsus [categoryLeaderboardControllerProvider].
class CategoryLeaderboardScreen extends ConsumerStatefulWidget {
  const CategoryLeaderboardScreen({
    required this.categoryId,
    required this.categoryName,
    super.key,
  });

  final int categoryId;
  final String categoryName;

  @override
  ConsumerState<CategoryLeaderboardScreen> createState() =>
      _CategoryLeaderboardScreenState();
}

class _CategoryLeaderboardScreenState
    extends ConsumerState<CategoryLeaderboardScreen> {
  final ScrollController _scrollController = ScrollController();
  LeaderboardScope _scope = LeaderboardScope.allTime;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _load() => ref
      .read(categoryLeaderboardControllerProvider.notifier)
      .load(categoryId: widget.categoryId, scope: _scope);

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    ref.read(categoryLeaderboardControllerProvider.notifier).loadMore();
  }

  void _onScopeChanged(LeaderboardScope scope) {
    setState(() => _scope = scope);
    _load();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.leaderboard);
    }
  }

  void _openPlayerDetail(BuildContext context, LeaderboardEntry entry) {
    if (entry.isCurrentUser || entry.id == null) return;
    context.push(AppRoutes.playerDetail, extra: {'userId': entry.id!});
  }

  @override
  Widget build(BuildContext context) {
    final CategoryLeaderboardState state = ref.watch(
      categoryLeaderboardControllerProvider,
    );
    final CategoryLeaderboardData? data = state.data;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(
                  title: widget.categoryName,
                  onBack: () => _goBack(context),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: LeaderboardSegmentControl(
                  selected: _scope,
                  onChanged: _onScopeChanged,
                ),
              ),
              AppSpacing.lg.vGap,
              if (state.hasError)
                Expanded(child: ErrorRetryView(onRetry: _load))
              else if (data == null)
                const Expanded(child: ShimmerListSkeleton())
              else if (data.entries.isEmpty && data.me == null)
                Expanded(
                  child: Center(
                    child: Text(
                      context.t.categoryLeaderboard.emptyState,
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: RankList(
                            entries: data.rankedWithMe,
                            onEntryTap: (entry) =>
                                _openPlayerDetail(context, entry),
                          ),
                        ),
                        if (state.isLoadingMore) ...[
                          AppSpacing.md.vGap,
                          const Center(
                            child: SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                          AppSpacing.md.vGap,
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
