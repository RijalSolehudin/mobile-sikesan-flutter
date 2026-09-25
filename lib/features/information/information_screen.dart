import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/filter_pill.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedStatusIndex = 3; // 'Dipublikasikan' is selected in screenshot

  final List<String> _categories = [
    'Semua',
    'Infak Kesantrian',
    'Keuangan SPP',
    'Uang Saku',
  ];

  final List<String> _statuses = [
    'Semua',
    'Draft',
    'Terjadwal',
    'Dipublikasikan',
    'Expired',
    'Arsip',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pusat Informasi',
                              style: AppTypography.headerTitle.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Informasi & Pengumuman Pesantren',
                              style: AppTypography.headerSubtitle,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Pengumuman',
                                style: AppTypography.badgeText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // 2x2 Metric Cards
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
                              Text('0', style: AppTypography.cardValueLarge),
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
                                '0',
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
                                '0',
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
                                '0',
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
                  const SizedBox(height: 16),

                  // Search Bar
                  const CustomTextField(
                    hintText: 'Cari informasi...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Pills
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return FilterPill(
                          label: _categories[index],
                          isSelected: _selectedCategoryIndex == index,
                          onTap: () =>
                              setState(() => _selectedCategoryIndex = index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Status Pills (with dark slate active color)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statuses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return FilterPill(
                          label: _statuses[index],
                          isSelected: _selectedStatusIndex == index,
                          selectedColor: AppColors.darkSlate,
                          onTap: () =>
                              setState(() => _selectedStatusIndex = index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Empty State Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.inbox_outlined,
                            size: 28,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada informasi.',
                          style: AppTypography.itemTitle.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
        ),
      ),
    );
  }
}
