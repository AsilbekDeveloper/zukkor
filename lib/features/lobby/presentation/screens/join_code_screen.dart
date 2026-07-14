import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../widgets/code_input_row.dart';
import 'lobby_screen.dart';

/// Join a friend's room by its 6-digit code — mirrors the prototype's
/// `view-join-code`.
///
/// CURRENT STATE: presentation only — the entered digits aren't
/// validated against a real room; "Join" always leads to the same mock
/// [LobbyScreen] as a guest.
class JoinCodeScreen extends StatelessWidget {
  const JoinCodeScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: AppStrings.joinWithCode, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    AppStrings.joinCodeHint,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                  ),
                ),
              ),
              AppSpacing.xl.vGap,
              const CodeInputRow(),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: AppStrings.joinButton,
                icon: const Icon(TablerIcons.arrowRight, color: Colors.white, size: 18),
                onPressed: () => context.push(AppRoutes.lobby, extra: LobbyRole.guest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
