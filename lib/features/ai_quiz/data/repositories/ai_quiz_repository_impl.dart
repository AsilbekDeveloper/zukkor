import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/ai_quiz.dart';
import '../../domain/repositories/ai_quiz_repository.dart';
import '../../domain/usecases/delete_ai_quiz_use_case.dart';
import '../../domain/usecases/generate_ai_quiz_use_case.dart';
import '../../domain/usecases/list_ai_quizzes_use_case.dart';
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
