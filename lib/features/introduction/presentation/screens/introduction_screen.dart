import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/audio/app_sound.dart';
import '../../../../core/audio/sound_controller.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../models/study_survey.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/interests_step.dart';
import '../widgets/intro_explainer_page.dart';
import '../widgets/intro_progress_header.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/study_survey_step.dart';
import '../widgets/welcome_step.dart';

/// 6-page first-launch walkthrough shown once, before Login/Register:
/// 4 "what is Zukkor" explainer pages, then a short 2-page survey
/// (interests, study place + quiz-liking) that feeds into onboarding
/// later. Reachable only when [AppPreferences.hasSeenIntroduction] is
/// false — see [AppRoutes.introduction] in the router.
///
/// Each page carries its own accent color (background wash + icon badge)
/// and finishing the last page plays a short confetti burst plus
/// [AppSound.success] before handing off to Login. Haptics and
/// [AppSound.tap] accompany navigation and selections.
///
/// CURRENT STATE: survey answers are saved locally ([AppPreferences]) on
/// finish — there's no user account yet at this point, so they can't be
/// sent directly. [OnboardingScreen] picks them up and folds them into its
/// `PATCH /users/me/profile` call once registration completes.
class IntroductionScreen extends ConsumerStatefulWidget {
  const IntroductionScreen({super.key});

  @override
  ConsumerState<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends ConsumerState<IntroductionScreen> {
  static const int _totalSteps = 6;

  int _step = 1;
  bool _isFinishing = false;

  // Skip can fire from any page, including before the survey pages (5-6)
  // are ever shown — in that case there's nothing real to save, just the
  // untouched defaults below.
  bool _reachedSurvey = false;

  final Set<String> _selectedInterests = {};
  bool _otherInterestSelected = false;
  final _otherInterestController = TextEditingController();

  StudyPlace _studyPlace = StudyPlace.school;
  final _otherStudyPlaceController = TextEditingController();
  QuizLiking _quizLiking = QuizLiking.loveIt;

  @override
  void dispose() {
    _otherInterestController.dispose();
    _otherStudyPlaceController.dispose();
    super.dispose();
  }

  Color _accentFor(int step) {
    return switch (step) {
      1 => context.colors.coral,
      2 => context.colors.teal,
      3 => context.colors.pink,
      4 => context.colors.green,
      5 => context.colors.blue,
      _ => context.colors.terra,
    };
  }

  void _toggleInterest(String label) {
    HapticFeedback.selectionClick();
    ref.playSound(AppSound.tap);
    setState(() {
      if (!_selectedInterests.remove(label)) {
        _selectedInterests.add(label);
      }
    });
  }

  void _toggleOtherInterest() {
    HapticFeedback.selectionClick();
    ref.playSound(AppSound.tap);
    setState(() => _otherInterestSelected = !_otherInterestSelected);
  }

  void _next() {
    context.hideKeyboard();
    HapticFeedback.selectionClick();
    if (_step < _totalSteps) {
      setState(() => _step++);
      if (_step >= 5) _reachedSurvey = true;
    } else {
      _complete();
    }
  }

  void _back() {
    context.hideKeyboard();
    HapticFeedback.selectionClick();
    ref.playSound(AppSound.tap);
    if (_step > 1) {
      setState(() => _step--);
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    ref.playSound(AppSound.tap);
    _finish();
  }

  /// Last page's "Get started" — plays a short celebratory burst before
  /// handing off (see [_finish]), unlike [_skip] which leaves right away.
  void _complete() {
    HapticFeedback.mediumImpact();
    ref.playSound(AppSound.success);
    setState(() => _isFinishing = true);
  }

  Future<void> _finish() async {
    if (_reachedSurvey) {
      final List<String> interests = [
        ..._selectedInterests,
        if (_otherInterestSelected && _otherInterestController.text.trim().isNotEmpty)
          _otherInterestController.text.trim(),
      ];
      final String studyPlace = _studyPlace == StudyPlace.other && _otherStudyPlaceController.text.trim().isNotEmpty
          ? _otherStudyPlaceController.text.trim()
          : _studyPlace.apiValue;

      await ref.read(appPreferencesProvider).saveIntroSurvey(
            interests: interests,
            studyPlace: studyPlace,
            quizLiking: _quizLiking.apiValue,
          );
    }
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
                          transitionBuilder: (child, animation) => FadeTransition(
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
                    PressableScale(
                      child: AppButton.primary(
                        label: _step == _totalSteps
                            ? context.t.introduction.getStarted
                            : context.t.onboarding.continueButton,
                        onPressed: _isFinishing ? null : _next,
                      ),
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
      4 => IntroExplainerPage(
          icon: TablerIcons.trophy,
          iconColor: accent,
          title: context.t.introduction.leaderboardTitle,
          subtitle: context.t.introduction.leaderboardSubtitle,
        ),
      5 => InterestsStep(
          selected: _selectedInterests,
          onToggle: _toggleInterest,
          otherSelected: _otherInterestSelected,
          onToggleOther: _toggleOtherInterest,
          otherController: _otherInterestController,
          accentColor: accent,
        ),
      _ => StudySurveyStep(
          studyPlace: _studyPlace,
          onStudyPlaceChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() => _studyPlace = value);
          },
          otherStudyPlaceController: _otherStudyPlaceController,
          quizLiking: _quizLiking,
          onQuizLikingChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() => _quizLiking = value);
          },
          accentColor: accent,
        ),
    };
  }
}
