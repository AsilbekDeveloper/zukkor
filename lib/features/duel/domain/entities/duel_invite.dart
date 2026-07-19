import '../../../quiz/domain/entities/category.dart';
import 'duel_participant.dart';

/// An incoming duel challenge, delivered over the duel WebSocket
/// (`duel_invite_received`).
class DuelInvite {
  const DuelInvite({
    required this.id,
    required this.fromUser,
    required this.category,
    required this.expiresAt,
  });

  final String id;
  final DuelParticipant fromUser;
  final Category category;
  final DateTime expiresAt;
}
