import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount, {String currencySymbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'ar').format(date);
  }
}