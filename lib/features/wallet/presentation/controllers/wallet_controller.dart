import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/currency_transaction.dart';

class WalletState {
  const WalletState({this.entries, this.hasMore = true, this.isLoadingMore = false, this.hasError = false});

  /// `null` means "not loaded yet" (or the initial load failed, see
  /// [hasError]).
  final List<CurrencyTransaction>? entries;

  /// Whether another page exists past the currently loaded [entries].
  final bool hasMore;

  /// True only while a [WalletController.loadMore] request is in flight -
  /// drives a small loading row at the bottom of the list.
  final bool isLoadingMore;

  /// True only when the initial [WalletController.load] failed (not a
  /// [loadMore] page) - the screen shows a retry affordance instead of
  /// its loading skeleton.
  final bool hasError;

  WalletState copyWith({
    List<CurrencyTransaction>? Function()? entries,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasError,
  }) =>
      WalletState(
        entries: entries != null ? entries() : this.entries,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasError: hasError ?? this.hasError,
      );
}

/// Coin/Diamond tarixi - `GET /wallet/transactions`, sahifalab (offset
/// asosida) yuklanadi - `HistoryController` bilan bir xil naqsh. Ekran
/// ochilganda [load] chaqirilishi kerak (avtomatik yuklanmaydi).
class WalletController extends Notifier<WalletState> {
  static const int _pageSize = 30;

  @override
  WalletState build() => const WalletState();

  Future<void> load() async {
    state = const WalletState();
    try {
      final page = await ref.read(getWalletTransactionsUseCaseProvider).call(limit: _pageSize, offset: 0);
      state = WalletState(entries: page.entries, hasMore: page.hasMore);
    } catch (_) {
      state = const WalletState(hasError: true);
    }
  }

  Future<void> loadMore() async {
    final List<CurrencyTransaction>? current = state.entries;
    if (current == null || !state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await ref.read(getWalletTransactionsUseCaseProvider).call(limit: _pageSize, offset: current.length);
      state = state.copyWith(
        entries: () => [...current, ...page.entries],
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final NotifierProvider<WalletController, WalletState> walletControllerProvider =
    NotifierProvider<WalletController, WalletState>(WalletController.new);
