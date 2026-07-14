import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../models/onboarding_direction.dart';
import '../widgets/avatar_step.dart';
import '../widgets/direction_step.dart';
import '../widgets/onboarding_progress_header.dart';
import '../widgets/profile_info_step.dart';

/// 3-step profile setup wizard: Avatar → Name/Username → Direction
/// (Zukkor_Profil_Yaratish.docx). All the data collected here is sent in a
/// single request on the last step — there is no per-step network call
/// (matches the prototype's client-side-only wizard state).
///
/// CURRENT STATE: presentation only — `_finish` doesn't call the backend
/// yet (auth data/domain hasn't been rebuilt). Photo upload is a stub too
/// (`_uploadPhoto`) since it needs image_picker + native permissions, a
/// separate concern from the wizard UI itself.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalSteps = 3;

  int _step = 1;
  AvatarColorOption _avatarColor = AvatarColorOption.fallback;
  OnboardingDirection? _direction;
  bool _directionTouched = false;

  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _uploadPhoto() {
    // TODO(onboarding): wire image_picker once native permissions are set up.
  }

  void _next() {
    context.hideKeyboard();

    if (_step == 2 && !(_profileFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_step == 3 && _direction == null) {
      setState(() => _directionTouched = true);
      return;
    }

    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _finish() {
    // TODO(onboarding): auth data/domain qurilganda PATCH /api/profile/setup/
    // shu yerdan chaqiriladi (first/last name, username, avatar_color,
    // direction). Hozircha to'g'ridan-to'g'ri Home'ga o'tadi.
    context.go(AppRoutes.home);
  }

  void _back() {
    context.hideKeyboard();
    if (_step > 1) {
      setState(() => _step--);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.sm.vGap,
              OnboardingProgressHeader(
                currentStep: _step,
                totalSteps: _totalSteps,
                onBack: _back,
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
                      child: _buildStep(),
                    ),
                  ),
                ),
              ),
              AppSpacing.md.vGap,
              AppButton.primary(
                label: _step == _totalSteps
                    ? AppStrings.onboardingStart
                    : AppStrings.onboardingContinue,
                onPressed: _next,
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      1 => AvatarStep(
          selectedColor: _avatarColor,
          onColorSelected: (color) => setState(() => _avatarColor = color),
          onUploadPhoto: _uploadPhoto,
        ),
      2 => ProfileInfoStep(
          formKey: _profileFormKey,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          usernameController: _usernameController,
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DirectionStep(
              selected: _direction,
              onSelected: (direction) => setState(() {
                _direction = direction;
                _directionTouched = false;
              }),
            ),
            if (_directionTouched && _direction == null) ...[
              AppSpacing.xs.vGap,
              Text(
                AppStrings.directionRequired,
                style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
    };
  }
}
