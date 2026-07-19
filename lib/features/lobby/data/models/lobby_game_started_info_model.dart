import '../../../quiz/domain/entities/category.dart';
import '../../domain/entities/lobby_game_started_info.dart';

/// `lobby_game_started` WebSocket message body.
class LobbyGameStartedInfoModel {
  const LobbyGameStartedInfoModel({required this.roomId, required this.category, required this.totalQuestions});

  factory LobbyGameStartedInfoModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> categoryJson = json['category'] as Map<String, dynamic>;
    return LobbyGameStartedInfoModel(
      roomId: json['room_id'] as String,
      category: Category(
        id: categoryJson['id'] as int,
        name: categoryJson['name'] as String,
        iconName: categoryJson['icon_name'] as String,
        colorKey: categoryJson['color_key'] as String,
        questionCount: categoryJson['question_count'] as int? ?? 0,
      ),
      totalQuestions: json['total_questions'] as int,
    );
  }

  final String roomId;
  final Category category;
  final int totalQuestions;

  LobbyGameStartedInfo toEntity() =>
      LobbyGameStartedInfo(roomId: roomId, category: category, totalQuestions: totalQuestions);
}
