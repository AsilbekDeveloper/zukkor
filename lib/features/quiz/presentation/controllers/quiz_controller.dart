import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/answer_result.dart';
import '../../domain/entities/quiz_start_result.dart';

/// Quiz sessiyasi bilan bog'liq tarmoq amallarini boshqaradi. Holati —
/// shunchaki `isLoading` bayrog'i; savol/sessiya holatining o'zi
/// [QuizScreen]ning ichida saqlanadi (Onboarding wizard'idagi kabi),
/// xatolikni har bir chaqiruvchi `try/catch` bilan ushlaydi.
class QuizController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) async {
    state = true;
    try {
      return await ref.read(startQuizUseCaseProvider).call(
            categoryId: categoryId,
            questionCount: questionCount,
          );
    } finally {
      state = false;
    }
  }

  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) async {
    state = true;
    try {
      return await ref.read(submitAnswerUseCaseProvider).call(
            sessionId: sessionId,
            sessionQuestionId: sessionQuestionId,
            selectedOption: selectedOption,
          );
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<QuizController, bool> quizControllerProvider =
    NotifierProvider<QuizController, bool>(QuizController.new);
