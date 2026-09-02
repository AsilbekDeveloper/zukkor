import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Foydalanuvchi hozir aktiv o'yinda (Solo Quiz, Duel yoki Lobby) ekanligini
/// kuzatib boradi — bezovta qiluvchi UI uzilishlarining (masalan avtomatik
/// to'liq ekranli duel taklifi) oldini olish uchun ishlatiladi.
class GameStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setInGame(bool value) => state = value;
}

final NotifierProvider<GameStatusNotifier, bool> isInActiveGameProvider =
    NotifierProvider<GameStatusNotifier, bool>(GameStatusNotifier.new);
