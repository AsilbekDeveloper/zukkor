import '../../../quiz/domain/entities/category.dart';
import '../../domain/entities/duel_started_info.dart';
import 'duel_participant_model.dart';

/// `duel_started` WebSocket message body.
class DuelStartedInfoModel {
  const DuelStartedInfoModel({
    required this.duelId,
    required this.category,
    required this.totalQuestions,
    required this.opponent,
  });

  factory DuelStartedInfoModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> categoryJson = json['category'] as Map<String, dynamic>;
    return DuelStartedInfoModel(
      duelId: json['duel_id'] as String,
      category: Category(
        id: categoryJson['id'] as int,
        name: categoryJson['name'] as String,
        iconName: categoryJson['icon_name'] as String,
        colorKey: categoryJson['color_key'] as String,
        questionCount: categoryJson['question_count'] as int? ?? 0,
      ),
      totalQuestions: json['total_questions'] as int,
      opponent: DuelParticipantModel.fromJson(json['opponent'] as Map<String, dynamic>),
    );
  }

  final String duelId;
  final Category category;
  final int totalQuestions;
  final DuelParticipantModel opponent;

  DuelStartedInfo toEntity() => DuelStartedInfo(
        duelId: duelId,
        category: category,
        totalQuestions: totalQuestions,
        opponent: opponent.toEntity(),
      );
}
