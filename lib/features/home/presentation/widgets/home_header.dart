import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';

/// Greeting + avatar on the left, notifications bell on the right —
/// mirrors the prototype's `.header`.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.hasUnreadNotifications,
    required this.onNotificationsTap,
    this.avatarImagePath,
    super.key,
  });

  final String name;
  final String initials;
  final AvatarColorOption avatarColor;
  final String? avatarImagePath;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: AppRadius.smAll, boxShadow: context.colors.shadowCoral),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t.home.greeting, style: context.textStyles.bodySmall),
              Text(
                name,
                style: context.textStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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

class _NotificationButtonState extends State<_NotificationButton> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: context.colors.line),
      ),
      child: InkWell(
        onTap: widget.onTap,
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
                        border: Border.all(color: context.colors.card, width: 2),
                      ),
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
