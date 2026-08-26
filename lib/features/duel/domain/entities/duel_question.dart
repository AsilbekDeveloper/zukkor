/// One question pushed over the duel socket — mirrors the solo quiz's
/// `QuizQuestionData`. The correct answer now comes with the question
/// itself (2026-08-26) so the client can reveal right/wrong the instant
/// the player taps, without waiting on `DuelQuestionResult`.
class DuelQuestion {
  const DuelQuestion({
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
