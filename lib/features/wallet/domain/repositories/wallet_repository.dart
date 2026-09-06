import '../entities/currency_transaction.dart';
import '../entities/diamond_pricing.dart';

abstract interface class WalletRepository {
  /// [hasMore] tells the caller whether another page exists past
  /// `offset + entries.length` - the paging cursor is a plain numeric
  /// offset, matching `HistoryRepository.getHistory`.
  Future<({List<CurrencyTransaction> entries, bool hasMore})> getTransactions({int limit = 30, int offset = 0});

  /// `GET /wallet/pricing` - fetched once and cached (see
  /// `diamondPricingProvider`), not re-fetched per screen.
  Future<DiamondPricing> getPricing();
}
