import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('null yoki bo\'sh qiymat — xato', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('   '), isNotNull);
    });

    test('noto\'g\'ri formatlar rad etiladi', () {
      expect(Validators.email('aziz'), isNotNull);
      expect(Validators.email('aziz@'), isNotNull);
      expect(Validators.email('aziz@mail'), isNotNull);
      expect(Validators.email('@mail.com'), isNotNull);
      expect(Validators.email('aziz mail@x.uz'), isNotNull);
    });

    test('to\'g\'ri formatlar o\'tadi', () {
      expect(Validators.email('aziz@example.com'), isNull);
      expect(Validators.email('a.z+test@mail.co.uz'), isNull);
      // Chetlaridagi bo'shliq trim qilinadi.
      expect(Validators.email('  aziz@example.com  '), isNull);
    });
  });

  group('Validators.password (backend: kamida 8 belgi)', () {
    test('bo\'sh — xato', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('7 belgi — xato, 8 belgi — o\'tadi (chegara)', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('bo\'sh — xato', () {
      expect(Validators.confirmPassword(null, 'parol123'), isNotNull);
      expect(Validators.confirmPassword('', 'parol123'), isNotNull);
    });

    test('asosiy parol bilan mos kelmasa — xato', () {
      expect(Validators.confirmPassword('boshqa123', 'parol123'), isNotNull);
    });

    test('asosiy parol bilan bir xil bo\'lsa — o\'tadi', () {
      expect(Validators.confirmPassword('parol123', 'parol123'), isNull);
    });
  });

  group('Validators.username (backend: ^[a-zA-Z0-9_]{3,30}\$)', () {
    test('chegaralar: 2 belgi xato, 3 va 30 o\'tadi, 31 xato', () {
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('abc'), isNull);
      expect(Validators.username('a' * 30), isNull);
      expect(Validators.username('a' * 31), isNotNull);
    });

    test('ruxsat etilmagan belgilar rad etiladi', () {
      expect(Validators.username('aziz karimov'), isNotNull);
      expect(Validators.username('aziz-karimov'), isNotNull);
      expect(Validators.username('aziz@k'), isNotNull);
      expect(Validators.username("o'zbek"), isNotNull);
    });

    test('harf/raqam/pastki chiziq o\'tadi', () {
      expect(Validators.username('Aziz_Karimov'), isNull);
      expect(Validators.username('user_123'), isNull);
    });
  });

  group('Validators.personName (backend: 1-50 belgi)', () {
    test('bo\'sh — xato', () {
      expect(Validators.personName(''), isNotNull);
      expect(Validators.personName('   '), isNotNull);
    });

    test('50 belgi o\'tadi, 51 — xato (chegara)', () {
      expect(Validators.personName('a' * 50), isNull);
      expect(Validators.personName('a' * 51), isNotNull);
    });
  });
}
