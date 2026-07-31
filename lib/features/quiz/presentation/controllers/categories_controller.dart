import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/category.dart';

/// Kategoriyalar ro'yxati — `GET /categories`. Ekran ochilganda [load]
/// chaqirilishi kerak (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa
/// `state.hasError` `true` bo'ladi — chaqiruvchi ekran qayta urinish
/// tugmasini ko'rsatadi.
class CategoriesController extends Notifier<LoadState<List<Category>>> {
  @override
  LoadState<List<Category>> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      state = LoadState(data: await ref.read(getCategoriesUseCaseProvider).call());
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }
}

final NotifierProvider<CategoriesController, LoadState<List<Category>>> categoriesControllerProvider =
    NotifierProvider<CategoriesController, LoadState<List<Category>>>(CategoriesController.new);
