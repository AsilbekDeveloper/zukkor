import 'package:flutter/material.dart';

/// Matn uslublari shkalasi — Plus Jakarta Sans, prototipdagi vazn/o'lchamlarga mos.
///
/// MUHIM: bu uslublar RANG BELGILAMAYDI — rang har doim temadan keladi
/// (`context.colors.ink` va h.k.), shunda light/dark almashganda matnlar
/// avtomatik to'g'ri ko'rinadi.
abstract final class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  /// Katta raqamlar/hero sarlavha (natija ekrani balli kabi).
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
  );

  /// Ekran sarlavhasi.
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.3,
  );

  /// Bo'lim sarlavhasi / dialog sarlavhasi.
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// Karta ichidagi nom, ro'yxat elementi sarlavhasi.
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  /// Asosiy matn.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.5,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  /// Tugma matni.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Kichik yordamchi matn (input ostidagi izoh, meta ma'lumot).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Juda kichik yorliqlar (badge, tab nomi).
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.3,
  );
}
