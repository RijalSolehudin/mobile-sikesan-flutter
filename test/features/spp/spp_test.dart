import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/models/spp_models.dart';

void main() {
  group('SPP Models Unit Tests', () {
    test('SppBillModel parses correctly and detects isPaid status', () {
      final jsonPaid = {
        'id': 'BILL-01',
        'student_id': 10,
        'period_month': 1,
        'period_year': 2026,
        'amount_billed': 750000,
        'status': 'PAID',
      };
      final billPaid = SppBillModel.fromJson(jsonPaid);
      expect(billPaid.id, 'BILL-01');
      expect(billPaid.periodMonth, 1);
      expect(billPaid.amountBilled, 750000);
      expect(billPaid.isPaid, true);

      final jsonUnpaid = {
        'id': 'BILL-02',
        'student_id': 10,
        'period_month': 2,
        'period_year': 2026,
        'amount_billed': 750000,
        'status': 'UNPAID',
      };
      final billUnpaid = SppBillModel.fromJson(jsonUnpaid);
      expect(billUnpaid.isPaid, false);
    });

    test('BankAccountModel returns default accounts with valid numbers', () {
      final accounts = BankAccountModel.defaultAccounts();
      expect(accounts.length, 3);
      expect(accounts.any((a) => a.bankName == 'BSI'), true);
      expect(accounts.any((a) => a.bankName == 'BCA'), true);
      expect(accounts.any((a) => a.bankName == 'Mandiri'), true);
    });

    test('SppReceiptModel parses receipt JSON correctly', () {
      final json = {
        'receipt_number': 'KW-SPP-12345678',
        'payment_id': 'PAY-99',
        'payment_date': '2026-09-23',
        'payment_time': '10:30:00',
        'total_paid_amount': 1500000,
        'payment_method': 'TRANSFER',
        'status': 'APPROVED',
        'student': {
          'name': 'Diki Rafsanjani',
          'nis': '12345',
          'classroom': 'Kelas 11',
        },
        'guardian': {
          'name': 'H. Ahmad',
        },
        'bills': [
          {
            'period_month': 1,
            'month_name': 'Januari',
            'period_year': 2026,
            'allocated_amount': 750000,
          },
          {
            'period_month': 2,
            'month_name': 'Februari',
            'period_year': 2026,
            'allocated_amount': 750000,
          },
        ],
      };

      final receipt = SppReceiptModel.fromJson(json);
      expect(receipt.receiptNumber, 'KW-SPP-12345678');
      expect(receipt.studentName, 'Diki Rafsanjani');
      expect(receipt.studentClass, 'Kelas 11');
      expect(receipt.totalPaidAmount, 1500000);
      expect(receipt.bills.length, 2);
      expect(receipt.bills.first.monthName, 'Januari');
    });
  });
}
