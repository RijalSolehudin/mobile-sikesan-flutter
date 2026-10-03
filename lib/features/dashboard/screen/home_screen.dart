import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
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
          mainValue: CurrencyFormatter.format(metrics.totalBalance),
          label1: 'TAGIHAN SPP',
          value1: CurrencyFormatter.format(metrics.totalUnpaidSpp),
          label2: 'TOTAL INFAK KESANTRIAN',
          value2: CurrencyFormatter.format(metrics.totalExpense),
        ),
        DashboardMetricCard(
          title: 'STATUS TAGIHAN SPP',
          badge: 'Semua Santri',
          mainValue: CurrencyFormatter.format(metrics.totalUnpaidSpp),
          label1: 'STATUS',
          value1: metrics.totalUnpaidSpp > 0 ? 'Belum Lunas' : 'Lunas',
          label2: 'KETERANGAN',
          value2: metrics.totalUnpaidSpp > 0 ? 'Tunggakan Aktif' : 'Semua Lunas',
        ),
        DashboardMetricCard(
          title: 'TOTAL INFAK KESANTRIAN',
          badge: 'Semua Santri',
          mainValue: CurrencyFormatter.format(metrics.totalExpense),
          label1: 'STATUS',
          value1: metrics.totalExpense > 0 ? 'Terbayar' : 'Belum Ada',
          label2: 'KETERANGAN',
          value2: 'Infak Kesantrian',
        ),
      ];
    } else {
      return [
        DashboardMetricCard(
          title: 'TOTAL TABUNGAN SANTRI',
          badge: 'Semua Santri',
          mainValue: CurrencyFormatter.format(metrics.totalBalance),
          label1: 'SPP BULAN INI',
          value1: CurrencyFormatter.format(metrics.totalIncome),
          label2: 'INFAK BULAN INI',
          value2: CurrencyFormatter.format(metrics.totalExpense),
        ),
        DashboardMetricCard(
          title: 'TOTAL PEMBAYARAN SPP',
          badge: 'Bulan Ini',
          mainValue: CurrencyFormatter.format(metrics.totalIncome),
          label1: 'STATUS',
          value1: 'Terkumpul',
          label2: 'PERIODE',
          value2: 'Bulan Berjalan',
        ),
        DashboardMetricCard(
          title: 'TOTAL INFAK KESANTRIAN',
          badge: 'Bulan Ini',
          mainValue: CurrencyFormatter.format(metrics.totalExpense),
          label1: 'STATUS',
          value1: 'Terkumpul',
          label2: 'PERIODE',
          value2: 'Bulan Berjalan',
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
            AppSnackBar.showError(context, state.errorMessage!);
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
              final displayTransactions = state.transactions.take(10).toList();

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

                                // History Section (Transactions)
                                DashboardHistorySection(
                                  transactions: displayTransactions,
                                  isLoading: isLoading,
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
