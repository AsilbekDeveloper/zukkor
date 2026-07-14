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

/// Ro'yxatdan o'tish ekrani — alohida sahifa (Login ustiga push qilinadi).
///
/// Faqat email + parol so'raladi (Zukkor_Login.docx, 2-bo'lim) — ism,
/// familiya va username keyinroq Profil yaratish oqimida to'ldiriladi.
///
/// HOZIRGI HOLAT: faqat presentation (UI) qatlami — auth data/domain
/// qurilganda `_submit`/`_signInWithGoogle` haqiqiy so'rovga ulanadi.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  void _submit() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO(auth): auth qatlami qurilganda haqiqiy so'rov shu yerdan
    // chaqiriladi; hozircha "ro'yxatdan o'tish muvaffaqiyatli" deb
    // hisoblab, yangi foydalanuvchini profil sozlashga (Onboarding)
    // yo'naltiramiz — Register/Login'ga qaytmasin uchun `go` bilan.
    context.go(AppRoutes.onboarding);
  }

  void _signInWithGoogle() {
    // TODO(auth): auth qatlami qurilganda Google Sign-In shu yerdan
    // chaqiriladi; hozircha xuddi ro'yxatdan o'tishdek Onboarding'ga
    // o'tkazamiz (Google orqali kirgan yangi foydalanuvchi ham profil
    // sozlashi kerak).
    context.go(AppRoutes.onboarding);
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
                    AppStrings.registerTitle,
                    style: context.textStyles.headlineMedium,
                  ),
                  AppSpacing.xs.vGap,
                  Text(
                    AppStrings.registerSubtitle,
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
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: Validators.password,
                          ),
                          AppSpacing.md.vGap,
                          AppTextField(
                            label: AppStrings.confirmPasswordLabel,
                            hint: AppStrings.confirmPasswordHint,
                            controller: _confirmPasswordController,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.xl.vGap,
                  AppButton.primary(
                    label: AppStrings.registerButton,
                    onPressed: _submit,
                  ),
                  AppSpacing.lg.vGap,
                  const AuthDivider(),
                  AppSpacing.lg.vGap,
                  GoogleButton(onPressed: _signInWithGoogle),
                  AppSpacing.xxl.vGap,
                  AuthSwitchPrompt(
                    promptText: AppStrings.haveAccountPrompt,
                    actionText: AppStrings.switchToLogin,
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
