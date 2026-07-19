import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/session_history_entry.dart';

/// O'tgan solo quiz seanslari — `GET /history`. Ekran ochilganda [load]
/// chaqirilishi kerak (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa
/// `state` eskicha (yoki `null`) qoladi.
class HistoryController extends Notifier<List<SessionHistoryEntry>?> {
  @override
  List<SessionHistoryEntry>? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getHistoryUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }
}

final NotifierProvider<HistoryController, List<SessionHistoryEntry>?> historyControllerProvider =
    NotifierProvider<HistoryController, List<SessionHistoryEntry>?>(HistoryController.new);
