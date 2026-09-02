import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/ai_quiz_repository_impl.dart';
import '../../domain/entities/ai_quiz.dart';
import '../../domain/entities/discover_quiz.dart';
import '../../domain/entities/manual_question_input.dart';

class AiQuizState {
  const AiQuizState({this.quizzes, this.hasListError = false, this.isGenerating = false});

  /// `null` — hali yuklanmagan (yoki yuklanmoqda); bo'sh ro'yxat — yuklandi,
  /// lekin hech qanday AI quiz yo'q.
  final List<AiQuiz>? quizzes;
  final bool hasListError;
  final bool isGenerating;

  AiQuizState copyWith({
    List<AiQuiz>? Function()? quizzes,
    bool? hasListError,
    bool? isGenerating,
  }) =>
      AiQuizState(
        quizzes: quizzes != null ? quizzes() : this.quizzes,
        hasListError: hasListError ?? this.hasListError,
        isGenerating: isGenerating ?? this.isGenerating,
      );
}

/// Foydalanuvchining shaxsiy AI-generatsiya qilingan quizlarini boshqaradi
/// — ro'yxatni yuklaydi, yangi hujjatdan generatsiya qiladi (natija
/// backend'da darhol saqlanadi, alohida "saqlash" qadami yo'q), va
/// o'chiradi.
class AiQuizController extends Notifier<AiQuizState> {
  @override
  AiQuizState build() => const AiQuizState();

  Future<void> loadList() async {
    state = state.copyWith(hasListError: false);
    try {
      final List<AiQuiz> quizzes = await ref.read(listAiQuizzesUseCaseProvider).call();
      state = state.copyWith(quizzes: () => quizzes);
    } catch (_) {
      state = state.copyWith(hasListError: true);
    }
  }

  /// Failure'ni tashqariga chiqaradi — chaqiruvchi ekran o'zi ushlab,
  /// xabarni ko'rsatishi kerak (ilovaning boshqa joylaridagi kabi).
  Future<AiQuiz> generate({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  }) async {
    state = state.copyWith(isGenerating: true);
    try {
      final AiQuiz quiz = await ref.read(generateAiQuizUseCaseProvider).call(
            filePath: filePath,
            fileName: fileName,
            instruction: instruction,
            topic: topic,
            questionCount: questionCount,
            topicCategoryId: topicCategoryId,
          );
      final List<AiQuiz> updated = [quiz, ...?state.quizzes];
      state = state.copyWith(quizzes: () => updated);
      return quiz;
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> delete(int id) async {
    await ref.read(deleteAiQuizUseCaseProvider).call(id);
    final List<AiQuiz> updated = (state.quizzes ?? const []).where((quiz) => quiz.id != id).toList();
    state = state.copyWith(quizzes: () => updated);
  }

  /// Failure'ni tashqariga chiqaradi — chaqiruvchi ekran ushlab, xabar
  /// ko'rsatishi kerak.
  Future<void> updateVisibility(int id, String visibility) async {
    final AiQuiz updated = await ref.read(updateAiQuizVisibilityUseCaseProvider).call(id, visibility);
    final List<AiQuiz> list = (state.quizzes ?? const []).map((q) => q.id == id ? updated : q).toList();
    state = state.copyWith(quizzes: () => list);
  }

  /// Failure'ni tashqariga chiqaradi — chaqiruvchi ekran ushlab, xabar
  /// ko'rsatishi kerak.
  Future<void> updateTopic(int id, int? topicCategoryId) async {
    final AiQuiz updated = await ref.read(updateQuizTopicUseCaseProvider).call(id, topicCategoryId);
    final List<AiQuiz> list = (state.quizzes ?? const []).map((q) => q.id == id ? updated : q).toList();
    state = state.copyWith(quizzes: () => list);
  }

  /// Failure'ni tashqariga chiqaradi — chaqiruvchi ekran ushlab, xabar
  /// ko'rsatishi kerak.
  Future<AiQuiz> createManual({
    required String name,
    required List<ManualQuestionInput> questions,
    int? topicCategoryId,
  }) async {
    state = state.copyWith(isGenerating: true);
    try {
      final AiQuiz quiz = await ref
          .read(createManualQuizUseCaseProvider)
          .call(name: name, questions: questions, topicCategoryId: topicCategoryId);
      final List<AiQuiz> updated = [quiz, ...?state.quizzes];
      state = state.copyWith(quizzes: () => updated);
      return quiz;
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  /// `POST /generate-async` chaqiradi va job_id qaytaradi.
  Future<String> generateAsync({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  }) async {
    return ref.read(aiQuizRepositoryProvider).generateAsync(
          filePath: filePath,
          fileName: fileName,
          instruction: instruction,
          topic: topic,
          questionCount: questionCount,
          topicCategoryId: topicCategoryId,
        );
  }

  /// Berilgan job holatini tekshiradi. Agar tugagan bo'lsa ro'yxatni yangilaydi.
  Future<({String status, AiQuiz? quiz, String? error})> checkJobStatus(String jobId) async {
    final result = await ref.read(aiQuizRepositoryProvider).getAsyncJobStatus(jobId);
    if (result.status == 'completed' && result.quiz != null) {
      final List<AiQuiz> current = state.quizzes ?? [];
      if (!current.any((q) => q.id == result.quiz!.id)) {
        state = state.copyWith(quizzes: () => [result.quiz!, ...current]);
      }
    }
    return result;
  }

  /// Failure'ni tashqariga chiqaradi. `state.quizzes`ga ta'sir qilmaydi —
  /// bu boshqa foydalanuvchining ro'yxati, "mening quizlarim" emas.
  Future<List<AiQuiz>> listForUser(String userId) => ref.read(listUserQuizzesUseCaseProvider).call(userId);

  Future<List<DiscoverQuiz>> discover({int? categoryId}) =>
      ref.read(discoverQuizzesUseCaseProvider).call(categoryId: categoryId);

  Future<List<DiscoverQuiz>> searchDiscover(String query, {int? categoryId}) =>
      ref.read(searchDiscoverQuizzesUseCaseProvider).call(query, categoryId: categoryId);
}

final NotifierProvider<AiQuizController, AiQuizState> aiQuizControllerProvider =
    NotifierProvider<AiQuizController, AiQuizState>(AiQuizController.new);
