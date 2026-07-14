import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// Visual state of a single answer option once the question has been
/// answered (or timed out) — mirrors the prototype's implicit
/// right/wrong feedback (`data-nav="result"` on every `.answer` there
/// just skips straight to the result; here it's animated for real).
enum AnswerVisualState {
  /// Not answered yet — default card styling.
  idle,

  /// This is the option the user picked, and it was correct.
  pickedCorrect,

  /// This is the option the user picked, and it was wrong.
  pickedWrong,

  /// The user picked a different (wrong) option — this reveals which
  /// one actually was correct.
  revealCorrect,
}

/// A single answer row — letter badge + text — mirrors the prototype's
/// `.answer` / `.answer-letter`.
class AnswerButton extends StatelessWidget {
  const AnswerButton({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
    super.key,
  });

  final String letter;
  final String text;
  final AnswerVisualState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color? fill = switch (state) {
      AnswerVisualState.idle => null,
      AnswerVisualState.pickedCorrect => context.colors.green,
      AnswerVisualState.pickedWrong => context.colors.error,
      AnswerVisualState.revealCorrect => null,
    };
    final Color border = switch (state) {
      AnswerVisualState.idle => context.colors.line,
      AnswerVisualState.pickedCorrect => context.colors.green,
      AnswerVisualState.pickedWrong => context.colors.error,
      AnswerVisualState.revealCorrect => context.colors.green,
    };
    final Color textColor = fill != null ? Colors.white : context.colors.ink;
    final Color badgeBg = fill != null ? Colors.white : context.colors.cream;
    final Color badgeFg = switch (state) {
      AnswerVisualState.idle => context.colors.ink2,
      AnswerVisualState.pickedCorrect => context.colors.green,
      AnswerVisualState.pickedWrong => context.colors.error,
      AnswerVisualState.revealCorrect => context.colors.green,
    };

    return Material(
      color: fill ?? context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: badgeBg, borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: state == AnswerVisualState.pickedCorrect || state == AnswerVisualState.revealCorrect
                    ? Icon(TablerIcons.check, size: 16, color: badgeFg)
                    : state == AnswerVisualState.pickedWrong
                        ? Icon(TablerIcons.x, size: 16, color: badgeFg)
                        : Text(
                            letter,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: badgeFg),
                          ),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
