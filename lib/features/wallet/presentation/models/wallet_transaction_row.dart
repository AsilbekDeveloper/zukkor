import '../../../../i18n/strings.g.dart';
import '../../domain/entities/currency_transaction.dart';

/// A single row on the Wallet screen - maps a raw backend `reason` string
/// to a translated label (falling back to [reasonOther] for a reason this
/// app version doesn't recognize yet, so a new backend reason never
/// breaks the screen) and formats the timestamp the same way
/// `GameHistoryEntry` does for Game History.
class WalletTransactionRow {
  const WalletTransactionRow({
    required this.isCoin,
    required this.isCredit,
    required this.amount,
    required this.reasonLabel,
    required this.subtitle,
    required this.balanceAfter,
  });

  factory WalletTransactionRow.fromEntity(CurrencyTransaction entity) => WalletTransactionRow(
        isCoin: entity.isCoin,
        isCredit: entity.isCredit,
        amount: entity.amount.abs(),
        reasonLabel: _reasonLabel(entity.reason),
        subtitle: _formatSubtitle(entity.createdAt),
        balanceAfter: entity.balanceAfter,
      );

  final bool isCoin;
  final bool isCredit;
  final int amount;
  final String reasonLabel;
  final String subtitle;
  final int balanceAfter;

  static String _reasonLabel(String reason) => switch (reason) {
        'daily_login' => t.wallet.reasonDailyLogin,
        'first_game' => t.wallet.reasonFirstGame,
        'streak_bonus_7d' => t.wallet.reasonStreakBonus7d,
        'referral' => t.wallet.reasonReferral,
        'signup_bonus' => t.wallet.reasonSignupBonus,
        'ai_generation' => t.wallet.reasonAiGeneration,
        'admin_adjustment' => t.wallet.reasonAdminAdjustment,
        'purchase' => t.wallet.reasonPurchase,
        'cosmetic_purchase' => t.wallet.reasonCosmeticPurchase,
        'streak_freeze' => t.wallet.reasonStreakFreeze,
        _ => t.wallet.reasonOther,
      };

  static String _formatSubtitle(DateTime createdAt) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final int diffDays = today.difference(day).inDays;
    final String time = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    if (diffDays == 0) return '${t.history.today}, $time';
    if (diffDays == 1) return '${t.history.yesterday}, $time';
    if (diffDays > 1 && diffDays < 7) return t.history.daysAgo(days: diffDays);
    final String dd = createdAt.day.toString().padLeft(2, '0');
    final String mm = createdAt.month.toString().padLeft(2, '0');
    return '$dd.$mm.${createdAt.year}';
  }
}
