import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';

class MutationSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onCalendarTap;

  const MutationSearchBar({
    super.key,
    required this.onChanged,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: 'Cari Nama Santri / Keterangan...',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onCalendarTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
