import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/currency_transaction.dart';
import '../controllers/wallet_controller.dart';
import '../models/wallet_transaction_row.dart';
import '../widgets/wallet_transaction_list.dart';

/// Coin/Diamond'ning to'liq harakat tarixi - Home sarlavhasidagi hamyon
/// chiplaridan ochiladi. `HistoryScreen` bilan bir xil naqsh (sahifalab
/// yuklash, xato/bo'sh holatlar) - faqat segment-filtrsiz, chunki bu
/// yerda "turi" (Coin/Diamond) allaqachon har bir qatorning o'zida
/// ko'rinadi.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (ref.read(walletControllerProvider).entries == null) {
      Future.microtask(() => ref.read(walletControllerProvider.notifier).load());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;
    ref.read(walletControllerProvider.notifier).loadMore();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final WalletState walletState = ref.watch(walletControllerProvider);
    final List<CurrencyTransaction>? transactions = walletState.entries;
    final List<WalletTransactionRow> rows =
        transactions == null ? const [] : transactions.map(WalletTransactionRow.fromEntity).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.wallet.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Expanded(
                child: walletState.hasError
                    ? ErrorRetryView(onRetry: () => ref.read(walletControllerProvider.notifier).load())
                    : transactions == null
                        ? const ShimmerListSkeleton()
                        : rows.isEmpty
                            ? Center(
                                child: Text(
                                  context.t.wallet.emptyState,
                                  textAlign: TextAlign.center,
                                  style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => ref.read(walletControllerProvider.notifier).load(),
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      WalletTransactionList(rows: rows),
                                      if (walletState.isLoadingMore) ...[
                                        AppSpacing.md.vGap,
                                        const Center(
                                          child: SizedBox.square(
                                            dimension: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5),
                                          ),
                                        ),
                                        AppSpacing.md.vGap,
                                      ],
                                    ],
                                  ),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
