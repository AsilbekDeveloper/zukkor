import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../duel/domain/entities/duel_invite.dart';
import '../../../duel/presentation/controllers/duel_controller.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../widgets/duel_category_chip.dart';

/// An incoming duel challenge — mirrors the prototype's `view-duel-invite`.
/// Reached only via [DuelController]'s live `incomingInvite` (Home
/// pushes this when a real `duel_invite_received` event arrives), so
/// [invite] is always real data, not a fixture.
class DuelInviteScreen extends ConsumerWidget {
  const DuelInviteScreen({required this.invite, super.key});

  final DuelInvite invite;

  void _decline(BuildContext context, WidgetRef ref) {
    ref.read(duelControllerProvider.notifier).respondToInvite(inviteId: invite.id, accept: false);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _accept(BuildContext context, WidgetRef ref) {
    ref.read(duelControllerProvider.notifier).respondToInvite(inviteId: invite.id, accept: true);
    context.pushReplacement(AppRoutes.duelGame);
  }

  static String _displayName(DuelInvite invite) {
    final String name = [invite.fromUser.firstName, invite.fromUser.lastName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');
    if (name.isNotEmpty) return name;
    if (invite.fromUser.username != null && invite.fromUser.username!.isNotEmpty) {
      return invite.fromUser.username!;
    }
    return t.leaderboard.anonymousPlayer;
  }

  static String _initials(DuelInvite invite) {
    final String first =
        (invite.fromUser.firstName?.isNotEmpty ?? false) ? invite.fromUser.firstName![0] : '';
    final String last = (invite.fromUser.lastName?.isNotEmpty ?? false) ? invite.fromUser.lastName![0] : '';
    final String combined = '$first$last'.toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AvatarColorOption avatarColor = AvatarColorOption.fromApiValue(invite.fromUser.avatarColor);
    final QuizCategory category = QuizCategory.fromEntity(invite.category);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              CloseHeader(title: context.t.duelInvite.title, onClose: () => _decline(context, ref)),
              AppSpacing.xl.vGap,
              Center(
                child: UserAvatar(
                  size: 64,
                  initials: _initials(invite),
                  avatarImagePath: invite.fromUser.avatarImagePath,
                  backgroundColor: avatarColor.resolve(context),
                  fontSize: 20,
                ),
              ),
              AppSpacing.sm.vGap,
              Center(
                child: Text(
                  _displayName(invite),
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
              Center(child: DuelCategoryChip(category: category)),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.duelInvite.accept,
                icon: const Icon(TablerIcons.check, color: Colors.white, size: 18),
                onPressed: () => _accept(context, ref),
              ),
              Center(
                child: TextButton(
                  onPressed: () => _decline(context, ref),
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
