import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';

/// Bot bergan 6 xonali kodni kiritib, Telegram hisobini bog'lash - Diamond
/// sotib olish uchun ([[ai_cost_architecture]] - Telegram bot Diamond
/// sotib olish kanali sifatida). Real `POST /telegram/link`.
class TelegramLinkScreen extends ConsumerStatefulWidget {
  const TelegramLinkScreen({super.key});

  @override
  ConsumerState<TelegramLinkScreen> createState() => _TelegramLinkScreenState();
}

class _TelegramLinkScreenState extends ConsumerState<TelegramLinkScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .linkTelegram(_codeController.text.trim());
      if (!mounted) return;
      context.showSnack(context.t.telegramLink.success);
      _goBack();
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(authControllerProvider);
    final bool isLinked =
        ref.watch(currentUserControllerProvider).data?.telegramLinked ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(
                  title: context.t.telegramLink.title,
                  onBack: _goBack,
                ),
              ),
              AppSpacing.xl.vGap,
              if (isLinked)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.brandTelegram,
                        color: context.colors.teal,
                      ),
                      AppSpacing.sm.hGap,
                      Expanded(
                        child: Text(
                          context.t.telegramLink.alreadyLinked,
                          style: context.textStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Text(
                    context.t.telegramLink.description,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                ),
                AppSpacing.xl.vGap,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Form(
                    key: _formKey,
                    child: AppTextField(
                      label: context.t.telegramLink.codeLabel,
                      hint: context.t.telegramLink.codeHint,
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      onSubmitted: (_) => _submit(),
                      validator: (value) =>
                          (value == null || value.trim().length != 6)
                          ? context.t.telegramLink.codeHint
                          : null,
                    ),
                  ),
                ),
                AppSpacing.xl.vGap,
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: AppButton.primary(
                    label: context.t.telegramLink.submit,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
