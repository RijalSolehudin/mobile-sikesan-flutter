class StudentSummaryModel {
  final int id;
  final String name;
  final String grade;
  final num walletBalance;

  const StudentSummaryModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.walletBalance,
  });

  factory StudentSummaryModel.fromJson(Map<String, dynamic> json) {
    return StudentSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Santri',
      grade: (json['grade'] as String?) ?? 'Santri',
      walletBalance: (json['wallet_balance'] as num?) ?? 0,
    );
  }
}

class DashboardMetricModel {
  final num totalBalance;
  final num totalIncome;
  final num totalExpense;
  final num totalUnpaidSpp;
  final num monthlyBill;
  final String unpaidStatus;
  final String role;
  final String? metricTitle1;
  final String? metricTitle2;
  final String? metricTitle3;
  final List<StudentSummaryModel> students;

  const DashboardMetricModel({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalUnpaidSpp,
    required this.monthlyBill,
    required this.unpaidStatus,
    this.role = 'Wali Santri',
    this.metricTitle1,
    this.metricTitle2,
    this.metricTitle3,
    this.students = const [],
  });

  factory DashboardMetricModel.fromGuardianJson(Map<String, dynamic> json) {
    final balance = (json['total_balance'] as num?) ?? 0;
    final unpaid = (json['total_unpaid_spp'] as num?) ?? 0;
    final infaq = (json['total_infaq_paid'] as num?) ?? 0;

    List<StudentSummaryModel> studentsList = [];
    if (json['students'] is List) {
      studentsList = (json['students'] as List)
          .whereType<Map<String, dynamic>>()
          .map((s) => StudentSummaryModel.fromJson(s))
          .toList();
    }

    return DashboardMetricModel(
      totalBalance: balance,
      totalIncome: unpaid,
      totalExpense: infaq,
      totalUnpaidSpp: unpaid,
      monthlyBill: unpaid,
      unpaidStatus: unpaid > 0 ? 'Tagihan Belum Lunas' : 'Semua Tagihan Lunas',
      role: 'Wali Santri',
      metricTitle1: 'TOTAL SALDO SANTRI',
      metricTitle2: 'TAGIHAN SPP',
      metricTitle3: 'TOTAL INFAK KESANTRIAN',
      students: studentsList,
    );
  }

  factory DashboardMetricModel.fromTreasurerJson(Map<String, dynamic> json) {
    final globalBalance = (json['global_wallet_balance'] as num?) ?? (json['total_savings'] as num?) ?? 0;
    final monthlySpp = (json['monthly_spp_collected'] as num?) ?? 0;
    final monthlyInfaq = (json['monthly_infaq_collected'] as num?) ?? 0;

    return DashboardMetricModel(
      totalBalance: globalBalance,
      totalIncome: monthlySpp,
      totalExpense: monthlyInfaq,
      totalUnpaidSpp: monthlySpp,
      monthlyBill: monthlySpp,
      unpaidStatus: 'Bulan Berjalan',
      role: 'Bendahara',
      metricTitle1: 'TOTAL TABUNGAN SANTRI',
      metricTitle2: 'SPP BULAN INI',
      metricTitle3: 'INFAK BULAN INI',
      students: const [],
    );
  }

  factory DashboardMetricModel.dummy() {
    return const DashboardMetricModel(
      totalBalance: 1230500,
      totalIncome: 3410000,
      totalExpense: 2179500,
      totalUnpaidSpp: 150750000,
      monthlyBill: 750000,
      unpaidStatus: 'Bulan Berjalan',
      students: [
        StudentSummaryModel(
          id: 1,
          name: 'Muhammad Alfatih',
          grade: 'SMP - Kelas 7A',
          walletBalance: 250000,
        ),
      ],
    );
  }
}
