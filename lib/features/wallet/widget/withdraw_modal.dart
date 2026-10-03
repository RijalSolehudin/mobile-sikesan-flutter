import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/dashboard_metric_model.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/models/withdraw_models.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'withdraw_receipt_modal.dart';

class WithdrawModal extends StatefulWidget {
  final int? preselectedStudentId;
  final String? preselectedStudentName;

  const WithdrawModal({
    super.key,
    this.preselectedStudentId,
    this.preselectedStudentName,
  });

  static Future<void> show(
    BuildContext context, {
    int? preselectedStudentId,
    String? preselectedStudentName,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawModal(
        preselectedStudentId: preselectedStudentId,
        preselectedStudentName: preselectedStudentName,
      ),
    );
  }

  @override
  State<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();

  int? _selectedStudentId;
  String _selectedStudentName = '';
  String _selectedStudentNis = '';
  String _selectedStudentClass = '';
  num _selectedStudentBalance = 0;

  num _amount = 0;
  bool _isLoading = false;
  bool _isSearchingStudent = false;
  List<StudentLookupModel> _searchedStudents = [];
  Timer? _searchDebounce;

  final List<num> _quickAmounts = [20000, 50000, 100000, 200000];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedStudentId != null) {
      _selectedStudentId = widget.preselectedStudentId;
      _selectedStudentName = widget.preselectedStudentName ?? 'Santri';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDefaultStudent();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _initDefaultStudent() {
    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian) {
      final dashboardStudents = context
          .read<DashboardBloc>()
          .state
          .metrics
          .students;
      if (dashboardStudents.isNotEmpty) {
        if (_selectedStudentId != null) {
          final matched = dashboardStudents.firstWhere(
            (s) => s.id == _selectedStudentId,
            orElse: () => dashboardStudents.first,
          );
          _selectGuardianStudent(matched);
        } else {
          _selectGuardianStudent(dashboardStudents.first);
        }
      }
    } else if (_selectedStudentId != null) {
      // Find initial student balance if preselected
      _fetchStudentDetail(_selectedStudentId!);
    }
  }

  Future<void> _fetchStudentDetail(int studentId) async {
    final walletRepo = RepositoryProvider.of<WalletRepository>(context);
    final result = await walletRepo.getStudents(
      search: widget.preselectedStudentName,
    );
    if (!mounted) return;
    if (result is ApiSuccess<List<StudentLookupModel>>) {
      final matched = result.data.firstWhere(
        (s) => s.id == studentId,
        orElse: () => result.data.first,
      );
      _selectLookupStudent(matched);
    }
  }

  void _selectGuardianStudent(StudentSummaryModel student) {
    setState(() {
      _selectedStudentId = student.id;
      _selectedStudentName = student.name;
      _selectedStudentNis = 'NIS-${student.id}';
      _selectedStudentClass = student.grade;
      _selectedStudentBalance = student.walletBalance;
      _searchController.text = student.name;
      _searchedStudents.clear();
      if (_amount > _selectedStudentBalance) {
        _amount = 0;
        _amountController.clear();
      }
    });
  }

  void _selectLookupStudent(StudentLookupModel student) {
    setState(() {
      _selectedStudentId = student.id;
      _selectedStudentName = student.name;
      _selectedStudentNis = student.nis;
      _selectedStudentClass = student.grade;
      _selectedStudentBalance = student.walletBalance;
      _searchController.text = student.name;
      _searchedStudents.clear();
      if (_amount > _selectedStudentBalance) {
        _amount = 0;
        _amountController.clear();
      }
    });
  }

  void _onAmountChanged(String val) {
    final numVal = CurrencyFormatter.parseClean(val);
    setState(() {
      _amount = numVal;
    });
  }

  void _selectQuickAmount(num val) {
    setState(() {
      _amount = val;
      _amountController.text = CurrencyFormatter.format(
        val,
      ).replaceAll('Rp ', '').trim();
      _amountController.selection = TextSelection.collapsed(
        offset: _amountController.text.length,
      );
    });
  }

  void _selectWithdrawAll() {
    if (_selectedStudentBalance <= 0) return;
    _selectQuickAmount(_selectedStudentBalance);
  }

  void _onSearchChanged(String query) {
    if (_selectedStudentId != null &&
        query.trim() == _selectedStudentName.trim()) {
      return;
    }
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchedStudents = [];
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchGlobalStudents(query);
    });
  }

  Future<void> _searchGlobalStudents(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchedStudents = [];
        _isSearchingStudent = false;
      });
      return;
    }
    setState(() => _isSearchingStudent = true);
    final walletRepo = RepositoryProvider.of<WalletRepository>(context);
    final result = await walletRepo.getStudents(search: trimmed);

    if (!mounted) return;

    if (result is ApiSuccess<List<StudentLookupModel>>) {
      setState(() {
        _searchedStudents = result.data;
        _isSearchingStudent = false;
      });
    } else {
      setState(() {
        _searchedStudents = [];
        _isSearchingStudent = false;
      });
    }
  }

  Future<void> _handleWithdraw() async {
    if (_selectedStudentId == null) {
      _showError('Pilih santri terlebih dahulu');
      return;
    }

    if (_amount < 1000) {
      _showError('Nominal penarikan minimal Rp 1.000');
      return;
    }

    if (_amount > _selectedStudentBalance && _selectedStudentBalance > 0) {
      _showError('Saldo tidak mencukupi untuk melakukan penarikan');
      return;
    }

    setState(() => _isLoading = true);

    if (!mounted) return;
    final navigator = Navigator.of(context);
    final parentContext = navigator.context;
    final walletRepo = RepositoryProvider.of<WalletRepository>(context);
    final dashboardBloc = context.read<DashboardBloc>();
    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final note = _noteController.text.trim();

    final result = await walletRepo.withdrawWallet(
      studentId: _selectedStudentId!,
      amount: _amount.toInt(),
      description: note.isNotEmpty ? note : 'Penarikan Tunai Saldo Santri',
    );

    if (!mounted || !parentContext.mounted) return;
    setState(() => _isLoading = false);

    if (result is ApiSuccess<WithdrawReceiptModel>) {
      final receipt = result.data;

      // Refresh dashboard metrics
      dashboardBloc.add(DashboardRefreshRequested(role: userRole));

      navigator.pop();
      if (!parentContext.mounted) return;
      WithdrawReceiptModal.show(parentContext, receipt);
    } else {
      final msg = result is ApiFailure
          ? (result as ApiFailure).message
          : 'Gagal memproses penarikan saldo';
      _showError(msg);
    }
  }

  void _showError(String message) {
    AppSnackBar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final userRole =
        context.watch<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');
    final isOverBalance =
        _selectedStudentBalance > 0 && _amount > _selectedStudentBalance;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Color(0xFFDC2626),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uang Keluar',
                            style: AppTypography.headerTitle.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pencairan uang saku & penarikan saldo santri',
                            style: AppTypography.itemSubtitle.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section: Pilih Santri
                if (isGuardian) ...[
                  _buildGuardianStudentSelector(),
                ] else ...[
                  _buildStaffStudentSearch(),
                ],
                const SizedBox(height: 14),

                // Balance Info Card
                if (_selectedStudentId != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 18,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo Tersedia',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(
                                    _selectedStudentBalance,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_selectedStudentBalance > 0)
                          TextButton(
                            onPressed: _selectWithdrawAll,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFEE2E2),
                              foregroundColor: const Color(0xFFDC2626),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Tarik Semua',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section: Input Nominal
                Text(
                  'Nominal Penarikan',
                  style: AppTypography.itemTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  onChanged: _onAmountChanged,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: isOverBalance
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isOverBalance
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isOverBalance
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isOverBalance
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFDC2626),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                if (isOverBalance) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 13,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Nominal penarikan melebihi saldo dompet yang tersedia',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),

                // Quick Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts.map((amt) {
                    final isSelected = _amount == amt;
                    final isDisabled =
                        _selectedStudentBalance > 0 &&
                        amt > _selectedStudentBalance;
                    return InkWell(
                      onTap: isDisabled ? null : () => _selectQuickAmount(amt),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFEE2E2)
                              : (isDisabled
                                    ? Colors.grey.shade100
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFDC2626)
                                : (isDisabled
                                      ? Colors.grey.shade200
                                      : Colors.transparent),
                          ),
                        ),
                        child: Text(
                          CurrencyFormatter.format(amt),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFDC2626)
                                : (isDisabled
                                      ? Colors.grey.shade400
                                      : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Section: Catatan / Keperluan (Opsional)
                Text(
                  'Keperluan / Catatan (Opsional)',
                  style: AppTypography.itemTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Uang saku mingguan, beli buku di koperasi...',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFDC2626),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isLoading || isOverBalance || _amount <= 0)
                        ? null
                        : _handleWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Proses Penarikan (${CurrencyFormatter.format(_amount)})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuardianStudentSelector() {
    final students = context.watch<DashboardBloc>().state.metrics.students;

    if (students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text('Tidak ada data santri ditemukan.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Santri',
          style: AppTypography.itemTitle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: students.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final student = students[index];
              final isSelected = _selectedStudentId == student.id;

              return InkWell(
                onTap: () => _selectGuardianStudent(student),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 170,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFEE2E2) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFDC2626)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Saldo: ${CurrencyFormatter.format(student.walletBalance)}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFB91C1C)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffStudentSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cari & Pilih Santri',
          style: AppTypography.itemTitle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Ketik Nama atau NIS Santri...',
            hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _isSearchingStudent
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchedStudents.clear();
                              _selectedStudentId = null;
                              _selectedStudentName = '';
                              _selectedStudentBalance = 0;
                            });
                          },
                        )
                      : null),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Search Results List
        if (_searchedStudents.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _searchedStudents.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final student = _searchedStudents[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  subtitle: Text(
                    'NIS: ${student.nis} • ${student.grade}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(student.walletBalance),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () => _selectLookupStudent(student),
                );
              },
            ),
          ),
        ],

        // Selected Student Summary Banner (if selected)
        if (_selectedStudentId != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFDC2626),
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedStudentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'NIS: $_selectedStudentNis • Kelas: $_selectedStudentClass',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
