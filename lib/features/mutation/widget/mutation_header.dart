import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class MutationHeader extends StatelessWidget {
  const MutationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mutasi & Transaksi',
                  style: AppTypography.headerTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  'Analisis Keuangan Santri & Operasional',
                  style: AppTypography.headerSubtitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
