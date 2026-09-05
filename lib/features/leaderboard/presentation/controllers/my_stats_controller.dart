import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../domain/entities/player_stats.dart';

/// Joriy foydalanuvchining o'z statistikasi — `GET /leaderboard/{user_id}`ni
/// o'z ID'si bilan chaqiradi (Home va Profile ekranlari uchun umumiy). Ekran
/// ochilganda [load] chaqirilishi kerak; muvaffaqiyatsiz bo'lsa
/// `state.hasError` `true` bo'ladi.
class MyStatsController extends Notifier<LoadState<PlayerStats>> {
  @override
  LoadState<PlayerStats> build() => const LoadState();

  Future<void> load(String userId) async {
    debugPrint('[ZUKKOR-DIAG] MyStatsController.load($userId) chaqirildi');
    state = const LoadState();
    try {
      final stats = await ref.read(getPlayerStatsUseCaseProvider).call(userId);
      debugPrint('[ZUKKOR-DIAG] MyStatsController.load() muvaffaqiyatli: ${stats.gamesPlayed} o\'yin');
      state = LoadState(data: stats);
    } catch (e, st) {
      debugPrint('[ZUKKOR-DIAG] MyStatsController.load() XATO: $e\n$st');
      state = const LoadState(hasError: true);
    }
  }
}

final NotifierProvider<MyStatsController, LoadState<PlayerStats>> myStatsControllerProvider =
    NotifierProvider<MyStatsController, LoadState<PlayerStats>>(MyStatsController.new);
