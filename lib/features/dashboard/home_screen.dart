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
    final userName = authUser?.name.isNotEmpty == true ? authUser!.name : 'Pengguna';
    final userRole = authUser?.role.isNotEmpty == true ? authUser!.role : 'Wali Santri';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.status == DashboardStatus.failure && state.errorMessage != null) {
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
          final isLoading = state.isLoading && state.transactions.isEmpty && state.metrics.totalBalance == 0;
          final menuList = state.menuItems.isNotEmpty ? state.menuItems : MenuItemModel.defaultMenus().where((m) => m.isVisibleForRole(userRole)).toList();
          final displayedMenus = state.isMenuExpanded ? menuList : menuList.take(8).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Top Green Hero Section
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      children: [
                        // User Greetings & Actions Header
                        Row(
                          children: [
                            const MosqueAvatar(size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Assalamu'alaikum,",
                                    style: AppTypography.headerSubtitle.copyWith(fontSize: 12),
                                  ),
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.headerTitle.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                userRole.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
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
                          style: AppTypography.headerSubtitle.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Pondok Pesantren Pribadi Terintegrasi',
                          style: AppTypography.headerSubtitle.copyWith(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Financial Metric Cards Carousel
                        isLoading
                            ? const ShimmerBox(width: double.infinity, height: 140, borderRadius: 16)
                            : SizedBox(
                                height: 140,
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    context.read<DashboardBloc>().add(DashboardCarouselChanged(index));
                                  },
                                  children: _buildCarouselCards(state, userRole),
                                ),
                              ),
                        const SizedBox(height: 12),

                        // Carousel Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (index) {
                            final bool isSelected = state.carouselIndex == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 4,
                              width: isSelected ? 20 : 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // Content Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slider Card Saldo Wallet Per-Santri (Khusus Wali Santri)
                        if (userRole.toLowerCase().contains('wali'))
                          _buildStudentWalletSlider(state.metrics.students),

                        // Menu Utama Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Menu Utama', style: AppTypography.sectionTitle),
                            if (menuList.length > 8)
                              GestureDetector(
                                onTap: () {
                                  context.read<DashboardBloc>().add(const DashboardToggleMenuExpanded());
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      state.isMenuExpanded ? 'Lihat Lebih Sedikit' : 'Lihat Semua',
                                      style: AppTypography.itemSubtitle.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      state.isMenuExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final menu = displayedMenus[index];
                            return GestureDetector(
                              onTap: () {
                                if (menu.title.toLowerCase().contains('spp')) {
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
                                    child: Icon(menu.icon, color: menu.color, size: 24),
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
                              child: Text('Riwayat Transaksi', style: AppTypography.sectionTitle),
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
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ShimmerBox(width: double.infinity, height: 64, borderRadius: 16),
                              ),
                            ),
                          )
                        else if (state.transactions.isEmpty)
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
                                Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada transaksi tercatat',
                                  style: AppTypography.itemTitle.copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Transaksi dompet santri akan muncul di sini',
                                  style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.transactions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final tx = state.transactions[index];
                              return _buildTransactionTile(tx);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentWalletSlider(List<StudentSummaryModel> students) {
    if (students.isEmpty) return const SizedBox.shrink();

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
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text('Saldo Santri Asuhan', style: AppTypography.sectionTitle.copyWith(fontSize: 13.5)),
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
                width: students.length == 1 ? MediaQuery.of(context).size.width - 32 : 230,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
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
                            style: AppTypography.itemSubtitle.copyWith(fontSize: 10),
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
          mainValue: CurrencyFormatter.format(metrics.totalBalance),
          label1: 'TAGIHAN SPP',
          value1: CurrencyFormatter.format(metrics.totalUnpaidSpp),
          label2: 'TOTAL INFAK KESANTRIAN',
          value2: CurrencyFormatter.format(metrics.totalExpense),
        ),
        _buildMetricCard(
          title: 'STATUS TAGIHAN SPP',
          badge: 'Periode Ini',
          mainValue: CurrencyFormatter.format(metrics.totalUnpaidSpp),
          label1: 'TOTAL INFAK KESANTRIAN',
          value1: CurrencyFormatter.format(metrics.totalExpense),
          label2: 'STATUS',
          value2: metrics.unpaidStatus,
        ),
      ];
    } else {
      return [
        _buildMetricCard(
          title: 'TOTAL TABUNGAN SANTRI',
          badge: 'Kas Santri Global',
          mainValue: CurrencyFormatter.format(metrics.totalBalance),
          label1: 'SPP BULAN INI',
          value1: CurrencyFormatter.format(metrics.totalIncome),
          label2: 'INFAK BULAN INI',
          value2: CurrencyFormatter.format(metrics.totalExpense),
        ),
        _buildMetricCard(
          title: 'REKAPITULASI KEUANGAN',
          badge: 'Bulan Berjalan',
          mainValue: CurrencyFormatter.format(metrics.totalIncome),
          label1: 'TOTAL INFAK BULAN INI',
          value1: CurrencyFormatter.format(metrics.totalExpense),
          label2: 'PERIODE',
          value2: 'Bulan Berjalan',
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
              color: tx.isIncome ? AppColors.incomeSurface : AppColors.expenseSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tx.isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
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
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.studentName ?? 'Santri'} • ${tx.category}',
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  badge,
                  style: AppTypography.badgeText.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(mainValue, style: AppTypography.cardValueLarge),
          const Spacer(),
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
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value1,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white,
                      fontSize: 12,
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
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value2,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white,
                      fontSize: 12,
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
