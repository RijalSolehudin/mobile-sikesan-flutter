import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

/// Komponen pemilihan tahun tagihan SPP
/// Memenuhi TASK-CONC-02 untuk modularitas UI
class SppYearSelector extends StatelessWidget {
  final int selectedYear;
  final List<int> availableYears;
  final ValueChanged<int> onYearChanged;

  const SppYearSelector({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Tahun',
              style: AppTypography.itemTitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedYear,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  items: availableYears.map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text(
                        '$y',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newYear) {
                    if (newYear != null && newYear != selectedYear) {
                      onYearChanged(newYear);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
