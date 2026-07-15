import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// The big coral "start a duel" card — mirrors the prototype's `.hero`.
class DuelHeroCard extends StatelessWidget {
  const DuelHeroCard({
    required this.streakDays,
    required this.onStartDuel,
    super.key,
  });

  final int streakDays;
  final VoidCallback onStartDuel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg + AppSpacing.xxs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF7A50),
            context.colors.coral,
            context.colors.coralDeep,
          ],
          stops: const [0, 0.45, 1],
        ),
        boxShadow: context.colors.shadowCoral,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative translucent circles, matching .hero-deco d1/d2.
          Positioned(
            top: -95,
            right: -45,
            child: _decoCircle(190, Colors.white.withValues(alpha: 0.12)),
          ),
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            child: Align(
              alignment: const Alignment(-0.2, 0),
              child: _decoCircle(110, Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t.home.duelHeroTitle,
                style: context.textStyles.headlineMedium?.copyWith(color: Colors.white),
              ),
              AppSpacing.xxs.vGap,
              Text(
                context.t.home.duelHeroSubtitle,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              AppSpacing.xl.vGap,
              // Both children stay at their natural (pill-shaped) width —
              // matching the prototype's `.hero-foot { justify-content:
              // space-between }` — instead of the button stretching to
              // fill the row (which was the bug: an oddly wide white bar
              // with the icon/label squashed to the left instead of a
              // compact pill).
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flexible (not Expanded): keeps its natural pill width
                  // normally, but can still shrink instead of overflowing
                  // if the card is ever narrower than both children need.
                  Flexible(child: _StartDuelButton(onTap: onStartDuel)),
                  AppSpacing.sm.hGap,
                  _StreakChip(days: streakDays),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decoCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _StartDuelButton extends StatelessWidget {
  const _StartDuelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 1, horizontal: AppSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(TablerIcons.swords, color: context.colors.coralDeep, size: 18),
              AppSpacing.xs.hGap,
              Flexible(
                child: Text(
                  context.t.home.startDuel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.coralDeep,
                    fontSize: 14,
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

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Icon(TablerIcons.flame, color: Color(0xFFFFD9A8), size: 17),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            context.t.common.dayUnit(count: days),
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
