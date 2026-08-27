import 'dart:async';

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
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_revalidateConfirmPassword);
  }

  void _revalidateConfirmPassword() {
    if (_confirmPasswordController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_revalidateConfirmPassword);
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(widget.email);
      if (mounted) context.showSnack(context.t.forgotPassword.codeSent);
    } catch (_) {
      // Rates limited or network error, but the forgotPassword call
      // already handles general Failure UI if it had one (it doesn't,
      // it's 204 always in standard case). For resend, we just best-effort.
    }
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
            email: widget.email,
            code: _codeController.text.trim(),
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      context.showSnack(context.t.resetPassword.success);
      context.go(AppRoutes.login);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.resetPassword.title, onBack: () => context.pop()),
              AppSpacing.xl.vGap,
              Text(
                context.t.resetPassword.subtitle(email: widget.email),
                style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
              ),
              AppSpacing.xl.vGap,
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: context.t.resetPassword.codeLabel,
                      hint: context.t.resetPassword.codeHint,
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: Validators.resetCode,
                    ),
                    AppSpacing.md.vGap,
                    AppTextField(
                      label: context.t.resetPassword.newPasswordLabel,
                      hint: context.t.resetPassword.newPasswordHint,
                      controller: _newPasswordController,
                      obscure: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      maxLength: kPasswordMaxLength,
                    ),
                    AppSpacing.md.vGap,
                    AppTextField(
                      label: context.t.resetPassword.confirmPasswordLabel,
                      hint: context.t.resetPassword.confirmPasswordHint,
                      controller: _confirmPasswordController,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _newPasswordController.text,
                      ),
                      onSubmitted: (_) => _submit(),
                      maxLength: kPasswordMaxLength,
                    ),
                  ],
                ),
              ),
              AppSpacing.sm.vGap,
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: isLoading ? null : _resendCode,
                  child: Text(context.t.resetPassword.resendCode),
                ),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.resetPassword.resetButton,
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
