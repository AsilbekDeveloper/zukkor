import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../core/widgets/step_header.dart';
import '../models/study_survey.dart';

/// Introduction page 6 — two short, fun closing questions: where the user
/// studies, and whether they like solving quizzes/puzzles.
class StudySurveyStep extends StatelessWidget {
  const StudySurveyStep({
    super.key,
    required this.studyPlace,
    required this.onStudyPlaceChanged,
    required this.otherStudyPlaceController,
    required this.quizLiking,
    required this.onQuizLikingChanged,
    this.accentColor,
  });

  final StudyPlace studyPlace;
  final ValueChanged<StudyPlace> onStudyPlaceChanged;
  final TextEditingController otherStudyPlaceController;
  final QuizLiking quizLiking;
  final ValueChanged<QuizLiking> onQuizLikingChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          icon: TablerIcons.school,
          title: AppStrings.introStudyTitle,
          subtitle: AppStrings.introStudySubtitle,
          badgeColor: accentColor,
        ),
        AppSpacing.xl.vGap,
        Text(AppStrings.introStudyPlaceLabel, style: context.textStyles.titleMedium),
        AppSpacing.sm.vGap,
        PillSegmentControl<StudyPlace>(
          values: StudyPlace.values,
          selected: studyPlace,
          labelBuilder: (value) => value.label,
          onChanged: onStudyPlaceChanged,
        ),
        if (studyPlace == StudyPlace.other) ...[
          AppSpacing.md.vGap,
          AppTextField(
            label: AppStrings.introOtherFieldLabel,
            hint: AppStrings.introOtherFieldHint,
            controller: otherStudyPlaceController,
            textInputAction: TextInputAction.done,
          ),
        ],
        AppSpacing.xl.vGap,
        Text(AppStrings.introQuizLikingLabel, style: context.textStyles.titleMedium),
        AppSpacing.sm.vGap,
        PillSegmentControl<QuizLiking>(
          values: QuizLiking.values,
          selected: quizLiking,
          labelBuilder: (value) => value.label,
          onChanged: onQuizLikingChanged,
        ),
      ],
    );
  }
}
