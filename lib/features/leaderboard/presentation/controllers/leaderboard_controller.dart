import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../../domain/entities/leaderboard_scope.dart';

/// Ranked list — `GET /leaderboard`. Ekran ochilganda [load] chaqirilishi
/// kerak (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa `state` eskicha
/// (yoki `null`) qoladi. Segment almashtirilganda [load] qayta chaqiriladi
/// (natija keshlanmaydi — har bir kesim uchun alohida so'rov).
class LeaderboardController extends Notifier<LeaderboardData?> {
  @override
  LeaderboardData? build() => null;

  Future<void> load({LeaderboardScope scope = LeaderboardScope.allTime}) async {
    state = null;
    try {
      state = await ref.read(getLeaderboardUseCaseProvider).call(scope: scope);
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }
}

final NotifierProvider<LeaderboardController, LeaderboardData?> leaderboardControllerProvider =
    NotifierProvider<LeaderboardController, LeaderboardData?>(LeaderboardController.new);
