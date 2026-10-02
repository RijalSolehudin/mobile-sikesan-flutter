class BillHistoryModel {
  final String id;
  final String billType; // 'SPP', 'INFAQ', 'ANNUAL_FEE'
  final String title;
  final String category;
  final int studentId;
  final String studentName;
  final String studentNis;
  final String studentClass;
  final int periodMonth;
  final int periodYear;
  final String monthName;
  final num amountBilled;
  final String status; // 'UNPAID', 'PENDING', 'PARTIAL', 'PAID'
  final String
  statusLabel; // 'Belum Lunas', 'Menunggu Verifikasi', 'Sebagian', 'Lunas'
  final DateTime? dueDate;
  final DateTime? createdAt;

  const BillHistoryModel({
    required this.id,
    required this.billType,
    required this.title,
    required this.category,
    required this.studentId,
    required this.studentName,
    required this.studentNis,
    required this.studentClass,
    required this.periodMonth,
    required this.periodYear,
    required this.monthName,
    required this.amountBilled,
    required this.status,
    required this.statusLabel,
    this.dueDate,
    this.createdAt,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isUnpaid =>
      status.toUpperCase() == 'UNPAID' || status.toUpperCase() == 'PARTIAL';

  factory BillHistoryModel.fromJson(Map<String, dynamic> json) {
    return BillHistoryModel(
      id: json['id']?.toString() ?? '',
      billType: json['bill_type']?.toString().toUpperCase() ?? 'SPP',
      title: json['title']?.toString() ?? 'Tagihan',
      category: json['category']?.toString() ?? 'Tagihan',
      studentId: int.tryParse(json['student_id']?.toString() ?? '') ?? 0,
      studentName: json['student_name']?.toString() ?? 'Santri',
      studentNis: json['student_nis']?.toString() ?? '',
      studentClass: json['student_class']?.toString() ?? '',
      periodMonth: int.tryParse(json['period_month']?.toString() ?? '') ?? 0,
      periodYear: int.tryParse(json['period_year']?.toString() ?? '') ?? 0,
      monthName: json['month_name']?.toString() ?? '',
      amountBilled: num.tryParse(json['amount_billed']?.toString() ?? '') ?? 0,
      status: json['status']?.toString().toUpperCase() ?? 'UNPAID',
      statusLabel: json['status_label']?.toString() ?? 'Belum Lunas',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
