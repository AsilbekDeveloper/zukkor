import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../domain/entities/player_stats.dart';

/// One player's full stats — `GET /leaderboard/{user_id}`. Holati —
/// shunchaki `isLoading` bayrog'i; xatolikni chaqiruvchi ekranning o'zi
/// `try/catch` bilan ushlaydi (Quiz'dagi kabi).
class PlayerStatsController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<PlayerStats> getPlayerStats(String userId) async {
    state = true;
    try {
      return await ref.read(getPlayerStatsUseCaseProvider).call(userId);
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<PlayerStatsController, bool> playerStatsControllerProvider =
    NotifierProvider<PlayerStatsController, bool>(PlayerStatsController.new);
