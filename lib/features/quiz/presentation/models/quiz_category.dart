import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';

/// A quiz category card, shown on both Home (top 6) and the full
/// Categories screen. Built from the backend's [Category] entity via
/// [QuizCategory.fromEntity] — [icon]/[colorKey] are resolved from the
/// entity's raw `iconName`/`colorKey` strings, with a fallback for any
/// unrecognized value so an unexpected backend value never crashes.
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.icon,
    required this.colorKey,
  });

  factory QuizCategory.fromEntity(Category entity) => QuizCategory(
        id: entity.id,
        name: entity.name,
        questionCount: entity.questionCount,
        icon: _iconByName[entity.iconName] ?? _fallbackIcon,
        colorKey: CategoryColorKey.values.firstWhere(
          (key) => key.name == entity.colorKey,
          orElse: () => CategoryColorKey.coral,
        ),
      );

  final int id;
  final String name;
  final int questionCount;
  final IconData icon;
  final CategoryColorKey colorKey;

  Color color(BuildContext context) => colorKey.resolve(context);

  static const IconData _fallbackIcon = TablerIcons.category;

  /// Backend's `icon_name` values (Tabler icon slugs) mapped to their
  /// Flutter constants. Add new mappings here as new categories arrive.
  static const Map<String, IconData> _iconByName = {
    'calculator': TablerIcons.calculator,
    'book': TablerIcons.book,
    'language': TablerIcons.language,
    'movie': TablerIcons.movie,
    'ball-football': TablerIcons.ballFootball,
    'mood-smile': TablerIcons.moodSmile,
    'math-symbols': TablerIcons.mathSymbols,
  };
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
