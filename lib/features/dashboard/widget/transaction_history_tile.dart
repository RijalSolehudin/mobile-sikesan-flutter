import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_item_model.dart';

class TransactionHistoryTile extends StatelessWidget {
  final TransactionItemModel tx;

  const TransactionHistoryTile({
    super.key,
    required this.tx,
  });

  @override
  Widget build(BuildContext context) {
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
}
