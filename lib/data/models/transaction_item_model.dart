class TransactionItemModel {
  final String id;
  final String title;
  final String category;
  final num amount;
  final bool isIncome;
  final DateTime date;
  final String? studentName;
  final String? studentClass;

  const TransactionItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.studentName,
    this.studentClass,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    final type = (json['type']?.toString().toUpperCase()) ?? 'DEBIT';
    final bool isCredit =
        (type == 'CREDIT' || type == 'TOP_UP' || type == 'INCOME');

    // Extract student name from wallet.student.name if available
    String studentName = 'Santri';
    if (json['student_name'] != null) {
      studentName = json['student_name'].toString();
    } else if (json['wallet'] != null && json['wallet'] is Map) {
      final wallet = json['wallet'] as Map<String, dynamic>;
      if (wallet['student'] != null && wallet['student'] is Map) {
        studentName = wallet['student']['name']?.toString() ?? 'Santri';
      }
    } else if (json['student'] != null && json['student'] is Map) {
      studentName = json['student']['name']?.toString() ?? 'Santri';
    }

    return TransactionItemModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title:
          json['description']?.toString() ??
          (isCredit ? 'Top Up Saldo' : 'Pengeluaran Saldo'),
      category:
          json['reference_type']?.toString() ??
          (isCredit ? 'Pemasukan Saldo' : 'Pengeluaran Saldo'),
      amount: (json['amount'] as num?) ?? 0,
      isIncome: isCredit,
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      studentName: studentName,
      studentClass: json['student_class']?.toString() ?? '',
    );
  }

  factory TransactionItemModel.fromSppJson(
    Map<String, dynamic> json, {
    bool isGuardian = true,
  }) {
    String studentName = 'Santri';
    if (json['student'] != null && json['student'] is Map) {
      studentName = json['student']['name']?.toString() ?? 'Santri';
    }

    final amount =
        (json['total_paid_amount'] as num?) ?? (json['amount'] as num?) ?? 0;
    final dateStr = json['payment_date'] ?? json['created_at'];

    return TransactionItemModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Pembayaran SPP',
      category: json['payment_method']?.toString() ?? 'Kasir / Transfer',
      amount: amount,
      isIncome:
          !isGuardian, // Bagi wali santri ini pengeluaran, bagi bendahara penerimaan
      date: dateStr != null
          ? DateTime.tryParse(dateStr.toString()) ?? DateTime.now()
          : DateTime.now(),
      studentName: studentName,
      studentClass: '',
    );
  }

  factory TransactionItemModel.fromInfaqJson(
    Map<String, dynamic> json, {
    bool isGuardian = true,
  }) {
    String studentName = 'Santri';
    if (json['student'] != null && json['student'] is Map) {
      studentName = json['student']['name']?.toString() ?? 'Santri';
    }

    String categoryName = 'Infak Santri';
    if (json['category'] != null && json['category'] is Map) {
      categoryName = json['category']['name']?.toString() ?? 'Infak Santri';
    }

    final amount = (json['amount'] as num?) ?? 0;
    final dateStr = json['created_at'];

    return TransactionItemModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Infak Kesantrian',
      category: categoryName,
      amount: amount,
      isIncome: !isGuardian,
      date: dateStr != null
          ? DateTime.tryParse(dateStr.toString()) ?? DateTime.now()
          : DateTime.now(),
      studentName: studentName,
      studentClass: '',
    );
  }

  static List<TransactionItemModel> dummies() {
    return [
      TransactionItemModel(
        id: '1',
        title: 'Top Up Saldo',
        category: 'Pemasukan Saldo',
        amount: 2250000,
        isIncome: true,
        date: DateTime(2026, 9, 23, 21, 44),
        studentName: 'Dadung',
        studentClass: 'Semua Santri',
      ),
    ];
  }
}
