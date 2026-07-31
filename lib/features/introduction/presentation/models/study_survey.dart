import 'package:flutter/widgets.dart';

import '../../../../i18n/strings.g.dart';

/// "Other" erkin matn javoblari (qiziqish va o'qish joyi) uchun belgilar
/// chegarasi. Backend'dagi `MAX_STUDY_PLACE_LEN` / `MAX_INTEREST_LEN` (50)
/// bilan bir xil — aks holda kiritilgan qiymatni server rad etardi.
const int kOtherAnswerMaxLength = 50;

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

  /// Backend's `study_place` choices — [StudyPlace.other]'s actual value
  /// is the free-text answer, resolved by the caller, not this tag.
  String get apiValue => switch (this) {
        StudyPlace.school => 'school',
        StudyPlace.university => 'university',
        StudyPlace.examPrep => 'exam_prep',
        StudyPlace.other => 'other',
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

  /// Backend's `quiz_liking` choices.
  String get apiValue => switch (this) {
        QuizLiking.loveIt => 'love_it',
        QuizLiking.itsOk => 'its_ok',
        QuizLiking.notReally => 'not_really',
      };
}

/// Turns a raw `User.studyPlace`/`User.quizLiking` string (as stored by
/// the backend) back into a translated label for display — used by
/// Profile/Edit Profile, which only have the raw string, not the enum
/// the Introduction survey originally picked from.
extension StudyPlaceRawValue on String {
  /// `null` when this is [StudyPlace.other]'s own free-text answer
  /// (stored as the literal text itself, not the `other` tag) rather
  /// than one of the fixed pill choices — used to pre-select the right
  /// pill (and route the actual text into the "Other" field) when
  /// Edit Profile reopens the survey for editing.
  StudyPlace? get matchedStudyPlaceTag {
    for (final tag in StudyPlace.values) {
      if (tag.apiValue == this) return tag;
    }
    return null;
  }

  /// An unrecognized value is already exactly what should be shown —
  /// [StudyPlace.other]'s free-text answer, never a raw, untranslated
  /// backend code leaking onto the screen.
  String studyPlaceLabel(BuildContext context) => matchedStudyPlaceTag?.label(context) ?? this;

  /// Unlike [studyPlaceLabel], `quiz_liking` has no free-text option, so
  /// an unrecognized value can only mean stale/foreign data — falls back
  /// to the raw string rather than hiding it outright.
  String quizLikingLabel(BuildContext context) {
    for (final tag in QuizLiking.values) {
      if (tag.apiValue == this) return tag.label(context);
    }
    return this;
  }
}
