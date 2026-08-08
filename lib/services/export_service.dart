import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets' as pw;
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

class ExportService {
  static String exportToCSV(List<TransactionModel> transactions, String currencySymbol) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Amount,Currency,Type,Category,Date,Note');

    for (final tx in transactions) {
      buffer.writeln(
        '${tx.id},"${tx.title}",${tx.amount},"$currencySymbol",${tx.type.name},"${tx.category}",${AppFormatters.formatDate(tx.date)},"${tx.note ?? ''}"',
      );
    }
    return buffer.toString();
  }

  static Future<void> generateAndPrintPDF(
    List<TransactionModel> transactions,
    double totalIncome,
    double totalExpenses,
    String currencySymbol,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Smart Budget Pro - Summary Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Income: $currencySymbol${totalIncome.toStringAsFixed(2)}'),
                  pw.Text('Total Expenses: $currencySymbol${totalExpenses.toStringAsFixed(2)}'),
                  pw.Text('Balance: $currencySymbol${(totalIncome - totalExpenses).toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Title', 'Category', 'Type', 'Amount'],
                  ...transactions.map((tx) => [
                        AppFormatters.formatDate(tx.date),
                        tx.title,
                        tx.category,
                        tx.type.name,
                        '$currencySymbol${tx.amount.toStringAsFixed(2)}',
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}