import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_colors.dart';

/// A quiz category card, shown on both Home (top 6) and the full
/// Categories screen (Zukkor_Ball_XP_Tizimi.docx: `Category` model —
/// name/icon/color/question_count). This is placeholder sample data —
/// once the `quiz` feature's data layer exists, this list comes from
/// `GET /api/categories/` instead.
class QuizCategory {
  const QuizCategory({
    required this.name,
    required this.questionCount,
    required this.icon,
    required this.colorKey,
  });

  final String name;
  final int questionCount;
  final IconData icon;
  final CategoryColorKey colorKey;

  Color color(BuildContext context) => colorKey.resolve(context);

  static const List<QuizCategory> sample = [
    QuizCategory(
      name: 'Math',
      questionCount: 120,
      icon: TablerIcons.mathSymbols,
      colorKey: CategoryColorKey.coral,
    ),
    QuizCategory(
      name: 'History',
      questionCount: 98,
      icon: TablerIcons.book2,
      colorKey: CategoryColorKey.terra,
    ),
    QuizCategory(
      name: 'English',
      questionCount: 150,
      icon: TablerIcons.language,
      colorKey: CategoryColorKey.teal,
    ),
    QuizCategory(
      name: 'Movies',
      questionCount: 76,
      icon: TablerIcons.movie,
      colorKey: CategoryColorKey.pink,
    ),
    QuizCategory(
      name: 'Football',
      questionCount: 64,
      icon: TablerIcons.ballFootball,
      colorKey: CategoryColorKey.green,
    ),
    QuizCategory(
      name: 'Memes',
      questionCount: 50,
      icon: TablerIcons.moodSmile,
      colorKey: CategoryColorKey.blue,
    ),
  ];
}

/// Matches the prototype's `.c-coral` / `.c-terra` / ... category badge
/// classes.
enum CategoryColorKey {
  coral,
  terra,
  teal,
  pink,
  green,
  blue;

  Color resolve(BuildContext context) {
    final AppColors c = context.colors;
    return switch (this) {
      CategoryColorKey.coral => c.coral,
      CategoryColorKey.terra => c.terra,
      CategoryColorKey.teal => c.teal,
      CategoryColorKey.pink => c.pink,
      CategoryColorKey.green => c.green,
      CategoryColorKey.blue => c.blue,
    };
  }
}
