import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../lobby/presentation/widgets/lobby_waiting_indicator.dart';
import '../models/duel_match.dart';
import '../widgets/duel_category_chip.dart';

/// Shown right after picking a friend + category to duel — mirrors the
/// prototype's `view-duel-waiting`: opponent + category recap, a pulsing
/// "waiting for their answer" indicator, and a demo "Start" button.
///
/// CURRENT STATE: presentation only — there's no real matchmaking/opponent
/// -ready signal yet, so "Start (demo)" just jumps straight into the quiz
/// intro countdown, matching the prototype's `duel-start-btn` demo hook.
class DuelWaitingScreen extends StatelessWidget {
  const DuelWaitingScreen({required this.match, super.key});

  final DuelMatch match;

  void _cancel(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              CloseHeader(title: AppStrings.duelWaitingTitle, onClose: () => _cancel(context)),
              AppSpacing.xl.vGap,
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: match.opponent.avatarColor.resolve(context),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    match.opponent.initials,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              AppSpacing.sm.vGap,
              Center(
                child: Text(
                  match.opponent.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
              ),
              AppSpacing.lg.vGap,
              Center(child: DuelCategoryChip(category: match.category)),
              AppSpacing.xl.vGap,
              const LobbyWaitingIndicator(label: AppStrings.waitingForAnswerLabel),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: AppStrings.startDemoButton,
                icon: const Icon(TablerIcons.playerPlay, color: Colors.white, size: 18),
                onPressed: () => context.push(AppRoutes.quizIntro, extra: match.category),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
