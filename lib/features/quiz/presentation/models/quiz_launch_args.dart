import 'quiz_category.dart';

/// [QuizScreen]'s route `extra` — a category, plus whether this is a
/// Lobby (multiplayer room) game. [isLobbyGame] changes what happens once
/// every question is answered: solo/duel games land on the plain
/// [ResultScreen], lobby games land on [LobbyResultScreen] (a room
/// leaderboard) instead.
class QuizLaunchArgs {
  const QuizLaunchArgs({required this.category, this.isLobbyGame = false});

  final QuizCategory category;
  final bool isLobbyGame;
}
