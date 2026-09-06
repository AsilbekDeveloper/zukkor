/// One row of the `/wallet/transactions` response - a single Coin or
/// Diamond balance change (earned, spent, or an admin adjustment).
/// `currency`/`reason` are left as raw backend strings (not enums) on
/// purpose - the backend can introduce a new `reason` (e.g. a future
/// cosmetic purchase) without this app needing an update just to keep
/// showing a sensible fallback label for it.
class CurrencyTransaction {
  const CurrencyTransaction({
    required this.id,
    required this.currency,
    required this.amount,
    required this.reason,
    required this.balanceAfter,
    required this.createdAt,
  });

  final String id;

  /// `"coin"` or `"diamond"`.
  final String currency;

  /// Positive - credited (earned/purchased/admin-added). Negative -
  /// debited (spent/admin-removed).
  final int amount;

  /// e.g. `"daily_login"`, `"first_game"`, `"streak_bonus_7d"`,
  /// `"referral"`, `"signup_bonus"`, `"ai_generation"`,
  /// `"admin_adjustment"`.
  final String reason;
  final int balanceAfter;
  final DateTime createdAt;

  bool get isCredit => amount >= 0;
  bool get isCoin => currency == 'coin';
}
