import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../models/quiz_category.dart';

/// Savollar sonini tanlash — tezkor variantlar (5/10/15/20, faqat
/// kategoriyada shuncha savol bo'lsa ko'rinadi) yoki "− son +" stepper
/// bilan istalgan sonni (1 dan kategoriyadagi haqiqiy savollar sonigacha)
/// tanlash. Backend `min(so'ralgan, mavjud)` orqali jimgina qisqartirib
/// yuborishi mumkin edi (`app/routers/quiz.py`) — bu ekran endi shu
/// chegaradan oshirib tanlashning oldini oladi, foydalanuvchi "20 tanladim,
/// nega 10 ta chiqdi" holatiga tushmaydi. Kategoriya tanlangandan keyin,
/// Countdown'dan oldin ko'rsatiladi. Shared by Solo, Duel, and Lobby —
/// [onStart] decides what "start" actually means for each (push Quiz
/// Intro, push Duel Waiting, or call LobbyController.startGame), keeping
/// this screen ignorant of those other features' types.
class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({
    required this.category,
    required this.onStart,
    super.key,
  });

  final QuizCategory category;
  final void Function(BuildContext context, WidgetRef ref, int questionCount)
  onStart;

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  static const List<int> _quickOptions = [5, 10, 15, 20];
  static const int _minCustom = 1;
  static const int _hardMax = 50;
  static const int _defaultCount = 10;

  late final int _available = widget.category.questionCount;
  late final bool _hasQuestions = _available > 0;
  late final int _maxCustom = _hasQuestions
      ? _available.clamp(_minCustom, _hardMax)
      : _minCustom;
  late final List<int> _availableQuickOptions = _quickOptions
      .where((v) => v <= _available)
      .toList();

  late int _selectedCount = _hasQuestions
      ? (_defaultCount <= _maxCustom ? _defaultCount : _maxCustom)
      : _minCustom;

  // A fast double-tap on "Start" (before the push transition to Duel
  // Waiting/Lobby actually happens) used to fire `onStart` twice - for
  // Duel that meant two separate invites sent to the same friend from
  // one tap (2026-09-13 real-device-testing prep audit).
  bool _starting = false;
  Timer? _reenableStartTimer;

  // 2026-09-28: quizni PDF (bosma test) sifatida eksport qilish - Diamond
  // bilan to'lanadi (server narxni savollar soniga qarab hisoblaydi).
  // Har doim BUTUN kategoriya eksport qilinadi - yuqoridagi
  // `_selectedCount` (faqat o'ynash uchun tanlanadigan miqdor) bunga
  // ta'sir qilmaydi, chalkashtirmaslik uchun ataylab alohida.
  bool _exporting = false;

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final List<int> bytes = await ref
          .read(quizRepositoryProvider)
          .exportQuizPdf(widget.category.id);
      final Directory tempDir = await getTemporaryDirectory();
      final String safeName = widget.category.name
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .trim();
      final File file = File(
        '${tempDir.path}/${safeName.isEmpty ? "quiz" : safeName}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')]);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // PillSegmentControl already fires its own tap sound + haptic
  // internally - this only updates the selection.
  void _selectQuick(int count) {
    setState(() => _selectedCount = count);
  }

  void _adjust(int delta) {
    final int next = (_selectedCount + delta).clamp(_minCustom, _maxCustom);
    if (next == _selectedCount) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedCount = next);
  }

  void _start() {
    if (_starting) return;
    setState(() => _starting = true);
    widget.onStart(context, ref, _selectedCount);
    // Re-enables shortly after - this only needs to survive the brief
    // window before the push/controller call above actually takes
    // effect (blocking a fast double-tap), not disable the button
    // forever. Without this, popping back here later (e.g. cancelling
    // a Duel invite from Duel Waiting) would leave Start permanently
    // stuck disabled, since this screen's State survives underneath.
    // Stored (and cancelled in dispose()) rather than a bare
    // Future.delayed - otherwise a test/navigation that disposes this
    // screen before the delay elapses trips Flutter's
    // "Timer still pending after dispose" leak check.
    _reenableStartTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _starting = false);
    });
  }

  @override
  void dispose() {
    _reenableStartTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(
                  title: context.t.quizSetup.title,
                  onBack: () => context.pop(),
                ),
              ),
              AppSpacing.sm.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: Text(
                  context.t.quizSetup.subtitle,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: _hasQuestions
                        ? _buildPicker(context)
                        : const _NoQuestionsState(),
                  ),
                ),
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: AppButton.primary(
                  label: context.t.quizSetup.startButton,
                  onPressed: _hasQuestions && !_starting ? _start : null,
                  isLoading: _starting,
                ),
              ),
              if (_hasQuestions) ...[
                AppSpacing.sm.vGap,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 210),
                  child: AppButton.secondary(
                    label: context.t.quizSetup.exportPdfButton,
                    onPressed: _exporting ? null : _exportPdf,
                    isLoading: _exporting,
                  ),
                ),
              ],
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_availableQuickOptions.isNotEmpty) ...[
          PillSegmentControl<int>(
            values: _availableQuickOptions,
            selected: _availableQuickOptions.contains(_selectedCount)
                ? _selectedCount
                : -1,
            labelBuilder: (value) => '$value',
            onChanged: _selectQuick,
          ),
          AppSpacing.xl.vGap,
        ],
        Text(
          context.t.quizSetup.customLabel,
          textAlign: TextAlign.center,
          style: context.textStyles.labelSmall,
        ),
        AppSpacing.sm.vGap,
        Center(
          child: _CountStepper(
            count: _selectedCount,
            onDecrement: _selectedCount > _minCustom ? () => _adjust(-1) : null,
            onIncrement: _selectedCount < _maxCustom ? () => _adjust(1) : null,
          ),
        ),
        AppSpacing.sm.vGap,
        Text(
          context.t.quizSetup.availableCount(count: _available),
          textAlign: TextAlign.center,
          style: context.textStyles.labelSmall?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ],
    );
  }
}

/// Kategoriyada hech qanday faol savol yo'q — backend baribir 400
/// qaytarardi (`Bu kategoriyada savollar yo'q`), lekin bu FAQAT "Start
/// quiz" bosilgandan keyin ma'lum bo'lardi. Endi bu holat oldindan,
/// picker'ning o'zi ko'rinishidan oldin aniqlanadi.
class _NoQuestionsState extends StatelessWidget {
  const _NoQuestionsState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(TablerIcons.alertTriangle, size: 32, color: context.colors.muted),
        AppSpacing.sm.vGap,
        Text(
          context.t.quizSetup.noQuestionsAvailable,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ],
    );
  }
}

/// "− son +" boshqaruvi — CupertinoPicker g'ildiragi o'rnini bosdi: xuddi
/// shu oraliqni qamrab oladi, lekin ekranning yarmini egallamaydi va tinch
/// holatda bo'sh ko'rinmaydi.
class _CountStepper extends StatelessWidget {
  const _CountStepper({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int count;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: BorderRadius.circular(999),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: TablerIcons.minus,
            onTap: onDecrement,
            semanticLabel: context.t.quizSetup.decrement,
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(color: context.colors.ink),
            ),
          ),
          _StepButton(
            icon: TablerIcons.plus,
            onTap: onIncrement,
            semanticLabel: context.t.quizSetup.increment,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return PressableScale(
      enabled: enabled,
      child: Material(
        color: enabled ? context.colors.coral : context.colors.line,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? Colors.white : context.colors.muted,
              semanticLabel: semanticLabel,
            ),
          ),
        ),
      ),
    );
  }
}
