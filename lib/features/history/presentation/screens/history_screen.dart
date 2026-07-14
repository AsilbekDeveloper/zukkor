import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../models/game_history_entry.dart';
import '../widgets/history_list.dart';

/// The Game History screen — mirrors the prototype's `view-history`: a
/// 4-way segment filter (All/Solo/Duel/Lobby) over a list of past plays.
///
/// CURRENT STATE: filters [GameHistoryEntry.sample] client-side — no
/// history backend/pagination exists yet.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  GameMode? _selectedMode;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  List<GameHistoryEntry> get _filteredEntries => _selectedMode == null
      ? GameHistoryEntry.sample
      : GameHistoryEntry.sample.where((entry) => entry.mode == _selectedMode).toList();

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
              BackHeader(title: AppStrings.gameHistory, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              PillSegmentControl<GameMode?>(
                values: const [null, GameMode.solo, GameMode.duel, GameMode.lobby],
                selected: _selectedMode,
                labelBuilder: (mode) => mode?.label ?? AppStrings.historySegmentAll,
                onChanged: (mode) => setState(() => _selectedMode = mode),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: SingleChildScrollView(
                  child: HistoryList(entries: _filteredEntries),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
