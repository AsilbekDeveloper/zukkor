import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../core/widgets/step_header.dart';
import '../../../../i18n/strings.g.dart';
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
          title: context.t.introduction.studyTitle,
          subtitle: context.t.introduction.studySubtitle,
          badgeColor: accentColor,
        ),
        AppSpacing.xl.vGap,
        Text(context.t.introduction.studyPlaceLabel, style: context.textStyles.titleMedium),
        AppSpacing.sm.vGap,
        PillSegmentControl<StudyPlace>(
          values: StudyPlace.values,
          selected: studyPlace,
          labelBuilder: (value) => value.label(context),
          onChanged: onStudyPlaceChanged,
        ),
        if (studyPlace == StudyPlace.other) ...[
          AppSpacing.md.vGap,
          AppTextField(
            label: context.t.introduction.otherFieldLabel,
            hint: context.t.introduction.otherFieldHint,
            controller: otherStudyPlaceController,
            textInputAction: TextInputAction.done,
          ),
        ],
        AppSpacing.xl.vGap,
        Text(context.t.introduction.quizLikingLabel, style: context.textStyles.titleMedium),
        AppSpacing.sm.vGap,
        PillSegmentControl<QuizLiking>(
          values: QuizLiking.values,
          selected: quizLiking,
          labelBuilder: (value) => value.label(context),
          onChanged: onQuizLikingChanged,
        ),
      ],
    );
  }
}
