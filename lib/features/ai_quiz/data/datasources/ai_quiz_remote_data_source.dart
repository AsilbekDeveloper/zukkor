import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/manual_question_input.dart';
import '../models/ai_quiz_model.dart';
import '../models/discover_quiz_model.dart';

/// `/ai-quiz/*` endpoint'lariga xom (Dio) so'rovlar. Xatolikni ushlamaydi —
/// [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni [Failure]ga
/// aylantirish [AiQuizRepositoryImpl]ning ishi.
class AiQuizRemoteDataSource {
  const AiQuizRemoteDataSource(this._dio);

  final Dio _dio;

  // Hujjatni yuklash + AI generatsiya qilish (PDF o'qish + Gemini so'rovi)
  // odatiy JSON so'rovlardan sezilarli sekinroq — global 20s receive
  // timeout bu yerga yetarli emas.
  static const Duration _generateTimeout = Duration(seconds: 120);

  Future<AiQuizModel> generate({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  }) async {
    final Map<String, dynamic> fields = {'question_count': questionCount};
    if (filePath != null && fileName != null) {
      fields['file'] = await MultipartFile.fromFile(filePath, filename: fileName);
    }
    if (instruction != null && instruction.isNotEmpty) {
      fields['instruction'] = instruction;
    }
    if (topic != null && topic.isNotEmpty) {
      fields['topic'] = topic;
    }
    if (topicCategoryId != null) {
      fields['topic_category_id'] = topicCategoryId;
    }
    final FormData formData = FormData.fromMap(fields);
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.aiQuizGenerate,
      data: formData,
      options: Options(sendTimeout: _generateTimeout, receiveTimeout: _generateTimeout),
    );
    return AiQuizModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AiQuizModel>> list() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.aiQuiz);
    return (response.data as List<dynamic>)
        .map((json) => AiQuizModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(int id) async {
    await _dio.delete<void>(ApiEndpoints.aiQuizDelete(id));
  }

  Future<AiQuizModel> updateVisibility(int id, String visibility) async {
    final Response<dynamic> response = await _dio.patch(
      ApiEndpoints.aiQuizVisibility(id),
      data: {'visibility': visibility},
    );
    return AiQuizModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AiQuizModel> updateTopic(int id, int? topicCategoryId) async {
    final Response<dynamic> response = await _dio.patch(
      '${ApiEndpoints.aiQuiz}/$id/topic',
      data: {'topic_category_id': topicCategoryId},
    );
    return AiQuizModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AiQuizModel> createManual({
    required String name,
    required List<ManualQuestionInput> questions,
    int? topicCategoryId,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.aiQuizManual,
      data: {
        'name': name,
        'topic_category_id': topicCategoryId,
        'questions': questions
            .map((q) => {
                  'question_text': q.questionText,
                  'options': q.options,
                  'correct_option_index': q.correctOptionIndex,
                })
            .toList(),
      },
    );
    return AiQuizModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AiQuizModel>> listForUser(String userId) async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.aiQuizForUser(userId));
    return (response.data as List<dynamic>)
        .map((json) => AiQuizModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiscoverQuizModel>> discover({int? categoryId}) async {
    final Response<dynamic> response = await _dio.get(
      ApiEndpoints.aiQuizDiscover,
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
    return (response.data as List<dynamic>)
        .map((json) => DiscoverQuizModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiscoverQuizModel>> searchDiscover(String query, {int? categoryId}) async {
    final Map<String, dynamic> params = {'q': query};
    if (categoryId != null) {
      params['category_id'] = categoryId;
    }
    final Response<dynamic> response = await _dio.get(
      '${ApiEndpoints.aiQuizDiscover}/search',
      queryParameters: params,
    );
    return (response.data as List<dynamic>)
        .map((json) => DiscoverQuizModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final Provider<AiQuizRemoteDataSource> aiQuizRemoteDataSourceProvider = Provider<AiQuizRemoteDataSource>(
  (ref) => AiQuizRemoteDataSource(ref.watch(dioProvider)),
);
