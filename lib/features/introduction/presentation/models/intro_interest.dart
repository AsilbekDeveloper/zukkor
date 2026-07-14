import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../quiz/presentation/models/quiz_category.dart';

/// One selectable chip on the Introduction interests survey page. Labels
/// mostly line up with [QuizCategory.sample] so the pick actually maps to
/// something the app can recommend later.
class IntroInterest {
  const IntroInterest({required this.label, required this.icon, required this.colorKey});

  final String label;
  final IconData icon;
  final CategoryColorKey colorKey;

  Color color(BuildContext context) => colorKey.resolve(context);

  static const List<IntroInterest> sample = [
    IntroInterest(label: 'Math', icon: TablerIcons.mathSymbols, colorKey: CategoryColorKey.coral),
    IntroInterest(label: 'History', icon: TablerIcons.book2, colorKey: CategoryColorKey.terra),
    IntroInterest(label: 'English', icon: TablerIcons.language, colorKey: CategoryColorKey.teal),
    IntroInterest(label: 'Movies', icon: TablerIcons.movie, colorKey: CategoryColorKey.pink),
    IntroInterest(label: 'Sport', icon: TablerIcons.ballFootball, colorKey: CategoryColorKey.green),
    IntroInterest(label: 'Memes', icon: TablerIcons.moodSmile, colorKey: CategoryColorKey.blue),
    IntroInterest(label: 'Science', icon: TablerIcons.flask, colorKey: CategoryColorKey.teal),
    IntroInterest(label: 'Music', icon: TablerIcons.music, colorKey: CategoryColorKey.pink),
    IntroInterest(label: 'Technology', icon: TablerIcons.deviceLaptop, colorKey: CategoryColorKey.coral),
    IntroInterest(label: 'Art', icon: TablerIcons.palette, colorKey: CategoryColorKey.terra),
  ];
}
