import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/navigation/navigation_keys.dart';
import 'package:mobile_sikesan_flutter/core/utils/date_formatter.dart';
import 'package:mobile_sikesan_flutter/data/models/bill_history_model.dart';
import 'package:mobile_sikesan_flutter/data/models/transaction_item_model.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/widget/transaction_detail_modal.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/widget/transaction_history_tile.dart';

void main() {
  group('DateFormatter UTC+7 Tests', () {
    test('converts UTC DateTime to UTC+7 WIB correctly', () {
      final utcDate = DateTime.utc(2026, 10, 3, 10, 0); // 10:00 UTC
      final formatted = DateFormatter.formatFull(utcDate);
      expect(formatted, contains('17:00 WIB'));
      expect(formatted, contains('03 Oktober 2026'));
    });

    test('parseUtc7 handles ISO-8601 strings with Z offset', () {
      final parsed = DateFormatter.parseUtc7('2026-10-03T10:00:00.000000Z');
      expect(parsed.hour, 17);
    });
  });

  group('TransactionItemModel Tests', () {
    test('parses status and generates appropriate labels', () {
      final pendingTx = TransactionItemModel(
        id: 'tx-1',
        title: 'Pembayaran SPP',
        category: 'SPP',
        amount: 250000,
        isIncome: false,
        date: DateTime(2026, 10, 3, 17, 0),
        status: 'PENDING',
        statusLabel: 'Menunggu Verifikasi',
      );

      expect(pendingTx.isPending, isTrue);
      expect(pendingTx.isPaidOrSuccess, isFalse);

      final paidTx = TransactionItemModel(
        id: 'tx-2',
        title: 'Top Up Saldo',
        category: 'Top Up',
        amount: 100000,
        isIncome: true,
        date: DateTime(2026, 10, 3, 17, 0),
        status: 'SUCCESS',
        statusLabel: 'Berhasil',
      );

      expect(paidTx.isPaidOrSuccess, isTrue);
      expect(paidTx.isPending, isFalse);
    });

    test('fromBillModel maps PENDING bill to TransactionItemModel correctly', () {
      final bill = BillHistoryModel(
        id: '101',
        billType: 'SPP',
        title: 'SPP Oktober 2026',
        category: 'Tagihan SPP',
        studentId: 1,
        studentName: 'Ahmad Faiz',
        studentNis: '1001',
        studentClass: '10 A',
        periodMonth: 10,
        periodYear: 2026,
        monthName: 'Oktober',
        amountBilled: 300000,
        status: 'PENDING',
        statusLabel: 'Menunggu Verifikasi',
        createdAt: DateTime.utc(2026, 10, 3, 10, 0),
      );

      final tx = TransactionItemModel.fromBillModel(bill);
      expect(tx.isPending, isTrue);
      expect(tx.statusLabel, 'Menunggu Verifikasi');
      expect(tx.studentName, 'Ahmad Faiz');
      expect(tx.amount, 300000);
      expect(tx.date.hour, 17); // UTC+7
    });
  });

  group('TransactionDetailModal & TransactionHistoryTile Widget Tests', () {
    testWidgets('TransactionHistoryTile displays status tag and opens modal on tap', (tester) async {
      final tx = TransactionItemModel(
        id: 'TRX-998877',
        transactionNumber: 'TRX-998877',
        title: 'Pembayaran SPP',
        category: 'Transfer Bank',
        amount: 350000,
        isIncome: false,
        date: DateTime.utc(2026, 10, 3, 10, 0),
        studentName: 'Zaidan Robbani',
        studentClass: 'Kelas 10 A',
        studentNis: '2026001',
        status: 'PENDING',
        statusLabel: 'Menunggu Verifikasi',
      );

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: Scaffold(
            body: Center(
              child: TransactionHistoryTile(tx: tx),
            ),
          ),
        ),
      );

      // Verify status badge and student name appear on the tile
      expect(find.text('Zaidan Robbani'), findsOneWidget);
      expect(find.text('Menunggu Verifikasi'), findsOneWidget);

      // Tap tile to open modal
      await tester.tap(find.byType(TransactionHistoryTile));
      await tester.pumpAndSettle();

      // Verify TransactionDetailModal opened
      expect(find.byType(TransactionDetailModal), findsOneWidget);
      expect(find.text('Detail Transaksi'), findsOneWidget);
      expect(find.text('TRX-998877'), findsOneWidget);
      expect(find.text('2026001 · Kelas 10 A'), findsOneWidget);
      // Pending notice banner is displayed
      expect(find.textContaining('menunggu verifikasi'), findsWidgets);
    });

    testWidgets('TransactionDetailModal displays receipt button when status is PAID/SUCCESS', (tester) async {
      final tx = TransactionItemModel(
        id: 'TRX-112233',
        transactionNumber: 'KW-SPP-112233',
        title: 'Pembayaran SPP',
        category: 'Kasir / Tunai',
        amount: 250000,
        isIncome: false,
        date: DateTime.utc(2026, 10, 3, 10, 0),
        studentName: 'Fatimah Az-Zahra',
        studentClass: 'Kelas 11 B',
        studentNis: '2026002',
        status: 'PAID',
        statusLabel: 'Lunas',
      );

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => TransactionDetailModal.show(ctx, tx),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailModal), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      // Receipt button is visible for paid transactions
      expect(find.text('Lihat Struk / Bukti Transaksi'), findsOneWidget);
    });
  });
}
