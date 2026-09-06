import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../models/wallet_transaction_row.dart';

/// A column of Coin/Diamond transaction rows - mirrors `HistoryList`'s
/// row style (icon square + title/subtitle + trailing amount) so the
/// Wallet screen feels like it belongs next to Game History, not like a
/// separately-designed widget.
class WalletTransactionList extends StatelessWidget {
  const WalletTransactionList({required this.rows, super.key});

  final List<WalletTransactionRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          _WalletRow(row: rows[i]),
          if (i < rows.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({required this.row});

  final WalletTransactionRow row;

  @override
  Widget build(BuildContext context) {
    final Color currencyColor = row.isCoin ? context.colors.terra : context.colors.teal;
    final Color amountColor = row.isCredit ? context.colors.green : context.colors.ink2;
    final String sign = row.isCredit ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 1),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: AppRadius.smAll,
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: currencyColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(
              row.isCoin ? TablerIcons.coinFilled : TablerIcons.diamondFilled,
              color: currencyColor,
              size: 19,
            ),
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.reasonLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                Text(
                  row.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelSmall,
                ),
              ],
            ),
          ),
          AppSpacing.sm.hGap,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$sign${row.amount}',
                style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: amountColor),
              ),
              Text(
                '${t.wallet.currentBalance}: ${row.balanceAfter}',
                style: context.textStyles.labelSmall?.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
