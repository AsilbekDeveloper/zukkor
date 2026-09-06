import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/currency_chip.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/user_avatar.dart';

/// Avatar + "Zukkor" wordmark on the left, Coin/Diamond hamyon chiplari va
/// qo'ng'iroq o'ng tomonda - hammasi BITTA qatorda (app bar kabi, doim
/// bir xil balandlikda). 2026-09-06: ism/username ko'rsatilgan versiya
/// foydalanuvchiga yoqmadi - qator ikkiga bo'linib pastga "tushib
/// ketgani" (kutilmagan balandlik o'zgarishi) noxush tuyuldi. Ism o'rniga
/// qisqa, sobit kenglikdagi brend yozuvi ("Zukkor") ishlatiladi - bu
/// o'zgaruvchan uzunlikdagi ism bilan bog'liq joylashuv muammosini ham
/// tubdan hal qiladi (sobit matn hech qachon kesilib qolmaydi).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.initials,
    required this.avatarColor,
    required this.hasUnreadNotifications,
    required this.onNotificationsTap,
    required this.coinBalance,
    required this.diamondBalance,
    required this.onWalletTap,
    this.avatarImagePath,
    super.key,
  });

  final String initials;
  final AvatarColorOption avatarColor;
  final String? avatarImagePath;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationsTap;
  final int coinBalance;
  final int diamondBalance;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            boxShadow: context.colors.shadowCoral,
          ),
          child: UserAvatar(
            size: 48,
            initials: initials,
            avatarImagePath: avatarImagePath,
            backgroundColor: avatarColor.resolve(context),
            borderRadius: AppRadius.smAll,
            fontSize: 15.5,
          ),
        ),
        AppSpacing.sm.hGap,
        Expanded(
          child: Text(
            'Zukkor',
            style: context.textStyles.titleLarge?.copyWith(
              color: context.colors.coral,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        CurrencyChip(
          icon: TablerIcons.coinFilled,
          color: context.colors.terra,
          value: coinBalance,
          onTap: onWalletTap,
        ),
        AppSpacing.xxs.hGap,
        CurrencyChip(
          icon: TablerIcons.diamondFilled,
          color: context.colors.teal,
          value: diamondBalance,
          onTap: onWalletTap,
        ),
        AppSpacing.xs.hGap,
        _NotificationButton(
          hasUnread: hasUnreadNotifications,
          onTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({required this.hasUnread, required this.onTap});

  final bool hasUnread;
  final VoidCallback onTap;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  // Cheksiz `repeat()` emas, atayin cheklangan (3 marta) - ikkita sabab
  // bilan: (1) doim-abadiy pulslash foydalanuvchini charchatadi, bir necha
  // marta "e'tibor tort" qilib tinch turgani ko'proq yoqimli; (2) cheksiz
  // AnimationController widget daraxtida turgani WidgetTester.pumpAndSettle()
  // ni HAR DOIM "timed out" qilib yiqitadi - Home ko'rinadigan (ko'p testda
  // shunday) har qanday keng testni buzadi (2026-09-06 topilgan va tuzatilgan
  // regressiya).
  static const int _maxPulses = 3;
  int _completedPulses = 0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.addStatusListener(_onStatusChanged);
    if (widget.hasUnread) _pulseController.forward();
  }

  @override
  void didUpdateWidget(_NotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bildirishnoma o'qilgach (masalan boshqa qurilmada) keyinroq yangi
    // o'qilmagan xabar kelsa, pulslashni yana boshidan ishga tushiramiz.
    if (widget.hasUnread && !oldWidget.hasUnread) {
      _completedPulses = 0;
      _pulseController.forward(from: 0);
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _pulseController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _completedPulses++;
      if (_completedPulses < _maxPulses) _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
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
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(TablerIcons.bell, color: context.colors.ink, size: 22),
                if (widget.hasUnread)
                  Positioned(
                    top: 9,
                    right: 10,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.coral,
                          border: Border.all(
                            color: context.colors.card,
                            width: 2,
                          ),
                        ),
                      ),
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
