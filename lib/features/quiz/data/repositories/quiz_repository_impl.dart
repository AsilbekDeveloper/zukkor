import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/answer_result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/quiz_start_result.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/get_categories_use_case.dart';
import '../../domain/usecases/start_quiz_use_case.dart';
import '../../domain/usecases/submit_answer_use_case.dart';
import '../datasources/quiz_remote_data_source.dart';
import '../models/category_model.dart';

class QuizRepositoryImpl implements QuizRepository {
  const QuizRepositoryImpl({required QuizRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final QuizRemoteDataSource _remoteDataSource;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final List<CategoryModel> models = await _remoteDataSource.getCategories();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) async {
    try {
      return (await _remoteDataSource.startQuiz(categoryId: categoryId, questionCount: questionCount))
          .toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) async {
    try {
      return (await _remoteDataSource.submitAnswer(
        sessionId: sessionId,
        sessionQuestionId: sessionQuestionId,
        selectedOption: selectedOption,
      ))
          .toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> reportQuestion({
    required int questionId,
    required String reason,
    String? comment,
  }) async {
    try {
      await _remoteDataSource.reportQuestion(questionId: questionId, reason: reason, comment: comment);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<QuizRepository> quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(remoteDataSource: ref.watch(quizRemoteDataSourceProvider)),
);

final Provider<GetCategoriesUseCase> getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>(
  (ref) => GetCategoriesUseCase(ref.watch(quizRepositoryProvider)),
);

final Provider<StartQuizUseCase> startQuizUseCaseProvider = Provider<StartQuizUseCase>(
  (ref) => StartQuizUseCase(ref.watch(quizRepositoryProvider)),
);

final Provider<SubmitAnswerUseCase> submitAnswerUseCaseProvider = Provider<SubmitAnswerUseCase>(
  (ref) => SubmitAnswerUseCase(ref.watch(quizRepositoryProvider)),
);
