import '../../../quiz/domain/entities/category.dart';

/// `lobby_game_started` — sent to every room member once the host has
/// started the game, before the first question arrives.
class LobbyGameStartedInfo {
  const LobbyGameStartedInfo({
    required this.roomId,
    required this.category,
    required this.totalQuestions,
  });

  final String roomId;
  final Category category;
  final int totalQuestions;
}
