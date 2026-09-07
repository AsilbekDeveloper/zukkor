import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';

/// "Savol qo'shish" taklifi — Profil sahifasida o'z alohida kartasi bor
/// (avval "Mening AI quizlarim" xabidagi uchta teng vaznli tugmadan biri
/// edi, u yerdan ko'chirildi: bu shaxsiy quiz yaratish emas, balki ochiq
/// kategoriyaga bitta savol bilan hissa qo'shish — mutlaqo boshqa maqsad,
/// shuning uchun endi shu maqsadga mos, alohida "chaqiruv" ko'rinishida).
///
/// To'liq to'yingan ko'k fon + oq matn/ikonka + soya — pale/tint fon emas
/// ([[ui_button_style_rule]]: bu foydalanuvchi hech qachon yoqtirmaydigan,
/// "sun'iy intellekt uslubi"dagi ko'rinish sifatida rad etilgan; har qanday
/// "primary/chaqiruvchi" element `AppButton.primary`dagi kabi - to'liq
/// to'yingan rang + oq + faol soya bilan chizilishi kerak).
class SubmitQuestionCard extends StatelessWidget {
  const SubmitQuestionCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color blue = context.colors.blue;
    return PressableScale(
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [blue, Color.lerp(blue, Colors.black, 0.28)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: blue.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -50,
                  right: -24,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.mdAll,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        TablerIcons.bulb,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    AppSpacing.sm.hGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.t.questionSubmission.profileCardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            context.t.questionSubmission.cardSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.xs.hGap,
                    const Icon(
                      TablerIcons.chevronRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
