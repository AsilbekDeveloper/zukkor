import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../friends/presentation/models/duel_match.dart';
import '../../../friends/presentation/models/friend_entry.dart';
import '../../../lobby/presentation/controllers/lobby_controller.dart';
import '../controllers/categories_controller.dart';
import '../models/quiz_category.dart';
import '../widgets/category_grid_view.dart';

/// Full category list — mirrors the prototype's `view-categories`:
/// a back button + centered title header, then the same grid shown on
/// Home's "Categories" section (here, the complete list). Categories are
/// fetched from `GET /categories` on open.
///
/// Doubles as the category picker for a pending duel: when reached from
/// the Duel (choose a friend) screen with [duelOpponent] set, tapping a
/// category opens Duel Waiting for that friend+category instead of the
/// solo question-count picker — mirrors the prototype's
/// `pendingDuelOpponent` flow (Duel and Solo share this same
/// category-picker screen, both real backend categories).
///
/// Also doubles as the category picker for starting a Lobby room's game:
/// when reached with [lobbyRoomId] set, tapping a category sends
/// `lobby_start` for that room and pops back to [LobbyScreen], which
/// navigates everyone into [LobbyGameScreen] once `lobby_game_started`
/// arrives.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({this.duelOpponent, this.lobbyRoomId, super.key});

  final FriendEntry? duelOpponent;
  final String? lobbyRoomId;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoriesControllerProvider.notifier).load());
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _onCategoryTap(BuildContext context, QuizCategory category) {
    if (widget.duelOpponent != null) {
      context.push(
        AppRoutes.duelWaiting,
        extra: DuelMatch(opponent: widget.duelOpponent!, category: category),
      );
    } else if (widget.lobbyRoomId != null) {
      ref.read(lobbyControllerProvider.notifier).startGame(category.id);
      context.pop();
    } else {
      context.push(AppRoutes.quizSetup, extra: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<QuizCategory>? categories = ref
        .watch(categoriesControllerProvider)
        ?.map(QuizCategory.fromEntity)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.categories.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Expanded(
                child: categories == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: CategoryGridView(
                          categories: categories,
                          onCategoryTap: (category) => _onCategoryTap(context, category),
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
