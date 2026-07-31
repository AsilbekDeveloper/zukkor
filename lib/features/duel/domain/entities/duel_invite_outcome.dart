/// What happened to an invite THIS device sent — correlated back via
/// [clientInviteId] (a client-generated id attached to the outgoing
/// `duel_invite` message, since the server-assigned invite id isn't
/// known until the `duel_invite_ack` arrives).
enum DuelInviteOutcomeStatus { accepted, declined, expired, failed }

class DuelInviteOutcome {
  const DuelInviteOutcome({required this.clientInviteId, required this.status, this.message});

  final String clientInviteId;
  final DuelInviteOutcomeStatus status;

  /// The server's own reason text — only set for [DuelInviteOutcomeStatus.
  /// failed] (e.g. "Faqat do'stlarni chaqirish mumkin" when the other
  /// person was unfriended after the picker showed them, or the category
  /// was deactivated in the meantime). Already in the app's display
  /// language, same as every other backend-authored error message.
  final String? message;
}
