import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/models/top_up_models.dart';

void main() {
  group('Top Up Models Unit Tests', () {
    test('TopUpRequestModel parses JSON correctly', () {
      final json = {
        'id': '01jq9x3v7z4',
        'student_id': 5,
        'requested_amount': 250000,
        'payment_method': 'TRANSFER',
        'status': 'PENDING',
        'proof_url': '/storage/topup-proofs/sample.jpg',
        'created_at': '2026-10-01T10:00:00.000Z',
        'student': {
          'name': 'Ahmad Dahlan',
          'nis': 'NIS-1002',
          'classroom': {
            'education_level': 'MA',
            'name': 'Kelas 12 IPA',
          },
        },
      };

      final model = TopUpRequestModel.fromJson(json);
      expect(model.id, '01jq9x3v7z4');
      expect(model.studentId, 5);
      expect(model.requestedAmount, 250000);
      expect(model.paymentMethod, 'TRANSFER');
      expect(model.status, 'PENDING');
      expect(model.isPending, true);
      expect(model.isApproved, false);
      expect(model.isRejected, false);
      expect(model.studentName, 'Ahmad Dahlan');
      expect(model.studentNis, 'NIS-1002');
      expect(model.studentGrade, 'MA Kelas 12 IPA');
    });

    test('TopUpRequestModel detects APPROVED status correctly', () {
      final json = {
        'id': '01jq9x3v7z5',
        'student_id': 2,
        'requested_amount': 500000,
        'payment_method': 'CASH',
        'status': 'APPROVED',
      };

      final model = TopUpRequestModel.fromJson(json);
      expect(model.isApproved, true);
      expect(model.isPending, false);
      expect(model.isRejected, false);
    });

    test('TopUpReceiptModel formats and holds data correctly', () {
      final receipt = TopUpReceiptModel(
        receiptNumber: 'KW-TOPUP-12345',
        topUpId: '01jq9x3v7z4',
        paymentDate: '2026-10-01',
        paymentTime: '10:15:00',
        amount: 300000,
        paymentMethod: 'CASH',
        status: 'APPROVED',
        studentName: 'Zaid bin Tsabit',
        studentNis: 'NIS-5544',
        studentClass: 'Kelas 10',
        guardianName: 'Kasir Utama',
      );

      expect(receipt.receiptNumber, 'KW-TOPUP-12345');
      expect(receipt.amount, 300000);
      expect(receipt.isApproved, true);
      expect(receipt.studentName, 'Zaid bin Tsabit');
    });
  });
}
