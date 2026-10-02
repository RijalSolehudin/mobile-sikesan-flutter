import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';

class MutationSummaryCards extends StatelessWidget {
  final num totalMasuk;
  final num totalKeluar;

  const MutationSummaryCards({
    super.key,
    required this.totalMasuk,
    required this.totalKeluar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Masuk',
                  style: AppTypography.itemSubtitle.copyWith(
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+ ${CurrencyFormatter.format(totalMasuk)}',
                  style: AppTypography.itemTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Keluar',
                  style: AppTypography.itemSubtitle.copyWith(
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '- ${CurrencyFormatter.format(totalKeluar)}',
                  style: AppTypography.itemTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
