import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/answer_response_model.dart';
import '../models/category_model.dart';
import '../models/quiz_start_response_model.dart';

/// `/categories`, `/quiz/*` endpoint'lariga xom (Dio) so'rovlar.
/// Xatolikni ushlamaydi — [DioException] to'g'ridan-to'g'ri tashqariga
/// chiqadi, uni [Failure]ga aylantirish [QuizRepositoryImpl]ning ishi.
class QuizRemoteDataSource {
  const QuizRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> getCategories() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.categories);
    return (response.data as List<dynamic>)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<QuizStartResponseModel> startQuiz({
    required int categoryId,
    required int questionCount,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.quizStart,
      data: {'category_id': categoryId, 'question_count': questionCount},
    );
    return QuizStartResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnswerResponseModel> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.quizAnswer(sessionId),
      data: {'session_question_id': sessionQuestionId, 'selected_option': selectedOption},
    );
    return AnswerResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> reportQuestion({
    required int questionId,
    required String reason,
    String? comment,
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.reportQuestion(questionId),
      data: {'reason': reason, 'comment': comment},
    );
  }
}

final Provider<QuizRemoteDataSource> quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>(
  (ref) => QuizRemoteDataSource(ref.watch(dioProvider)),
);
