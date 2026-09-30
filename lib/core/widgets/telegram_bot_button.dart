import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// [AppConfig.telegramBotUrl]ni tashqi Telegram ilovasida ochadigan tugma —
/// "Hamyon", "Telegram bilan bog'lash" va Yordam markazida bot birinchi
/// marta aniq nom bilan ko'rsatilishi uchun (2026-10-01, foydalanuvchi
/// so'rovi: bot hech qayerda nomlanmagan edi).
class TelegramBotButton extends StatelessWidget {
  const TelegramBotButton({required this.label, super.key});

  final String label;

  Future<void> _open() =>
      launchUrl(Uri.parse(AppConfig.telegramBotUrl), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: _open,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(TablerIcons.brandTelegram, size: 18, color: context.colors.teal),
              AppSpacing.xs.hGap,
              Flexible(
                child: Text(
                  label,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
