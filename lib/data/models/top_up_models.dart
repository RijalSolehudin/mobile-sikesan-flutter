class TopUpRequestModel {
  final String id;
  final int studentId;
  final num requestedAmount;
  final String paymentMethod; // 'TRANSFER' or 'CASH'
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String? proofUrl;
  final DateTime? createdAt;
  final String? studentName;
  final String? studentNis;
  final String? studentGrade;

  const TopUpRequestModel({
    required this.id,
    required this.studentId,
    required this.requestedAmount,
    required this.paymentMethod,
    required this.status,
    this.proofUrl,
    this.createdAt,
    this.studentName,
    this.studentNis,
    this.studentGrade,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  factory TopUpRequestModel.fromJson(Map<String, dynamic> json) {
    String? sName;
    String? sNis;
    String? sGrade;

    if (json['student'] is Map<String, dynamic>) {
      final s = json['student'] as Map<String, dynamic>;
      sName = s['name']?.toString();
      sNis = s['nis']?.toString();
      if (s['classroom'] is Map<String, dynamic>) {
        final c = s['classroom'] as Map<String, dynamic>;
        sGrade = '${c['education_level'] ?? ''} ${c['name'] ?? ''}'.trim();
      }
    }

    return TopUpRequestModel(
      id: json['id']?.toString() ?? '',
      studentId: int.tryParse(json['student_id']?.toString() ?? '') ?? 0,
      requestedAmount:
          num.tryParse(json['requested_amount']?.toString() ?? '') ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? 'TRANSFER',
      status: json['status']?.toString() ?? 'PENDING',
      proofUrl: json['proof_url']?.toString() ?? json['proof_full_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      studentName: sName,
      studentNis: sNis,
      studentGrade: sGrade,
    );
  }
}

class TopUpReceiptModel {
  final String receiptNumber;
  final String topUpId;
  final String paymentDate;
  final String paymentTime;
  final num amount;
  final String paymentMethod;
  final String status;
  final String studentName;
  final String studentNis;
  final String studentClass;
  final String guardianName;

  const TopUpReceiptModel({
    required this.receiptNumber,
    required this.topUpId,
    required this.paymentDate,
    required this.paymentTime,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.studentName,
    required this.studentNis,
    required this.studentClass,
    required this.guardianName,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
}
