import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../i18n/strings.g.dart';

/// The 4 direction choices offered in onboarding step 3. `apiValue` matches
/// the backend's `direction` choices exactly (Zukkor_Profil_Yaratish.docx):
/// 'student_uni' | 'student_school' | 'exam_prep' | 'casual'.
enum OnboardingDirection {
  studentUni(apiValue: 'student_uni', icon: TablerIcons.school),
  studentSchool(apiValue: 'student_school', icon: TablerIcons.backpack),
  examPrep(apiValue: 'exam_prep', icon: TablerIcons.certificate),
  casual(apiValue: 'casual', icon: TablerIcons.moodSmile);

  const OnboardingDirection({required this.apiValue, required this.icon});

  final String apiValue;
  final IconData icon;

  /// Not a const field — needs [context] so it re-translates when the
  /// locale changes.
  String title(BuildContext context) => switch (this) {
        OnboardingDirection.studentUni => context.t.onboarding.studentUniTitle,
        OnboardingDirection.studentSchool => context.t.onboarding.studentSchoolTitle,
        OnboardingDirection.examPrep => context.t.onboarding.examPrepTitle,
        OnboardingDirection.casual => context.t.onboarding.casualTitle,
      };

  String subtitle(BuildContext context) => switch (this) {
        OnboardingDirection.studentUni => context.t.onboarding.studentUniSubtitle,
        OnboardingDirection.studentSchool => context.t.onboarding.studentSchoolSubtitle,
        OnboardingDirection.examPrep => context.t.onboarding.examPrepSubtitle,
        OnboardingDirection.casual => context.t.onboarding.casualSubtitle,
      };

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
