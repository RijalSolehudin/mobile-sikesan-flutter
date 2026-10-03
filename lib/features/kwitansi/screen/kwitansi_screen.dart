import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/navigation/navigation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/repositories/kwitansi_repository.dart';
import '../bloc/kwitansi_bloc.dart';
import '../models/kwitansi_model.dart';
import '../widget/kwitansi_header.dart';
import '../widget/kwitansi_search_bar.dart';
import '../widget/kwitansi_filter_chips.dart';
import '../widget/kwitansi_summary_card.dart';
import '../widget/kwitansi_card.dart';
import '../widget/kwitansi_detail_modal.dart';
import '../widget/create_kwitansi_modal.dart';

class KwitansiScreen extends StatelessWidget {
  const KwitansiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          KwitansiBloc(repository: context.read<KwitansiRepository>())
            ..add(const KwitansiStarted()),
      child: const _KwitansiScreenBody(),
    );
  }
}

class _KwitansiScreenBody extends StatefulWidget {
  const _KwitansiScreenBody();

  @override
  State<_KwitansiScreenBody> createState() => _KwitansiScreenBodyState();
}

class _KwitansiScreenBodyState extends State<_KwitansiScreenBody> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  KwitansiBloc get _bloc => context.read<KwitansiBloc>();

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _bloc.add(KwitansiSearchChanged(value.trim()));
    });
  }

  Future<void> _handleCalendarTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bloc.state.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
      _bloc.add(KwitansiDateChanged(picked));
    }
  }

  void _openDetail(KwitansiModel item) {
    final bloc = _bloc;
    KwitansiDetailModal.show(
      context,
      item: item,
      onDeleted: () => bloc.add(KwitansiItemRemoved(item.id)),
      onUpdated: (updated) => bloc.add(KwitansiItemUpserted(updated)),
    );
  }

  void _handleCreateNew() {
    final bloc = _bloc;
    CreateKwitansiModal.show(
      context,
      existingCategories: bloc.state.categories,
      onCreated: (newKwitansi, _) {
        bloc.add(KwitansiItemUpserted(newKwitansi));
        AppSnackBar.showSuccess(
          context,
          'Kwitansi #${newKwitansi.receiptNumber} berhasil dibuat',
        );

        // Langsung buka detail kwitansi yang baru dibuat
        Future.microtask(() {
          if (mounted) _openDetail(newKwitansi);
        });
      },
    );
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      _bloc.add(const KwitansiLoadMoreRequested());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Prioritas 1: Tutup modal/dialog aktif jika ada di root navigator
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrent && (rootNavigatorKey.currentState?.canPop() ?? false)) {
          rootNavigatorKey.currentState?.pop();
          return;
        }

        // Prioritas 2: Pop halaman kwitansi kembali ke /home
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
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
            child: BlocConsumer<KwitansiBloc, KwitansiState>(
              listenWhen: (prev, curr) =>
                  curr.errorMessage != null &&
                  curr.errorMessage != prev.errorMessage,
              listener: (context, state) {
                AppSnackBar.showError(context, state.errorMessage!);
              },
              builder: (context, state) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _bloc.add(const KwitansiRefreshed());
                    await _bloc.stream.firstWhere(
                      (s) => s.status != KwitansiStatus.loading,
                    );
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
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
                                onChanged: _onSearchChanged,
                                onCalendarTap: _handleCalendarTap,
                                hasActiveDateFilter: state.selectedDate != null,
                              ),
                              const SizedBox(height: 12),

                              // Category Filter Chips
                              KwitansiFilterChips(
                                categories: state.categories,
                                selectedCategory: state.selectedCategory,
                                onSelected: (cat) =>
                                    _bloc.add(KwitansiCategoryChanged(cat)),
                              ),

                              // Active Date Filter Tag (if any)
                              if (state.selectedDate != null) ...[
                                const SizedBox(height: 8),
                                _buildDateTag(state.selectedDate!),
                              ],
                              const SizedBox(height: 14),

                              // Total Kwitansi Summary Card
                              KwitansiSummaryCard(count: state.total),
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

                              _buildList(state),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDateTag(DateTime date) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
                DateFormat('dd/MM/yyyy').format(date),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _bloc.add(const KwitansiDateChanged(null)),
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
    );
  }

  Widget _buildList(KwitansiState state) {
    final isInitialLoading =
        state.status == KwitansiStatus.loading ||
        state.status == KwitansiStatus.initial;

    if (isInitialLoading && state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.status == KwitansiStatus.error && state.items.isEmpty) {
      return _buildEmptyBox(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat kwitansi',
        subtitle:
            'Tarik ke bawah atau ketuk tombol di bawah untuk mencoba lagi',
        action: TextButton.icon(
          onPressed: () => _bloc.add(const KwitansiStarted()),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          label: Text(
            'Coba Lagi',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return _buildEmptyBox(
        icon: Icons.receipt_long_outlined,
        title: 'Tidak ada kwitansi ditemukan',
        subtitle: 'Coba sesuaikan pencarian atau filter kategori Anda',
      );
    }

    return Column(
      children: [
        if (isInitialLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(
              color: AppColors.primary,
              minHeight: 2,
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return KwitansiCard(item: item, onTap: () => _openDetail(item));
          },
        ),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyBox({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Container(
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
          Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: const Color(0xFF94A3B8),
            ),
          ),
          if (action != null) ...[const SizedBox(height: 8), action],
        ],
      ),
    );
  }
}
