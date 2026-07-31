import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/session_history_entry.dart';
import '../controllers/history_controller.dart';
import '../models/game_history_entry.dart';
import '../widgets/history_list.dart';

/// The Game History screen — mirrors the prototype's `view-history`: a
/// 4-way segment filter (All/Solo/Duel/Lobby) over a list of past plays.
///
/// CURRENT STATE: All 4 segments show real `GET /history` data.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  GameMode? _selectedMode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cached for the session — finishing a game invalidates this
    // provider directly (see DuelController/LobbyController/QuizScreen),
    // so a stale list here would only happen if that hook were missing.
    if (ref.read(historyControllerProvider).entries == null) {
      Future.microtask(() => ref.read(historyControllerProvider.notifier).load());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // Fires the next page a little before the user actually hits the
  // bottom, so the new rows are ready by the time they get there.
  void _onScroll() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;
    ref.read(historyControllerProvider.notifier).loadMore();
  }

  /// A segment filter (Duel/Lobby) is applied client-side over whatever
  /// page(s) [HistoryController] has already fetched — so a user whose
  /// history is mostly solo games can end up with a filtered list that's
  /// too short (or empty) to scroll at all, even though matching entries
  /// exist further back. [_onScroll] alone would never fire in that case
  /// (there's nothing to scroll), silently hiding real data. Called after
  /// every build, this keeps pulling pages until the filtered list either
  /// fills the viewport or [HistoryState.hasMore] runs out.
  void _maybeLoadMoreForFilter(HistoryState state, List<GameHistoryEntry> filteredEntries) {
    if (!mounted || state.entries == null || !state.hasMore || state.isLoadingMore) return;
    final bool viewportNotFull =
        !_scrollController.hasClients || _scrollController.position.maxScrollExtent <= 0;
    if (filteredEntries.isEmpty || viewportNotFull) {
      ref.read(historyControllerProvider.notifier).loadMore();
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  List<GameHistoryEntry> _filteredEntries(List<SessionHistoryEntry> sessions) {
    final HistorySessionMode? wantedMode = switch (_selectedMode) {
      GameMode.solo => HistorySessionMode.solo,
      GameMode.duel => HistorySessionMode.duel,
      GameMode.lobby => HistorySessionMode.lobby,
      null => null,
    };
    return sessions
        .where((session) => wantedMode == null || session.mode == wantedMode)
        .map(GameHistoryEntry.fromEntity)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final HistoryState historyState = ref.watch(historyControllerProvider);
    final List<SessionHistoryEntry>? sessions = historyState.entries;
    final List<GameHistoryEntry> entries = sessions == null ? const [] : _filteredEntries(sessions);
    final String emptyMessage =
        _selectedMode == null ? context.t.history.noGamesYet : context.t.history.emptyState;

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMoreForFilter(historyState, entries));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.profile.gameHistory, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              PillSegmentControl<GameMode?>(
                values: const [null, GameMode.solo, GameMode.duel, GameMode.lobby],
                selected: _selectedMode,
                labelBuilder: (mode) => mode?.label(context) ?? context.t.history.segmentAll,
                onChanged: (mode) => setState(() => _selectedMode = mode),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: historyState.hasError
                    ? ErrorRetryView(onRetry: () => ref.read(historyControllerProvider.notifier).load())
                    : sessions == null
                    ? const ShimmerListSkeleton()
                    : entries.isEmpty
                        ? Center(
                            child: Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(historyControllerProvider.notifier).load(),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  HistoryList(entries: entries),
                                  if (historyState.isLoadingMore) ...[
                                    AppSpacing.md.vGap,
                                    const Center(
                                      child: SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      ),
                                    ),
                                    AppSpacing.md.vGap,
                                  ],
                                ],
                              ),
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
