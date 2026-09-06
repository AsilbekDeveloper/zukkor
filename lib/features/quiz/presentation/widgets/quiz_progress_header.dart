import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';

/// Back button + "Question X/Y" progress bar + running score — mirrors
/// the prototype's quiz `.header` / `.quiz-progress` / `.quiz-score`.
class QuizProgressHeader extends StatelessWidget {
  const QuizProgressHeader({
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    required this.onBack,
    super.key,
  });

  final int questionNumber;
  final int totalQuestions;
  final int score;
  final VoidCallback onBack;

  void _handleBack() {
    HapticFeedback.lightImpact();
    onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PressableScale(
          child: Material(
            color: context.colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.smAll,
              side: BorderSide(color: context.colors.line),
            ),
            child: InkWell(
              onTap: _handleBack,
              borderRadius: AppRadius.smAll,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  TablerIcons.arrowLeft,
                  color: context.colors.ink,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        AppSpacing.sm.hGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t.quiz.questionProgress(
                  current: questionNumber,
                  total: totalQuestions,
                ),
                style: context.textStyles.labelSmall,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: questionNumber / totalQuestions,
                  ),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: context.colors.line,
                    valueColor: AlwaysStoppedAnimation(
                      context.colors.surfaceDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.sm.hGap,
        Text(
          '$score',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: context.colors.coralDeep,
          ),
        ),
      ],
    );
  }
}
