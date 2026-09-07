import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';

/// The big coral "start a duel" card — mirrors the prototype's `.hero`.
class DuelHeroCard extends StatelessWidget {
  const DuelHeroCard({
    required this.streakDays,
    required this.onStartDuel,
    this.weeklyActivity,
    super.key,
  });

  final int streakDays;
  final VoidCallback onStartDuel;
  final List<bool>? weeklyActivity;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Trimmed from the original lg+xxs/lg (24/20) padding - the card was
      // tall enough to leave Home scrolling by a few pixels on common
      // screen sizes. Shaved off top/bottom padding here plus the internal
      // gaps below add up to ~36px total, without touching the text sizes
      // or the weekly-activity row's legibility.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
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
                style: context.textStyles.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              AppSpacing.xxs.vGap,
              Text(
                context.t.home.duelHeroSubtitle,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              if (weeklyActivity != null && weeklyActivity!.length == 7) ...[
                AppSpacing.sm.vGap,
                _WeeklyActivityRow(days: weeklyActivity!),
              ],
              AppSpacing.md.vGap,
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

class _WeeklyActivityRow extends StatelessWidget {
  const _WeeklyActivityRow({required this.days});

  final List<bool> days;

  static const List<String> _labels = [
    'Du',
    'Se',
    'Cho',
    'Pa',
    'Ju',
    'Sha',
    'Ya',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final bool isToday = i == 6;
        final bool played = days[i];
        final double size = isToday ? 30 : (played ? 24 : 22);
        return Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday
                    ? const Color(0xFFFFD9A8)
                    : played
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.20),
                boxShadow: isToday
                    ? [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: isToday
                  ? Icon(
                      TablerIcons.flame,
                      color: context.colors.coralDeep,
                      size: 16,
                    )
                  : played
                  ? Icon(
                      TablerIcons.check,
                      color: context.colors.coralDeep,
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              isToday ? 'Bugun' : _labels[i],
              style: TextStyle(
                fontSize: 9,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: Colors.white.withValues(alpha: isToday ? 1 : 0.6),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StartDuelButton extends StatelessWidget {
  const _StartDuelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  TablerIcons.swords,
                  color: context.colors.coralDeep,
                  size: 18,
                ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
