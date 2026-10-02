import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_item_model.dart';

class MutationItemTile extends StatelessWidget {
  final TransactionItemModel tx;

  const MutationItemTile({
    super.key,
    required this.tx,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, HH:mm').format(tx.date);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tx.isIncome
                  ? AppColors.incomeSurface
                  : AppColors.expenseSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tx.isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: tx.isIncome ? AppColors.income : AppColors.expense,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
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
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.studentName ?? 'Santri'}${tx.studentClass != null && tx.studentClass!.isNotEmpty ? ' · ${tx.studentClass}' : ''}',
                  style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatWithSign(
                  tx.amount,
                  tx.isIncome,
                ),
                style: AppTypography.itemTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: tx.isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: AppTypography.itemSubtitle.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
