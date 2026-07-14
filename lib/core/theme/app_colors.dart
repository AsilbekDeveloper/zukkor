import 'package:flutter/material.dart';

/// Zukkor rang tizimi — prototip (style4.css) bilan 1:1.
///
/// `ThemeExtension` sifatida yozilgan: light/dark rejim almashganda
/// `context.colors` avtomatik to'g'ri palitrani qaytaradi, ekran kodi
/// hech qachon rejimni tekshirmaydi va hex qiymat yozmaydi.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.coral,
    required this.coralDeep,
    required this.coralDark,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.line,
    required this.cream,
    required this.card,
    required this.surfaceDark,
    required this.terra,
    required this.teal,
    required this.pink,
    required this.green,
    required this.blue,
    required this.error,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowCoral,
  });

  /// Brend rangi — tugmalar, aksentlar.
  final Color coral;
  final Color coralDeep;
  final Color coralDark;

  /// Asosiy matn rangi.
  final Color ink;

  /// Ikkilamchi matn.
  final Color ink2;

  /// Xira matn (izohlar, placeholder).
  final Color muted;

  /// Chegara/ajratgich chiziqlar.
  final Color line;

  /// Ekran foni.
  final Color cream;

  /// Karta/panel foni.
  final Color card;

  /// Ataylab to'q dekorativ yuza (hero karta osti, kod maydoni).
  final Color surfaceDark;

  // Kategoriya ranglari.
  final Color terra;
  final Color teal;
  final Color pink;
  final Color green;
  final Color blue;

  /// Xatolik holati.
  final Color error;

  // Soyalar — prototipdagi shadow-sm/md/coral.
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowCoral;

  static const AppColors light = AppColors(
    coral: Color(0xFFF4502C),
    coralDeep: Color(0xFFD93B18),
    coralDark: Color(0xFFB32E10),
    ink: Color(0xFF211410),
    ink2: Color(0xFF55423B),
    muted: Color(0xFF94827B),
    line: Color(0xFFF0E4DF),
    cream: Color(0xFFFBF6F2),
    card: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF211410),
    terra: Color(0xFFD97706),
    teal: Color(0xFF0D9488),
    pink: Color(0xFFDB2777),
    green: Color(0xFF16A34A),
    blue: Color(0xFF2563EB),
    error: Color(0xFFDC2626),
    shadowSm: [
      BoxShadow(
        color: Color(0x0D211410), // rgba(33,20,16,.05)
        offset: Offset(0, 2),
        blurRadius: 10,
      ),
    ],
    shadowMd: [
      BoxShadow(
        color: Color(0x17211410), // rgba(33,20,16,.09)
        offset: Offset(0, 12),
        blurRadius: 30,
      ),
    ],
    shadowCoral: [
      BoxShadow(
        color: Color(0x52D93B18), // rgba(217,59,24,.32)
        offset: Offset(0, 12),
        blurRadius: 28,
      ),
    ],
  );

  static const AppColors dark = AppColors(
    coral: Color(0xFFF4502C),
    coralDeep: Color(0xFFD93B18),
    coralDark: Color(0xFFB32E10),
    ink: Color(0xFFF2ECE7),
    ink2: Color(0xFFC7B8AE),
    muted: Color(0xFF93857C),
    line: Color(0xFF372B23),
    cream: Color(0xFF17120E),
    card: Color(0xFF221A15),
    surfaceDark: Color(0xFF0B0806),
    terra: Color(0xFFD97706),
    teal: Color(0xFF0D9488),
    pink: Color(0xFFDB2777),
    green: Color(0xFF16A34A),
    blue: Color(0xFF2563EB),
    error: Color(0xFFEF4444),
    shadowSm: [
      BoxShadow(
        color: Color(0x59000000), // rgba(0,0,0,.35)
        offset: Offset(0, 2),
        blurRadius: 10,
      ),
    ],
    shadowMd: [
      BoxShadow(
        color: Color(0x73000000), // rgba(0,0,0,.45)
        offset: Offset(0, 12),
        blurRadius: 30,
      ),
    ],
    shadowCoral: [
      BoxShadow(
        color: Color(0x61F4502C), // rgba(244,80,44,.38)
        offset: Offset(0, 12),
        blurRadius: 28,
      ),
    ],
  );

  @override
  AppColors copyWith({
    Color? coral,
    Color? coralDeep,
    Color? coralDark,
    Color? ink,
    Color? ink2,
    Color? muted,
    Color? line,
    Color? cream,
    Color? card,
    Color? surfaceDark,
    Color? terra,
    Color? teal,
    Color? pink,
    Color? green,
    Color? blue,
    Color? error,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
    List<BoxShadow>? shadowCoral,
  }) {
    return AppColors(
      coral: coral ?? this.coral,
      coralDeep: coralDeep ?? this.coralDeep,
      coralDark: coralDark ?? this.coralDark,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      cream: cream ?? this.cream,
      card: card ?? this.card,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      terra: terra ?? this.terra,
      teal: teal ?? this.teal,
      pink: pink ?? this.pink,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      error: error ?? this.error,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowCoral: shadowCoral ?? this.shadowCoral,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      coral: Color.lerp(coral, other.coral, t)!,
      coralDeep: Color.lerp(coralDeep, other.coralDeep, t)!,
      coralDark: Color.lerp(coralDark, other.coralDark, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      card: Color.lerp(card, other.card, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      terra: Color.lerp(terra, other.terra, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      green: Color.lerp(green, other.green, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      error: Color.lerp(error, other.error, t)!,
      shadowSm: BoxShadow.lerpList(shadowSm, other.shadowSm, t) ?? shadowSm,
      shadowMd: BoxShadow.lerpList(shadowMd, other.shadowMd, t) ?? shadowMd,
      shadowCoral:
          BoxShadow.lerpList(shadowCoral, other.shadowCoral, t) ?? shadowCoral,
    );
  }
}
