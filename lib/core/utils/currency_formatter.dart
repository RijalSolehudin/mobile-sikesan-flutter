import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _plainFormatter = NumberFormat('#,###', 'id_ID');

  /// Formats amount with standard 'Rp ' prefix: e.g. Rp 100.000
  static String format(num amount) {
    return _formatter.format(amount).replaceAll(',', '.');
  }

  /// Formats amount with sign: e.g. +Rp 100.000 or -Rp 50.000
  static String formatWithSign(num amount, bool isIncome) {
    final formatted = format(amount.abs());
    return isIncome ? '+$formatted' : '-$formatted';
  }

  /// Formats amount without 'Rp ' symbol: e.g. 100.000
  static String formatWithoutSymbol(num amount) {
    if (amount == 0) return '0';
    return _plainFormatter.format(amount).replaceAll(',', '.');
  }

  /// Parses text by stripping non-digit characters to an integer (defaults to 0)
  static int parseClean(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }
}

/// A TextInputFormatter that automatically formats input numbers with thousand separators
/// in real-time as the user types (e.g. typing 100000 becomes 100.000).
class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;

  CurrencyInputFormatter({this.maxDigits = 12});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Strip everything except numeric digits
    String cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Remove leading zeros (e.g. "05" -> "5")
    if (cleanDigits.length > 1 && cleanDigits.startsWith('0')) {
      cleanDigits = cleanDigits.replaceFirst(RegExp(r'^0+'), '');
      if (cleanDigits.isEmpty) cleanDigits = '0';
    }

    // Enforce maximum length
    if (cleanDigits.length > maxDigits) {
      return oldValue;
    }

    final number = int.tryParse(cleanDigits) ?? 0;
    final formatted = CurrencyFormatter.formatWithoutSymbol(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
