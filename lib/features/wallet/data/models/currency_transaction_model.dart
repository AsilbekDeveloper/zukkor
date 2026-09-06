import '../../domain/entities/currency_transaction.dart';

class CurrencyTransactionModel {
  const CurrencyTransactionModel({
    required this.id,
    required this.currency,
    required this.amount,
    required this.reason,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory CurrencyTransactionModel.fromJson(Map<String, dynamic> json) => CurrencyTransactionModel(
        id: json['id'] as String,
        currency: json['currency'] as String,
        amount: json['amount'] as int,
        reason: json['reason'] as String,
        balanceAfter: json['balance_after'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String currency;
  final int amount;
  final String reason;
  final int balanceAfter;
  final DateTime createdAt;

  CurrencyTransaction toEntity() => CurrencyTransaction(
        id: id,
        currency: currency,
        amount: amount,
        reason: reason,
        balanceAfter: balanceAfter,
        createdAt: createdAt.toLocal(),
      );
}
