/// One question pushed over the lobby socket — mirrors the duel
/// feature's `DuelQuestion`. The correct answer now comes with the
/// question itself (2026-08-26) so the client can reveal right/wrong
/// the instant the player taps, without waiting on `LobbyQuestionResult`.
class LobbyQuestion {
  const LobbyQuestion({
    required this.text,
    required this.options,
    required this.correctOption,
    required this.timeLimitMs,
  });

  final String text;
  final List<String> options;
  final int correctOption;
  final int timeLimitMs;
}
