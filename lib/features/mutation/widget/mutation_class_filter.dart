import 'package:flutter/material.dart';
import '../../../core/widgets/filter_pill.dart';

class MutationClassFilter extends StatelessWidget {
  final List<String> classes;
  final int selectedIndex;
  final ValueChanged<int> onClassSelected;

  const MutationClassFilter({
    super.key,
    required this.classes,
    required this.selectedIndex,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: classes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FilterPill(
            label: classes[index],
            isSelected: selectedIndex == index,
            onTap: () => onClassSelected(index),
          );
        },
      ),
    );
  }
}
