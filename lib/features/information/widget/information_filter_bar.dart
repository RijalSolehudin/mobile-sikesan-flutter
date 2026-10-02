import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/filter_pill.dart';

class InformationFilterBar extends StatelessWidget {
  final List<String> categories;
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategorySelected;
  final List<String> statuses;
  final int selectedStatusIndex;
  final ValueChanged<int> onStatusSelected;
  final ValueChanged<String>? onSearchChanged;

  const InformationFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    required this.statuses,
    required this.selectedStatusIndex,
    required this.onStatusSelected,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: 'Cari informasi...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Category Pills
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return FilterPill(
                label: categories[index],
                isSelected: selectedCategoryIndex == index,
                onTap: () => onCategorySelected(index),
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
            itemCount: statuses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return FilterPill(
                label: statuses[index],
                isSelected: selectedStatusIndex == index,
                selectedColor: AppColors.darkSlate,
                onTap: () => onStatusSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
