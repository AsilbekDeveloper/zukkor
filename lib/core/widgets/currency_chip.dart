import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';
import 'animated_counter.dart';
import 'pressable_scale.dart';

/// Coin/Diamond hamyon chipi - [[ai_cost_architecture]]. Ilovaning o'zida
/// allaqachon bor ranglar (terra/teal) bilan ishlatiladi - shu orqali
/// qolgan qismidan "begona vidjet" bo'lib ajralib turmaydi. Avval faqat
/// Home sarlavhasida (`home_header.dart`) yashagan - Profil ekraniga ham
/// balans ko'rinishi kerak bo'lgach, umumiy widget sifatida shu yerga
/// chiqarildi (2026-09-06).
class CurrencyChip extends StatelessWidget {
  const CurrencyChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;
  final int value;
  final VoidCallback onTap;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smAll,
          side: BorderSide(color: context.colors.line),
        ),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: AppRadius.smAll,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 15),
                AppSpacing.xxs.hGap,
                AnimatedCounter(
                  value: value,
                  formatter: (v) => '$v',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
