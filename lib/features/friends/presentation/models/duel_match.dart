import '../../../quiz/presentation/models/quiz_category.dart';
import 'friend_entry.dart';

/// Which friend and category a duel is being set up for — bundles both
/// into one object so they can travel together through a single
/// go_router `extra` (Categories → Duel Waiting).
class DuelMatch {
  const DuelMatch({required this.opponent, required this.category});

  final FriendEntry opponent;
  final QuizCategory category;
}
