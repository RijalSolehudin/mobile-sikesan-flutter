import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_item_model.dart';
import '../../dashboard/widget/transaction_detail_modal.dart';

class MutationItemTile extends StatelessWidget {
  final TransactionItemModel tx;
  final VoidCallback? onTap;

  const MutationItemTile({
    super.key,
    required this.tx,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Acuan waktu UTC+7
    final dateStr = DateFormatter.formatShort(tx.date);

    final isPending = tx.isPending;
    final isPaid = tx.isPaidOrSuccess;
    final isRejected = tx.isRejectedOrFailed;

    // Status badge colors & icon
    final Color statusBg = isPending
        ? const Color(0xFFFEF3C7)
        : (isRejected
            ? const Color(0xFFFEE2E2)
            : (isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE)));
    final Color statusFg = isPending
        ? const Color(0xFFD97706)
        : (isRejected
            ? const Color(0xFFDC2626)
            : (isPaid ? const Color(0xFF16A34A) : const Color(0xFF0284C7)));
    final IconData statusIcon = isPending
        ? Icons.hourglass_top_rounded
        : (isRejected
            ? Icons.cancel_rounded
            : (isPaid ? Icons.check_circle_rounded : Icons.info_outline_rounded));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => TransactionDetailModal.show(context, tx),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Direction Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFFFBEB)
                      : (tx.isIncome
                          ? AppColors.incomeSurface
                          : AppColors.expenseSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: isPending
                      ? Border.all(color: const Color(0xFFFDE68A), width: 1)
                      : null,
                ),
                child: Icon(
                  isPending
                      ? Icons.hourglass_top_rounded
                      : (tx.isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded),
                  color: isPending
                      ? const Color(0xFFD97706)
                      : (tx.isIncome ? AppColors.income : AppColors.expense),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Title, Subtitle, & Status Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: AppTypography.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.studentName ?? 'Santri'}${tx.studentClass != null && tx.studentClass!.isNotEmpty ? ' · ${tx.studentClass}' : ''}',
                      style: AppTypography.itemSubtitle.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Status Badge Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 10, color: statusFg),
                          const SizedBox(width: 3.5),
                          Text(
                            tx.statusLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: statusFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Amount & Date (UTC+7)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatWithSign(tx.amount, tx.isIncome),
                    style: AppTypography.itemTitle.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isPending
                          ? const Color(0xFFD97706)
                          : (tx.isIncome ? AppColors.income : AppColors.expense),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 10.5,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        dateStr,
                        style: AppTypography.itemSubtitle.copyWith(
                          fontSize: 10.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
