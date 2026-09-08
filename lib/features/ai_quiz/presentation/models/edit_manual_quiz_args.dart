/// `EditManualQuizScreen`'s route `extra` — the hub screen already has
/// both of these in memory (from the [AiQuiz] it's showing), so there's
/// no need for the edit screen to re-fetch them just to show its header.
class EditManualQuizArgs {
  const EditManualQuizArgs({required this.quizId, required this.quizName});

  final int quizId;
  final String quizName;
}
