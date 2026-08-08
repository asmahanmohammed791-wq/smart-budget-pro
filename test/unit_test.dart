import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_pro/models/account_model.dart';
import 'package:smart_budget_pro/models/savings_goal_model.dart';
import 'package:smart_budget_pro/models/transaction_model.dart';
import 'package:smart_budget_pro/utils/constants.dart';
import 'package:smart_budget_pro/utils/formatters.dart';

void main() {
  group('TransactionModel Tests', () {
    test('Expense transaction initializes with correct properties', () {
      final tx = TransactionModel(
        id: 'tx_01',
        title: 'بقالة أسبوعية',
        amount: 150.75,
        date: DateTime(2026, 8, 6),
        type: TransactionType.expense,
        category: 'طعام ومشروبات',
        note: 'شراء خضار وفواكه',
      );

      expect(tx.id, 'tx_01');
      expect(tx.title, 'بقالة أسبوعية');
      expect(tx.amount, 150.75);
      expect(tx.type, TransactionType.expense);
      expect(tx.category, 'طعام ومشروبات');
      expect(tx.note, 'شراء خضار وفواكه');
    });

    test('Income transaction initializes with correct properties', () {
      final tx = TransactionModel(
        id: 'tx_02',
        title: 'راتب شهري',
        amount: 5000.0,
        date: DateTime(2026, 8, 1),
        type: TransactionType.income,
        category: 'راتب',
      );

      expect(tx.amount, 5000.0);
      expect(tx.type, TransactionType.income);
    });
  });

  group('SavingsGoalModel Tests', () {
    test('Savings progress percentage calculates accurately', () {
      final goal = SavingsGoalModel(
        id: 'goal_01',
        title: 'شراء سيارة',
        targetAmount: 50000.0,
        currentAmount: 25000.0,
        targetDate: DateTime(2027, 1, 1),
      );

      expect(goal.progressPercentage, 0.5);
      expect(goal.isCompleted, isFalse);
    });

    test('Goal marked as completed when target is met or exceeded', () {
      final goal = SavingsGoalModel(
        id: 'goal_02',
        title: 'صندوق الطوارئ',
        targetAmount: 10000.0,
        currentAmount: 10000.0,
        targetDate: DateTime(2026, 12, 31),
      );

      expect(goal.progressPercentage, 1.0);
      expect(goal.isCompleted, isTrue);
    });
  });

  group('AppFormatters Tests', () {
    test('formatDate outputs formatted YYYY/MM/DD', () {
      final date = DateTime(2026, 8, 6);
      final formatted = AppFormatters.formatDate(date);
      expect(formatted, '2026/08/06');
    });

    test('formatCurrency outputs formatted string with custom symbol', () {
      final formatted = AppFormatters.formatCurrency(1250.50, currencySymbol: 'SAR');
      expect(formatted.contains('1,250.50') || formatted.contains('1250.50'), isTrue);
      expect(formatted.contains('SAR'), isTrue);
    });
  });
}