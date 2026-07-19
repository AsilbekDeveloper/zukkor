import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/category.dart';

/// Kategoriyalar ro'yxati — `GET /categories`. Ekran ochilganda [load]
/// chaqirilishi kerak (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa
/// `state` eskicha (yoki `null`) qoladi.
class CategoriesController extends Notifier<List<Category>?> {
  @override
  List<Category>? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getCategoriesUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }
}

final NotifierProvider<CategoriesController, List<Category>?> categoriesControllerProvider =
    NotifierProvider<CategoriesController, List<Category>?>(CategoriesController.new);
