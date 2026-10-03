import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/models/transaction_item_model.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/widget/dashboard_history_section.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/widget/transaction_history_tile.dart';

void main() {
  group('DashboardHistorySection Widget Tests', () {
    final mockTransactions = List.generate(
      15,
      (i) => TransactionItemModel(
        id: 'tx-$i',
        title: 'Transaksi Santri $i',
        amount: 50000.0 + (i * 1000),
        date: DateTime.now().subtract(Duration(hours: i)),
        isIncome: i % 2 == 0,
        category: 'SPP',
        studentName: 'Santri $i',
      ),
    );

    testWidgets('displays only 10 transactions even if 15 are provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardHistorySection(
                transactions: mockTransactions,
                isLoading: false,
                onViewAllTransactions: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure "Riwayat Transaksi" and "Lihat Semua" are visible
      expect(find.text('Riwayat Transaksi'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsOneWidget);

      // Verify that bill filter/tabs are NOT present
      expect(find.text('Riwayat Tagihan'), findsNothing);
      expect(find.text('Belum Lunas'), findsNothing);

      // Verify that exactly 10 TransactionHistoryTile widgets are rendered
      expect(find.byType(TransactionHistoryTile), findsNWidgets(10));
    });

    testWidgets(
      'triggers onViewAllTransactions callback when Lihat Semua is tapped',
      (tester) async {
        var callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DashboardHistorySection(
                  transactions: mockTransactions,
                  isLoading: false,
                  onViewAllTransactions: () {
                    callbackCalled = true;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final viewAllFinder = find.text('Lihat Semua');
        expect(viewAllFinder, findsOneWidget);

        await tester.tap(viewAllFinder);
        await tester.pumpAndSettle();

        expect(callbackCalled, isTrue);
      },
    );

    testWidgets('displays empty state when transactions list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardHistorySection(
                transactions: const [],
                isLoading: false,
                onViewAllTransactions: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum ada transaksi terbaru'), findsOneWidget);
      expect(find.byType(TransactionHistoryTile), findsNothing);
    });
  });
}
