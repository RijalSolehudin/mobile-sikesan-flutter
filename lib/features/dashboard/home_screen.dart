import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/avatar_icon.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../data/models/dashboard_metric_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/transaction_item_model.dart';
import '../auth/bloc/auth_bloc.dart';
import '../spp/widgets/pay_spp_modal.dart';
import 'bloc/dashboard_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  bool _hasFetched = false;

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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final authState = context.read<AuthBloc>().state;
    final role = authState.user?.role ?? 'Wali Santri';
    context.read<DashboardBloc>().add(DashboardRefreshRequested(role: role));
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
                            Row(
                              children: [
                                const MosqueAvatar(size: 44),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Assalamu'alaikum,",
                                        style: AppTypography.headerSubtitle
                                            .copyWith(fontSize: 12),
                                      ),
                                      Text(
                                        userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.headerTitle
                                            .copyWith(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isWide || constraints.maxWidth > 560) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF047857,
                                      ).withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Semua Kelas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF047857,
                                      ).withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Semua Santri',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      userRole.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF047857,
                                        ).withValues(alpha: 0.75),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(3.5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 14,
                                          minHeight: 14,
                                        ),
                                        child: const Text(
                                          '1',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                              style: AppTypography.headerSubtitle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pondok Pesantren Pribadi Terintegrasi',
                              style: AppTypography.headerSubtitle.copyWith(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Financial Metric Cards Carousel / Side-by-side
                            isLoading
                                ? const ShimmerBox(
                                    width: double.infinity,
                                    height: 140,
                                    borderRadius: 16,
                                  )
                                : isWide
                                ? Row(
                                    children: cards
                                        .map(
                                          (card) => Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                              child: card,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                                : SizedBox(
                                    height: 140,
                                    child: PageView(
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        context.read<DashboardBloc>().add(
                                          DashboardCarouselChanged(index),
                                        );
                                      },
                                      children: cards,
                                    ),
                                  ),
                            if (!isWide) ...[
                              const SizedBox(height: 12),
                              // Carousel Indicators
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(cards.length, (index) {
                                  final bool isSelected =
                                      state.carouselIndex == index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    height: 4,
                                    width: isSelected ? 20 : 6,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ],
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
                              _buildStudentWalletSlider(
                                state.metrics.students,
                                screenWidth: constraints.maxWidth,
                              ),

                            // Menu Utama Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Menu Utama',
                                  style: AppTypography.sectionTitle,
                                ),
                                if (!isWide && menuList.length > 8)
                                  GestureDetector(
                                    onTap: () {
                                      context.read<DashboardBloc>().add(
                                        const DashboardToggleMenuExpanded(),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          state.isMenuExpanded
                                              ? 'Lihat Lebih Sedikit'
                                              : 'Lihat Semua',
                                          style: AppTypography.itemSubtitle
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Icon(
                                          state.isMenuExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Menu Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayedMenus.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: childAspectRatio,
                                  ),
                              itemBuilder: (context, index) {
                                final menu = displayedMenus[index];
                                return GestureDetector(
                                  onTap: () {
                                    if (menu.title.toLowerCase().contains(
                                      'spp',
                                    )) {
                                      PaySppModal.show(context);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: menu.bg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          menu.icon,
                                          color: menu.color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        menu.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.itemTitle.copyWith(
                                          fontSize: 10.5,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Riwayat Transaksi Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Riwayat Transaksi',
                                    style: AppTypography.sectionTitle,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go('/mutation');
                                  },
                                  child: Text(
                                    'Lihat Semua >',
                                    style: AppTypography.itemSubtitle.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Transaction List or Empty State
                            if (isLoading)
                              Column(
                                children: List.generate(
                                  3,
                                  (i) => const Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: ShimmerBox(
                                      width: double.infinity,
                                      height: 64,
                                      borderRadius: 16,
                                    ),
                                  ),
                                ),
                              )
                            else if (displayTransactions.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long_outlined,
                                        size: 24,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Belum ada transaksi terbaru',
                                      style: AppTypography.itemTitle.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Riwayat transaksi santri akan muncul di sini',
                                      style:
                                          AppTypography.itemSubtitle.copyWith(
                                        fontSize: 11,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayTransactions.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final tx = displayTransactions[index];
                                  return _buildTransactionTile(tx);
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

  Widget _buildStudentWalletSlider(
    List<StudentSummaryModel> students, {
    double? screenWidth,
  }) {
    if (students.isEmpty) return const SizedBox.shrink();

    final isWide = (screenWidth ?? 400) > 600;
    final cardWidth = students.length == 1
        ? (isWide ? 340.0 : MediaQuery.of(context).size.width - 32)
        : (isWide ? 260.0 : 230.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saldo Santri Asuhan',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 13.5),
                ),
              ],
            ),
            Text(
              '${students.length} Santri',
              style: AppTypography.itemSubtitle.copyWith(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            student.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.itemTitle.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 1.5),
                          Text(
                            student.grade,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.itemSubtitle.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(student.walletBalance),
                            style: AppTypography.itemTitle.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  List<Widget> _buildCarouselCards(DashboardState state, String role) {
    final metrics = state.metrics;
    final isGuardian = role.toLowerCase().contains('wali');

    if (isGuardian) {
      return [
        _buildMetricCard(
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
        _buildMetricCard(
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
        _buildMetricCard(
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
        _buildMetricCard(
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
        _buildMetricCard(
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
        _buildMetricCard(
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

  Widget _buildTransactionTile(TransactionItemModel tx) {
    final dateStr = DateFormat('dd MMM, HH:mm').format(tx.date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tx.isIncome
                  ? AppColors.incomeSurface
                  : AppColors.expenseSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tx.isIncome
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: tx.isIncome ? AppColors.income : AppColors.expense,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.studentName ?? tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.itemTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.studentName != null ? tx.title : tx.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.itemSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatWithSign(tx.amount, tx.isIncome),
                style: AppTypography.itemTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tx.isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String badge,
    required String mainValue,
    required String label1,
    required String value1,
    required String label2,
    required String value2,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.badgeText.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  badge,
                  style: AppTypography.badgeText.copyWith(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mainValue,
            style: AppTypography.cardValueLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label1,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value1,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label2,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value2,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
