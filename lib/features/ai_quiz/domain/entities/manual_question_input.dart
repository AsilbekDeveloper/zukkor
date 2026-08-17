/// Qo'lda kiritilgan bitta savol — foydalanuvchi tomonidan yozilgan,
/// backend'ga yuboriladigan xom kirish (saqlangan [AiQuiz] ichidagi
/// savol emas, shunchaki so'rov uchun ma'lumot).
class ManualQuestionInput {
  const ManualQuestionInput({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
}
