class AppConstants {
  static const String appName = 'Smart Budget Pro';
  static const String appVersion = '2.0.0';
  
  static const String hiveBoxTransactions = 'transactions';
  static const String hiveBoxGoals = 'savings_goals';
  static const String hiveBoxSettings = 'app_settings';

  static const List<String> categoriesExpense = [
    'طعام ومشروبات',
    'تسوق',
    'فواتير ومرافق',
    'مواصلات',
    'ترفيه',
    'صحة',
    'تعليم',
    'سفر',
    'عام',
  ];

  static const List<String> categoriesIncome = [
    'راتب',
    'استثمار',
    'عمل حر',
    'مكافأة',
    'أخرى',
  ];

  static const Map<String, String> currencies = {
    'USD': '\$',
    'EUR': '€',
    'SAR': 'ر.س',
    'EGP': 'ج.م',
    'AED': 'د.إ',
  };
}
