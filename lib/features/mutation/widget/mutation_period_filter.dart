import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class MutationPeriodFilter extends StatelessWidget {
  final int? selectedMonth;
  final int? selectedYear;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;
  final VoidCallback onReset;

  const MutationPeriodFilter({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onReset,
  });

  static const List<String> monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return [currentYear + 1, currentYear, currentYear - 1, currentYear - 2];
  }

  static Future<void> showPeriodPicker(
    BuildContext context, {
    int? currentMonth,
    int? currentYear,
    required void Function(int? month, int? year) onApplied,
  }) async {
    int? tempMonth = currentMonth;
    int? tempYear = currentYear;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Periode Transaksi',
                          style: AppTypography.heading4.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tahun',
                      style: AppTypography.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua'),
                          selected: tempYear == null,
                          onSelected: (val) {
                            setModalState(() => tempYear = null);
                          },
                        ),
                        for (final y in availableYears)
                          ChoiceChip(
                            label: Text(y.toString()),
                            selected: tempYear == y,
                            onSelected: (val) {
                              setModalState(() => tempYear = val ? y : null);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bulan',
                      style: AppTypography.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua Bulan'),
                          selected: tempMonth == null,
                          onSelected: (val) {
                            setModalState(() => tempMonth = null);
                          },
                        ),
                        for (int i = 0; i < monthNames.length; i++)
                          ChoiceChip(
                            label: Text(monthNames[i]),
                            selected: tempMonth == i + 1,
                            onSelected: (val) {
                              setModalState(
                                () => tempMonth = val ? (i + 1) : null,
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              onApplied(null, null);
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              onApplied(tempMonth, tempYear);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Terapkan Filter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = selectedMonth != null || selectedYear != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActiveFilter ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 20,
            color: hasActiveFilter ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),

          // Dropdown Bulan
          Expanded(
            flex: 6,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedMonth,
                isExpanded: true,
                hint: Text(
                  'Semua Bulan',
                  style: AppTypography.itemSubtitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Semua Bulan',
                      style: AppTypography.itemTitle.copyWith(fontSize: 13),
                    ),
                  ),
                  for (int i = 0; i < monthNames.length; i++)
                    DropdownMenuItem<int?>(
                      value: i + 1,
                      child: Text(
                        monthNames[i],
                        style: AppTypography.itemTitle.copyWith(
                          fontSize: 13,
                          fontWeight: selectedMonth == i + 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                ],
                onChanged: onMonthChanged,
              ),
            ),
          ),

          const SizedBox(width: 8),
          Container(
            height: 24,
            width: 1,
            color: AppColors.border,
          ),
          const SizedBox(width: 8),

          // Dropdown Tahun
          Expanded(
            flex: 4,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedYear,
                isExpanded: true,
                hint: Text(
                  'Semua Tahun',
                  style: AppTypography.itemSubtitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Semua Tahun',
                      style: AppTypography.itemTitle.copyWith(fontSize: 13),
                    ),
                  ),
                  for (final year in availableYears)
                    DropdownMenuItem<int?>(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: AppTypography.itemTitle.copyWith(
                          fontSize: 13,
                          fontWeight: selectedYear == year
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                ],
                onChanged: onYearChanged,
              ),
            ),
          ),

          if (hasActiveFilter) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
