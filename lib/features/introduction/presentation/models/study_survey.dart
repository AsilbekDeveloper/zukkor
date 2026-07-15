import 'package:flutter/widgets.dart';

import '../../../../i18n/strings.g.dart';

/// Where the user studies — offered as quick pills on the last
/// Introduction page. [other] reveals a free-text field for anything not
/// listed (e.g. "not studying", a specific exam).
enum StudyPlace { school, university, examPrep, other }

extension StudyPlaceLabel on StudyPlace {
  /// Needs [context] (not a const field) so the label re-translates when
  /// the locale changes.
  String label(BuildContext context) => switch (this) {
        StudyPlace.school => context.t.introduction.studyPlaceSchool,
        StudyPlace.university => context.t.introduction.studyPlaceUniversity,
        StudyPlace.examPrep => context.t.introduction.studyPlaceExamPrep,
        StudyPlace.other => context.t.introduction.otherOption,
      };
}

/// "Do you enjoy solving quizzes and puzzles?" — a light-touch sentiment
/// pill, no free-text fallback needed.
enum QuizLiking { loveIt, itsOk, notReally }

extension QuizLikingLabel on QuizLiking {
  String label(BuildContext context) => switch (this) {
        QuizLiking.loveIt => context.t.introduction.quizLikingLoveIt,
        QuizLiking.itsOk => context.t.introduction.quizLikingItsOk,
        QuizLiking.notReally => context.t.introduction.quizLikingNotReally,
      };
}
