import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/budget_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Map<String, double> _calculateCategoryData(List<TransactionModel> transactions) {
    final Map<String, double> categoryMap = {};
    for (var tx in transactions.where((t) => t.type == TransactionType.expense)) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }
    return categoryMap;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final categoryData = _calculateCategoryData(provider.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المصروفات حسب التصنيف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            categoryData.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(child: Text('لا توجد بيانات مصروفات حالية')),
                  )
                : Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: categoryData.entries.map((entry) {
                          return PieChartSectionData(
                            title: entry.key,
                            value: entry.value,
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            const Text('تفاصيل المصروفات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...categoryData.entries.map((entry) => Card(
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      AppFormatters.formatCurrency(entry.value, currencySymbol: provider.currencySymbol),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.expense),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}