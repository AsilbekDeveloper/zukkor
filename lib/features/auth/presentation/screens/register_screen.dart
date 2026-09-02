import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/brand_logo.dart';
import '../widgets/google_button.dart';

/// Ro'yxatdan o'tish ekrani — alohida sahifa (Login ustiga push qilinadi).
/// Faqat email + parol so'raladi — ism, familiya, username Profil
/// yaratish (Onboarding) oqimida to'ldiriladi.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({this.isAddingAccount = false, super.key});

  final bool isAddingAccount;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Asosiy parol o'zgarganda "tasdiqlash" maydoni ham qayta tekshirilsin —
    // aks holda foydalanuvchi parolni tuzatgach, eski "mos kelmadi" xatosi
    // ekranda osilib qolib, chalkashtirib yuboradi.
    _passwordController.addListener(_revalidateConfirmPassword);
  }

  void _revalidateConfirmPassword() {
    if (_confirmPasswordController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_revalidateConfirmPassword);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      if (widget.isAddingAccount) {
        await ref.read(authControllerProvider.notifier).addAccountViaRegister(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      } else {
        await ref.read(authControllerProvider.notifier).register(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
      if (!mounted) return;
      // Ro'yxatdan o'tgach profil sozlashga (Onboarding) yo'naltiramiz —
      // Register/Login'ga qaytmasin uchun `go` bilan.
      if (widget.isAddingAccount) {
        context.go(AppRoutes.splash);
      } else {
        context.go(AppRoutes.onboarding);
      }
      if (!widget.isAddingAccount) {
        unawaited(ref.read(analyticsServiceProvider).logSignUp('email'));
      }
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final user = widget.isAddingAccount
          ? await ref.read(authControllerProvider.notifier).addAccountWithGoogle()
          : await ref.read(authControllerProvider.notifier).signInWithGoogle();

      if (!mounted || user == null) return; // foydalanuvchi tanlagichni yopdi — bekor qilingan
      if (!user.onboardingCompleted && !widget.isAddingAccount) {
        unawaited(ref.read(analyticsServiceProvider).logSignUp('google'));
      }
      context.go(user.onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  void _goToLogin() {
    // Tez ketma-ket bosilsa ham faqat bitta marta o'tishi uchun (login
    // ekranidagi debounce bilan bir xil mantiq).
    if (ModalRoute.of(context)?.isCurrent != true) return;
    context.hideKeyboard();
    // To'g'ridan-to'g'ri havola orqali kelingan bo'lsa (push stack bo'sh)
    // ham ishlashi uchun pop/go orasida tanlaymiz.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: widget.isAddingAccount ? AppBar(title: Text(context.t.auth.addAccount)) : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.xxl.vGap,
                  const Center(child: BrandLogo()),
                  AppSpacing.xxl.vGap,
                  Text(
                    context.t.auth.registerTitle,
                    style: context.textStyles.headlineMedium,
                  ),
                  AppSpacing.xs.vGap,
                  Text(
                    context.t.auth.registerSubtitle,
                    style: context.textStyles.bodyMedium,
                  ),
                  AppSpacing.xl.vGap,
                  Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            label: context.t.auth.emailLabel,
                            hint: context.t.auth.emailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: Validators.email,
                          ),
                          AppSpacing.md.vGap,
                          AppTextField(
                            label: context.t.auth.passwordLabel,
                            hint: context.t.auth.passwordHint,
                            controller: _passwordController,
                            obscure: true,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: Validators.password,
                            maxLength: kPasswordMaxLength,
                          ),
                          AppSpacing.md.vGap,
                          AppTextField(
                            label: context.t.auth.confirmPasswordLabel,
                            hint: context.t.auth.confirmPasswordHint,
                            controller: _confirmPasswordController,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            onSubmitted: (_) => _submit(),
                            maxLength: kPasswordMaxLength,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.xl.vGap,
                  AppButton.primary(
                    label: context.t.auth.registerButton,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  AppSpacing.lg.vGap,
                  const AuthDivider(),
                  AppSpacing.lg.vGap,
                  GoogleButton(onPressed: _signInWithGoogle),
                  AppSpacing.xxl.vGap,
                  AuthSwitchPrompt(
                    promptText: context.t.auth.haveAccountPrompt,
                    actionText: context.t.auth.switchToLogin,
                    onTap: _goToLogin,
                  ),
                  AppSpacing.lg.vGap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
