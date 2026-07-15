import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../models/friend_entry.dart';
import '../widgets/duel_category_chip.dart';

/// An incoming duel challenge — mirrors the prototype's `view-duel-invite`
/// (reached by tapping the "Malika challenged you to a duel" notification).
///
/// CURRENT STATE: presentation only, a single fixed demo invite (matches
/// the prototype: Malika Yusupova, History) — there's no real invite
/// backend/push notification yet. Accepting jumps straight into the quiz
/// intro countdown; declining returns to Notifications.
class DuelInviteScreen extends StatelessWidget {
  const DuelInviteScreen({super.key});

  static final FriendEntry _opponent = FriendEntry.sampleAll.first;
  static final QuizCategory _category = QuizCategory.sample[1]; // History

  void _decline(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.notifications);
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
              CloseHeader(title: context.t.duelInvite.title, onClose: () => _decline(context)),
              AppSpacing.xl.vGap,
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _opponent.avatarColor.resolve(context),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _opponent.initials,
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
                  _opponent.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  context.t.duelInvite.challengesYou,
                  style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                ),
              ),
              AppSpacing.lg.vGap,
              Center(child: DuelCategoryChip(category: _category)),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.duelInvite.accept,
                icon: const Icon(TablerIcons.check, color: Colors.white, size: 18),
                onPressed: () => context.push(AppRoutes.quizIntro, extra: _category),
              ),
              Center(
                child: TextButton(
                  onPressed: () => _decline(context),
                  child: Text(context.t.duelInvite.decline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
