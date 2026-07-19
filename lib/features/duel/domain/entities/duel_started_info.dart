import '../../../quiz/domain/entities/category.dart';
import 'duel_participant.dart';

/// `duel_started` — sent to both players right after acceptance, before
/// the first question arrives.
class DuelStartedInfo {
  const DuelStartedInfo({
    required this.duelId,
    required this.category,
    required this.totalQuestions,
    required this.opponent,
  });

  final String duelId;
  final Category category;
  final int totalQuestions;
  final DuelParticipant opponent;
}
