import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../../friends/domain/entities/discovered_user.dart';
import '../../../friends/presentation/controllers/send_friend_request_controller.dart';
import '../../../friends/presentation/controllers/user_search_controller.dart';
import '../../../friends/presentation/models/discoverable_user.dart';
import '../../../friends/presentation/widgets/discoverable_user_list.dart';
import '../../../friends/presentation/widgets/friends_search_bar.dart';
import '../../../quiz/domain/entities/category.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../../domain/entities/discover_quiz.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/quiz_card.dart';

enum _DiscoverMode { feed, search }

/// What the shared search bar searches - quizzes (the screen's original
/// purpose) or people (2026-09-12, reuses Friends/Add Friend's own
/// search rather than a second implementation).
enum _SearchTarget { quizzes, people }

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const Duration _debounce = Duration(milliseconds: 350);

  _DiscoverMode _mode = _DiscoverMode.feed;
  _SearchTarget _searchTarget = _SearchTarget.quizzes;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  int? _selectedCategoryId;
  List<DiscoverQuiz>? _feed;
  List<DiscoverQuiz>? _searchResults;
  bool _hasError = false;
  bool _searchHasError = false;

  final Set<String> _addedIds = {};

  /// So'rov hali javob kutayotgan foydalanuvchilar — tugma shu vaqtda
  /// o'chirilgan turadi (qo'sh so'rov yuborilmasligi uchun).
  final Set<String> _sendingIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadFeed();
      ref.read(categoriesControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _hasError = false;
      _feed = null;
    });
    try {
      final quizzes = await ref
          .read(aiQuizControllerProvider.notifier)
          .discover(categoryId: _selectedCategoryId);
      if (!mounted) return;
      setState(() => _feed = quizzes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    if (value.isEmpty) {
      setState(() {
        _mode = _DiscoverMode.feed;
        _searchResults = null;
        _searchHasError = false;
      });
      ref.read(userSearchControllerProvider.notifier).clear();
      if (_searchTarget == _SearchTarget.quizzes) _loadFeed();
      return;
    }

    _debounceTimer = Timer(_debounce, () {
      if (_searchTarget == _SearchTarget.quizzes) {
        setState(() => _mode = _DiscoverMode.search);
        _searchQuizzes(value);
      } else {
        ref.read(userSearchControllerProvider.notifier).search(value);
      }
    });
  }

  /// Switching mode re-runs the SAME text the user already typed against
  /// whichever search it now targets - feels continuous instead of
  /// forcing them to retype to see the other kind of result.
  void _onSearchTargetChanged(_SearchTarget target) {
    if (_searchTarget == target) return;
    setState(() => _searchTarget = target);
    final String query = _searchController.text;
    if (query.isEmpty) return;
    if (target == _SearchTarget.quizzes) {
      setState(() => _mode = _DiscoverMode.search);
      _searchQuizzes(query);
    } else {
      ref.read(userSearchControllerProvider.notifier).search(query);
    }
  }

  void _openDiscoveredDetail(DiscoverableUser user) {
    context.push(
      AppRoutes.playerDetail,
      extra: {
        'userId': user.id,
        if (user.requestPending || _addedIds.contains(user.id))
          'requestSent': true,
      },
    );
  }

  Future<void> _addFriend(DiscoverableUser user) async {
    if (_sendingIds.contains(user.id)) return;
    setState(() => _sendingIds.add(user.id));
    try {
      await ref
          .read(sendFriendRequestControllerProvider.notifier)
          .sendRequest(user.id);
      if (!mounted) return;
      setState(() => _addedIds.add(user.id));
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _sendingIds.remove(user.id));
    }
  }

  Future<void> _searchQuizzes(String query) async {
    setState(() {
      _searchResults = null;
      _searchHasError = false;
    });
    try {
      final results = await ref
          .read(aiQuizControllerProvider.notifier)
          .searchDiscover(query, categoryId: _selectedCategoryId);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (_) {
      // Avval bu ham "natija yo'q" bilan bir xil holatga tushirilardi —
      // foydalanuvchi buni "mos quiz topilmadi" deb tushunardi, aslida
      // so'rovning o'zi muvaffaqiyatsiz bo'lgan, qayta urinish imkoni
      // ham yo'q edi. Endi alohida xato holati.
      if (mounted) setState(() => _searchHasError = true);
    }
  }

  void _retrySearch() {
    if (_searchController.text.isNotEmpty) {
      _searchQuizzes(_searchController.text);
    }
  }

  void _selectCategory(int? id) {
    if (_selectedCategoryId == id) return;
    setState(() => _selectedCategoryId = id);
    if (_mode == _DiscoverMode.search && _searchController.text.isNotEmpty) {
      _searchQuizzes(_searchController.text);
    } else {
      _loadFeed();
    }
  }

  void _pick(DiscoverQuiz quiz) {
    final QuizCategory category = QuizCategory(
      id: quiz.id,
      name: quiz.name,
      questionCount: quiz.questionCount,
      icon: TablerIcons.sparkle,
      colorKey: CategoryColorKey.coral,
    );
    context.push(
      AppRoutes.quizIntro,
      extra: QuizLaunchArgs(
        category: category,
        questionCount: quiz.questionCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.xs.vGap,
            FadeSlideIn(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: _buildHeader(),
              ),
            ),
            AppSpacing.md.vGap,
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: PillSegmentControl<_SearchTarget>(
                  values: _SearchTarget.values,
                  selected: _searchTarget,
                  labelBuilder: (target) => switch (target) {
                    _SearchTarget.quizzes => context.t.discover.modeQuizzes,
                    _SearchTarget.people => context.t.discover.modePeople,
                  },
                  onChanged: _onSearchTargetChanged,
                ),
              ),
            ),
            if (_searchTarget == _SearchTarget.quizzes) ...[
              AppSpacing.md.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: _CategoryFilterRow(
                  selectedId: _selectedCategoryId,
                  onSelected: _selectCategory,
                ),
              ),
            ],
            AppSpacing.lg.vGap,
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        PressableScale(
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            icon: const Icon(TablerIcons.arrowLeft),
          ),
        ),
        Expanded(
          child: FriendsSearchBar(
            placeholder: _searchTarget == _SearchTarget.quizzes
                ? context.t.discover.searchQuizHint
                : context.t.discover.searchUserHint,
            controller: _searchController,
            onChanged: _onQueryChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_searchTarget == _SearchTarget.people) return _buildPeopleBody();

    final quizzes = _mode == _DiscoverMode.feed ? _feed : _searchResults;

    if (_mode == _DiscoverMode.feed && _hasError) {
      return ErrorRetryView(onRetry: _loadFeed);
    }
    if (_mode == _DiscoverMode.search && _searchHasError) {
      return ErrorRetryView(onRetry: _retrySearch);
    }

    if (quizzes == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
        child: const ShimmerQuizGridSkeleton(),
      );
    }

    if (quizzes.isEmpty) {
      return Center(
        child: Text(
          _mode == _DiscoverMode.feed
              ? context.t.discover.emptyFeed
              : context.t.discover.noResults,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          context.screenHPad,
          0,
          context.screenHPad,
          AppSpacing.lg,
        ),
        // Column count derives from the container's own width (2 on
        // phones, more on tablets) - never a hardcoded crossAxisCount.
        // Height is fixed content-driven extent (QuizCard.gridExtent),
        // never a childAspectRatio - see [[responsive_methodology]].
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisExtent: QuizCard.gridExtent(context),
        ),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return QuizCard(
            name: quiz.name,
            questionCount: quiz.questionCount,
            creatorName: context.t.discover.byCreator(
              name: quiz.ownerUsername ?? 'user',
            ),
            topicName: quiz.topicCategoryName,
            onTap: () => _pick(quiz),
          );
        },
      ),
    );
  }

  /// People mode intentionally has no browsable "everyone" feed (unlike
  /// quizzes) - only a search, matching the earlier product decision to
  /// not offer an open user-browsing surface anywhere in the app.
  Widget _buildPeopleBody() {
    // Watched unconditionally (even while the query is still empty) - if
    // this were only reached AFTER the empty-query check below, the
    // subscription would never be established while the prompt shows,
    // and the eventual search result arriving later would have nothing
    // listening to trigger a rebuild.
    final List<DiscoveredUser>? results = ref.watch(
      userSearchControllerProvider,
    );

    if (_searchController.text.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Text(
            context.t.discover.peopleSearchPrompt,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
      );
    }

    if (results == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
        child: const ShimmerListSkeleton(count: 5, trailingWidth: 70),
      );
    }

    final List<DiscoverableUser> discovered = results
        .map(DiscoverableUser.fromEntity)
        .toList();
    if (discovered.isEmpty) {
      return Center(
        child: Text(
          context.t.addFriend.noUsersFound,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.screenHPad,
        0,
        context.screenHPad,
        AppSpacing.lg,
      ),
      child: DiscoverableUserList(
        users: discovered,
        addedIds: _addedIds,
        sendingIds: _sendingIds,
        onAddTap: _addFriend,
        onRowTap: _openDiscoveredDetail,
      ),
    );
  }
}

class _CategoryFilterRow extends ConsumerWidget {
  const _CategoryFilterRow({
    required this.selectedId,
    required this.onSelected,
  });

  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesControllerProvider);
    final List<Category>? categories = categoriesState.data;

    if (categories == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
      child: Row(
        children: [
          _FilterChip(
            label: context.t.discover.categoryAll,
            isSelected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          AppSpacing.sm.hGap,
          for (final cat in categories) ...[
            _FilterChip(
              label: cat.name,
              icon: QuizCategory.fromEntity(cat).icon,
              isSelected: cat.id == selectedId,
              onTap: () => onSelected(cat.id),
              activeColor: QuizCategory.fromEntity(cat).color(context),
            ),
            if (cat != categories.last) AppSpacing.sm.hGap,
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.activeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final Color color = activeColor ?? context.colors.coral;

    return PressableScale(
      child: Material(
        color: isSelected ? color : context.colors.card,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.smAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: isSelected ? color : context.colors.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  AppSpacing.xs.hGap,
                ],
                Text(
                  label,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : context.colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
