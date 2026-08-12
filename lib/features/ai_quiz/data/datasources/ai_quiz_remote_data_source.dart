import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ai_quiz_model.dart';

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
}

final Provider<AiQuizRemoteDataSource> aiQuizRemoteDataSourceProvider = Provider<AiQuizRemoteDataSource>(
  (ref) => AiQuizRemoteDataSource(ref.watch(dioProvider)),
);
