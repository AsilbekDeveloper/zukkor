import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// ThemeData quruvchi — komponentlarning ko'rinishi (tugma, input, karta,
/// appbar) BIR MARTA shu yerda belgilanadi. Ekranlar hech qachon o'z uslubini
/// qayta yozmaydi (DRY): `ElevatedButton` hamma joyda avtomatik coral bo'ladi.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.coral,
      onPrimary: Colors.white,
      secondary: c.teal,
      onSecondary: Colors.white,
      error: c.error,
      onError: Colors.white,
      surface: c.card,
      onSurface: c.ink,
      surfaceContainerHighest: c.cream,
      outline: c.line,
      outlineVariant: c.line,
      shadow: Colors.black26,
    );

    final TextTheme textTheme = TextTheme(
      displaySmall: AppTextStyles.display.copyWith(color: c.ink),
      headlineMedium: AppTextStyles.headline.copyWith(color: c.ink),
      titleLarge: AppTextStyles.title.copyWith(color: c.ink),
      titleMedium: AppTextStyles.subtitle.copyWith(color: c.ink),
      bodyMedium: AppTextStyles.body.copyWith(color: c.ink2),
      labelLarge: AppTextStyles.button.copyWith(color: c.ink),
      bodySmall: AppTextStyles.caption.copyWith(color: c.muted),
      labelSmall: AppTextStyles.micro.copyWith(color: c.muted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: c.cream,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: c.cream,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(color: c.ink),
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      // Asosiy (coral) tugma — prototipdagi .hero-play.full uslubi.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.coral,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.coral.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Ikkilamchi (oq/karta fonli) tugma — prototipdagi .mp-btn.light uslubi.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.card,
          foregroundColor: c.ink,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: c.line, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.coralDeep,
          textStyle: AppTextStyles.button.copyWith(fontSize: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        hintStyle: AppTextStyles.body.copyWith(color: c.muted),
        labelStyle: AppTextStyles.caption.copyWith(color: c.ink2),
        errorStyle: AppTextStyles.caption.copyWith(color: c.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.coral, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: c.error, width: 1.8),
        ),
      ),

      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: c.line),
        ),
      ),

      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceDark,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.coral),
    );
  }
}
