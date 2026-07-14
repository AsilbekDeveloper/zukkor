import '../../../../core/constants/app_strings.dart';

/// Where the user studies — offered as quick pills on the last
/// Introduction page. [other] reveals a free-text field for anything not
/// listed (e.g. "not studying", a specific exam).
enum StudyPlace {
  school(AppStrings.introStudyPlaceSchool),
  university(AppStrings.introStudyPlaceUniversity),
  examPrep(AppStrings.introStudyPlaceExamPrep),
  other(AppStrings.introOtherOption);

  const StudyPlace(this.label);

  final String label;
}

/// "Do you enjoy solving quizzes and puzzles?" — a light-touch sentiment
/// pill, no free-text fallback needed.
enum QuizLiking {
  loveIt(AppStrings.introQuizLikingLoveIt),
  itsOk(AppStrings.introQuizLikingItsOk),
  notReally(AppStrings.introQuizLikingNotReally);

  const QuizLiking(this.label);

  final String label;
}
