import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/weekly_activity.dart';

class WeeklyActivityController extends Notifier<LoadState<WeeklyActivity>> {
  @override
  LoadState<WeeklyActivity> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      state = LoadState(data: await ref.read(historyRepositoryProvider).getWeeklyActivity());
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }
}

final NotifierProvider<WeeklyActivityController, LoadState<WeeklyActivity>> weeklyActivityControllerProvider =
    NotifierProvider<WeeklyActivityController, LoadState<WeeklyActivity>>(WeeklyActivityController.new);
