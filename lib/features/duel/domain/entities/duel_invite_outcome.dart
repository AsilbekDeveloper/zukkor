/// What happened to an invite THIS device sent — correlated back via
/// [clientInviteId] (a client-generated id attached to the outgoing
/// `duel_invite` message, since the server-assigned invite id isn't
/// known until the `duel_invite_ack` arrives).
enum DuelInviteOutcomeStatus { accepted, declined, expired }

class DuelInviteOutcome {
  const DuelInviteOutcome({required this.clientInviteId, required this.status});

  final String clientInviteId;
  final DuelInviteOutcomeStatus status;
}
