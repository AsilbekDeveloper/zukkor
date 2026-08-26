import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/audio/app_sound.dart';
import '../../../../core/audio/sound_controller.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../i18n/strings.g.dart';
import '../models/quiz_category.dart';

/// Savollar sonini tanlash — tezkor variantlar (5/10/15/20) yoki
/// "− son +" stepper bilan istalgan sonni (1-50) tanlash. Kategoriya
/// tanlangandan keyin, Countdown'dan oldin ko'rsatiladi. Shared by Solo,
/// Duel, and Lobby — [onStart] decides what "start" actually means for
/// each (push Quiz Intro, push Duel Waiting, or call
/// LobbyController.startGame), keeping this screen ignorant of those
/// other features' types.
class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({required this.category, required this.onStart, super.key});

  final QuizCategory category;
  final void Function(BuildContext context, WidgetRef ref, int questionCount) onStart;

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  static const List<int> _quickOptions = [5, 10, 15, 20];
  static const int _minCustom = 1;
  static const int _maxCustom = 50;
  static const int _defaultCount = 10;

  int _selectedCount = _defaultCount;

  void _selectQuick(int count) {
    ref.playSound(AppSound.tap);
    setState(() => _selectedCount = count);
  }

  void _adjust(int delta) {
    final int next = (_selectedCount + delta).clamp(_minCustom, _maxCustom);
    if (next == _selectedCount) return;
    ref.playSound(AppSound.tap);
    setState(() => _selectedCount = next);
  }

  void _start() {
    widget.onStart(context, ref, _selectedCount);
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
              BackHeader(title: context.t.quizSetup.title, onBack: () => context.pop()),
              AppSpacing.sm.vGap,
              Text(
                context.t.quizSetup.subtitle,
                style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PillSegmentControl<int>(
                        values: _quickOptions,
                        selected: _quickOptions.contains(_selectedCount) ? _selectedCount : -1,
                        labelBuilder: (value) => '$value',
                        onChanged: _selectQuick,
                      ),
                      AppSpacing.xl.vGap,
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
                    ],
                  ),
                ),
              ),
              AppButton.primary(
                label: context.t.quizSetup.startButton,
                onPressed: _start,
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}

/// "− son +" boshqaruvi — CupertinoPicker g'ildiragi o'rnini bosdi: xuddi
/// shu 1-50 oralig'ini qamrab oladi, lekin ekranning yarmini egallamaydi
/// va tinch holatda bo'sh ko'rinmaydi.
class _CountStepper extends StatelessWidget {
  const _CountStepper({required this.count, required this.onDecrement, required this.onIncrement});

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
          _StepButton(icon: TablerIcons.minus, onTap: onDecrement, semanticLabel: context.t.quizSetup.decrement),
          SizedBox(
            width: 64,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(color: context.colors.ink),
            ),
          ),
          _StepButton(icon: TablerIcons.plus, onTap: onIncrement, semanticLabel: context.t.quizSetup.increment),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap, required this.semanticLabel});

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Material(
      color: enabled ? context.colors.coral : context.colors.line,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 18, color: enabled ? Colors.white : context.colors.muted, semanticLabel: semanticLabel),
        ),
      ),
    );
  }
}
