import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CsEmptyState extends StatelessWidget {
  const CsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Fitur Belum Tersedia',
                style: AppTypography.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Layanan pesan & CS SIKESAN sedang dalam tahap pengembangan dan akan segera hadir pada pembaruan mendatang.',
                textAlign: TextAlign.center,
                style: AppTypography.itemSubtitle.copyWith(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
