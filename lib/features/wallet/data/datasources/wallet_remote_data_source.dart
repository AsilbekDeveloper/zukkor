import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/currency_transaction_model.dart';
import '../models/diamond_pricing_model.dart';

/// `/wallet/transactions` endpoint'iga xom (Dio) so'rov. Xatolikni
/// ushlamaydi - [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni
/// [Failure]ga aylantirish [WalletRepositoryImpl]ning ishi.
class WalletRemoteDataSource {
  const WalletRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({List<CurrencyTransactionModel> entries, bool hasMore})> getTransactions({
    int limit = 30,
    int offset = 0,
  }) async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.walletTransactions(limit: limit, offset: offset));
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final List<CurrencyTransactionModel> entries = (data['entries'] as List<dynamic>)
        .map((json) => CurrencyTransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return (entries: entries, hasMore: data['has_more'] as bool? ?? false);
  }

  Future<DiamondPricingModel> getPricing() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.walletPricing);
    return DiamondPricingModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final Provider<WalletRemoteDataSource> walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>(
  (ref) => WalletRemoteDataSource(ref.watch(dioProvider)),
);
