import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_pro/models/transaction_model.dart';

void main() {
  test('Transaction model calculation test', () {
    final tx = TransactionModel(
      id: '1',
      title: 'Coffee',
      amount: 5.5,
      date: DateTime.now(),
      type: TransactionType.expense,
      category: 'طعام ومشروبات',
    );

    expect(tx.amount, 5.5);
    expect(tx.type, TransactionType.expense);
  });
}