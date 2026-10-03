import '../../core/utils/date_formatter.dart';
import 'bill_history_model.dart';
import 'infaq_models.dart';
import 'spp_models.dart';
import 'top_up_models.dart';

class TransactionItemModel {
  final String id;
  final String? transactionNumber;
  final String title;
  final String category;
  final num amount;
  final bool isIncome;
  final DateTime date;
  final String? studentName;
  final String? studentClass;
  final String? studentNis;
  final int? studentId;
  final String status;
  final String statusLabel;
  final String? paymentMethod;
  final String? senderBankName;
  final String? senderAccountHolder;
  final String? proofUrl;
  final String? description;
  final SppReceiptModel? receipt;
  final Map<String, dynamic>? rawJson;

  const TransactionItemModel({
    required this.id,
    this.transactionNumber,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.studentName,
    this.studentClass,
    this.studentNis,
    this.studentId,
    this.status = 'SUCCESS',
    this.statusLabel = 'Berhasil',
    this.paymentMethod,
    this.senderBankName,
    this.senderAccountHolder,
    this.proofUrl,
    this.description,
    this.receipt,
    this.rawJson,
  });

  bool get isPending =>
      status.toUpperCase() == 'PENDING' ||
      status.toUpperCase() == 'WAITING' ||
      status.toUpperCase() == 'SUBMITTED' ||
      status.toUpperCase() == 'MENUNGGU' ||
      status.toUpperCase() == 'MENUNGGU VERIFIKASI';

  bool get isPaidOrSuccess =>
      status.toUpperCase() == 'PAID' ||
      status.toUpperCase() == 'SUCCESS' ||
      status.toUpperCase() == 'APPROVED' ||
      status.toUpperCase() == 'VERIFIED' ||
      status.toUpperCase() == 'LUNAS' ||
      status.toUpperCase() == 'BERHASIL';

  bool get isRejectedOrFailed =>
      status.toUpperCase() == 'REJECTED' ||
      status.toUpperCase() == 'FAILED' ||
      status.toUpperCase() == 'DITOLAK' ||
      status.toUpperCase() == 'CANCELLED';

  bool get isUnpaid =>
      status.toUpperCase() == 'UNPAID' ||
      status.toUpperCase() == 'BELUM LUNAS' ||
      status.toUpperCase() == 'PARTIAL';

  static String normalizeStatus(dynamic rawStatus) {
    if (rawStatus == null) return 'SUCCESS';
    final s = rawStatus.toString().trim().toUpperCase();
    if (s.isEmpty) return 'SUCCESS';
    return s;
  }

  static String formatStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'WAITING':
      case 'SUBMITTED':
      case 'MENUNGGU':
      case 'MENUNGGU VERIFIKASI':
        return 'Menunggu Verifikasi';
      case 'PAID':
      case 'LUNAS':
        return 'Lunas';
      case 'SUCCESS':
      case 'APPROVED':
      case 'VERIFIED':
      case 'BERHASIL':
        return 'Berhasil';
      case 'REJECTED':
      case 'DITOLAK':
        return 'Ditolak';
      case 'FAILED':
      case 'GAGAL':
        return 'Gagal';
      case 'CANCELLED':
      case 'BATAL':
        return 'Dibatalkan';
      case 'PARTIAL':
      case 'SEBAGIAN':
        return 'Sebagian';
      case 'UNPAID':
      case 'BELUM LUNAS':
        return 'Belum Lunas';
      default:
        return status;
    }
  }

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    final type = (json['type']?.toString().toUpperCase()) ?? 'DEBIT';
    final bool isCredit =
        (type == 'CREDIT' || type == 'TOP_UP' || type == 'INCOME');

    // Extract student name, class, nis, id
    String studentName = 'Santri';
    String studentClass = json['student_class']?.toString() ?? '';
    String? studentNis = json['student_nis']?.toString();
    int? studentId = int.tryParse(json['student_id']?.toString() ?? '');

    if (json['student_name'] != null) {
      studentName = json['student_name'].toString();
    } else if (json['wallet'] != null && json['wallet'] is Map) {
      final wallet = json['wallet'] as Map<String, dynamic>;
      studentId ??= int.tryParse(wallet['student_id']?.toString() ?? '');
      if (wallet['student'] != null && wallet['student'] is Map) {
        final st = wallet['student'] as Map<String, dynamic>;
        studentId ??= int.tryParse(st['id']?.toString() ?? '');
        studentName = st['name']?.toString() ?? 'Santri';
        studentNis ??= st['nis']?.toString();
        if (studentClass.isEmpty &&
            st['classroom'] != null &&
            st['classroom'] is Map) {
          studentClass = st['classroom']['name']?.toString() ?? '';
        }
      }
    } else if (json['student'] != null && json['student'] is Map) {
      final st = json['student'] as Map<String, dynamic>;
      studentId ??= int.tryParse(st['id']?.toString() ?? '');
      studentName = st['name']?.toString() ?? 'Santri';
      studentNis ??= st['nis']?.toString();
      if (studentClass.isEmpty &&
          st['classroom'] != null &&
          st['classroom'] is Map) {
        studentClass = st['classroom']['name']?.toString() ?? '';
      }
    }

    final rawStatus = json['status']?.toString();
    final status = normalizeStatus(rawStatus ?? 'SUCCESS');
    final statusLabel =
        json['status_label']?.toString() ?? formatStatusLabel(status);

    final rawDate = json['created_at'] ?? json['date'];
    final date = DateFormatter.parseUtc7(rawDate);

    final txNumber = json['reference_number']?.toString() ??
        json['transaction_number']?.toString() ??
        json['reference_id']?.toString() ??
        json['id']?.toString();

    final paymentMethod = json['payment_method']?.toString() ??
        (isCredit ? 'TRANSFER' : 'WALLET');

    final proofUrl = json['proof_url']?.toString() ??
        json['proof']?.toString() ??
        json['proof_full_url']?.toString();

    final desc =
        json['description']?.toString() ?? json['notes']?.toString();

    return TransactionItemModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNumber: txNumber,
      title: json['description']?.toString() ??
          (isCredit ? 'Top Up Saldo' : 'Pengeluaran Saldo'),
      category: json['reference_type']?.toString() ??
          (isCredit ? 'Pemasukan Saldo' : 'Pengeluaran Saldo'),
      amount: (json['amount'] as num?) ?? 0,
      isIncome: isCredit,
      date: date,
      studentName: studentName,
      studentClass: studentClass,
      studentNis: studentNis,
      studentId: studentId,
      status: status,
      statusLabel: statusLabel,
      paymentMethod: paymentMethod,
      senderBankName: json['bank_name']?.toString() ??
          json['sender_bank_name']?.toString(),
      senderAccountHolder: json['account_holder']?.toString() ??
          json['sender_account_holder']?.toString(),
      proofUrl: proofUrl,
      description: desc,
      rawJson: json,
    );
  }

  factory TransactionItemModel.fromSppJson(
    Map<String, dynamic> json, {
    bool isGuardian = true,
  }) {
    String studentName = 'Santri';
    String studentClass = '';
    String? studentNis;
    int? studentId;

    if (json['student'] != null && json['student'] is Map) {
      final st = json['student'] as Map<String, dynamic>;
      studentId = int.tryParse(st['id']?.toString() ?? '');
      studentName = st['name']?.toString() ?? 'Santri';
      studentNis = st['nis']?.toString();
      if (st['classroom'] != null && st['classroom'] is Map) {
        studentClass = st['classroom']['name']?.toString() ?? '';
      } else if (st['classroom'] is String) {
        studentClass = st['classroom'].toString();
      }
    }
    studentId ??= int.tryParse(json['student_id']?.toString() ?? '');

    final amount =
        (json['total_paid_amount'] as num?) ?? (json['amount'] as num?) ?? 0;
    final dateStr = json['payment_date'] ?? json['created_at'];
    final date = DateFormatter.parseUtc7(dateStr);

    final rawStatus = json['status']?.toString();
    final status = normalizeStatus(
      rawStatus ??
          (json['verified_at'] != null || json['is_approved'] == true
              ? 'PAID'
              : (json['proof'] != null || json['payment_proof'] != null
                  ? 'PENDING'
                  : 'PAID')),
    );
    final statusLabel = json['status_label']?.toString() ??
        (status == 'PAID' ? 'Lunas' : formatStatusLabel(status));

    final txNumber = json['receipt_number']?.toString() ??
        json['payment_id']?.toString() ??
        json['id']?.toString();

    SppReceiptModel? receipt;
    if (json['receipt_number'] != null || json['bills'] != null) {
      try {
        receipt = SppReceiptModel.fromJson(json);
      } catch (_) {}
    }

    return TransactionItemModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNumber: txNumber,
      title: 'Pembayaran SPP',
      category: json['payment_method']?.toString() ?? 'Kasir / Transfer',
      amount: amount,
      isIncome: !isGuardian,
      date: date,
      studentName: studentName,
      studentClass: studentClass,
      studentNis: studentNis,
      studentId: studentId,
      status: status,
      statusLabel: statusLabel,
      paymentMethod: json['payment_method']?.toString() ?? 'TRANSFER',
      senderBankName: json['sender_bank_name']?.toString(),
      senderAccountHolder: json['sender_account_holder']?.toString(),
      proofUrl: json['proof_url']?.toString() ??
          json['proof']?.toString() ??
          json['payment_proof']?.toString(),
      description: json['notes']?.toString() ?? 'Pembayaran SPP Santri',
      receipt: receipt,
      rawJson: json,
    );
  }

  factory TransactionItemModel.fromInfaqJson(
    Map<String, dynamic> json, {
    bool isGuardian = true,
  }) {
    String studentName = 'Santri';
    String studentClass = '';
    String? studentNis;
    int? studentId;

    if (json['student'] != null && json['student'] is Map) {
      final st = json['student'] as Map<String, dynamic>;
      studentId = int.tryParse(st['id']?.toString() ?? '');
      studentName = st['name']?.toString() ?? 'Santri';
      studentNis = st['nis']?.toString();
      if (st['classroom'] != null && st['classroom'] is Map) {
        studentClass = st['classroom']['name']?.toString() ?? '';
      } else if (st['classroom'] is String) {
        studentClass = st['classroom'].toString();
      }
    }
    studentId ??= int.tryParse(json['student_id']?.toString() ?? '');

    String categoryName = 'Infak Santri';
    if (json['category'] != null && json['category'] is Map) {
      categoryName = json['category']['name']?.toString() ?? 'Infak Santri';
    }

    final amount = (json['amount'] as num?) ??
        (json['total_paid_amount'] as num?) ??
        0;
    final dateStr = json['created_at'] ?? json['payment_date'];
    final date = DateFormatter.parseUtc7(dateStr);

    final rawStatus = json['status']?.toString();
    final status = normalizeStatus(
      rawStatus ??
          (json['verified_at'] != null || json['is_approved'] == true
              ? 'PAID'
              : (json['proof'] != null ? 'PENDING' : 'PAID')),
    );
    final statusLabel = json['status_label']?.toString() ??
        (status == 'PAID' ? 'Lunas' : formatStatusLabel(status));

    final txNumber = json['receipt_number']?.toString() ??
        json['payment_id']?.toString() ??
        json['id']?.toString();

    SppReceiptModel? receipt;
    if (json['receipt_number'] != null || json['bills'] != null) {
      try {
        receipt = InfaqReceiptModel.fromJson(json).toSppReceiptModel();
      } catch (_) {}
    }

    return TransactionItemModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      transactionNumber: txNumber,
      title: 'Infak Kesantrian',
      category: categoryName,
      amount: amount,
      isIncome: !isGuardian,
      date: date,
      studentName: studentName,
      studentClass: studentClass,
      studentNis: studentNis,
      studentId: studentId,
      status: status,
      statusLabel: statusLabel,
      paymentMethod: json['payment_method']?.toString() ?? 'TRANSFER',
      senderBankName: json['sender_bank_name']?.toString(),
      senderAccountHolder: json['sender_account_holder']?.toString(),
      proofUrl: json['proof_url']?.toString() ?? json['proof']?.toString(),
      description: json['notes']?.toString() ?? 'Infak Kesantrian',
      receipt: receipt,
      rawJson: json,
    );
  }

  factory TransactionItemModel.fromBillModel(BillHistoryModel bill) {
    final isPaid = bill.isPaid;
    final isPending = bill.isPending;
    final status = isPaid ? 'PAID' : (isPending ? 'PENDING' : bill.status);
    final statusLabel = bill.statusLabel.isNotEmpty
        ? bill.statusLabel
        : formatStatusLabel(status);

    final date = DateFormatter.parseUtc7(bill.createdAt ?? bill.dueDate);

    return TransactionItemModel(
      id: bill.id,
      transactionNumber: 'TAG-${bill.id}',
      title: bill.title,
      category: bill.category,
      amount: bill.amountBilled,
      isIncome: false,
      date: date,
      studentName: bill.studentName,
      studentClass: bill.studentClass,
      studentNis: bill.studentNis,
      studentId: bill.studentId > 0 ? bill.studentId : null,
      status: status,
      statusLabel: statusLabel,
      paymentMethod: 'TRANSFER / KASIR',
      description:
          '${bill.title} Periode ${bill.monthName} ${bill.periodYear}',
    );
  }

  factory TransactionItemModel.fromTopUpModel(TopUpRequestModel topUp) {
    final date = DateFormatter.parseUtc7(topUp.createdAt);
    final status = normalizeStatus(topUp.status);
    final statusLabel = formatStatusLabel(status);

    return TransactionItemModel(
      id: topUp.id,
      transactionNumber: 'TOP-${topUp.id}',
      title: 'Top Up Saldo',
      category: 'Pemasukan Saldo',
      amount: topUp.requestedAmount,
      isIncome: true,
      date: date,
      studentName: topUp.studentName ?? 'Santri',
      studentClass: topUp.studentGrade ?? '',
      studentNis: topUp.studentNis,
      studentId: topUp.studentId > 0 ? topUp.studentId : null,
      status: status,
      statusLabel: statusLabel,
      paymentMethod: topUp.paymentMethod,
      proofUrl: topUp.proofUrl,
      description: 'Pengajuan Top Up Saldo Dompet Santri',
    );
  }
}
