/// One question pushed over the duel socket — mirrors the solo quiz's
/// `QuizQuestionData`, minus the correct answer (the server withholds it
/// until [DuelQuestionResult] arrives for this index).
class DuelQuestion {
  const DuelQuestion({
    required this.text,
    required this.options,
    required this.timeLimitMs,
  });

  final String text;
  final List<String> options;
  final int timeLimitMs;
}
