import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../domain/entities/player_stats.dart';

/// Joriy foydalanuvchining o'z statistikasi — `GET /leaderboard/{user_id}`ni
/// o'z ID'si bilan chaqiradi (Home va Profile ekranlari uchun umumiy). Ekran
/// ochilganda [load] chaqirilishi kerak; muvaffaqiyatsiz bo'lsa `state`
/// eskicha (yoki `null`) qoladi.
class MyStatsController extends Notifier<PlayerStats?> {
  @override
  PlayerStats? build() => null;

  Future<void> load(String userId) async {
    try {
      state = await ref.read(getPlayerStatsUseCaseProvider).call(userId);
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }
}

final NotifierProvider<MyStatsController, PlayerStats?> myStatsControllerProvider =
    NotifierProvider<MyStatsController, PlayerStats?>(MyStatsController.new);
