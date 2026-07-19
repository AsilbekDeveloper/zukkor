/// One question pushed over the lobby socket — mirrors the duel
/// feature's `DuelQuestion`, minus the correct answer (the server
/// withholds it until [LobbyQuestionResult] arrives for this index).
class LobbyQuestion {
  const LobbyQuestion({
    required this.text,
    required this.options,
    required this.timeLimitMs,
  });

  final String text;
  final List<String> options;
  final int timeLimitMs;
}
