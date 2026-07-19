import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../duel/presentation/controllers/duel_controller.dart';
import '../../../lobby/presentation/widgets/lobby_waiting_indicator.dart';
import '../models/duel_match.dart';
import '../widgets/duel_category_chip.dart';

/// Shown right after picking a friend + category to duel — mirrors the
/// prototype's `view-duel-waiting`: opponent + category recap, a pulsing
/// "waiting" indicator while the real invite is out.
///
/// Sends a real invite over the duel WebSocket on open and waits for
/// [DuelController]'s `outgoingStatus` to resolve: accepted moves both
/// sides into the (still independently-played, not yet synced) quiz;
/// declined/expired shows a message with a way back.
class DuelWaitingScreen extends ConsumerStatefulWidget {
  const DuelWaitingScreen({required this.match, super.key});

  final DuelMatch match;

  @override
  ConsumerState<DuelWaitingScreen> createState() => _DuelWaitingScreenState();
}

class _DuelWaitingScreenState extends ConsumerState<DuelWaitingScreen> {
  @override
  void initState() {
    super.initState();
    final String? opponentId = widget.match.opponent.id;
    if (opponentId != null) {
      // sendInvite() overwrites outgoingStatus/clientInviteId fresh each
      // time, so there's no stale state to clean up on dispose — and
      // mutating provider state from dispose() is unsafe (other widgets
      // depending on it may be unmounting in the same pass).
      Future.microtask(() => ref.read(duelControllerProvider.notifier).sendInvite(
            toUserId: opponentId,
            categoryId: widget.match.category.id,
          ));
    }
  }

  void _cancel(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(duelControllerProvider, (previous, next) {
      if (next.outgoingStatus == OutgoingDuelStatus.accepted) {
        context.pushReplacement(AppRoutes.duelGame);
      }
    });

    final OutgoingDuelStatus status = ref.watch(duelControllerProvider).outgoingStatus;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              CloseHeader(title: context.t.duelWaiting.title, onClose: () => _cancel(context)),
              AppSpacing.xl.vGap,
              Center(
                child: UserAvatar(
                  size: 64,
                  initials: widget.match.opponent.initials,
                  avatarImagePath: widget.match.opponent.avatarImagePath,
                  backgroundColor: widget.match.opponent.avatarColor.resolve(context),
                  fontSize: 20,
                ),
              ),
              AppSpacing.sm.vGap,
              Center(
                child: Text(
                  widget.match.opponent.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
              ),
              AppSpacing.lg.vGap,
              Center(child: DuelCategoryChip(category: widget.match.category)),
              AppSpacing.xl.vGap,
              ..._statusSection(context, status),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _statusSection(BuildContext context, OutgoingDuelStatus status) {
    return switch (status) {
      OutgoingDuelStatus.declined => [
          Center(
            child: Text(
              context.t.duelWaiting.declined,
              style: context.textStyles.bodyMedium?.copyWith(color: context.colors.coralDeep),
            ),
          ),
          AppSpacing.lg.vGap,
          AppButton.secondary(
            label: context.t.duelWaiting.backToHome,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      OutgoingDuelStatus.expired => [
          Center(
            child: Text(
              context.t.duelWaiting.expired,
              style: context.textStyles.bodyMedium?.copyWith(color: context.colors.coralDeep),
            ),
          ),
          AppSpacing.lg.vGap,
          AppButton.secondary(
            label: context.t.duelWaiting.backToHome,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      OutgoingDuelStatus.waiting || OutgoingDuelStatus.idle || OutgoingDuelStatus.accepted => [
          LobbyWaitingIndicator(label: context.t.duelWaiting.waitingForAccept),
        ],
    };
  }
}
