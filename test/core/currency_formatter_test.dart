import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter & CurrencyInputFormatter Tests', () {
    test('format formats numbers with Rp prefix and dot separators', () {
      expect(CurrencyFormatter.format(0), 'Rp 0');
      expect(CurrencyFormatter.format(50000), 'Rp 50.000');
      expect(CurrencyFormatter.format(1000000), 'Rp 1.000.000');
    });

    test('formatWithoutSymbol formats numbers without Rp prefix', () {
      expect(CurrencyFormatter.formatWithoutSymbol(0), '0');
      expect(CurrencyFormatter.formatWithoutSymbol(25000), '25.000');
      expect(CurrencyFormatter.formatWithoutSymbol(500000), '500.000');
      expect(CurrencyFormatter.formatWithoutSymbol(15000000), '15.000.000');
    });

    test('parseClean parses formatted strings accurately to integer', () {
      expect(CurrencyFormatter.parseClean(''), 0);
      expect(CurrencyFormatter.parseClean('0'), 0);
      expect(CurrencyFormatter.parseClean('50.000'), 50000);
      expect(CurrencyFormatter.parseClean('Rp 1.250.000'), 1250000);
      expect(CurrencyFormatter.parseClean('abc 750 def 000'), 750000);
    });

    test('CurrencyInputFormatter formats input in real-time as user types', () {
      final formatter = CurrencyInputFormatter();

      // Empty input
      final emptyResult = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: ''),
      );
      expect(emptyResult.text, '');

      // Typing '50000'
      final result1 = formatter.formatEditUpdate(
        const TextEditingValue(text: '5000'),
        const TextEditingValue(text: '50000'),
      );
      expect(result1.text, '50.000');
      expect(result1.selection.baseOffset, 6);

      // Typing '1000000'
      final result2 = formatter.formatEditUpdate(
        const TextEditingValue(text: '100000'),
        const TextEditingValue(text: '1000000'),
      );
      expect(result2.text, '1.000.000');
      expect(result2.selection.baseOffset, 9);

      // Pasting dirty string 'Rp 250.000'
      final result3 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'Rp 250.000'),
      );
      expect(result3.text, '250.000');

      // Leading zero
      final result4 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '05'),
      );
      expect(result4.text, '5');
    });
  });
}
