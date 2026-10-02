import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widget/cs_header.dart';
import '../widget/cs_empty_state.dart';

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
          CsHeader(
            filters: _filters,
            selectedFilterIndex: _selectedFilterIndex,
            onFilterSelected: (index) {
              setState(() => _selectedFilterIndex = index);
            },
          ),
          const Expanded(child: CsEmptyState()),
        ],
      ),
    );
  }
}
