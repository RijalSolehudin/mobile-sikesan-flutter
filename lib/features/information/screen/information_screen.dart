import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widget/information_header.dart';
import '../widget/information_metric_cards.dart';
import '../widget/information_filter_bar.dart';
import '../widget/information_empty_state.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedStatusIndex = 3; // 'Dipublikasikan'

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
            InformationHeader(
              onAddAnnouncement: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form pengumuman segera hadir.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InformationMetricCards(),
                      const SizedBox(height: 16),
                      InformationFilterBar(
                        categories: _categories,
                        selectedCategoryIndex: _selectedCategoryIndex,
                        onCategorySelected: (index) {
                          setState(() => _selectedCategoryIndex = index);
                        },
                        statuses: _statuses,
                        selectedStatusIndex: _selectedStatusIndex,
                        onStatusSelected: (index) {
                          setState(() => _selectedStatusIndex = index);
                        },
                      ),
                      const SizedBox(height: 16),
                      const InformationEmptyState(),
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
