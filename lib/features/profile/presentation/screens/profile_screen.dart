import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/currency_chip.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/inline_retry_row.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../../leaderboard/domain/entities/player_stats.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../widgets/profile_banner.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_name_block.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/settings_list.dart';
import '../widgets/submit_question_card.dart';

/// The Profile tab — mirrors the prototype's `view-profile`: header +
/// settings shortcut, coral banner with an overlapping avatar, name
/// block, level ring card, a 3-stat strip, and a settings shortcut list.
///
/// Name/username/avatar initials come from the real backend user
/// (`GET /auth/me`, fetched on open). Level/XP/game stats are real too,
/// from `GET /leaderboard/{my_user_id}` via [MyStatsController] (shared
/// with [HomeScreen]).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Loaded once per session, not on every visit — [EditProfileScreen]
    // already reloads [currentUserControllerProvider] directly after a
    // successful save, and finishing a game invalidates
    // [myStatsControllerProvider]. If the one-time load here never
    // finished or failed (e.g. a network hiccup on this device's first
    // Profile visit), retry both together; on failure again,
    // [_progressSection] shows an [InlineRetryRow] in place of just the
    // stats row - previously a failed load here left the screen silently
    // stuck showing 0/0 stats with no way to recover.
    if (ref.read(currentUserControllerProvider).data == null ||
        ref.read(myStatsControllerProvider).data == null) {
      Future.microtask(_reloadEssentialData);
    }
  }

  /// Current user + my stats, reloaded together - used both for the
  /// initial load (if it never finished or failed) and for pull-to-
  /// refresh / the error-state retry button.
  Future<void> _reloadEssentialData() async {
    await ref.read(currentUserControllerProvider.notifier).load();
    final String? userId = ref.read(currentUserControllerProvider).data?.id;
    if (userId != null) {
      await ref.read(myStatsControllerProvider.notifier).load(userId);
    }
  }

  /// Stats row (games/win-rate/streak). Shows an [InlineRetryRow] instead
  /// of silently falling back to 0/0 when the load failed - the rest of
  /// the screen (header, banner, settings list) stays fully usable either
  /// way.
  List<Widget> _progressSection(BuildContext context) {
    final myStatsState = ref.watch(myStatsControllerProvider);
    final PlayerStats? stats = myStatsState.data;
    if (myStatsState.hasError) {
      return [InlineRetryRow(onRetry: _reloadMyStats)];
    }
    return [
      ProfileStatsRow(
        totalGames: stats?.gamesPlayed ?? 0,
        winRatePercent: stats?.winRatePercent ?? 0,
        longestStreak: stats?.longestStreak ?? 0,
      ),
    ];
  }

  Future<void> _reloadMyStats() async {
    final String? userId = ref.read(currentUserControllerProvider).data?.id;
    if (userId != null) {
      await ref.read(myStatsControllerProvider.notifier).load(userId);
    }
  }

  /// Settings shortcuts.
  Widget _settingsSection(BuildContext context) {
    return SettingsList(
      rows: [
        SettingsRowData(
          icon: TablerIcons.history,
          label: context.t.profile.gameHistory,
          onTap: () => context.push(AppRoutes.history),
        ),
        SettingsRowData(
          icon: TablerIcons.sparkle,
          label: context.t.aiQuiz.myQuizzesTitle,
          onTap: () => context.push(AppRoutes.myAiQuizzes),
        ),
        SettingsRowData(
          icon: TablerIcons.settings,
          label: context.t.profile.settingsAndHelp,
          onTap: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  /// Coin/Diamond balansi - Home'dagi bilan bir xil chip (`CurrencyChip`,
  /// 2026-09-06 umumiy widgetga chiqarilgan) - foydalanuvchi so'rovi bilan
  /// Profilga ham qo'shildi (avval faqat Home'da ko'rinardi).
  Widget _walletRow(BuildContext context, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CurrencyChip(
          icon: TablerIcons.coinFilled,
          color: context.colors.terra,
          value: user?.coinBalance ?? 0,
          onTap: () => context.push(AppRoutes.wallet),
        ),
        AppSpacing.xs.hGap,
        CurrencyChip(
          icon: TablerIcons.diamondFilled,
          color: context.colors.teal,
          value: user?.diamondBalance ?? 0,
          onTap: () => context.push(AppRoutes.wallet),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final User? user = ref.watch(currentUserControllerProvider).data;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _reloadEssentialData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              hPad,
              AppSpacing.xs,
              hPad,
              AppSpacing.lg,
            ),
            children: [
              FadeSlideIn(
                child: ProfileHeader(
                  onSettingsTap: () => context.push(AppRoutes.settings),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: ProfileBanner(
                  initials: user.initials,
                  avatarColor: AvatarColorOption.fromApiValue(
                    user?.avatarColor,
                  ),
                  avatarImagePath: user?.avatarImagePath,
                  onEditTap: () => context.push(AppRoutes.editProfile),
                ),
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: ProfileNameBlock(
                  name: user.displayName,
                  username: user?.username ?? '',
                ),
              ),
              AppSpacing.sm.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: _walletRow(context, user),
              ),
              AppSpacing.lg.vGap,
              for (final Widget section in _progressSection(context))
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: section,
                ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: SubmitQuestionCard(
                  onTap: () => context.push(AppRoutes.submitQuestion),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _settingsSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
