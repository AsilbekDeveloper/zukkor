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
    test('422 validatsiya: maydon xatolari loc/msg dan ajratiladi', () {
      final Failure failure = FailureMapper.fromDio(_badResponse(422, {
        'detail': [
          {
            'type': 'value_error',
            'loc': ['body', 'password'],
            'msg': "Parolda kamida 1 ta katta harf bo'lishi kerak",
          },
        ],
      }));

      expect(failure, isA<ValidationFailure>());
      final ValidationFailure v = failure as ValidationFailure;
      expect(v.forField('password'), "Parolda kamida 1 ta katta harf bo'lishi kerak");
      expect(v.forField('email'), isNull);
      // Umumiy xabar ham birinchi maydon xatosidan olinadi — maydon nomi
      // bilan, aks holda "field required" kabi xabarlar qaysi maydon
      // haqida ekani noma'lum bo'lib qoladi.
      expect(v.message, "password: Parolda kamida 1 ta katta harf bo'lishi kerak");
    });

    test("422 loc faqat ['body'] bo'lsa: xabar maydon nomisiz qoladi", () {
      final Failure failure = FailureMapper.fromDio(_badResponse(422, {
        'detail': [
          {'type': 'value_error', 'loc': ['body'], 'msg': 'field required'},
        ],
      }));

      expect(failure.message, 'field required');
    });

    test('400 oddiy detail matn: umumiy ValidationFailure (maydonsiz)', () {
      final Failure failure = FailureMapper.fromDio(_badResponse(400, {
        'detail': "Bu email allaqachon ro'yxatdan o'tgan",
      }));

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, "Bu email allaqachon ro'yxatdan o'tgan");
    });

    test('401 invalid_credentials: string detail xabar bo\'ladi', () {
      final Failure failure = FailureMapper.fromDio(_badResponse(401, {
        'detail': "Email yoki parol noto'g'ri",
      }));

      expect(failure, isA<AuthFailure>());
      expect(failure.message, "Email yoki parol noto'g'ri");
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
