import 'spp_models.dart';

class InfaqBillModel {
  final String id;
  final int studentId;
  final int periodMonth;
  final int periodYear;
  final num amountBilled;
  final String status; // 'PAID', 'UNPAID', 'PARTIAL', 'PENDING'

  const InfaqBillModel({
    required this.id,
    required this.studentId,
    required this.periodMonth,
    required this.periodYear,
    required this.amountBilled,
    required this.status,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';
  bool get isPending => status.toUpperCase() == 'PENDING';

  factory InfaqBillModel.fromJson(Map<String, dynamic> json) {
    return InfaqBillModel(
      id: json['id']?.toString() ?? '',
      studentId: int.tryParse(json['student_id']?.toString() ?? '') ?? 0,
      periodMonth: int.tryParse(json['period_month']?.toString() ?? '') ?? 1,
      periodYear:
          int.tryParse(json['period_year']?.toString() ?? '') ??
          DateTime.now().year,
      amountBilled: num.tryParse(json['amount_billed']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'UNPAID',
    );
  }
}

class InfaqReceiptBillItem {
  final int month;
  final String monthName;
  final int year;
  final num amount;

  const InfaqReceiptBillItem({
    required this.month,
    required this.monthName,
    required this.year,
    required this.amount,
  });

  factory InfaqReceiptBillItem.fromJson(Map<String, dynamic> json) {
    return InfaqReceiptBillItem(
      month: int.tryParse(json['period_month']?.toString() ?? '') ?? 1,
      monthName: json['month_name']?.toString() ?? 'Bulan',
      year:
          int.tryParse(json['period_year']?.toString() ?? '') ??
          DateTime.now().year,
      amount:
          num.tryParse(json['allocated_amount']?.toString() ?? '') ??
          num.tryParse(json['amount_billed']?.toString() ?? '') ??
          0,
    );
  }
}

class InfaqReceiptModel {
  final String receiptNumber;
  final String paymentId;
  final String paymentDate;
  final String paymentTime;
  final num totalPaidAmount;
  final String paymentMethod;
  final String status;
  final String studentName;
  final String studentNis;
  final String studentClass;
  final String guardianName;
  final List<InfaqReceiptBillItem> bills;

  const InfaqReceiptModel({
    required this.receiptNumber,
    required this.paymentId,
    required this.paymentDate,
    required this.paymentTime,
    required this.totalPaidAmount,
    required this.paymentMethod,
    required this.status,
    required this.studentName,
    required this.studentNis,
    required this.studentClass,
    required this.guardianName,
    required this.bills,
  });

  factory InfaqReceiptModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    final guardian = json['guardian'] as Map<String, dynamic>?;
    final billsRaw = json['bills'] as List<dynamic>? ?? [];

    return InfaqReceiptModel(
      receiptNumber: json['receipt_number']?.toString() ?? 'KW-INF-0000',
      paymentId: json['payment_id']?.toString() ?? '',
      paymentDate:
          json['payment_date']?.toString() ?? DateTime.now().toIso8601String(),
      paymentTime: json['payment_time']?.toString() ?? '00:00:00',
      totalPaidAmount:
          num.tryParse(json['total_paid_amount']?.toString() ?? '') ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? 'TRANSFER',
      status: json['status']?.toString() ?? 'APPROVED',
      studentName: student?['name']?.toString() ?? 'Santri',
      studentNis: student?['nis']?.toString() ?? '-',
      studentClass: student?['classroom']?.toString() ?? '-',
      guardianName: guardian?['name']?.toString() ?? '-',
      bills: billsRaw
          .whereType<Map<String, dynamic>>()
          .map((b) => InfaqReceiptBillItem.fromJson(b))
          .toList(),
    );
  }

  SppReceiptModel toSppReceiptModel() {
    return SppReceiptModel(
      receiptNumber: receiptNumber,
      paymentId: paymentId,
      paymentDate: paymentDate,
      paymentTime: paymentTime,
      totalPaidAmount: totalPaidAmount,
      paymentMethod: paymentMethod,
      status: status,
      studentName: studentName,
      studentNis: studentNis,
      studentClass: studentClass,
      guardianName: guardianName,
      bills: bills
          .map(
            (b) => SppReceiptBillItem(
              month: b.month,
              monthName: b.monthName,
              year: b.year,
              amount: b.amount,
            ),
          )
          .toList(),
    );
  }
}
