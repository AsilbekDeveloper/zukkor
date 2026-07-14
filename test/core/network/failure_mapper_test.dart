import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/error/failures.dart';
import 'package:zukkor/core/network/failure_mapper.dart';

DioException _badResponse(int status, dynamic data) {
  final RequestOptions options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: data,
    ),
  );
}

void main() {
  group('FailureMapper — tarmoq holatlari', () {
    test('timeout → NetworkFailure', () {
      final DioException e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(FailureMapper.fromDio(e), isA<NetworkFailure>());
    });

    test('ulanish yo\'q → NetworkFailure', () {
      final DioException e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      expect(FailureMapper.fromDio(e), isA<NetworkFailure>());
    });
  });

  group('FailureMapper — backend xatolik formati', () {
    test('400 validation_error: maydon xatolari ajratiladi', () {
      final Failure failure = FailureMapper.fromDio(_badResponse(400, {
        'error': 'validation_error',
        'detail': {
          'email': ["Bu email allaqachon ro'yxatdan o'tgan."],
        },
      }));

      expect(failure, isA<ValidationFailure>());
      final ValidationFailure v = failure as ValidationFailure;
      expect(v.forField('email'), "Bu email allaqachon ro'yxatdan o'tgan.");
      expect(v.forField('password'), isNull);
      // Umumiy xabar ham birinchi maydon xatosidan olinadi.
      expect(v.message, "Bu email allaqachon ro'yxatdan o'tgan.");
    });

    test('401 invalid_credentials: string detail xabar bo\'ladi', () {
      final Failure failure = FailureMapper.fromDio(_badResponse(401, {
        'error': 'invalid_credentials',
        'detail': "Email yoki parol noto'g'ri.",
      }));

      expect(failure, isA<AuthFailure>());
      expect(failure.message, "Email yoki parol noto'g'ri.");
    });

    test('500 → ServerFailure', () {
      expect(
        FailureMapper.fromDio(_badResponse(500, 'Internal error')),
        isA<ServerFailure>(),
      );
    });

    test('kutilmagan body formati yiqilmaydi', () {
      expect(
        FailureMapper.fromDio(_badResponse(400, 'oddiy matn')),
        isA<ValidationFailure>(),
      );
      expect(
        FailureMapper.fromDio(_badResponse(400, null)),
        isA<ValidationFailure>(),
      );
    });
  });
}
