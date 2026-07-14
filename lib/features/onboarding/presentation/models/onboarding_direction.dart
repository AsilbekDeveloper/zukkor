import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_colors.dart';

/// The 4 direction choices offered in onboarding step 3. `apiValue` matches
/// the backend's `direction` choices exactly (Zukkor_Profil_Yaratish.docx):
/// 'student_uni' | 'student_school' | 'exam_prep' | 'casual'.
enum OnboardingDirection {
  studentUni(
    apiValue: 'student_uni',
    title: AppStrings.directionStudentUniTitle,
    subtitle: AppStrings.directionStudentUniSubtitle,
    icon: TablerIcons.school,
  ),
  studentSchool(
    apiValue: 'student_school',
    title: AppStrings.directionStudentSchoolTitle,
    subtitle: AppStrings.directionStudentSchoolSubtitle,
    icon: TablerIcons.backpack,
  ),
  examPrep(
    apiValue: 'exam_prep',
    title: AppStrings.directionExamPrepTitle,
    subtitle: AppStrings.directionExamPrepSubtitle,
    icon: TablerIcons.certificate,
  ),
  casual(
    apiValue: 'casual',
    title: AppStrings.directionCasualTitle,
    subtitle: AppStrings.directionCasualSubtitle,
    icon: TablerIcons.moodSmile,
  );

  const OnboardingDirection({
    required this.apiValue,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String apiValue;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Accent color per option — resolved from the theme so it flips
  /// correctly between light/dark (matches the prototype's c-coral/
  /// c-teal/c-green/c-pink badges).
  Color accentColor(BuildContext context) {
    final AppColors colors = context.colors;
    return switch (this) {
      OnboardingDirection.studentUni => colors.coral,
      OnboardingDirection.studentSchool => colors.teal,
      OnboardingDirection.examPrep => colors.green,
      OnboardingDirection.casual => colors.pink,
    };
  }
}
