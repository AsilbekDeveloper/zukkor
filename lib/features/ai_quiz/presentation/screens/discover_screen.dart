import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../../friends/presentation/widgets/friends_search_bar.dart';
import '../../../quiz/domain/entities/category.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../../domain/entities/discover_quiz.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/quiz_card.dart';

enum _DiscoverMode { feed, search }

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

  int? _selectedCategoryId;
  List<DiscoverQuiz>? _feed;
  List<DiscoverQuiz>? _searchResults;
  bool _hasError = false;

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
      final quizzes = await ref.read(aiQuizControllerProvider.notifier).discover(
            categoryId: _selectedCategoryId,
          );
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
      });
      _loadFeed();
      return;
    }

    _debounceTimer = Timer(_debounce, () {
      setState(() => _mode = _DiscoverMode.search);
      _searchQuizzes(value);
    });
  }

  Future<void> _searchQuizzes(String query) async {
    setState(() => _searchResults = null);
    try {
      final results = await ref.read(aiQuizControllerProvider.notifier).searchDiscover(
            query,
            categoryId: _selectedCategoryId,
          );
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
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
      extra: QuizLaunchArgs(category: category, questionCount: quiz.questionCount),
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
            AppSpacing.md.vGap,
            _CategoryFilterRow(
              selectedId: _selectedCategoryId,
              onSelected: _selectCategory,
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
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(TablerIcons.arrowLeft),
        ),
        Expanded(
          child: FriendsSearchBar(
            placeholder: context.t.discover.searchQuizHint,
            controller: _searchController,
            onChanged: _onQueryChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
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
        separatorBuilder: (_, _) => AppSpacing.xs.vGap,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return QuizCard(
            name: quiz.name,
            questionCount: quiz.questionCount,
            creatorName: context.t.discover.byCreator(name: quiz.ownerUsername ?? 'user'),
            topicName: quiz.topicCategoryName,
            onTap: () => _pick(quiz),
          );
        },
      ),
    );
  }
}

class _CategoryFilterRow extends ConsumerWidget {
  const _CategoryFilterRow({required this.selectedId, required this.onSelected});

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

    return Material(
      color: isSelected ? color : context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: isSelected ? color : context.colors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: isSelected ? Colors.white : color),
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
    );
  }
}
