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

    test('SppBillModel parses MySQL YEAR string format safely without cast error', () {
      final jsonFromString = {
        'id': '01m33vbmzdpnnz9epp5cnk0sjs',
        'student_id': '1',
        'period_month': '8',
        'period_year': '2026',
        'amount_billed': '500000',
        'status': 'UNPAID',
      };
      final bill = SppBillModel.fromJson(jsonFromString);
      expect(bill.id, '01m33vbmzdpnnz9epp5cnk0sjs');
      expect(bill.studentId, 1);
      expect(bill.periodMonth, 8);
      expect(bill.periodYear, 2026);
      expect(bill.amountBilled, 500000);
      expect(bill.isPaid, false);
    });

    test('FIFO selection: selecting month 10 automatically selects months 8 and 9 if 1-7 are paid', () {
      final unpaidMonths = [8, 9, 10, 11, 12];
      final selectedMonths = <int>[];

      void onMonthTapped(int monthNumber) {
        if (!unpaidMonths.contains(monthNumber)) return;
        final maxSelected = selectedMonths.isEmpty ? 0 : selectedMonths.reduce((a, b) => a > b ? a : b);
        if (selectedMonths.contains(monthNumber)) {
          if (monthNumber == maxSelected) {
            selectedMonths.remove(monthNumber);
          } else {
            selectedMonths.removeWhere((m) => m > monthNumber);
          }
        } else {
          selectedMonths.clear();
          for (final m in unpaidMonths) {
            if (m <= monthNumber) {
              selectedMonths.add(m);
            }
          }
        }
      }

      // Tap month 10 -> should select [8, 9, 10]
      onMonthTapped(10);
      expect(selectedMonths, [8, 9, 10]);

      // Tap month 9 -> should shrink to [8, 9]
      onMonthTapped(9);
      expect(selectedMonths, [8, 9]);

      // Tap month 9 again (it is maxSelected) -> should remove 9, leaving [8]
      onMonthTapped(9);
      expect(selectedMonths, [8]);

      // Tap month 8 again (it is maxSelected) -> should clear
      onMonthTapped(8);
      expect(selectedMonths, isEmpty);
    });
  });
}
