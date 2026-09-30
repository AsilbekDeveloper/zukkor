import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// One stop in a [CoachMarkController] tour — a widget to spotlight
/// (via its [targetKey]) plus the title/description shown next to it.
class CoachMarkStep {
  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;
}

/// Ketma-ket "coachmark" tur — har bir qadamda [steps]dagi widget atrofi
/// yoritilib, tagida/ustida sarlavha+tavsif ko'rsatiladi. Ilovaga birinchi
/// marta kirganda asosiy tugmalar nima qilishini tushuntirish uchun
/// (2026-10-01, foydalanuvchi so'rovi — "boshqa applardagi kabi" tur).
///
/// Uchinchi tomon paket ishlatilmadi — bosqichlar soni kam (atigi bir
/// nechta ekran), oddiy [OverlayEntry] + [CustomPainter] yetarli.
class CoachMarkController {
  CoachMarkController({
    required this.steps,
    required this.skipLabel,
    required this.nextLabel,
    required this.doneLabel,
  });

  final List<CoachMarkStep> steps;
  final String skipLabel;
  final String nextLabel;
  final String doneLabel;

  OverlayEntry? _entry;
  int _index = 0;
  VoidCallback? _onFinished;
  BuildContext? _context;

  void start(BuildContext context, {VoidCallback? onFinished}) {
    _context = context;
    _onFinished = onFinished;
    _index = 0;
    _showStep();
  }

  void _showStep() {
    _entry?.remove();
    _entry = null;
    final BuildContext? context = _context;
    if (context == null || !context.mounted) return;

    // Maqsad widget hali chizilmagan/ekranda yo'q bo'lsa (masalan boshqa
    // tabga o'tib ketilgan), shu qadamni tashlab, keyingisiga o'tamiz.
    while (_index < steps.length &&
        steps[_index].targetKey.currentContext?.findRenderObject() == null) {
      _index++;
    }
    if (_index >= steps.length) {
      _finish();
      return;
    }

    final CoachMarkStep step = steps[_index];
    final RenderBox box =
        step.targetKey.currentContext!.findRenderObject()! as RenderBox;
    final Rect targetRect = (box.localToGlobal(Offset.zero) & box.size).inflate(6);

    _entry = OverlayEntry(
      builder: (overlayContext) => _CoachMarkFrame(
        targetRect: targetRect,
        title: step.title,
        description: step.description,
        skipLabel: skipLabel,
        nextLabel: _index == steps.length - 1 ? doneLabel : nextLabel,
        onNext: _next,
        onSkip: _finish,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _next() {
    _index++;
    _showStep();
  }

  void _finish() {
    _entry?.remove();
    _entry = null;
    _onFinished?.call();
  }
}

class _CoachMarkFrame extends StatelessWidget {
  const _CoachMarkFrame({
    required this.targetRect,
    required this.title,
    required this.description,
    required this.skipLabel,
    required this.nextLabel,
    required this.onNext,
    required this.onSkip,
  });

  final Rect targetRect;
  final String title;
  final String description;
  final String skipLabel;
  final String nextLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final bool showBelow = targetRect.bottom < screen.height * 0.6;
    final double cardTop = showBelow
        ? targetRect.bottom + AppSpacing.md
        : targetRect.top - AppSpacing.md;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onNext,
            child: CustomPaint(
              painter: _SpotlightPainter(targetRect),
              size: screen,
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: showBelow ? cardTop : null,
          bottom: showBelow ? null : screen.height - cardTop,
          child: Material(
            color: context.colors.card,
            borderRadius: AppRadius.mdAll,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.xs.vGap,
                  Text(
                    description,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.ink2,
                      height: 1.4,
                    ),
                  ),
                  AppSpacing.sm.vGap,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: onSkip,
                        child: Text(skipLabel),
                      ),
                      FilledButton(
                        onPressed: onNext,
                        child: Text(nextLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// To'liq qorong'i parda chizadi, faqat [targetRect] atrofida yumaloq
/// burchakli "teshik" qoldiradi — shu orqali diqqat maqsad widgetga
/// qaratiladi.
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter(this.targetRect);

  final Rect targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    final Path outer = Path()..addRect(Offset.zero & size);
    final Path hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(targetRect, const Radius.circular(12)),
      );
    final Path overlay = Path.combine(PathOperation.difference, outer, hole);
    canvas.drawPath(overlay, Paint()..color = Colors.black.withValues(alpha: 0.72));
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, const Radius.circular(12)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}
