import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/models/spp_models.dart';
import 'package:mobile_sikesan_flutter/features/spp/utils/spp_fifo_helper.dart';
import 'package:mobile_sikesan_flutter/features/spp/widget/spp_bill_summary_card.dart';
import 'package:mobile_sikesan_flutter/features/spp/widget/spp_month_grid_selector.dart';
import 'package:mobile_sikesan_flutter/features/spp/widget/spp_submit_button.dart';

void main() {
  group('SPP FIFO Helper Unit Tests', () {
    test(
      'Selecting month 10 automatically selects months 8, 9, 10 when 1-7 are paid',
      () {
        final unpaid = [8, 9, 10, 11, 12];
        var selection = <int>{};

        // Tap 10
        selection = SppFifoHelper.computeFifoSelection(
          currentSelection: selection,
          tappedMonth: 10,
          unpaidMonthsSorted: unpaid,
        );
        expect(selection, {8, 9, 10});

        // Tap 9 -> shrink to 8, 9
        selection = SppFifoHelper.computeFifoSelection(
          currentSelection: selection,
          tappedMonth: 9,
          unpaidMonthsSorted: unpaid,
        );
        expect(selection, {8, 9});

        // Tap 9 again (it is the highest) -> removes 9, leaves 8
        selection = SppFifoHelper.computeFifoSelection(
          currentSelection: selection,
          tappedMonth: 9,
          unpaidMonthsSorted: unpaid,
        );
        expect(selection, {8});

        // Tap 8 again -> clears selection
        selection = SppFifoHelper.computeFifoSelection(
          currentSelection: selection,
          tappedMonth: 8,
          unpaidMonthsSorted: unpaid,
        );
        expect(selection, isEmpty);
      },
    );

    test('Tapping an already paid month does not modify selection', () {
      final unpaid = [3, 4, 5];
      final current = {3, 4};

      // Tap month 1 (paid)
      final result = SppFifoHelper.computeFifoSelection(
        currentSelection: current,
        tappedMonth: 1,
        unpaidMonthsSorted: unpaid,
      );
      expect(result, {3, 4});
    });
  });

  group('Pay SPP Modular Widget Tests', () {
    testWidgets('SppSubmitButton is disabled when no month is selected', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SppSubmitButton(
              isSubmitting: false,
              isEnabled: false,
              totalAmount: 0,
              onSubmit: () => tapped = true,
            ),
          ),
        ),
      );

      final btnFinder = find.byType(ElevatedButton);
      expect(btnFinder, findsOneWidget);

      final btn = tester.widget<ElevatedButton>(btnFinder);
      expect(btn.onPressed, isNull);

      expect(find.text('Pilih Bulan Tagihan'), findsOneWidget);

      await tester.tap(btnFinder);
      expect(tapped, isFalse);
    });

    testWidgets(
      'SppSubmitButton is enabled and shows formatted total when months are selected',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SppSubmitButton(
                isSubmitting: false,
                isEnabled: true,
                totalAmount: 1500000,
                onSubmit: () => tapped = true,
              ),
            ),
          ),
        );

        final btnFinder = find.byType(ElevatedButton);
        expect(btnFinder, findsOneWidget);

        final btn = tester.widget<ElevatedButton>(btnFinder);
        expect(btn.onPressed, isNotNull);

        expect(find.text('Bayar Rp 1.500.000'), findsOneWidget);

        await tester.tap(btnFinder);
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'SppSubmitButton shows CircularProgressIndicator while submitting',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SppSubmitButton(
                isSubmitting: true,
                isEnabled: true,
                totalAmount: 750000,
                onSubmit: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'SppBillSummaryCard renders bill count and total amount accurately',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SppBillSummaryCard(
                selectedMonthsCount: 3,
                rate: 750000,
                totalAmount: 2250000,
              ),
            ),
          ),
        );

        expect(find.text('Total Tagihan'), findsOneWidget);
        expect(find.text('3 bulan x Rp 750.000'), findsOneWidget);
        expect(find.text('Rp 2.250.000'), findsOneWidget);
      },
    );

    testWidgets(
      'SppMonthGridSelector disables pending months and displays pending styling',
      (tester) async {
        int? tappedMonth;
        final bills = [
          SppBillModel(
            id: 'b1',
            studentId: 1,
            periodMonth: 1,
            periodYear: 2026,
            amountBilled: 750000,
            status: 'PAID',
          ),
          SppBillModel(
            id: 'b2',
            studentId: 1,
            periodMonth: 2,
            periodYear: 2026,
            amountBilled: 750000,
            status: 'PENDING',
          ),
          SppBillModel(
            id: 'b3',
            studentId: 1,
            periodMonth: 3,
            periodYear: 2026,
            amountBilled: 750000,
            status: 'UNPAID',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SppMonthGridSelector(
                  selectedYear: 2026,
                  selectedStudentId: 1,
                  selectedMonths: const {},
                  bills: bills,
                  isLoadingBills: false,
                  onMonthTapped: (m) => tappedMonth = m,
                ),
              ),
            ),
          ),
        );

        // Month 1 (Jan) is PAID -> has check icon
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

        // Month 2 (Feb) is PENDING -> has access_time_rounded icon
        expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);

        // Tapping Month 2 (Feb) should not trigger onMonthTapped
        await tester.tap(find.text('Feb'));
        await tester.pump();
        expect(tappedMonth, isNull);

        // Tapping Month 3 (Mar - UNPAID) triggers onMonthTapped
        await tester.tap(find.text('Mar'));
        await tester.pump();
        expect(tappedMonth, 3);
      },
    );
  });
}
