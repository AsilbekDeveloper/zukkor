import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../ai_quiz/domain/entities/ai_quiz.dart';
import '../../../ai_quiz/presentation/controllers/ai_quiz_controller.dart';
import '../../../friends/presentation/controllers/friend_requests_controller.dart';
import '../../../friends/presentation/controllers/send_friend_request_controller.dart';
import '../../../leaderboard/domain/entities/player_stats.dart';
import '../../../leaderboard/presentation/controllers/player_stats_controller.dart';
import '../../../leaderboard/presentation/models/leaderboard_entry.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../models/player_detail_args.dart';

/// A read-only profile card for someone else — mirrors the prototype's
/// `view-player-detail` / `openPlayerDetail()`. Reachable from the
/// Leaderboard, Friends, Add Friend, and Friend Requests lists.
///
/// Its own small feature (not folded into Leaderboard or Friends)
/// because it genuinely needs both: player stats from Leaderboard's
/// `GET /leaderboard/{user_id}`, and the friendship actions (add,
/// accept, decline) from Friends. Hosting it inside either one would
/// make that feature depend back on the other just to reach this
/// screen — a real circular dependency this split avoids.
///
/// Always fetches fresh via [PlayerDetailArgs.userId] on open (no
/// instant-paint from a caller-supplied preview) — trades a brief
/// loading spinner for callers not needing to carry a shared model type.
/// The action row (Add to friends / already friends / accept-decline)
/// is driven by [PlayerDetailArgs.relation].
class PlayerDetailScreen extends ConsumerStatefulWidget {
  const PlayerDetailScreen({required this.args, super.key});

  final PlayerDetailArgs args;

  @override
  ConsumerState<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends ConsumerState<PlayerDetailScreen> {
  late bool _requestSent = widget.args.initialRequestSent;
  bool _sendingRequest = false;
  bool _respondingToRequest = false;
  PlayerStats? _stats;
  List<AiQuiz>? _aiQuizzes;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadStats);
    Future.microtask(_loadAiQuizzes);
  }

  Future<void> _loadStats() async {
    try {
      final PlayerStats stats =
          await ref.read(playerStatsControllerProvider.notifier).getPlayerStats(widget.args.userId);
      if (!mounted) return;
      setState(() => _stats = stats);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
      _close(context);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
      _close(context);
    }
  }

  Future<void> _loadAiQuizzes() async {
    try {
      final List<AiQuiz> quizzes =
          await ref.read(aiQuizControllerProvider.notifier).listForUser(widget.args.userId);
      if (!mounted) return;
      setState(() => _aiQuizzes = quizzes);
    } catch (_) {
      // Ikkinchi darajali bo'lim - xato bo'lsa shunchaki ko'rsatilmaydi.
    }
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.leaderboard);
    }
  }

  Future<void> _addToFriends() async {
    if (_sendingRequest) return;
    setState(() => _sendingRequest = true);
    try {
      await ref.read(sendFriendRequestControllerProvider.notifier).sendRequest(widget.args.userId);
      if (!mounted) return;
      setState(() => _requestSent = true);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _sendingRequest = false);
    }
  }

  Future<void> _respondToRequest(bool accept) async {
    final String requestId = widget.args.incomingRequestId!;
    setState(() => _respondingToRequest = true);
    try {
      final FriendRequestsController notifier = ref.read(friendRequestsControllerProvider.notifier);
      if (accept) {
        await notifier.accept(requestId);
      } else {
        await notifier.decline(requestId);
      }
      if (!mounted) return;
      _close(context);
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _respondingToRequest = false);
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _respondingToRequest = false);
      context.showSnack(t.errors.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerStats? stats = _stats;

    if (stats == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.xs.vGap,
                CloseHeader(title: context.t.playerDetail.title, onClose: () => _close(context)),
                AppSpacing.xl.vGap,
                const _PlayerDetailShimmer(),
              ],
            ),
          ),
        ),
      );
    }

    final LeaderboardEntry entry = LeaderboardEntry.fromPlayerStats(stats);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              CloseHeader(title: context.t.playerDetail.title, onClose: () => _close(context)),
              AppSpacing.xl.vGap,
              Center(
                child: UserAvatar(
                  size: 76,
                  initials: entry.initials,
                  avatarImagePath: entry.avatarImagePath,
                  backgroundColor: entry.avatarColor.resolve(context),
                  fontSize: 24,
                ),
              ),
              AppSpacing.md.vGap,
              Center(
                child: Text(
                  entry.displayName(context),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  context.t.playerDetail.rankedLabel(rank: entry.rank, xp: formatThousands(entry.xp)),
                  style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                ),
              ),
              AppSpacing.lg.vGap,
              _PlayerStatsRow(
                winRatePercent: stats.winRatePercent,
                streak: stats.currentStreak,
              ),
              AppSpacing.xl.vGap,
              _actionSection(context),
              if (_aiQuizzes != null && _aiQuizzes!.isNotEmpty) ...[
                AppSpacing.xl.vGap,
                _AiQuizzesSection(quizzes: _aiQuizzes!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionSection(BuildContext context) {
    switch (widget.args.relation) {
      case PlayerDetailRelation.friend:
        return _AlreadyFriendsBadge(label: context.t.playerDetail.alreadyFriends);
      case PlayerDetailRelation.incomingRequest:
        return Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: context.t.playerDetail.declineRequest,
                isLoading: _respondingToRequest,
                onPressed: _respondingToRequest ? null : () => _respondToRequest(false),
              ),
            ),
            AppSpacing.sm.hGap,
            Expanded(
              child: AppButton.primary(
                label: context.t.playerDetail.acceptRequest,
                isLoading: _respondingToRequest,
                onPressed: _respondingToRequest ? null : () => _respondToRequest(true),
              ),
            ),
          ],
        );
      case PlayerDetailRelation.unknown:
        return AppButton.primary(
          label: _requestSent ? context.t.playerDetail.requestSent : context.t.playerDetail.addToFriends,
          icon: Icon(
            _requestSent ? TablerIcons.check : TablerIcons.userPlus,
            color: Colors.white,
            size: 18,
          ),
          isLoading: _sendingRequest,
          onPressed: (_requestSent || _sendingRequest) ? null : _addToFriends,
        );
    }
  }
}

class _PlayerDetailShimmer extends StatelessWidget {
  const _PlayerDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          const Center(child: ShimmerCircle(size: 76)),
          AppSpacing.md.vGap,
          const Center(child: ShimmerBox(width: 140, height: 16)),
          const SizedBox(height: 6),
          const Center(child: ShimmerBox(width: 100, height: 11)),
          AppSpacing.lg.vGap,
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: context.colors.line),
            ),
            child: const Row(
              children: [
                Expanded(child: Center(child: ShimmerBox(width: 30, height: 24))),
                Expanded(child: Center(child: ShimmerBox(width: 30, height: 24))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlreadyFriendsBadge extends StatelessWidget {
  const _AlreadyFriendsBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.userCheck, size: 18, color: context.colors.teal),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: context.colors.muted),
          ),
        ],
      ),
    );
  }
}

class _PlayerStatsRow extends StatelessWidget {
  const _PlayerStatsRow({required this.winRatePercent, required this.streak});

  final int winRatePercent;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(value: '$winRatePercent%', label: context.t.profile.statWinRate)),
          _divider(context),
          Expanded(child: _Stat(value: '$streak', label: context.t.playerDetail.streakLabel)),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(width: 1, margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs), color: context.colors.line);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: context.textStyles.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: context.textStyles.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _AiQuizzesSection extends StatelessWidget {
  const _AiQuizzesSection({required this.quizzes});

  final List<AiQuiz> quizzes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.playerDetail.aiQuizzesTitle,
          style: context.textStyles.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: context.colors.ink2),
        ),
        AppSpacing.sm.vGap,
        for (final quiz in quizzes) ...[
          _PublicAiQuizRow(quiz: quiz),
          AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _PublicAiQuizRow extends StatelessWidget {
  const _PublicAiQuizRow({required this.quiz});

  final AiQuiz quiz;

  void _play(BuildContext context) {
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
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: () => _play(context),
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: context.colors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: context.colors.coral, borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.sparkle, color: Colors.white, size: 16),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  quiz.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                context.t.common.questionCount(count: quiz.questionCount),
                style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

