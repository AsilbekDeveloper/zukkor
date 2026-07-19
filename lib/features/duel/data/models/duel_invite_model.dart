import '../../../quiz/domain/entities/category.dart';
import '../../domain/entities/duel_invite.dart';
import 'duel_participant_model.dart';

/// `duel_invite_received` WebSocket message body.
class DuelInviteModel {
  const DuelInviteModel({
    required this.id,
    required this.fromUser,
    required this.category,
    required this.expiresAt,
  });

  factory DuelInviteModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> categoryJson = json['category'] as Map<String, dynamic>;
    return DuelInviteModel(
      id: json['invite_id'] as String,
      fromUser: DuelParticipantModel.fromJson(json['from_user'] as Map<String, dynamic>),
      category: Category(
        id: categoryJson['id'] as int,
        name: categoryJson['name'] as String,
        iconName: categoryJson['icon_name'] as String,
        colorKey: categoryJson['color_key'] as String,
        questionCount: categoryJson['question_count'] as int? ?? 0,
      ),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  final String id;
  final DuelParticipantModel fromUser;
  final Category category;
  final DateTime expiresAt;

  DuelInvite toEntity() => DuelInvite(
        id: id,
        fromUser: fromUser.toEntity(),
        category: category,
        expiresAt: expiresAt,
      );
}
