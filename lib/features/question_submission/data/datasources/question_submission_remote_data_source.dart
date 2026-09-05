import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/question_submission_result_model.dart';

class QuestionSubmissionRemoteDataSource {
  const QuestionSubmissionRemoteDataSource(this._dio);

  final Dio _dio;

  Future<QuestionSubmissionResultModel> submit({
    required String questionText,
    required List<String> options,
    required int correctOptionIndex,
    int? categoryId,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.submitQuestion,
      data: {
        'question_text': questionText,
        'options': options,
        'correct_option_index': correctOptionIndex,
        'category_id': categoryId,
      },
    );
    return QuestionSubmissionResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final Provider<QuestionSubmissionRemoteDataSource> questionSubmissionRemoteDataSourceProvider =
    Provider<QuestionSubmissionRemoteDataSource>(
  (ref) => QuestionSubmissionRemoteDataSource(ref.watch(dioProvider)),
);
