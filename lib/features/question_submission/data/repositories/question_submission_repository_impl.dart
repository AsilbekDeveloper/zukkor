import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/question_submission_result.dart';
import '../../domain/repositories/question_submission_repository.dart';
import '../datasources/question_submission_remote_data_source.dart';

class QuestionSubmissionRepositoryImpl implements QuestionSubmissionRepository {
  const QuestionSubmissionRepositoryImpl({required QuestionSubmissionRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final QuestionSubmissionRemoteDataSource _remoteDataSource;

  @override
  Future<QuestionSubmissionResult> submit({
    required String questionText,
    required List<String> options,
    required int correctOptionIndex,
    int? categoryId,
  }) async {
    try {
      return (await _remoteDataSource.submit(
        questionText: questionText,
        options: options,
        correctOptionIndex: correctOptionIndex,
        categoryId: categoryId,
      ))
          .toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<QuestionSubmissionRepository> questionSubmissionRepositoryProvider =
    Provider<QuestionSubmissionRepository>(
  (ref) => QuestionSubmissionRepositoryImpl(
    remoteDataSource: ref.watch(questionSubmissionRemoteDataSourceProvider),
  ),
);
