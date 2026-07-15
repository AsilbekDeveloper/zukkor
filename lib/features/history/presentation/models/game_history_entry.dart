import 'package:flutter/widgets.dart';

import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

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

/// A single row on the Game History screen (`view-history`'s
/// `.history-row`). Icon/color/name come straight from [QuizCategory] —
/// every sample row here is a past play of one of that list's categories.
class GameHistoryEntry {
  const GameHistoryEntry({
    required this.category,
    required this.mode,
    required this.subtitle,
    required this.resultText,
    this.isWinBadge,
  });

  final QuizCategory category;
  final GameMode mode;
  final String subtitle;

  /// The score/placement text ("8/10", "2nd place") when [isWinBadge] is
  /// null. Ignored (win/loss label is derived from [isWinBadge] at render
  /// time instead, see [HistoryList]) when [isWinBadge] isn't null.
  final String resultText;

  /// null = plain score/placement text (`.history-score`); true/false =
  /// a win/loss badge pill (`.history-badge.win` / `.history-badge.loss`).
  final bool? isWinBadge;

  static final List<GameHistoryEntry> sample = [
    GameHistoryEntry(
      category: QuizCategory.sample[0], // Math
      mode: GameMode.solo,
      subtitle: 'Solo · Today, 14:30',
      resultText: '8/10',
    ),
    GameHistoryEntry(
      category: QuizCategory.sample[1], // History
      mode: GameMode.duel,
      subtitle: 'Duel vs Malika · Today, 10:15',
      resultText: 'Win',
      isWinBadge: true,
    ),
    GameHistoryEntry(
      category: QuizCategory.sample[4], // Football
      mode: GameMode.lobby,
      subtitle: 'Lobby · 4 players · Yesterday',
      resultText: '2nd place',
    ),
    GameHistoryEntry(
      category: QuizCategory.sample[2], // English
      mode: GameMode.solo,
      subtitle: 'Solo · Yesterday',
      resultText: '6/10',
    ),
    GameHistoryEntry(
      category: QuizCategory.sample[3], // Movies
      mode: GameMode.duel,
      subtitle: 'Duel vs Shohruh · 2 days ago',
      resultText: 'Loss',
      isWinBadge: false,
    ),
    GameHistoryEntry(
      category: QuizCategory.sample[5], // Memes
      mode: GameMode.solo,
      subtitle: 'Solo · 3 days ago',
      resultText: '10/10',
    ),
  ];
}
