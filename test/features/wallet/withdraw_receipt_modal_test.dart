import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/models/withdraw_models.dart';
import 'package:mobile_sikesan_flutter/features/wallet/widget/withdraw_receipt_modal.dart';

void main() {
  testWidgets('WithdrawReceiptModal renders without throwing LocaleDataException', (tester) async {
    final receipt = WithdrawReceiptModel(
      receiptNumber: 'WD-20261003-ABCDEF',
      transactionId: '01HA123456789',
      studentId: 1,
      studentName: 'Ahmad Santri',
      studentNis: '12345',
      studentClass: '7 - A',
      amount: 50000,
      balanceBefore: 150000,
      balanceAfter: 100000,
      date: DateTime.now(),
      processedBy: 'Bendahara Utama',
      description: 'Uang Saku Mingguan',
      status: 'SUCCESS',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WithdrawReceiptModal(receipt: receipt),
        ),
      ),
    );

    expect(find.text('Bukti Penarikan Saldo'), findsOneWidget);
  });
}
