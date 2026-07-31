import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// Wraps [child] in a shimmering sweep — use for skeleton placeholders
/// shown while a screen's real content is still loading. Base/highlight
/// are derived from [AppColors.line] so the sweep direction (dark →
/// light) stays correct in both themes, since `line` isn't consistently
/// the lighter or darker of the theme's neutrals across light/dark.
class AppShimmer extends StatelessWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color base = context.colors.line;
    final Color highlight = Color.lerp(base, Colors.white, context.isDark ? 0.12 : 0.9)!;
    return Shimmer.fromColors(baseColor: base, highlightColor: highlight, child: child);
  }
}

/// A solid rounded-rect placeholder block — the basic building block for
/// skeleton screens (a line of text, an icon, a button...). Must be used
/// inside an [AppShimmer].
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({this.width, this.height = 14, this.radius = 6, super.key});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: context.colors.line, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// A circular placeholder — avatars. Must be used inside an [AppShimmer].
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: context.colors.line, shape: BoxShape.circle),
    );
  }
}

/// A generic skeleton list — mimics an avatar/icon + two-line card row,
/// repeated [count] times. Fits any screen whose real content is a list
/// of cards shaped like this: Friends, Duel opponent picker, Friend
/// Requests, Add Friend results, History, Notifications, Leaderboard.
class ShimmerListSkeleton extends StatelessWidget {
  const ShimmerListSkeleton({this.count = 6, this.trailingWidth, super.key});

  final int count;

  /// Width of a trailing placeholder box (e.g. a duel-challenge button)
  /// — omitted when the real row has no trailing action.
  final double? trailingWidth;

  @override
  Widget build(BuildContext context) {
    // A plain Column would overflow when this lands somewhere with a
    // tight height constraint (e.g. an `Expanded` on a short/landscape
    // screen) — SingleChildScrollView absorbs that instead, while still
    // sizing to content when its parent's height is unbounded (a
    // scrollable screen's own Column).
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            for (int i = 0; i < count; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : AppSpacing.xs),
                child: _row(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        children: [
          const ShimmerCircle(size: 36),
          AppSpacing.sm.hGap,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 120, height: 13),
                SizedBox(height: 6),
                ShimmerBox(width: 70, height: 10),
              ],
            ),
          ),
          if (trailingWidth != null) ...[
            AppSpacing.sm.hGap,
            ShimmerBox(width: trailingWidth!, height: 36, radius: 11),
          ],
        ],
      ),
    );
  }
}

/// A skeleton for [CategoryGridView]'s fluid grid — same
/// `maxCrossAxisExtent` layout so the placeholder cards land in the same
/// columns/rows the real category cards will.
class ShimmerCategoryGridSkeleton extends StatelessWidget {
  const ShimmerCategoryGridSkeleton({this.count = 8, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: AppSpacing.sm - 1,
          crossAxisSpacing: AppSpacing.sm - 1,
          mainAxisExtent: 66,
        ),
        itemBuilder: (context, index) => _card(context),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 42, height: 42, radius: AppRadius.sm),
          AppSpacing.sm.hGap,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerBox(width: 80, height: 13),
                SizedBox(height: 6),
                ShimmerBox(width: 50, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
