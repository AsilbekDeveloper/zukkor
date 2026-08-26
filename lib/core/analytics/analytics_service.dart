import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Analytics'ga custom event yuborish uchun yupqa o'ram — xatolar
/// shu yerda yutiladi, chunki analytics ilovaning asosiy funksiyasi emas.
class AnalyticsService {
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (_) {}
  }

  Future<void> logOnboardingStepViewed(int step) async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_step_viewed',
        parameters: {'step': step},
      );
    } catch (_) {}
  }

  Future<void> logOnboardingCompleted() async {
    try {
      await _analytics.logEvent(name: 'onboarding_completed');
    } catch (_) {}
  }

  Future<void> logGameStart({required String mode, required int categoryId}) async {
    try {
      await _analytics.logEvent(
        name: 'game_start',
        parameters: {'mode': mode, 'category_id': categoryId},
      );
    } catch (_) {}
  }

  Future<void> logGameComplete({
    required String mode,
    required int categoryId,
    required int xpEarned,
    required int ballEarned,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'game_complete',
        parameters: {
          'mode': mode,
          'category_id': categoryId,
          'xp_earned': xpEarned,
          'ball_earned': ballEarned,
        },
      );
    } catch (_) {}
  }
}

final Provider<AnalyticsService> analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());
