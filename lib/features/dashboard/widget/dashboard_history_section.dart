import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../data/models/bill_history_model.dart';
import '../../../data/models/transaction_item_model.dart';
import 'bill_history_tile.dart';
import 'transaction_history_tile.dart';

class DashboardHistorySection extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final String billStatusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final List<BillHistoryModel> bills;
  final List<TransactionItemModel> transactions;
  final bool isLoading;
  final bool isLoadingMoreBills;
  final bool billsHasMore;
  final VoidCallback onViewAllTransactions;

  const DashboardHistorySection({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.billStatusFilter,
    required this.onStatusFilterChanged,
    required this.bills,
    required this.transactions,
    required this.isLoading,
    required this.isLoadingMoreBills,
    required this.billsHasMore,
    required this.onViewAllTransactions,
  });

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = value == billStatusFilter;
    return GestureDetector(
      onTap: () => onStatusFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented Tab Header: Riwayat Tagihan / Riwayat Transaksi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildTabButton(
                  title: 'Riwayat Tagihan',
                  isSelected: selectedTab == 0,
                  onTap: () => onTabChanged(0),
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  title: 'Riwayat Transaksi',
                  isSelected: selectedTab == 1,
                  onTap: () => onTabChanged(1),
                ),
              ],
            ),
            if (selectedTab == 1)
              GestureDetector(
                onTap: onViewAllTransactions,
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

        // Filter status chips (hanya aktif saat tab Riwayat Tagihan)
        if (selectedTab == 0) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 6),
                _buildFilterChip('Belum Lunas', 'unpaid'),
                const SizedBox(width: 6),
                _buildFilterChip('Menunggu Verifikasi', 'pending'),
                const SizedBox(width: 6),
                _buildFilterChip('Lunas', 'paid'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // List Content: Riwayat Tagihan vs Riwayat Transaksi
        if (selectedTab == 0) ...[
          // TAB 0: RIWAYAT TAGIHAN DENGAN LAZY LOADING
          if (isLoading && bills.isEmpty)
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
          else if (bills.isEmpty)
            Container(
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
                    'Tidak ada tagihan ditemukan',
                    style: AppTypography.itemTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riwayat tagihan santri akan muncul di sini',
                    style: AppTypography.itemSubtitle.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bills.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final bill = bills[index];
                return BillHistoryTile(bill: bill);
              },
            ),
            // Lazy Loading Indicator
            if (isLoadingMoreBills) ...[
              const SizedBox(height: 14),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Memuat tagihan lainnya...',
                      style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ] else if (!billsHasMore && bills.isNotEmpty) ...[
              const SizedBox(height: 14),
              Center(
                child: Text(
                  '— Semua tagihan telah ditampilkan —',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ] else ...[
          // TAB 1: RIWAYAT TRANSAKSI (DOMPET)
          if (isLoading && transactions.isEmpty)
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
          else if (transactions.isEmpty)
            Container(
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
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return TransactionHistoryTile(tx: tx);
              },
            ),
        ],
      ],
    );
  }
}
