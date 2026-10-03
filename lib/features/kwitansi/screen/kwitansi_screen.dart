import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../models/kwitansi_model.dart';
import '../widget/kwitansi_header.dart';
import '../widget/kwitansi_search_bar.dart';
import '../widget/kwitansi_filter_chips.dart';
import '../widget/kwitansi_summary_card.dart';
import '../widget/kwitansi_card.dart';
import '../widget/kwitansi_detail_modal.dart';
import '../widget/create_kwitansi_modal.dart';

class KwitansiScreen extends StatefulWidget {
  const KwitansiScreen({super.key});

  @override
  State<KwitansiScreen> createState() => _KwitansiScreenState();
}

class _KwitansiScreenState extends State<KwitansiScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<KwitansiModel> _allKwitansi = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  DateTime? _selectedDate;

  final List<String> _categories = ['Semua', 'Pondok'];

  @override
  void initState() {
    super.initState();
    _allKwitansi = List.from(KwitansiModel.initialData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<KwitansiModel> get _filteredKwitansi {
    return _allKwitansi.where((item) {
      // Category filter
      if (_selectedCategory != 'Semua' &&
          item.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // Search query (recipient name, invoice number)
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final nameMatches = item.recipientName.toLowerCase().contains(query);
        final invoiceMatches = item.receiptNumber.toLowerCase().contains(query);
        if (!nameMatches && !invoiceMatches) {
          return false;
        }
      }

      // Date filter
      if (_selectedDate != null) {
        final targetDateStr = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        if (!item.dateTime.startsWith(targetDateStr)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _handleCalendarTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2026, 9, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _handleCreateNew() {
    CreateKwitansiModal.show(
      context,
      existingCategories: _categories,
      onCreated: (newKwitansi, newCategory) {
        setState(() {
          if (newCategory != null &&
              newCategory.trim().isNotEmpty &&
              !_categories.contains(newCategory.trim())) {
            _categories.add(newCategory.trim());
          }
          _allKwitansi.insert(0, newKwitansi);
        });
        AppSnackBar.showSuccess(
          context,
          'Kwitansi #${newKwitansi.receiptNumber} berhasil dibuat',
        );

        // Open KwitansiDetailModal immediately (as shown in Screenshot 3)!
        Future.microtask(() {
          if (mounted) {
            KwitansiDetailModal.show(
              context,
              item: newKwitansi,
              onDeleted: () {
                setState(() {
                  _allKwitansi.removeWhere(
                    (element) => element.id == newKwitansi.id,
                  );
                });
              },
              onUpdated: (updated) {
                setState(() {
                  final idx = _allKwitansi.indexWhere(
                    (element) => element.id == updated.id,
                  );
                  if (idx != -1) {
                    _allKwitansi[idx] = updated;
                  }
                });
              },
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredKwitansi;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateNew,
        backgroundColor: AppColors.primary,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: Column(
        children: [
          // Header
          const KwitansiHeader(),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar & Calendar Filter
                      KwitansiSearchBar(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                        onCalendarTap: _handleCalendarTap,
                        hasActiveDateFilter: _selectedDate != null,
                      ),
                      const SizedBox(height: 12),

                      // Category Filter Chips
                      KwitansiFilterChips(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onSelected: (cat) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),

                      // Active Date Filter Tag (if any)
                      if (_selectedDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate!),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: _clearDateFilter,
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Total Kwitansi Summary Card
                      KwitansiSummaryCard(count: filteredList.length),
                      const SizedBox(height: 18),

                      // Riwayat Kwitansi Header
                      Text(
                        'Riwayat Kwitansi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Kwitansi List
                      if (filteredList.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tidak ada kwitansi ditemukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Coba sesuaikan pencarian atau filter kategori Anda',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return KwitansiCard(
                              item: item,
                              onTap: () {
                                KwitansiDetailModal.show(
                                  context,
                                  item: item,
                                  onDeleted: () {
                                    setState(() {
                                      _allKwitansi.removeWhere(
                                        (element) => element.id == item.id,
                                      );
                                    });
                                  },
                                  onUpdated: (updated) {
                                    setState(() {
                                      final idx = _allKwitansi.indexWhere(
                                        (element) => element.id == updated.id,
                                      );
                                      if (idx != -1) {
                                        _allKwitansi[idx] = updated;
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          },
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
