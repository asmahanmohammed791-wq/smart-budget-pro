import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';
import '../utils/constants.dart';

class BudgetProvider extends ChangeNotifier {
  late Box<TransactionModel> _txBox;
  late Box<SavingsGoalModel> _goalsBox;
  late Box _settingsBox;

  List<TransactionModel> _transactions = [];
  List<SavingsGoalModel> _goals = [];

  String _userName = '';
  double _monthlyBudget = 0.0;
  String _selectedCurrency = 'USD';
  String _currencySymbol = '\$';
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');

  BudgetProvider() {
    _initHive();
  }

  String get userName => _userName;
  List<TransactionModel> get transactions => _transactions;
  List<SavingsGoalModel> get goals => _goals;
  double get monthlyBudget => _monthlyBudget;
  String get selectedCurrency => _selectedCurrency;
  String get currencySymbol => _currencySymbol;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpenses;

  bool get isBudgetExceeded => _monthlyBudget > 0 && totalExpenses >= _monthlyBudget;
  bool get isNearBudgetLimit => _monthlyBudget > 0 && totalExpenses >= (_monthlyBudget * 0.85);

  Future<void> _initHive() async {
    _txBox = Hive.box<TransactionModel>(AppConstants.hiveBoxTransactions);
    _goalsBox = Hive.box<SavingsGoalModel>(AppConstants.hiveBoxGoals);
    _settingsBox = Hive.box(AppConstants.hiveBoxSettings);

    _userName = _settingsBox.get('userName', defaultValue: '');
    _monthlyBudget = _settingsBox.get('monthlyBudget', defaultValue: 0.0);
    _selectedCurrency = _settingsBox.get('currency', defaultValue: 'USD');
    _currencySymbol = AppConstants.currencies[_selectedCurrency] ?? '\$';

    _loadData();
  }

  void _loadData() {
    _transactions = _txBox.values.toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    _goals = _goalsBox.values.toList();

    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _txBox.put(transaction.id, transaction);
    _loadData();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _txBox.put(transaction.id, transaction);
    _loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await _txBox.delete(id);
    _loadData();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _settingsBox.put('userName', name);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await _settingsBox.put('monthlyBudget', budget);
    notifyListeners();
  }

  Future<void> setCurrency(String currencyCode) async {
    _selectedCurrency = currencyCode;
    _currencySymbol = AppConstants.currencies[currencyCode] ?? '\$';
    await _settingsBox.put('currency', currencyCode);
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await _goalsBox.put(goal.id, goal);
    _loadData();
  }

  Future<void> updateGoalProgress(String id, double amount) async {
    final goal = _goalsBox.get(id);
    if (goal != null) {
      goal.currentAmount += amount;
      await goal.save();
      _loadData();
    }
  }

  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
    _loadData();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  // Backup & Restore
  String exportBackupData() {
    final data = {
      'userName': _userName,
      'monthlyBudget': _monthlyBudget,
      'currency': _selectedCurrency,
      'transactions': _transactions.map((t) => {
        'id': t.id,
        'title': t.title,
        'amount': t.amount,
        'date': t.date.toIso8601String(),
        'type': t.type.index,
        'category': t.category,
        'note': t.note,
      }).toList(),
    };
    return jsonEncode(data);
  }

  Future<bool> restoreBackupData(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data.containsKey('userName')) {
        await setUserName(data['userName']);
      }
      if (data.containsKey('monthlyBudget')) {
        await setMonthlyBudget((data['monthlyBudget'] as num).toDouble());
      }
      if (data.containsKey('currency')) {
        await setCurrency(data['currency']);
      }
      if (data.containsKey('transactions')) {
        await _txBox.clear();
        for (var txData in data['transactions']) {
          final tx = TransactionModel(
            id: txData['id'],
            title: txData['title'],
            amount: (txData['amount'] as num).toDouble(),
            date: DateTime.parse(txData['date']),
            type: TransactionType.values[txData['type']],
            category: txData['category'],
            note: txData['note'],
          );
          await _txBox.put(tx.id, tx);
        }
      }
      _loadData();
      return true;
    } catch (e) {
      return false;
    }
  }
}