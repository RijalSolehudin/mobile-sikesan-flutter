class SppBillModel {
  final String id;
  final int studentId;
  final int periodMonth;
  final int periodYear;
  final num amountBilled;
  final String status; // 'PAID', 'UNPAID', 'PARTIAL'

  const SppBillModel({
    required this.id,
    required this.studentId,
    required this.periodMonth,
    required this.periodYear,
    required this.amountBilled,
    required this.status,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';

  factory SppBillModel.fromJson(Map<String, dynamic> json) {
    return SppBillModel(
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

class StudentLookupModel {
  final int id;
  final String name;
  final String nis;
  final String grade;

  const StudentLookupModel({
    required this.id,
    required this.name,
    required this.nis,
    required this.grade,
  });

  factory StudentLookupModel.fromJson(Map<String, dynamic> json) {
    String gradeStr = 'Santri';
    if (json['classroom'] != null && json['classroom'] is Map) {
      final c = json['classroom'] as Map<String, dynamic>;
      final level = c['education_level']?.toString() ?? '';
      final cName = c['name']?.toString() ?? '';
      gradeStr = trimGrade(level, cName);
    } else if (json['grade'] != null) {
      gradeStr = json['grade'].toString();
    }

    return StudentLookupModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Santri',
      nis: json['nis']?.toString() ?? '-',
      grade: gradeStr,
    );
  }

  static String trimGrade(String level, String name) {
    final combined = '${level.isNotEmpty ? '$level - ' : ''}$name'.trim();
    return combined.isEmpty ? 'Santri' : combined;
  }
}

class BankAccountModel {
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String code;

  const BankAccountModel({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.code,
  });

  static List<BankAccountModel> defaultAccounts() {
    return const [
      BankAccountModel(
        bankName: 'BSI',
        accountNumber: '7145892301',
        accountHolder: 'Pesantren Sikesan',
        code: 'bsi',
      ),
      BankAccountModel(
        bankName: 'BCA',
        accountNumber: '8820491823',
        accountHolder: 'Yayasan Sikesan',
        code: 'bca',
      ),
      BankAccountModel(
        bankName: 'Mandiri',
        accountNumber: '131009823412',
        accountHolder: 'Ponpes Sikesan',
        code: 'mandiri',
      ),
    ];
  }
}

class SppReceiptBillItem {
  final int month;
  final String monthName;
  final int year;
  final num amount;

  const SppReceiptBillItem({
    required this.month,
    required this.monthName,
    required this.year,
    required this.amount,
  });

  factory SppReceiptBillItem.fromJson(Map<String, dynamic> json) {
    return SppReceiptBillItem(
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

class SppReceiptModel {
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
  final List<SppReceiptBillItem> bills;

  const SppReceiptModel({
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

  factory SppReceiptModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    final guardian = json['guardian'] as Map<String, dynamic>?;
    final billsRaw = json['bills'] as List<dynamic>? ?? [];

    return SppReceiptModel(
      receiptNumber: json['receipt_number']?.toString() ?? 'KW-SPP-0000',
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
          .map((b) => SppReceiptBillItem.fromJson(b))
          .toList(),
    );
  }
}
