import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../data/models/bill_history_model.dart';
import '../../../data/models/transaction_item_model.dart';
import 'transaction_history_tile.dart';

class DashboardHistorySection extends StatelessWidget {
  final List<TransactionItemModel> transactions;
  final bool isLoading;
  final VoidCallback onViewAllTransactions;

  // Optional legacy parameters for backwards compatibility
  final bool isGuardian;
  final int selectedTab;
  final ValueChanged<int>? onTabChanged;
  final String billStatusFilter;
  final ValueChanged<String>? onStatusFilterChanged;
  final List<BillHistoryModel> bills;
  final bool isLoadingMoreBills;
  final bool billsHasMore;

  const DashboardHistorySection({
    super.key,
    required this.transactions,
    required this.isLoading,
    required this.onViewAllTransactions,
    this.isGuardian = false,
    this.selectedTab = 1,
    this.onTabChanged,
    this.billStatusFilter = 'all',
    this.onStatusFilterChanged,
    this.bills = const [],
    this.isLoadingMoreBills = false,
    this.billsHasMore = false,
  });

  Widget _buildViewAllButton() {
    return InkWell(
      onTap: onViewAllTransactions,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Lihat Semua',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionItemModel> displayList) {
    if (isLoading && displayList.isEmpty) {
      return Column(
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
      );
    }

    if (displayList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
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
              style: AppTypography.itemSubtitle.copyWith(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tx = displayList[index];
        return TransactionHistoryTile(tx: tx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTransactions = transactions.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: AppTypography.heading4.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            _buildViewAllButton(),
          ],
        ),
        const SizedBox(height: 14),
        _buildTransactionsList(displayTransactions),
      ],
    );
  }
}
