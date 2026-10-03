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

    // Extract student name and class
    String studentName = 'Santri';
    String studentClass = json['student_class']?.toString() ?? '';
    if (json['student_name'] != null) {
      studentName = json['student_name'].toString();
    } else if (json['wallet'] != null && json['wallet'] is Map) {
      final wallet = json['wallet'] as Map<String, dynamic>;
      if (wallet['student'] != null && wallet['student'] is Map) {
        final st = wallet['student'] as Map<String, dynamic>;
        studentName = st['name']?.toString() ?? 'Santri';
        if (studentClass.isEmpty && st['classroom'] != null && st['classroom'] is Map) {
          studentClass = st['classroom']['name']?.toString() ?? '';
        }
      }
    } else if (json['student'] != null && json['student'] is Map) {
      final st = json['student'] as Map<String, dynamic>;
      studentName = st['name']?.toString() ?? 'Santri';
      if (studentClass.isEmpty && st['classroom'] != null && st['classroom'] is Map) {
        studentClass = st['classroom']['name']?.toString() ?? '';
      }
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
      studentClass: studentClass,
    );
  }

  factory TransactionItemModel.fromSppJson(
    Map<String, dynamic> json, {
    bool isGuardian = true,
  }) {
    String studentName = 'Santri';
    String studentClass = '';
    if (json['student'] != null && json['student'] is Map) {
      final st = json['student'] as Map<String, dynamic>;
      studentName = st['name']?.toString() ?? 'Santri';
      if (st['classroom'] != null && st['classroom'] is Map) {
        studentClass = st['classroom']['name']?.toString() ?? '';
      }
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
      studentClass: studentClass,
    );
  }

  factory TransactionItemModel.fromInfaqJson(
    Map<String, dynamic> json, {
    bool isGuardian = true,
  }) {
    String studentName = 'Santri';
    String studentClass = '';
    if (json['student'] != null && json['student'] is Map) {
      final st = json['student'] as Map<String, dynamic>;
      studentName = st['name']?.toString() ?? 'Santri';
      if (st['classroom'] != null && st['classroom'] is Map) {
        studentClass = st['classroom']['name']?.toString() ?? '';
      }
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
      studentClass: studentClass,
    );
  }
}
