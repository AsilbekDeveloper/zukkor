import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/brand_logo.dart';
import '../widgets/google_button.dart';

/// Kirish ekrani. Ro'yxatdan o'tish alohida sahifada — [RegisterScreen]
/// (pastdagi havola shu sahifaga o'tkazadi).
///
/// HOZIRGI HOLAT: faqat presentation (UI) qatlami — forma validatsiyasi
/// mahalliy ishlaydi, lekin tugmalar hech qanday tarmoq so'rovi
/// yubormaydi (auth data/domain qatlami hali qurilmagan). `_submit` va
/// `_signInWithGoogle` ichidagi TODO'lar keyingi bosqichda ulanadi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO(auth): auth qatlami qurilganda haqiqiy so'rov shu yerdan
    // chaqiriladi; hozircha "kirish muvaffaqiyatli" deb hisoblab, mavjud
    // (allaqachon profili tayyor) foydalanuvchini Home'ga o'tkazamiz.
    context.go(AppRoutes.home);
  }

  void _signInWithGoogle() {
    // TODO(auth): auth qatlami qurilganda Google Sign-In shu yerdan
    // chaqiriladi; hozircha xuddi oddiy kirishdek Home'ga o'tkazamiz.
    context.go(AppRoutes.home);
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
                    AppStrings.loginTitle,
                    style: context.textStyles.headlineMedium,
                  ),
                  AppSpacing.xs.vGap,
                  Text(
                    AppStrings.loginSubtitle,
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
                            label: AppStrings.emailLabel,
                            hint: AppStrings.emailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: Validators.email,
                          ),
                          AppSpacing.md.vGap,
                          AppTextField(
                            label: AppStrings.passwordLabel,
                            hint: AppStrings.passwordHint,
                            controller: _passwordController,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: Validators.password,
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.xl.vGap,
                  AppButton.primary(
                    label: AppStrings.loginButton,
                    onPressed: _submit,
                  ),
                  AppSpacing.lg.vGap,
                  const AuthDivider(),
                  AppSpacing.lg.vGap,
                  GoogleButton(onPressed: _signInWithGoogle),
                  AppSpacing.xxl.vGap,
                  AuthSwitchPrompt(
                    promptText: AppStrings.noAccountPrompt,
                    actionText: AppStrings.switchToRegister,
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
