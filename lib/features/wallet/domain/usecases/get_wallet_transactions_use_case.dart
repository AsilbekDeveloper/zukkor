import '../entities/currency_transaction.dart';
import '../repositories/wallet_repository.dart';

class GetWalletTransactionsUseCase {
  const GetWalletTransactionsUseCase(this._repository);

  final WalletRepository _repository;

  Future<({List<CurrencyTransaction> entries, bool hasMore})> call({int limit = 30, int offset = 0}) =>
      _repository.getTransactions(limit: limit, offset: offset);
}
