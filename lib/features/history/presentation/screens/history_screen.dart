import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/pill_segment_control.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyControllerProvider.notifier).load());
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
    final List<SessionHistoryEntry>? sessions = ref.watch(historyControllerProvider);
    final List<GameHistoryEntry> entries = sessions == null ? const [] : _filteredEntries(sessions);
    final String emptyMessage =
        _selectedMode == null ? context.t.history.noGamesYet : context.t.history.emptyState;

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
                child: sessions == null
                    ? const Center(child: CircularProgressIndicator())
                    : entries.isEmpty
                        ? Center(
                            child: Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                            ),
                          )
                        : SingleChildScrollView(child: HistoryList(entries: entries)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
