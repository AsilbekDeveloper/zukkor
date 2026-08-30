import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/accounts_controller.dart';

class AccountSwitcherScreen extends ConsumerWidget {
  const AccountSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(
                title: context.t.auth.accounts,
                onBack: () => context.pop(),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: accountsAsync.when(
                  data: (accounts) => ListView.separated(
                    itemCount: accounts.length + 1,
                    separatorBuilder: (context, index) => AppSpacing.sm.vGap,
                    itemBuilder: (context, index) {
                      if (index == accounts.length) {
                        return _AddAccountRow(
                          onTap: () => context.push(AppRoutes.login, extra: true),
                        );
                      }
                      return _AccountRow(account: accounts[index]);
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, stack) => Center(child: Text(e.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends ConsumerWidget {
  const _AccountRow({required this.account});

  final AccountEntry account;

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await ConfirmDialog.show(
      context,
      title: context.t.auth.removeAccountConfirmTitle,
      message: context.t.auth.removeAccountConfirmMessage,
      confirmLabel: context.t.common.delete,
      isDanger: true,
      onConfirm: (_) async {},
    );

    if (confirmed != true) return;

    final result = await ref.read(accountsControllerProvider.notifier).remove(account.info.userId);
    if (!context.mounted) return;

    if (result == null) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: account.isActive
            ? null
            : () async {
                final success = await ref
                    .read(accountsControllerProvider.notifier)
                    .switchTo(account.info.userId);
                if (success && context.mounted) {
                  context.go(AppRoutes.home);
                }
              },
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: account.isActive ? context.colors.coral : context.colors.line,
              width: account.isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              UserAvatar(
                size: 40,
                initials: (account.info.username ?? account.info.email)[0].toUpperCase(),
                avatarImagePath: account.info.avatarUrl,
                fontSize: 16,
              ),
              AppSpacing.md.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (account.info.username != null)
                      Text(
                        account.info.username!,
                        style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    Text(
                      account.info.email,
                      style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                    ),
                  ],
                ),
              ),
              if (account.isActive)
                Icon(TablerIcons.circleCheckFilled, color: context.colors.coral, size: 20)
              else
                IconButton(
                  onPressed: () => _remove(context, ref),
                  icon: Icon(TablerIcons.trash, color: context.colors.muted, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAccountRow extends StatelessWidget {
  const _AddAccountRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton.secondary(
      label: context.t.auth.addAccount,
      icon: const Icon(TablerIcons.userPlus, size: 20),
      onPressed: onTap,
    );
  }
}
