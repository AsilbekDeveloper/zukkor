import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/onboarding_progress_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../models/onboarding_direction.dart';
import '../widgets/avatar_step.dart';
import '../widgets/direction_step.dart';
import '../widgets/profile_info_step.dart';

/// 3-step profile setup wizard: Avatar → Name/Username → Direction
/// (Zukkor_Profil_Yaratish.docx). All the data collected here is sent in a
/// single request on the last step (`PATCH /users/me/profile`) — there is
/// no per-step network call, EXCEPT step 2, which does a lightweight
/// `GET /users/username-available` check before advancing so a taken
/// username is caught immediately rather than only after step 3.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _totalSteps = 3;

  int _step = 1;
  AvatarColorOption _avatarColor = AvatarColorOption.fallback;
  OnboardingDirection? _direction;
  bool _directionTouched = false;
  bool _usernameTaken = false;
  bool _checkingUsername = false;

  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Foydalanuvchi username'ni tuzatgach, eski "band" xatosi ekranda
    // osilib qolmasin.
    _usernameController.addListener(_clearUsernameTakenError);
  }

  void _clearUsernameTakenError() {
    if (_usernameTaken) {
      setState(() => _usernameTaken = false);
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearUsernameTakenError);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _uploadPhoto() {
    // TODO(onboarding): wire image_picker once native permissions are set up.
    // Backend hozircha faqat avatar_color'ni qo'llab-quvvatlaydi, rasm
    // yuklash uchun alohida endpoint yo'q.
  }

  Future<void> _next() async {
    context.hideKeyboard();

    if (_step == 2) {
      if (!(_profileFormKey.currentState?.validate() ?? false)) return;
      final bool? available = await _checkUsernameAvailable();
      if (available == null) return; // xatolik — o'sha yerda ko'rsatildi
      if (!available) {
        setState(() => _usernameTaken = true);
        _profileFormKey.currentState?.validate();
        return;
      }
    }
    if (_step == 3 && _direction == null) {
      setState(() => _directionTouched = true);
      return;
    }

    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      unawaited(_finish());
    }
  }

  /// `null` — so'rov xatolik bilan tugadi (snackbar ko'rsatildi, joriy
  /// bosqichda qoladi). `true`/`false` — muvaffaqiyatli tekshiruv natijasi.
  Future<bool?> _checkUsernameAvailable() async {
    setState(() => _checkingUsername = true);
    try {
      return await ref
          .read(checkUsernameAvailableUseCaseProvider)
          .call(_usernameController.text.trim());
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
      return null;
    } finally {
      if (mounted) setState(() => _checkingUsername = false);
    }
  }

  Future<void> _finish() async {
    try {
      await ref.read(authControllerProvider.notifier).completeOnboarding(
            username: _usernameController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            avatarColor: _avatarColor.apiValue,
            direction: _direction!.apiValue,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
      // Eng ehtimoliy xato sababi (username band) shu bosqichda tuzatiladi.
      setState(() => _step = 2);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
      setState(() => _step = 2);
    }
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
    final bool isLoading = _checkingUsername || ref.watch(authControllerProvider);

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
                    ? context.t.onboarding.start
                    : context.t.onboarding.continueButton,
                isLoading: isLoading,
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
          usernameTaken: _usernameTaken,
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
                context.t.onboarding.directionRequired,
                style: context.textStyles.bodySmall?.copyWith(color: context.colors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
    };
  }
}
