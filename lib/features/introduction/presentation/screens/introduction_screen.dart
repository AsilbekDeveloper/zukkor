import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/intro_explainer_page.dart';
import '../widgets/intro_progress_header.dart';
import '../widgets/welcome_step.dart';

/// 4-page first-launch walkthrough shown once, before Login/Register:
/// a welcome page + 3 "what is Zukkor" explainer pages. Reachable only
/// when [AppPreferences.hasSeenIntroduction] is false — see
/// [AppRoutes.introduction] in the router.
///
/// Each page carries its own accent color (background wash + icon badge)
/// and finishing the last page plays a short confetti burst before
/// handing off to Login. Haptics accompany navigation and selections.
class IntroductionScreen extends ConsumerStatefulWidget {
  const IntroductionScreen({super.key});

  @override
  ConsumerState<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends ConsumerState<IntroductionScreen> {
  static const int _totalSteps = 4;

  int _step = 1;
  bool _isFinishing = false;

  Color _accentFor(int step) {
    return switch (step) {
      1 => context.colors.coral,
      2 => context.colors.teal,
      3 => context.colors.pink,
      _ => context.colors.green,
    };
  }

  void _next() {
    context.hideKeyboard();
    HapticFeedback.selectionClick();
    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      _complete();
    }
  }

  void _back() {
    context.hideKeyboard();
    HapticFeedback.selectionClick();
    if (_step > 1) {
      setState(() => _step--);
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    _finish();
  }

  /// Last page's "Get started" — plays a short celebratory burst before
  /// handing off (see [_finish]), unlike [_skip] which leaves right away.
  void _complete() {
    HapticFeedback.mediumImpact();
    setState(() => _isFinishing = true);
  }

  Future<void> _finish() async {
    await ref.read(appPreferencesProvider).saveHasSeenIntroduction(true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentFor(_step);

    return Scaffold(
      body: AnimatedContainer(
        duration: AppDurations.slow,
        curve: AppDurations.ease,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.4, -0.7),
            radius: 1.3,
            colors: [accent.withValues(alpha: 0.16), context.colors.cream],
            stops: const [0, 0.75],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.sm.vGap,
                    IntroProgressHeader(
                      currentStep: _step,
                      totalSteps: _totalSteps,
                      onBack: _step > 1 ? _back : null,
                      onSkip: _skip,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: AnimatedSwitcher(
                          duration: AppDurations.normal,
                          switchInCurve: AppDurations.ease,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: _buildStep(context, accent),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.md.vGap,
                    // AppButton already wraps itself in PressableScale -
                    // no need to double it here.
                    AppButton.primary(
                      label: _step == _totalSteps
                          ? context.t.introduction.getStarted
                          : context.t.onboarding.continueButton,
                      onPressed: _isFinishing ? null : _next,
                    ),
                    AppSpacing.lg.vGap,
                  ],
                ),
              ),
            ),
            if (_isFinishing)
              Positioned.fill(
                child: ConfettiBurst(
                  colors: [
                    context.colors.coral,
                    context.colors.teal,
                    context.colors.pink,
                    context.colors.green,
                    context.colors.blue,
                  ],
                  onDone: _finish,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, Color accent) {
    return switch (_step) {
      1 => const WelcomeStep(),
      2 => IntroExplainerPage(
        icon: TablerIcons.bulb,
        iconColor: accent,
        title: context.t.introduction.soloTitle,
        subtitle: context.t.introduction.soloSubtitle,
      ),
      3 => IntroExplainerPage(
        icon: TablerIcons.swords,
        iconColor: accent,
        title: context.t.introduction.duelTitle,
        subtitle: context.t.introduction.duelSubtitle,
      ),
      _ => IntroExplainerPage(
        icon: TablerIcons.trophy,
        iconColor: accent,
        title: context.t.introduction.leaderboardTitle,
        subtitle: context.t.introduction.leaderboardSubtitle,
      ),
    };
  }
}
