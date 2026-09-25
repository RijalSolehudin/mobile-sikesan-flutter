import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/filter_pill.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../data/models/transaction_item_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../auth/bloc/auth_bloc.dart';

class MutationScreen extends StatefulWidget {
  const MutationScreen({super.key});

  @override
  State<MutationScreen> createState() => _MutationScreenState();
}

class _MutationScreenState extends State<MutationScreen> {
  int _selectedTab = 0; // 0: Uang Saku, 1: Pembayaran SPP, 2: Infak Kesantrian
  int _selectedClassIndex = 0;
  int _selectedFilterType = 0; // 0: Semua, 1: Pemasukan, 2: Pengeluaran
  final String _timeRange = 'Harian';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasInitialLoaded = false;

  final List<String> _tabs = [
    'Uang Saku',
    'Pembayaran SPP',
    'Infak Kesantrian',
  ];
  final List<String> _classes = [
    'Semua Kelas',
    'Kelas 7',
    'Kelas 8',
    'Kelas 9',
    'Kelas 10',
    'Kelas 11',
  ];
  final List<String> _filterTypes = ['Semua', 'Pemasukan', 'Pengeluaran'];

  List<TransactionItemModel> _transactions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialLoaded) {
      _hasInitialLoaded = true;
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final repo = context.read<DashboardRepository>();
    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    ApiResult<List<TransactionItemModel>> result;
    if (_selectedTab == 0) {
      result = await repo.getRecentTransactions(perPage: 30);
    } else if (_selectedTab == 1) {
      result = await repo.getSppTransactions(isGuardian: isGuardian);
    } else {
      result = await repo.getInfaqTransactions(isGuardian: isGuardian);
    }

    if (!mounted) return;

    final res = result;
    if (res is ApiSuccess<List<TransactionItemModel>>) {
      setState(() {
        _transactions = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TransactionItemModel> _getFilteredTransactions() {
    return _transactions.where((tx) {
      // Filter by type
      if (_selectedFilterType == 1 && !tx.isIncome) return false;
      if (_selectedFilterType == 2 && tx.isIncome) return false;

      // Filter by search query (student name or transaction title)
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (tx.studentName ?? '').toLowerCase();
        final title = tx.title.toLowerCase();
        final cat = tx.category.toLowerCase();
        if (!name.contains(query) &&
            !title.contains(query) &&
            !cat.contains(query)) {
          return false;
        }
      }

      // Filter by class if selected
      if (_selectedClassIndex > 0) {
        final selectedClass = _classes[_selectedClassIndex].toLowerCase();
        final txClass = (tx.studentClass ?? '').toLowerCase();
        if (txClass.isNotEmpty &&
            !txClass.contains(selectedClass.replaceAll('kelas ', ''))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredTransactions();
    final totalMasuk = _transactions
        .where((t) => t.isIncome)
        .fold<num>(0, (s, t) => s + t.amount);
    final totalKeluar = _transactions
        .where((t) => !t.isIncome)
        .fold<num>(0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Top Green Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mutasi & Transaksi',
                            style: AppTypography.headerTitle.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Analisis Keuangan Santri & Operasional',
                            style: AppTypography.headerSubtitle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Segmented Tabs Container
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: List.generate(_tabs.length, (index) {
                          final isSelected = _selectedTab == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_selectedTab != index) {
                                  setState(() => _selectedTab = index);
                                  _loadTransactions();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _tabs[index],
                                  textAlign: TextAlign.center,
                                  style: AppTypography.badgeText.copyWith(
                                    fontSize: 11,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Search Bar with Calendar Action
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hintText: 'Cari Nama Santri / Keterangan...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onChanged: (val) {
                              setState(() => _searchQuery = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Class Filter Chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _classes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return FilterPill(
                            label: _classes[index],
                            isSelected: _selectedClassIndex == index,
                            onTap: () =>
                                setState(() => _selectedClassIndex = index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Two Summary Cards (Total Masuk & Total Keluar)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Masuk',
                                  style: AppTypography.itemSubtitle.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+ ${CurrencyFormatter.format(totalMasuk)}',
                                  style: AppTypography.itemTitle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.income,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Keluar',
                                  style: AppTypography.itemSubtitle.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '- ${CurrencyFormatter.format(totalKeluar)}',
                                  style: AppTypography.itemTitle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.expense,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Statistik Transaksi Chart Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Statistik Transaksi',
                                style: AppTypography.itemTitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _timeRange,
                                      style: AppTypography.badgeText.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: _getLine,
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.toInt()) {
                                          case 0:
                                            return const Text(
                                              '0k',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: AppColors.textMuted,
                                              ),
                                            );
                                          case 7:
                                            return const Text(
                                              '7.5k',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: AppColors.textMuted,
                                              ),
                                            );
                                          case 15:
                                            return const Text(
                                              '15k',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: AppColors.textMuted,
                                              ),
                                            );
                                          case 22:
                                            return const Text(
                                              '22.5k',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: AppColors.textMuted,
                                              ),
                                            );
                                          case 30:
                                            return const Text(
                                              '30k',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: AppColors.textMuted,
                                              ),
                                            );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (val, meta) => Text(
                                        val.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 1,
                                maxX: 10,
                                minY: 0,
                                maxY: 30,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: const [
                                      FlSpot(1, 0),
                                      FlSpot(2, 0),
                                      FlSpot(3, 0),
                                      FlSpot(4, 0),
                                      FlSpot(5, 0),
                                      FlSpot(6, 2),
                                      FlSpot(7, 22),
                                      FlSpot(8, 0),
                                      FlSpot(9, 0),
                                      FlSpot(10, 4),
                                    ],
                                    isCurved: true,
                                    color: AppColors.expense,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.expense.withValues(
                                            alpha: 0.35,
                                          ),
                                          AppColors.expense.withValues(
                                            alpha: 0.0,
                                          ),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Riwayat Transaksi Header & Filter Types
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: AppTypography.sectionTitle,
                        ),
                        Text(
                          '${filteredList.length} Transaksi',
                          style: AppTypography.badgeText.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(_filterTypes.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterPill(
                            label: _filterTypes[index],
                            isSelected: _selectedFilterType == index,
                            onTap: () =>
                                setState(() => _selectedFilterType = index),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Transaction List or Loading / Empty state
                    if (_isLoading)
                      Column(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ShimmerBox(
                              width: double.infinity,
                              height: 64,
                              borderRadius: 16,
                            ),
                          ),
                        ),
                      )
                    else if (filteredList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 36,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tidak ada data transaksi ditemukan',
                              style: AppTypography.itemTitle.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final tx = filteredList[index];
                          final dateStr = DateFormat(
                            'dd MMM, HH:mm',
                          ).format(tx.date);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: tx.isIncome
                                        ? AppColors.incomeSurface
                                        : AppColors.expenseSurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    tx.isIncome
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: tx.isIncome
                                        ? AppColors.income
                                        : AppColors.expense,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: AppTypography.itemTitle.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tx.studentName ?? 'Santri'}${tx.studentClass != null && tx.studentClass!.isNotEmpty ? ' · ${tx.studentClass}' : ''}',
                                        style: AppTypography.itemSubtitle
                                            .copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatWithSign(
                                        tx.amount,
                                        tx.isIncome,
                                      ),
                                      style: AppTypography.itemTitle.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: tx.isIncome
                                            ? AppColors.income
                                            : AppColors.expense,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateStr,
                                      style: AppTypography.itemSubtitle
                                          .copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  static FlLine _getLine(double value) {
    return const FlLine(color: AppColors.borderLight, strokeWidth: 1);
  }
}
