import 'dart:io';
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String currencySymbol;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencySymbol,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: (isExpense ? AppColors.expense : AppColors.income).withOpacity(0.1),
            child: Icon(
              isExpense ? Icons.north_east_rounded : Icons.south_west_rounded,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Row(
            children: [
              Text(
                '${transaction.category} • ${AppFormatters.formatDate(transaction.date)}',
                style: const TextStyle(fontSize: 12),
              ),
              if (transaction.receiptImagePath != null) ...[
                const SizedBox(width: 6),
                const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.primary),
              ],
            ],
          ),
          trailing: Text(
            '${isExpense ? '-' : '+'}${AppFormatters.formatCurrency(transaction.amount, currencySymbol: currencySymbol)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ),
      ),
    );
  }
}