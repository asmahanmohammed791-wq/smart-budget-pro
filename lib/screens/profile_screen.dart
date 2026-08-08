import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../services/export_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي والإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              final controller = TextEditingController(text: provider.userName);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تعديل اسم المستخدم'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'أدخل اسمك',
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    ElevatedButton(
                      onPressed: () {
                        provider.setUserName(controller.text.trim());
                        Navigator.pop(ctx);
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.userName.isEmpty ? 'اضغط لتعيين اسم المستخدم' : provider.userName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: provider.userName.isEmpty ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('العملة المفضلة'),
            trailing: DropdownButton<String>(
              value: provider.selectedCurrency,
              items: ['USD', 'EUR', 'SAR', 'EGP', 'AED']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) provider.setCurrency(val);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: provider.themeMode == ThemeMode.dark,
            onChanged: (val) => provider.toggleTheme(val),
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('الميزانية الشهرية'),
            subtitle: Text('${provider.monthlyBudget} ${provider.currencySymbol}'),
            onTap: () {
              final controller = TextEditingController(text: provider.monthlyBudget.toString());
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تحديد الميزانية الشهرية'),
                  content: TextField(controller: controller, keyboardType: TextInputType.number),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                    ElevatedButton(
                      onPressed: () {
                        final b = double.tryParse(controller.text) ?? 0.0;
                        provider.setMonthlyBudget(b);
                        Navigator.pop(ctx);
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('تصدير تقرير PDF'),
            onTap: () {
              ExportService.generateAndPrintPDF(
                provider.transactions,
                provider.totalIncome,
                provider.totalExpenses,
                provider.currencySymbol,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('نسخ احتياطي للبيانات'),
            onTap: () {
              final jsonStr = provider.exportBackupData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تصدير النسخة الاحتياطية بنجاح!')),
              );
            },
          ),
        ],
      ),
    );
  }
}