/// Which relationship-aware action row [PlayerDetailScreen] shows — the
/// caller already knows this from its own list (Friends/Add Friend/
/// Friend Requests each know the relationship without an extra API
/// round-trip), so it's passed in rather than re-derived.
enum PlayerDetailRelation {
  /// Default (Leaderboard doesn't track friendship) — shows "Add to
  /// friends" / "Sent".
  unknown,

  /// Opened from the Friends list — shows a non-interactive "You're
  /// friends" badge instead of an action.
  friend,

  /// Opened from Friend Requests — shows Accept/Decline for
  /// [PlayerDetailArgs.incomingRequestId].
  incomingRequest,
}

/// Everything [PlayerDetailScreen] needs. Deliberately just this one
/// small, standalone type (no [leaderboard]/[friends] model embedded in
/// it) — every caller (Leaderboard, Friends, Add Friend, Friend
/// Requests) builds one from primitives it already has, so none of them
/// need to import this feature just to navigate here (they pass a plain
/// `Map` as the route's `extra`; only the router constructs this type).
class PlayerDetailArgs {
  const PlayerDetailArgs({
    required this.userId,
    this.relation = PlayerDetailRelation.unknown,
    this.incomingRequestId,
    this.initialRequestSent = false,
  }) : assert(
          relation != PlayerDetailRelation.incomingRequest || incomingRequestId != null,
          'incomingRequestId is required when relation is incomingRequest',
        );

  final String userId;
  final PlayerDetailRelation relation;

  /// Required when [relation] is [PlayerDetailRelation.incomingRequest].
  final String? incomingRequestId;

  /// Seeds the "Add to friends" button's sent state — set by Add Friend
  /// for a user whose request is already pending.
  final bool initialRequestSent;
}
