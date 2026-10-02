import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class InformationMetricCards extends StatelessWidget {
  final int totalInfo;
  final int unreadCount;
  final int readCount;
  final int importantCount;

  const InformationMetricCards({
    super.key,
    this.totalInfo = 0,
    this.unreadCount = 0,
    this.readCount = 0,
    this.importantCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total Informasi & Belum Dibaca
        Row(
          children: [
            // Total Informasi Card (Green solid)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Informasi',
                      style: AppTypography.badgeText.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$totalInfo', style: AppTypography.cardValueLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Belum Dibaca (White card, red text)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum Dibaca',
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$unreadCount',
                      style: AppTypography.cardValueLarge.copyWith(
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Sudah Dibaca & Informasi Sangat Penting
        Row(
          children: [
            // Sudah Dibaca (White card, green text)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sudah Dibaca',
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$readCount',
                      style: AppTypography.cardValueLarge.copyWith(
                        color: AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Informasi Sangat Penting (White card, red text)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Sangat Penting',
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$importantCount',
                      style: AppTypography.cardValueLarge.copyWith(
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
