import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/currency_transaction.dart';
import '../../domain/entities/diamond_pricing.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/get_wallet_transactions_use_case.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl({required WalletRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  final WalletRemoteDataSource _remoteDataSource;

  @override
  Future<({List<CurrencyTransaction> entries, bool hasMore})> getTransactions({int limit = 30, int offset = 0}) async {
    try {
      final page = await _remoteDataSource.getTransactions(limit: limit, offset: offset);
      return (entries: page.entries.map((model) => model.toEntity()).toList(), hasMore: page.hasMore);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<DiamondPricing> getPricing() async {
    try {
      return (await _remoteDataSource.getPricing()).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<WalletRepository> walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepositoryImpl(remoteDataSource: ref.watch(walletRemoteDataSourceProvider)),
);

final Provider<GetWalletTransactionsUseCase> getWalletTransactionsUseCaseProvider =
    Provider<GetWalletTransactionsUseCase>(
  (ref) => GetWalletTransactionsUseCase(ref.watch(walletRepositoryProvider)),
);

/// Diamond narxlash formulasi - bir marta olinib, butun sessiya davomida
/// keshlanadi (autoDispose emas - kamdan-kam o'zgaradi, har bir
/// generatsiya ekraniga qayta-qayta so'rov yuborish shart emas).
final FutureProvider<DiamondPricing> diamondPricingProvider = FutureProvider<DiamondPricing>(
  (ref) => ref.watch(walletRepositoryProvider).getPricing(),
);
