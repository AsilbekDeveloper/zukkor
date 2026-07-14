import 'package:flutter/material.dart';

/// Standart gorizontal padding — barcha ekran o'lchamlarida bir xil
/// (prototipdagi 20px).
extension ScreenPaddingX on BuildContext {
  double get screenHPad => 20;
}

/// Sistema shrift masshtabini [min]–[max] orasida ushlaydi.
/// MaterialApp.builder ichida bir marta o'raladi — butun ilovaga ta'sir qiladi.
Widget clampTextScaling(
  BuildContext context,
  Widget? child, {
  double min = 1.0,
  double max = 1.3,
}) {
  final MediaQueryData mq = MediaQuery.of(context);
  return MediaQuery(
    data: mq.copyWith(
      textScaler: mq.textScaler.clamp(
        minScaleFactor: min,
        maxScaleFactor: max,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}
