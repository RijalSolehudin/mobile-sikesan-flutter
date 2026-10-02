import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/filter_pill.dart';

class CsHeader extends StatelessWidget {
  final List<String> filters;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterSelected;
  final ValueChanged<String>? onSearchChanged;

  const CsHeader({
    super.key,
    required this.filters,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                CustomTextField(
                  hintText: 'Cari nama, username, ID santri, No. WA...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return FilterPill(
                        label: filters[index],
                        isSelected: selectedFilterIndex == index,
                        onTap: () => onFilterSelected(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
