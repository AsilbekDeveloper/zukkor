import '../../domain/entities/duel_final_result.dart';
import '../../domain/entities/duel_player_score.dart';

/// `duel_finished` WebSocket message body.
class DuelFinalResultModel {
  const DuelFinalResultModel({
    required this.duelId,
    required this.outcome,
    required this.yourScore,
    required this.opponentScore,
    required this.xpEarned,
    required this.ballEarned,
  });

  factory DuelFinalResultModel.fromJson(Map<String, dynamic> json) => DuelFinalResultModel(
        duelId: json['duel_id'] as String,
        outcome: _outcomeFromString(json['result'] as String),
        yourScore: _scoreFromJson(json['your_score'] as Map<String, dynamic>),
        opponentScore: _scoreFromJson(json['opponent_score'] as Map<String, dynamic>),
        xpEarned: json['xp_earned'] as int,
        ballEarned: json['ball_earned'] as int,
      );

  final String duelId;
  final DuelOutcome outcome;
  final DuelPlayerScore yourScore;
  final DuelPlayerScore opponentScore;
  final int xpEarned;
  final int ballEarned;

  static DuelOutcome _outcomeFromString(String value) => switch (value) {
        'won' => DuelOutcome.won,
        'lost' => DuelOutcome.lost,
        _ => DuelOutcome.draw,
      };

  static DuelPlayerScore _scoreFromJson(Map<String, dynamic> json) => DuelPlayerScore(
        correct: json['correct'] as int,
        total: json['total'] as int,
        totalTimeMs: json['total_time_ms'] as int,
      );

  DuelFinalResult toEntity() => DuelFinalResult(
        duelId: duelId,
        outcome: outcome,
        yourScore: yourScore,
        opponentScore: opponentScore,
        xpEarned: xpEarned,
        ballEarned: ballEarned,
      );
}
