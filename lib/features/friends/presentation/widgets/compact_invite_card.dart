import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// Compact single-row taklif kodi + ulashish — [InviteCodeCard]ning
/// (core/widgets) qisqartirilgan versiyasi, faqat Friends sahifasi uchun.
/// [InviteCodeCard]ning o'zi Lobby ekranida ham ishlatilgani uchun
/// tegilmaydi. Qatorning o'ziga bosilsa kod clipboard'ga nusxalanadi.
class CompactInviteCard extends StatelessWidget {
  const CompactInviteCard({required this.code, required this.onShareTap, super.key});

  final String code;
  final VoidCallback onShareTap;

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x38211410), offset: Offset(0, 10), blurRadius: 22),
  ];

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) context.showSnack(context.t.addFriend.codeCopied);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceDark,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: () => _copyCode(context),
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: const BoxDecoration(borderRadius: AppRadius.smAll, boxShadow: _shadow),
          child: Row(
            children: [
              Icon(TablerIcons.ticket, size: 18, color: Colors.white.withValues(alpha: 0.7)),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              AppSpacing.sm.hGap,
              _ShareIconButton(onTap: onShareTap, semanticLabel: context.t.addFriend.shareLink),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareIconButton extends StatelessWidget {
  const _ShareIconButton({required this.onTap, required this.semanticLabel});

  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(TablerIcons.share3, size: 16, color: Colors.white, semanticLabel: semanticLabel),
        ),
      ),
    );
  }
}
