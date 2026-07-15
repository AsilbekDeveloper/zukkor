import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../models/friend_entry.dart';
import '../widgets/friend_list.dart';

/// Choose a friend to challenge to a 1v1 duel — mirrors the prototype's
/// `view-duel`. Only online friends can be challenged right now.
///
/// Picking a friend opens the Categories screen with that friend as the
/// pending duel opponent — the same category picker Solo uses, per the
/// prototype's `pendingDuelOpponent` flow.
class DuelScreen extends StatelessWidget {
  const DuelScreen({super.key});

  void _goBack(BuildContext context) {
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.duelPick.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Text(context.t.duelPick.chooseYourFriend, style: context.textStyles.titleLarge),
              AppSpacing.sm.vGap,
              Expanded(
                child: SingleChildScrollView(
                  child: FriendList(
                    entries: FriendEntry.sampleOnlineForDuel,
                    onDuelTap: (friend) =>
                        context.push(AppRoutes.categories, extra: friend),
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
