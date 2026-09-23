import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount).replaceAll(',', '.');
  }

  static String formatWithSign(num amount, bool isIncome) {
    final formatted = format(amount.abs());
    return isIncome ? '+$formatted' : '-$formatted';
  }
}
