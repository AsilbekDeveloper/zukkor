import 'package:flutter/widgets.dart';

import '../../../../i18n/strings.g.dart';
import '../../../quiz/domain/entities/category.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../domain/entities/session_history_entry.dart';

/// Which play mode a past game was — mirrors the prototype's
/// `data-seg="all|solo|duel|lobby"` filter on the history screen.
enum GameMode { solo, duel, lobby }

extension GameModeLabel on GameMode {
  /// Needs [context] (not a const field) so the label re-translates when
  /// the locale changes.
  String label(BuildContext context) => switch (this) {
        GameMode.solo => context.t.history.segmentSolo,
        GameMode.duel => context.t.history.segmentDuel,
        GameMode.lobby => context.t.history.segmentLobby,
      };
}

/// A win/loss/draw badge pill (`.history-badge.win/.loss`) — only shown
/// for duel rows; solo rows show a plain score instead (see
/// [GameHistoryEntry.resultText]).
enum HistoryBadgeKind { win, loss, draw }

/// A single row on the Game History screen (`view-history`'s
/// `.history-row`). Icon/color/name come straight from [QuizCategory] —
/// every sample row here is a past play of one of that list's categories.
class GameHistoryEntry {
  const GameHistoryEntry({
    required this.category,
    required this.mode,
    required this.subtitle,
    required this.resultText,
    this.badge,
  });

  /// Builds a row from a real `GET /history` entry — solo entries show a
  /// score, duel entries show the opponent's name (as the subtitle) and a
  /// win/loss/draw badge, lobby entries show the player count (as the
  /// subtitle) and this player's placement instead.
  factory GameHistoryEntry.fromEntity(SessionHistoryEntry entity) => GameHistoryEntry(
        category: QuizCategory.fromEntity(
          Category(
            id: entity.categoryId,
            name: entity.categoryName,
            iconName: entity.categoryIconName,
            colorKey: entity.categoryColorKey,
            questionCount: 0,
          ),
        ),
        mode: switch (entity.mode) {
          HistorySessionMode.duel => GameMode.duel,
          HistorySessionMode.lobby => GameMode.lobby,
          HistorySessionMode.solo => GameMode.solo,
        },
        subtitle: switch (entity.mode) {
          HistorySessionMode.duel => '${entity.opponent!.name} · ${_formatSubtitle(entity.finishedAt)}',
          HistorySessionMode.lobby =>
            '${t.history.lobbyPlayerCount(count: entity.lobbyResult!.participantCount)} · ${_formatSubtitle(entity.finishedAt)}',
          HistorySessionMode.solo => _formatSubtitle(entity.finishedAt),
        },
        resultText: entity.mode == HistorySessionMode.lobby
            ? '#${entity.lobbyResult!.rank}'
            : '${entity.correctCount}/${entity.totalQuestions}',
        badge: switch (entity.duelOutcome) {
          DuelHistoryOutcome.won => HistoryBadgeKind.win,
          DuelHistoryOutcome.lost => HistoryBadgeKind.loss,
          DuelHistoryOutcome.draw => HistoryBadgeKind.draw,
          null => null,
        },
      );

  final QuizCategory category;
  final GameMode mode;
  final String subtitle;

  /// The score text ("8/10") when [badge] is null. Ignored (the badge is
  /// shown instead, see [HistoryList]) when [badge] isn't null.
  final String resultText;

  /// null = plain score text (`.history-score`); otherwise a win/loss/draw
  /// badge pill (duel rows only).
  final HistoryBadgeKind? badge;

  static String _formatSubtitle(DateTime finishedAt) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(finishedAt.year, finishedAt.month, finishedAt.day);
    final int diffDays = today.difference(day).inDays;
    final String time =
        '${finishedAt.hour.toString().padLeft(2, '0')}:${finishedAt.minute.toString().padLeft(2, '0')}';

    if (diffDays == 0) return '${t.history.today}, $time';
    if (diffDays == 1) return '${t.history.yesterday}, $time';
    if (diffDays > 1 && diffDays < 7) return t.history.daysAgo(days: diffDays);
    final String dd = finishedAt.day.toString().padLeft(2, '0');
    final String mm = finishedAt.month.toString().padLeft(2, '0');
    return '$dd.$mm.${finishedAt.year}';
  }
}
