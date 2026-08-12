/// A quiz generated from a document (PDF/Word/text) the user uploaded —
/// stored server-side as a private category only its owner can see or
/// play (`GET /ai-quiz`).
class AiQuiz {
  const AiQuiz({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;
}
