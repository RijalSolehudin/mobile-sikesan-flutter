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
import '../widget/mutation_period_filter.dart';
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
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 0; // 0: Uang Saku, 1: Pembayaran SPP, 2: Infak Kesantrian
  int _selectedClassIndex = 0;
  int _selectedFilterType = 0; // 0: Semua, 1: Pemasukan, 2: Pengeluaran
  int? _selectedMonth;
  int? _selectedYear;
  final String _timeRange = 'Harian';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _perPage = 15;
  bool _hasInitialLoaded = false;

  void _onPeriodChanged({int? month, int? year}) {
    setState(() {
      _selectedMonth = month;
      _selectedYear = year;
    });
    _loadTransactions();
  }

  void _openPeriodPicker() {
    MutationPeriodFilter.showPeriodPicker(
      context,
      currentMonth: _selectedMonth,
      currentYear: _selectedYear,
      onApplied: (m, y) {
        _onPeriodChanged(month: m, year: y);
      },
    );
  }

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
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialLoaded) {
      _hasInitialLoaded = true;
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
    });
    final repo = context.read<DashboardRepository>();
    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    ApiResult<List<TransactionItemModel>> result;
    if (_selectedTab == 0) {
      result = await repo.getRecentTransactions(
        page: 1,
        perPage: _perPage,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } else if (_selectedTab == 1) {
      result = await repo.getSppTransactions(
        isGuardian: isGuardian,
        page: 1,
        perPage: _perPage,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } else {
      result = await repo.getInfaqTransactions(
        isGuardian: isGuardian,
        page: 1,
        perPage: _perPage,
        month: _selectedMonth,
        year: _selectedYear,
      );
    }

    if (!mounted) return;

    if (result is ApiSuccess<List<TransactionItemModel>>) {
      final items = result.data;
      setState(() {
        _transactions = items;
        _hasMore = items.length >= _perPage;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final repo = context.read<DashboardRepository>();
    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');
    final nextPage = _page + 1;

    ApiResult<List<TransactionItemModel>> result;
    if (_selectedTab == 0) {
      result = await repo.getRecentTransactions(
        page: nextPage,
        perPage: _perPage,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } else if (_selectedTab == 1) {
      result = await repo.getSppTransactions(
        isGuardian: isGuardian,
        page: nextPage,
        perPage: _perPage,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } else {
      result = await repo.getInfaqTransactions(
        isGuardian: isGuardian,
        page: nextPage,
        perPage: _perPage,
        month: _selectedMonth,
        year: _selectedYear,
      );
    }

    if (!mounted) return;

    if (result is ApiSuccess<List<TransactionItemModel>>) {
      final newItems = result.data;
      setState(() {
        _page = nextPage;
        _transactions.addAll(newItems);
        _hasMore = newItems.length >= _perPage;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
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

      // Filter by month
      if (_selectedMonth != null && tx.date.month != _selectedMonth) {
        return false;
      }

      // Filter by year
      if (_selectedYear != null && tx.date.year != _selectedYear) {
        return false;
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
          controller: _scrollController,
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
                          onCalendarTap: _openPeriodPicker,
                        ),
                        const SizedBox(height: 12),

                        // Month & Year Filter Dropdown Selector
                        MutationPeriodFilter(
                          selectedMonth: _selectedMonth,
                          selectedYear: _selectedYear,
                          onMonthChanged: (m) =>
                              _onPeriodChanged(month: m, year: _selectedYear),
                          onYearChanged: (y) =>
                              _onPeriodChanged(month: _selectedMonth, year: y),
                          onReset: () =>
                              _onPeriodChanged(month: null, year: null),
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
                        else ...[
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
                          if (_isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Memuat transaksi lainnya...',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (!_hasMore && filteredList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Semua transaksi telah dimuat',
                                  style: AppTypography.itemSubtitle.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
