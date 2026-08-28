import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/ai_quiz.dart';
import '../../domain/entities/discover_quiz.dart';
import '../../domain/entities/manual_question_input.dart';
import '../../domain/repositories/ai_quiz_repository.dart';
import '../../domain/usecases/create_manual_quiz_use_case.dart';
import '../../domain/usecases/delete_ai_quiz_use_case.dart';
import '../../domain/usecases/discover_quizzes_use_case.dart';
import '../../domain/usecases/generate_ai_quiz_use_case.dart';
import '../../domain/usecases/list_ai_quizzes_use_case.dart';
import '../../domain/usecases/list_user_quizzes_use_case.dart';
import '../../domain/usecases/search_discover_quizzes_use_case.dart';
import '../../domain/usecases/update_ai_quiz_visibility_use_case.dart';
import '../datasources/ai_quiz_remote_data_source.dart';

class AiQuizRepositoryImpl implements AiQuizRepository {
  const AiQuizRepositoryImpl(this._remoteDataSource);

  final AiQuizRemoteDataSource _remoteDataSource;

  @override
  Future<AiQuiz> generate({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
  }) async {
    try {
      return (await _remoteDataSource.generate(
        filePath: filePath,
        fileName: fileName,
        instruction: instruction,
        topic: topic,
        questionCount: questionCount,
      ))
          .toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<List<AiQuiz>> list() async {
    try {
      return (await _remoteDataSource.list()).map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _remoteDataSource.delete(id);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<AiQuiz> updateVisibility(int id, String visibility) async {
    try {
      return (await _remoteDataSource.updateVisibility(id, visibility)).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<AiQuiz> createManual({required String name, required List<ManualQuestionInput> questions}) async {
    try {
      return (await _remoteDataSource.createManual(name: name, questions: questions)).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<List<AiQuiz>> listForUser(String userId) async {
    try {
      return (await _remoteDataSource.listForUser(userId)).map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<List<DiscoverQuiz>> discover() async {
    try {
      return (await _remoteDataSource.discover()).map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<List<DiscoverQuiz>> searchDiscover(String query) async {
    try {
      return (await _remoteDataSource.searchDiscover(query)).map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<AiQuizRepository> aiQuizRepositoryProvider = Provider<AiQuizRepository>(
  (ref) => AiQuizRepositoryImpl(ref.watch(aiQuizRemoteDataSourceProvider)),
);

final Provider<GenerateAiQuizUseCase> generateAiQuizUseCaseProvider = Provider<GenerateAiQuizUseCase>(
  (ref) => GenerateAiQuizUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<ListAiQuizzesUseCase> listAiQuizzesUseCaseProvider = Provider<ListAiQuizzesUseCase>(
  (ref) => ListAiQuizzesUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<DeleteAiQuizUseCase> deleteAiQuizUseCaseProvider = Provider<DeleteAiQuizUseCase>(
  (ref) => DeleteAiQuizUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<UpdateAiQuizVisibilityUseCase> updateAiQuizVisibilityUseCaseProvider =
    Provider<UpdateAiQuizVisibilityUseCase>(
  (ref) => UpdateAiQuizVisibilityUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<CreateManualQuizUseCase> createManualQuizUseCaseProvider = Provider<CreateManualQuizUseCase>(
  (ref) => CreateManualQuizUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<ListUserQuizzesUseCase> listUserQuizzesUseCaseProvider = Provider<ListUserQuizzesUseCase>(
  (ref) => ListUserQuizzesUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<DiscoverQuizzesUseCase> discoverQuizzesUseCaseProvider = Provider<DiscoverQuizzesUseCase>(
  (ref) => DiscoverQuizzesUseCase(ref.watch(aiQuizRepositoryProvider)),
);

final Provider<SearchDiscoverQuizzesUseCase> searchDiscoverQuizzesUseCaseProvider =
    Provider<SearchDiscoverQuizzesUseCase>(
  (ref) => SearchDiscoverQuizzesUseCase(ref.watch(aiQuizRepositoryProvider)),
);
