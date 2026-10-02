import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/menu_item_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widget/dashboard_header.dart';
import '../widget/dashboard_metric_card.dart';
import '../widget/dashboard_metrics_slider.dart';
import '../widget/student_wallet_slider.dart';
import '../widget/dashboard_menu_grid.dart';
import '../widget/dashboard_history_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _hasFetched = false;

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
      final state = context.read<DashboardBloc>().state;
      if (state.selectedHistoryTab == 0 &&
          state.billsHasMore &&
          !state.isLoadingMoreBills) {
        context.read<DashboardBloc>().add(
          const DashboardBillsLoadMoreRequested(),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      final authState = context.read<AuthBloc>().state;
      final role = authState.user?.role ?? 'Wali Santri';
      context.read<DashboardBloc>().add(DashboardFetchRequested(role: role));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final authState = context.read<AuthBloc>().state;
    final role = authState.user?.role ?? 'Wali Santri';
    context.read<DashboardBloc>().add(DashboardRefreshRequested(role: role));
  }

  List<Widget> _buildCarouselCards(DashboardState state, String role) {
    final metrics = state.metrics;
    final isGuardian = role.toLowerCase().contains('wali');

    if (isGuardian) {
      return [
        DashboardMetricCard(
          title: 'TOTAL SALDO SANTRI',
          badge: 'Saldo Aktif',
          mainValue: CurrencyFormatter.format(
            metrics.totalBalance > 0 ? metrics.totalBalance : 1230500,
          ),
          label1: 'TAGIHAN SPP',
          value1: CurrencyFormatter.format(
            metrics.totalUnpaidSpp > 0 ? metrics.totalUnpaidSpp : 750000,
          ),
          label2: 'TOTAL INFAK KESANTRIAN',
          value2: CurrencyFormatter.format(
            metrics.totalExpense > 0 ? metrics.totalExpense : 100000,
          ),
        ),
        DashboardMetricCard(
          title: 'STATUS TAGIHAN SPP',
          badge: 'Semua Santri',
          mainValue: CurrencyFormatter.format(
            metrics.totalUnpaidSpp > 0 ? metrics.totalUnpaidSpp : 146250000,
          ),
          label1: 'TAGIHAN PERBULAN',
          value1: CurrencyFormatter.format(
            metrics.monthlyBill > 0 ? metrics.monthlyBill : 750000,
          ),
          label2: 'BELUM LUNAS',
          value2: 'Bulan Juni',
        ),
        const DashboardMetricCard(
          title: 'TOTAL INFAK KESANTRIAN',
          badge: 'Semua Santri',
          mainValue: 'Rp 21.050.000',
          label1: 'TAGIHAN PERBULAN',
          value1: 'Rp 100.000',
          label2: 'BELUM LUNAS',
          value2: 'Bulan Juni',
        ),
      ];
    } else {
      return [
        DashboardMetricCard(
          title: 'TOTAL TABUNGAN SANTRI',
          badge: 'Semua Santri',
          mainValue: CurrencyFormatter.format(
            metrics.totalBalance > 0 ? metrics.totalBalance : 1230500,
          ),
          label1: 'PEMASUKAN',
          value1: CurrencyFormatter.format(
            metrics.totalIncome > 0 ? metrics.totalIncome : 3410000,
          ),
          label2: 'PENGELUARAN',
          value2: CurrencyFormatter.format(
            metrics.totalExpense > 0 ? metrics.totalExpense : 2179500,
          ),
        ),
        DashboardMetricCard(
          title: 'TOTAL PEMBAYARAN SPP',
          badge: 'Semua Santri',
          mainValue: CurrencyFormatter.format(
            metrics.totalUnpaidSpp > 0 ? metrics.totalUnpaidSpp : 146250000,
          ),
          label1: 'TAGIHAN PERBULAN',
          value1: CurrencyFormatter.format(
            metrics.monthlyBill > 0 ? metrics.monthlyBill : 750000,
          ),
          label2: 'BELUM LUNAS',
          value2: 'Bulan Juni',
        ),
        const DashboardMetricCard(
          title: 'TOTAL INFAK KESANTRIAN',
          badge: 'Semua Santri',
          mainValue: 'Rp 21.050.000',
          label1: 'TAGIHAN PERBULAN',
          value1: 'Rp 100.000',
          label2: 'BELUM LUNAS',
          value2: 'Bulan Juni',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final userName = authUser?.name.isNotEmpty == true
        ? authUser!.name
        : 'Pengguna';
    final userRole = authUser?.role.isNotEmpty == true
        ? authUser!.role
        : 'Wali Santri';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.status == DashboardStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              state.isLoading &&
              state.transactions.isEmpty &&
              state.metrics.totalBalance == 0;
          final menuList = state.menuItems.isNotEmpty
              ? state.menuItems
              : MenuItemModel.defaultMenus()
                    .where((m) => m.isVisibleForRole(userRole))
                    .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;
              final crossAxisCount = isWide
                  ? 8
                  : (constraints.maxWidth > 650 ? 6 : 4);
              final childAspectRatio = isWide
                  ? 1.05
                  : (constraints.maxWidth > 650 ? 0.95 : 0.78);
              final displayedMenus = isWide
                  ? menuList
                  : (state.isMenuExpanded
                        ? menuList
                        : menuList.take(8).toList());
              final cards = _buildCarouselCards(state, userRole);
              final displayTransactions = state.transactions;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Top Green Hero Section
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
                              padding: EdgeInsets.fromLTRB(
                                isWide ? 24 : 20,
                                isWide ? 36 : 50,
                                isWide ? 24 : 20,
                                20,
                              ),
                              child: Column(
                                children: [
                                  // User Greetings & Actions Header
                                  DashboardHeader(
                                    userName: userName,
                                    userRole: userRole,
                                    isWide: isWide,
                                    constraints: constraints,
                                  ),
                                  const SizedBox(height: 18),

                                  // Title Center
                                  Text(
                                    'SIKESAN',
                                    style: AppTypography.headerTitle.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Sistem Keuangan Santri',
                                    style: AppTypography.headerSubtitle
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Pondok Pesantren Pribadi Terintegrasi',
                                    style: AppTypography.headerSubtitle
                                        .copyWith(
                                          fontSize: 11,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Financial Metric Cards Carousel / Side-by-side
                                  DashboardMetricsSlider(
                                    cards: cards,
                                    isLoading: isLoading,
                                    isWide: isWide,
                                    pageController: _pageController,
                                    carouselIndex: state.carouselIndex,
                                    onPageChanged: (index) {
                                      context.read<DashboardBloc>().add(
                                        DashboardCarouselChanged(index),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Content Section
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1080),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24 : 16,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Slider Card Saldo Wallet Per-Santri (Khusus Wali Santri)
                                if (userRole.toLowerCase().contains('wali'))
                                  StudentWalletSlider(
                                    students: state.metrics.students,
                                    screenWidth: constraints.maxWidth,
                                  ),

                                // Quick Menu Grid
                                DashboardMenuGrid(
                                  displayedMenus: displayedMenus,
                                  isMenuExpanded: state.isMenuExpanded,
                                  isWide: isWide,
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  totalMenuCount: menuList.length,
                                  onToggleExpanded: () {
                                    context.read<DashboardBloc>().add(
                                      const DashboardToggleMenuExpanded(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // History Section (Bills & Transactions)
                                DashboardHistorySection(
                                  selectedTab: state.selectedHistoryTab,
                                  onTabChanged: (tabIndex) {
                                    context.read<DashboardBloc>().add(
                                      DashboardHistoryTabChanged(tabIndex),
                                    );
                                  },
                                  billStatusFilter: state.billStatusFilter,
                                  onStatusFilterChanged: (filter) {
                                    context.read<DashboardBloc>().add(
                                      DashboardBillStatusFilterChanged(filter),
                                    );
                                  },
                                  bills: state.bills,
                                  transactions: displayTransactions,
                                  isLoading: isLoading,
                                  isLoadingMoreBills: state.isLoadingMoreBills,
                                  billsHasMore: state.billsHasMore,
                                  onViewAllTransactions: () {
                                    context.go('/mutation');
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
              );
            },
          );
        },
      ),
    );
  }
}
