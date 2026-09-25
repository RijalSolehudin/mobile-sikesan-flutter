import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/filter_pill.dart';

class CsScreen extends StatefulWidget {
  const CsScreen({super.key});

  @override
  State<CsScreen> createState() => _CsScreenState();
}

class _CsScreenState extends State<CsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Belum Dibaca',
    'Kelas 7',
    'Kelas 8',
    'Kelas 9',
    'Kelas 10',
    'Kelas 11',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Green Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CS SIKESAN',
                        style: AppTypography.headerTitle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      const CustomTextField(
                        hintText: 'Cari nama, username, ID santri, No. WA...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return FilterPill(
                              label: _filters[index],
                              isSelected: _selectedFilterIndex == index,
                              onTap: () =>
                                  setState(() => _selectedFilterIndex = index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Placeholder Content State
          Expanded(
            child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}
