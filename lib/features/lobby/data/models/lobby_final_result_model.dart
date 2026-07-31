import '../../../quiz/data/models/question_breakdown_item_model.dart';
import '../../../quiz/domain/entities/question_breakdown_item.dart';
import '../../domain/entities/lobby_final_result.dart';
import '../../domain/entities/lobby_player_score.dart';

/// `lobby_game_finished` WebSocket message body.
class LobbyFinalResultModel {
  const LobbyFinalResultModel({
    required this.roomId,
    required this.standings,
    required this.xpEarned,
    required this.ballEarned,
    required this.breakdown,
  });

  factory LobbyFinalResultModel.fromJson(Map<String, dynamic> json) => LobbyFinalResultModel(
        roomId: json['room_id'] as String,
        standings: (json['standings'] as List<dynamic>)
            .map(
              (entry) {
                final Map<String, dynamic> e = entry as Map<String, dynamic>;
                return LobbyPlayerScore(
                  participantId: e['participant_id'] as String,
                  correct: e['correct'] as int,
                  total: e['total'] as int,
                  totalTimeMs: e['total_time_ms'] as int,
                );
              },
            )
            .toList(),
        xpEarned: json['xp_earned'] as int,
        ballEarned: json['ball_earned'] as int,
        breakdown: parseQuestionBreakdown(json['breakdown']),
      );

  final String roomId;
  final List<LobbyPlayerScore> standings;
  final int xpEarned;
  final int ballEarned;
  final List<QuestionBreakdownItem> breakdown;

  LobbyFinalResult toEntity() => LobbyFinalResult(
        roomId: roomId,
        standings: standings,
        xpEarned: xpEarned,
        ballEarned: ballEarned,
        breakdown: breakdown,
      );
}
