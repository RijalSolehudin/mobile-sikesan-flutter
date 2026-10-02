import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/filter_pill.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../data/models/transaction_item_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widget/mutation_header.dart';
import '../widget/mutation_segmented_tabs.dart';
import '../widget/mutation_search_bar.dart';
import '../widget/mutation_class_filter.dart';
import '../widget/mutation_summary_cards.dart';
import '../widget/mutation_chart_card.dart';
import '../widget/mutation_item_tile.dart';

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
              const MutationHeader(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Segmented Tabs Container
                        MutationSegmentedTabs(
                          tabs: _tabs,
                          selectedIndex: _selectedTab,
                          onTabSelected: (index) {
                            setState(() => _selectedTab = index);
                            _loadTransactions();
                          },
                        ),
                        const SizedBox(height: 14),

                        // Search Bar with Calendar Action
                        MutationSearchBar(
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Class Filter Chips
                        MutationClassFilter(
                          classes: _classes,
                          selectedIndex: _selectedClassIndex,
                          onClassSelected: (index) {
                            setState(() => _selectedClassIndex = index);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Two Summary Cards (Total Masuk & Total Keluar)
                        MutationSummaryCards(
                          totalMasuk: totalMasuk,
                          totalKeluar: totalKeluar,
                        ),
                        const SizedBox(height: 14),

                        // Statistik Transaksi Chart Card
                        MutationChartCard(timeRange: _timeRange),
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
                              (i) => const Padding(
                                padding: EdgeInsets.only(bottom: 8),
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
                              return MutationItemTile(tx: tx);
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
}
