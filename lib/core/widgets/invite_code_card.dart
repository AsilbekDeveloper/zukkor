import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// The dark "big code" card — mirrors the prototype's `.room-card`.
/// Shared by the Add Friend screen ("Your invite code") and the Lobby
/// screen ("Room code") — same visuals, different [label].
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({required this.label, required this.code, super.key});

  final String label;
  final String code;

  // rgba(33,20,16,.22), matching the prototype's `.room-card` box-shadow —
  // a one-off, heavier than any of the shared AppColors shadow tiers.
  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x38211410), offset: Offset(0, 14), blurRadius: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surfaceDark,
        borderRadius: AppRadius.lgAll,
        boxShadow: _shadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 6),
          // FittedBox.scaleDown: stays 28px whenever it fits, and shrinks
          // uniformly on very narrow screens instead of overflowing.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              code,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 28,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
