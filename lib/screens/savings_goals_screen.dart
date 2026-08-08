import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/savings_goal_model.dart';
import '../providers/budget_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة هدف ادخار جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'اسم الهدف (مثلاً: شراء سيارة)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ المستهدف'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final target = double.tryParse(targetController.text) ?? 0.0;
              if (title.isNotEmpty && target > 0) {
                final goal = SavingsGoalModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  targetAmount: target,
                  currentAmount: 0.0,
                  targetDate: DateTime.now().add(const Duration(days: 365)),
                );
                Provider.of<BudgetProvider>(context, listen: false).addGoal(goal);
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, SavingsGoalModel goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة مبلغ إلى ${goal.title}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'المبلغ المودع'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                Provider.of<BudgetProvider>(context, listen: false).updateGoalProgress(goal.id, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('إيداع'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أهداف الادخار'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        label: const Text('هدف جديد'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.goals.isEmpty
          ? const Center(child: Text('لا توجد أهداف ادخار حالياً. أضف هدفك الأول!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.goals.length,
              itemBuilder: (context, index) {
                final goal = provider.goals[index];
                final percent = (goal.progressPercentage * 100).toStringAsFixed(1);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                              onPressed: () => provider.deleteGoal(goal.id),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: goal.progressPercentage,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.income,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppFormatters.formatCurrency(goal.currentAmount, currencySymbol: provider.currencySymbol)} من ${AppFormatters.formatCurrency(goal.targetAmount, currencySymbol: provider.currencySymbol)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text('$percent%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.income)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () => _showDepositDialog(context, goal),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('إضافة ادخار'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}