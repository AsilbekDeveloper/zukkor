import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// BuildContext qisqartmalari — ekran kodini toza saqlaydi:
/// `Theme.of(context).extension<AppColors>()!` o'rniga `context.colors`.
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// Zukkor palitra (light/dark ga qarab avtomatik).
  AppColors get colors => theme.extension<AppColors>()!;

  TextTheme get textStyles => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Klaviatura balandligi (ochiq bo'lsa > 0).
  double get keyboardInset => MediaQuery.viewInsetsOf(this).bottom;

  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: action,
      ));
  }
}
