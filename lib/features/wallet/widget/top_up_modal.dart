import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_upload_helper.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/dashed_upload_box.dart';
import '../../../data/models/dashboard_metric_model.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/models/top_up_models.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import 'top_up_receipt_modal.dart';

class TopUpModal extends StatefulWidget {
  final int? preselectedStudentId;
  final String? preselectedStudentName;

  const TopUpModal({
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
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopUpModal(
        preselectedStudentId: preselectedStudentId,
        preselectedStudentName: preselectedStudentName,
      ),
    );
  }

  @override
  State<TopUpModal> createState() => _TopUpModalState();
}

class _TopUpModalState extends State<TopUpModal> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int? _selectedStudentId;
  String _selectedStudentName = '';
  String _selectedStudentNis = '-';
  String _selectedStudentClass = '-';

  int _selectedAmount = 100000;
  String _selectedPaymentMethod = 'TRANSFER'; // 'TRANSFER' or 'CASH'

  Uint8List? _proofBytes;
  String? _proofFilename;
  bool _isSubmitting = false;

  // Search suggestions for staff / cashier / treasurer
  List<StudentLookupModel> _searchedStudents = [];
  bool _isSearchingStudent = false;

  final List<int> _presetAmounts = [50000, 100000, 200000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _amountController.text = CurrencyFormatter.formatWithoutSymbol(
      _selectedAmount,
    );

    if (widget.preselectedStudentId != null) {
      _selectedStudentId = widget.preselectedStudentId;
      _selectedStudentName = widget.preselectedStudentName ?? 'Santri';
      _searchController.text = _selectedStudentName;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDefaultStudent();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initDefaultStudent() {
    if (_selectedStudentId != null) return;

    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian) {
      final dashboardStudents = context
          .read<DashboardBloc>()
          .state
          .metrics
          .students;
      if (dashboardStudents.isNotEmpty) {
        _selectGuardianStudent(dashboardStudents.first);
      }
    }
  }

  void _selectGuardianStudent(StudentSummaryModel student) {
    setState(() {
      _selectedStudentId = student.id;
      _selectedStudentName = student.name;
      _selectedStudentNis = 'NIS-${student.id}';
      _selectedStudentClass = student.grade;
      _searchController.text = student.name;
      _searchedStudents.clear();
    });
  }

  void _selectLookupStudent(StudentLookupModel student) {
    setState(() {
      _selectedStudentId = student.id;
      _selectedStudentName = student.name;
      _selectedStudentNis = student.nis;
      _selectedStudentClass = student.grade;
      _searchController.text = student.name;
      _searchedStudents.clear();
    });
  }

  void _onAmountChanged(String val) {
    final numVal = CurrencyFormatter.parseClean(val);
    setState(() {
      _selectedAmount = numVal;
    });
  }

  void _selectPresetAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = CurrencyFormatter.formatWithoutSymbol(amount);
      _amountController.selection = TextSelection.collapsed(
        offset: _amountController.text.length,
      );
    });
  }

  Future<void> _searchGlobalStudents(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchedStudents = []);
      return;
    }
    setState(() => _isSearchingStudent = true);
    final walletRepo = RepositoryProvider.of<WalletRepository>(context);
    final result = await walletRepo.getStudents(search: query);

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImageUploadHelper.pickImageWithCompression(
        _picker,
        source: source,
      );
      if (picked != null) {
        final isValidSize = await ImageUploadHelper.validateFileSize(picked);
        if (!isValidSize) {
          if (mounted) {
            AppSnackBar.showError(
              context,
              ImageUploadHelper.maxFileSizeExceededMessage,
            );
          }
          return;
        }

        final bytes = await picked.readAsBytes();
        setState(() {
          _proofBytes = bytes;
          _proofFilename = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Gagal memilih gambar: $e');
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQrisDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QRIS Top Up Santri',
                    style: AppTypography.itemTitle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'QRIS STANDAR NASIONAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 180,
                            color: Colors.grey.shade800,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pondok Pesantren SIKESAN',
                      style: AppTypography.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NMID: ID1020304050607',
                      style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buka BCA Mobile, Livin, GoPay, OVO, Dana, atau ShopeePay lalu scan QRIS di atas untuk mengisi saldo santri.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.showSuccess(
      context,
      'Nomor rekening $label ($text) berhasil disalin',
    );
  }

  Future<void> _showSuccessAnimation(bool isApproved) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 54,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                isApproved ? 'Top Up Berhasil!' : 'Permintaan Terkirim!',
                style: AppTypography.itemTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isApproved
                    ? 'Saldo santri berhasil ditambahkan.'
                    : 'Menunggu konfirmasi bendahara pesantren.',
                style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    ).timeout(
      const Duration(milliseconds: 1400),
      onTimeout: () {
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );
  }

  Future<void> _handleTopUp() async {
    if (_selectedStudentId == null) {
      AppSnackBar.showError(context, 'Silakan pilih santri terlebih dahulu');
      return;
    }

    if (_selectedAmount <= 0) {
      AppSnackBar.showError(context, 'Nominal top up harus lebih dari Rp 0');
      return;
    }

    final user = context.read<AuthBloc>().state.user;
    final userRole = user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian && _proofBytes == null) {
      AppSnackBar.showError(
        context,
        'Silakan unggah bukti transfer/pembayaran',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final walletRepo = RepositoryProvider.of<WalletRepository>(context);
    final paymentMethod = isGuardian ? 'TRANSFER' : _selectedPaymentMethod;

    final result = await walletRepo.submitTopUpRequest(
      studentId: _selectedStudentId!,
      amount: _selectedAmount,
      paymentMethod: paymentMethod,
      proofBytes: _proofBytes,
      proofFilename: _proofFilename ?? 'topup_proof.jpg',
    );

    if (!mounted) return;

    if (result is ApiSuccess<TopUpRequestModel>) {
      final topUp = result.data;
      bool isApproved = topUp.isApproved;

      // Auto approve for cash deposit at counter if Cashier / Treasurer / Admin
      if (!isGuardian && paymentMethod == 'CASH' && !isApproved) {
        final approveResult = await walletRepo.approveTopUp(topUp.id);
        if (approveResult is ApiSuccess) {
          isApproved = true;
        }
      }

      if (!mounted) return;

      final navigator = Navigator.of(context);
      final parentContext = navigator.context;
      final guardianName = user?.name ?? 'Wali Santri';

      // Refresh dashboard balances
      context.read<DashboardBloc>().add(
        DashboardRefreshRequested(role: userRole),
      );

      await _showSuccessAnimation(isApproved);

      navigator.pop(); // Close top up modal

      if (!parentContext.mounted) return;

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final receiptNumber =
          'KW-TOPUP-${now.millisecondsSinceEpoch.toString().substring(5)}';

      final receipt = TopUpReceiptModel(
        receiptNumber: receiptNumber,
        topUpId: topUp.id,
        paymentDate: dateStr,
        paymentTime: timeStr,
        amount: _selectedAmount,
        paymentMethod: paymentMethod,
        status: isApproved ? 'APPROVED' : 'PENDING',
        studentName: _selectedStudentName,
        studentNis: _selectedStudentNis,
        studentClass: _selectedStudentClass,
        guardianName: guardianName,
      );

      TopUpReceiptModal.show(parentContext, receipt);
    } else {
      setState(() => _isSubmitting = false);
      final msg = result is ApiFailure
          ? (result as ApiFailure).message
          : 'Gagal mengajukan top up saldo';
      AppSnackBar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final userRole = user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');
    final dashboardStudents = context
        .watch<DashboardBloc>()
        .state
        .metrics
        .students;

    final bankAccounts = BankAccountModel.defaultAccounts();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
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
          child: Column(
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Up Saldo Santri',
                        style: AppTypography.headerTitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tambah saldo dompet digital santri',
                        style: AppTypography.itemSubtitle.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Pemilihan Santri
                      Row(
                        children: [
                          Text(
                            'Pilih Santri',
                            style: AppTypography.itemTitle.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (isGuardian) ...[
                        if (dashboardStudents.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Text(
                              'Belum ada santri asuhan yang terhubung.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dashboardStudents.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: dashboardStudents.length == 1
                                      ? 1
                                      : 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 72,
                                ),
                            itemBuilder: (context, index) {
                              final st = dashboardStudents[index];
                              final isSelected = _selectedStudentId == st.id;

                              return InkWell(
                                onTap: () => _selectGuardianStudent(st),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primarySurface
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                      width: isSelected ? 1.6 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.12),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.02,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              st.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: isSelected
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFF334155),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Saldo: ${CurrencyFormatter.format(st.walletBalance)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? AppColors.primaryDark
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ] else ...[
                        // Global Student Search (Kasir / Bendahara / Admin)
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau NIS santri...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF94A3B8),
                            ),
                            suffixIcon: _isSearchingStudent
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: _searchGlobalStudents,
                        ),
                        if (_searchedStudents.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 160),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchedStudents.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final st = _searchedStudents[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    st.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${st.nis} • ${st.grade}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onTap: () => _selectLookupStudent(st),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 18),

                      // 2. Nominal Top Up
                      Row(
                        children: [
                          Text(
                            'Nominal Top Up',
                            style: AppTypography.itemTitle.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Custom Amount Input
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyInputFormatter()],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 16, right: 8),
                              child: Text(
                                'Rp',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            hintText: '0',
                          ),
                          onChanged: _onAmountChanged,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Preset Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presetAmounts.map((amt) {
                          final isSelected = _selectedAmount == amt;
                          return ChoiceChip(
                            label: Text(
                              CurrencyFormatter.format(amt),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            onSelected: (_) => _selectPresetAmount(amt),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // 3. Metode Pembayaran
                      Row(
                        children: [
                          Text(
                            'Metode Pembayaran',
                            style: AppTypography.itemTitle.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (isGuardian) ...[
                        // Guardian: Bank Accounts
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bankAccounts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.1,
                              ),
                          itemBuilder: (context, index) {
                            final acc = bankAccounts[index];
                            return GestureDetector(
                              onTap: () => _copyToClipboard(
                                acc.accountNumber,
                                acc.bankName,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        acc.bankName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      acc.accountNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      acc.accountHolder,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 10,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'Salin',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // QRIS Button
                        GestureDetector(
                          onTap: _showQrisDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 24,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'QRIS Pondok Pesantren',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Klik untuk scan via BCA Mobile, Mandiri, Dana, GoPay, dll.',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bukti Pembayaran
                        Row(
                          children: [
                            Text(
                              'Bukti Pembayaran',
                              style: AppTypography.itemTitle.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        DashedUploadBox(
                          imageBytes: _proofBytes,
                          filename: _proofFilename,
                          onTap: _showImagePickerOptions,
                          onRemove: () {
                            setState(() {
                              _proofBytes = null;
                              _proofFilename = null;
                            });
                          },
                        ),
                      ] else ...[
                        // Cashier / Treasurer: Toggle Transfer vs Cash
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _selectedPaymentMethod = 'TRANSFER',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentMethod == 'TRANSFER'
                                        ? AppColors.primarySurface
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          _selectedPaymentMethod == 'TRANSFER'
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.swap_horiz_rounded,
                                        size: 18,
                                        color:
                                            _selectedPaymentMethod == 'TRANSFER'
                                            ? AppColors.primary
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Transfer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color:
                                              _selectedPaymentMethod ==
                                                  'TRANSFER'
                                              ? AppColors.primary
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _selectedPaymentMethod = 'CASH',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentMethod == 'CASH'
                                        ? AppColors.primarySurface
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _selectedPaymentMethod == 'CASH'
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.point_of_sale_rounded,
                                        size: 18,
                                        color: _selectedPaymentMethod == 'CASH'
                                            ? AppColors.primary
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tunai (Kasir)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color:
                                              _selectedPaymentMethod == 'CASH'
                                              ? AppColors.primary
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Optional Proof upload for Cashier / Admin
                        DashedUploadBox(
                          imageBytes: _proofBytes,
                          filename: _proofFilename,
                          title: 'Lampirkan Bukti / Struk (Opsional)',
                          subtitle: 'PNG, JPG (Max 2MB)',
                          onTap: _showImagePickerOptions,
                          onRemove: () {
                            setState(() {
                              _proofBytes = null;
                              _proofFilename = null;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedAmount <= 0
                      ? null
                      : _handleTopUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _selectedAmount <= 0
                              ? 'Masukkan Nominal'
                              : 'Top Up ${CurrencyFormatter.format(_selectedAmount)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
