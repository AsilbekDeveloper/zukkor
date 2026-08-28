import 'dart:async';

import 'package:flutter/material.dart';
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
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../../friends/presentation/controllers/user_search_controller.dart';
import '../../../friends/presentation/models/discoverable_user.dart';
import '../../../friends/presentation/widgets/discoverable_user_list.dart';
import '../../../friends/presentation/widgets/friends_search_bar.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../../domain/entities/discover_quiz.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/quiz_card.dart';

enum _DiscoverMode { feed, searchQuiz, searchUser }

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const Duration _debounce = Duration(milliseconds: 350);

  _DiscoverMode _mode = _DiscoverMode.feed;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<DiscoverQuiz>? _feed;
  List<DiscoverQuiz>? _searchResults;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFeed);
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
      final quizzes = await ref.read(aiQuizControllerProvider.notifier).discover();
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
      if (_mode == _DiscoverMode.searchUser) {
        ref.read(userSearchControllerProvider.notifier).clear();
      } else {
        setState(() => _searchResults = null);
      }
      return;
    }

    _debounceTimer = Timer(_debounce, () {
      if (_mode == _DiscoverMode.searchQuiz) {
        _searchQuizzes(value);
      } else if (_mode == _DiscoverMode.searchUser) {
        ref.read(userSearchControllerProvider.notifier).search(value);
      }
    });
  }

  Future<void> _searchQuizzes(String query) async {
    setState(() => _searchResults = null);
    try {
      final results = await ref.read(aiQuizControllerProvider.notifier).searchDiscover(query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (_) {
      // Search errors are handled gracefully by showing "no results"
      // or similar, rather than a full retry screen.
      if (mounted) setState(() => _searchResults = []);
    }
  }

  void _toggleSearchQuiz() {
    setState(() {
      if (_mode == _DiscoverMode.searchQuiz) {
        _mode = _DiscoverMode.feed;
        _searchController.clear();
        _searchResults = null;
      } else {
        _mode = _DiscoverMode.searchQuiz;
        _searchController.clear();
      }
    });
  }

  void _toggleSearchUser() {
    setState(() {
      if (_mode == _DiscoverMode.searchUser) {
        _mode = _DiscoverMode.feed;
        _searchController.clear();
        ref.read(userSearchControllerProvider.notifier).clear();
      } else {
        _mode = _DiscoverMode.searchUser;
        _searchController.clear();
      }
    });
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
      extra: QuizLaunchArgs(category: category, questionCount: quiz.questionCount),
    );
  }

  void _openUserQuizzes(DiscoverableUser user) {
    context.push(
      AppRoutes.userQuizzes,
      extra: (
        userId: user.id,
        displayName: user.name,
        onCategoryPicked: null, // use default behavior (quizIntro)
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: _buildHeader(),
            ),
            AppSpacing.lg.vGap,
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_mode == _DiscoverMode.searchQuiz || _mode == _DiscoverMode.searchUser) {
      return Row(
        children: [
          IconButton(
            onPressed: () => setState(() {
              _mode = _DiscoverMode.feed;
              _searchController.clear();
              _searchResults = null;
              ref.read(userSearchControllerProvider.notifier).clear();
            }),
            icon: const Icon(TablerIcons.arrowLeft),
          ),
          Expanded(
            child: FriendsSearchBar(
              placeholder: _mode == _DiscoverMode.searchQuiz
                  ? context.t.discover.searchQuizHint
                  : context.t.discover.searchUserHint,
              controller: _searchController,
              onChanged: _onQueryChanged,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(TablerIcons.arrowLeft),
        ),
        Expanded(
          child: Text(
            context.t.discover.title,
            style: context.textStyles.titleLarge,
          ),
        ),
        IconButton(
          onPressed: _toggleSearchUser,
          icon: const Icon(TablerIcons.userSearch),
          tooltip: context.t.discover.userFilter,
        ),
        IconButton(
          onPressed: _toggleSearchQuiz,
          icon: const Icon(TablerIcons.search),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_mode == _DiscoverMode.searchUser) {
      final results = ref.watch(userSearchControllerProvider);
      if (results == null && _searchController.text.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: const ShimmerListSkeleton(count: 4, trailingWidth: 70),
        );
      }
      final users = (results ?? []).map(DiscoverableUser.fromEntity).toList();
      if (users.isEmpty && _searchController.text.isNotEmpty) {
        return Center(child: Text(context.t.discover.noResults));
      }
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
        child: DiscoverableUserList(
          users: users,
          addedIds: const {}, // we don't care about friendship status here
          onAddTap: (_) {}, // we don't show the add button here ideally, but for now it's okay
          onRowTap: _openUserQuizzes,
        ),
      );
    }

    final quizzes = _mode == _DiscoverMode.feed ? _feed : _searchResults;

    if (_hasError && _mode == _DiscoverMode.feed) {
      return ErrorRetryView(onRetry: _loadFeed);
    }

    if (quizzes == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
        child: const ShimmerListSkeleton(count: 5, trailingWidth: 40),
      );
    }

    if (quizzes.isEmpty) {
      return Center(
        child: Text(
          _mode == _DiscoverMode.feed ? context.t.discover.emptyFeed : context.t.discover.noResults,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(context.screenHPad, 0, context.screenHPad, AppSpacing.lg),
        itemCount: quizzes.length,
        separatorBuilder: (_, __) => AppSpacing.xs.vGap,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return QuizCard(
            name: quiz.name,
            questionCount: quiz.questionCount,
            creatorName: context.t.discover.byCreator(name: quiz.ownerUsername ?? 'user'),
            onTap: () => _pick(quiz),
          );
        },
      ),
    );
  }
}
