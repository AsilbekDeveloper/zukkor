import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// Kirish ekrani. Ro'yxatdan o'tish alohida sahifada — [RegisterScreen]
/// (pastdagi havola shu sahifaga o'tkazadi).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final user = await ref.read(authControllerProvider.notifier).signInWithGoogle();
      if (!mounted || user == null) return; // foydalanuvchi tanlagichni yopdi — bekor qilingan
      context.go(user.onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  void _goToRegister() {
    // Tez ketma-ket bosilsa ham faqat bitta marta o'tishi uchun: bu
    // ekran allaqachon "joriy" (topdagi) marshrut bo'lmasa (masalan,
    // o'tish animatsiyasi allaqachon boshlangan bo'lsa), qayta push
    // qilinmaydi.
    if (ModalRoute.of(context)?.isCurrent != true) return;
    context.hideKeyboard();
    context.push(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(authControllerProvider);

    return Scaffold(
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
                    context.t.auth.loginTitle,
                    style: context.textStyles.headlineMedium,
                  ),
                  AppSpacing.xs.vGap,
                  Text(
                    context.t.auth.loginSubtitle,
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
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            // Login'da faqat bo'shligini tekshiramiz —
                            // ro'yxatdan o'tish qoidalarini (uzunlik/format)
                            // emas: noto'g'ri parolni backend aytadi, mavjud
                            // hisobga kirishni client validatori to'smasin.
                            validator: Validators.currentPassword,
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.xl.vGap,
                  AppButton.primary(
                    label: context.t.auth.loginButton,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  AppSpacing.lg.vGap,
                  const AuthDivider(),
                  AppSpacing.lg.vGap,
                  GoogleButton(onPressed: _signInWithGoogle),
                  AppSpacing.xxl.vGap,
                  AuthSwitchPrompt(
                    promptText: context.t.auth.noAccountPrompt,
                    actionText: context.t.auth.switchToRegister,
                    onTap: _goToRegister,
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
