class WithdrawReceiptModel {
  final String receiptNumber;
  final String transactionId;
  final int studentId;
  final String studentName;
  final String studentNis;
  final String studentClass;
  final num amount;
  final num balanceBefore;
  final num balanceAfter;
  final DateTime date;
  final String processedBy;
  final String description;
  final String status;

  const WithdrawReceiptModel({
    required this.receiptNumber,
    required this.transactionId,
    required this.studentId,
    required this.studentName,
    required this.studentNis,
    required this.studentClass,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.date,
    required this.processedBy,
    required this.description,
    required this.status,
  });

  factory WithdrawReceiptModel.fromJson(Map<String, dynamic> json) {
    return WithdrawReceiptModel(
      receiptNumber:
          json['receipt_number']?.toString() ??
          'WD-${DateTime.now().millisecondsSinceEpoch}',
      transactionId: json['transaction_id']?.toString() ?? '',
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      studentName: json['student_name']?.toString() ?? 'Santri',
      studentNis: json['student_nis']?.toString() ?? '-',
      studentClass: json['student_class']?.toString() ?? 'Santri',
      amount: (json['amount'] as num?) ?? 0,
      balanceBefore: (json['balance_before'] as num?) ?? 0,
      balanceAfter: (json['balance_after'] as num?) ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      processedBy: json['processed_by']?.toString() ?? 'Bendahara / Kasir',
      description:
          json['description']?.toString() ?? 'Penarikan Tunai Saldo Santri',
      status: json['status']?.toString() ?? 'SUCCESS',
    );
  }
}
