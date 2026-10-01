import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/models/infaq_models.dart';
import '../../../data/repositories/infaq_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../spp/widgets/receipt_preview_modal.dart';

class PayInfaqModal extends StatefulWidget {
  const PayInfaqModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PayInfaqModal(),
    );
  }

  @override
  State<PayInfaqModal> createState() => _PayInfaqModalState();
}

class _PayInfaqModalState extends State<PayInfaqModal>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  int? _selectedStudentId;
  String _selectedStudentName = '';
  int _selectedYear = DateTime.now().year;
  final Set<int> _selectedMonths = {};
  String _selectedPaymentMethod = 'TRANSFER'; // 'TRANSFER' or 'CASH'

  Uint8List? _proofBytes;
  String? _proofFilename;
  bool _isLoadingBills = false;
  bool _isSubmitting = false;
  List<InfaqBillModel> _bills = [];

  // For Treasurer Global Student Search
  final TextEditingController _searchController = TextEditingController();
  List<StudentLookupModel> _searchedStudents = [];
  bool _isSearchingStudent = false;

  final List<String> _monthNamesShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final List<int> _availableYears = [
    DateTime.now().year - 1,
    DateTime.now().year,
    DateTime.now().year + 1,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDefaultStudent();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initDefaultStudent() {
    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian) {
      final dashboardState = context.read<DashboardBloc>().state;
      final students = dashboardState.metrics.students;
      if (students.isNotEmpty) {
        _selectStudent(students.first.id, students.first.name);
      }
    }
  }

  void _selectStudent(int id, String name) {
    setState(() {
      _selectedStudentId = id;
      _selectedStudentName = name;
      _selectedMonths.clear();
      _searchedStudents.clear();
      _searchController.text = name;
    });
    _loadBillsForStudent(id, year: _selectedYear);
  }

  Future<void> _loadBillsForStudent(int studentId, {int? year}) async {
    setState(() => _isLoadingBills = true);
    final infaqRepo = RepositoryProvider.of<InfaqRepository>(context);
    final result = await infaqRepo.getStudentBills(
      studentId,
      year: year ?? _selectedYear,
    );

    if (!mounted) return;

    if (result is ApiSuccess<List<InfaqBillModel>>) {
      setState(() {
        _bills = result.data;
        _isLoadingBills = false;
      });
    } else {
      final msg = result is ApiFailure
          ? (result as ApiFailure).message
          : 'Gagal memuat tagihan Infak Kesantrian';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
      setState(() {
        _bills = [];
        _isLoadingBills = false;
      });
    }
  }

  void _onMonthTapped(int monthNumber) {
    // Kumpulkan seluruh bulan yang belum lunas (UNPAID) untuk tahun yang dipilih
    final unpaidMonths = <int>[];
    for (int m = 1; m <= 12; m++) {
      final bill = _bills.firstWhere(
        (b) => b.periodYear == _selectedYear && b.periodMonth == m,
        orElse: () => InfaqBillModel(
          id: '',
          studentId: _selectedStudentId ?? 0,
          periodMonth: m,
          periodYear: _selectedYear,
          amountBilled: 350000,
          status: 'UNPAID',
        ),
      );
      if (!bill.isPaid && !bill.isPending) {
        unpaidMonths.add(m);
      }
    }

    if (!unpaidMonths.contains(monthNumber)) {
      return; // Bulan sudah lunas atau pending, tidak dapat dipilih
    }

    setState(() {
      final maxSelected = _selectedMonths.isEmpty
          ? 0
          : _selectedMonths.reduce((a, b) => a > b ? a : b);

      if (_selectedMonths.contains(monthNumber)) {
        if (monthNumber == maxSelected) {
          _selectedMonths.remove(monthNumber);
        } else {
          _selectedMonths.removeWhere((m) => m > monthNumber);
        }
      } else {
        // FIFO: pilih otomatis bulan tertua yang belum lunas sampai bulan ini
        _selectedMonths.clear();
        for (final m in unpaidMonths) {
          if (m <= monthNumber) {
            _selectedMonths.add(m);
          }
        }
      }
    });
  }

  Future<void> _searchGlobalStudents(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchedStudents = []);
      return;
    }
    setState(() => _isSearchingStudent = true);
    final infaqRepo = RepositoryProvider.of<InfaqRepository>(context);
    final result = await infaqRepo.getStudents(search: query);

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
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _proofBytes = bytes;
          _proofFilename = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
                    'QRIS Infak Kesantrian',
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
                              Icons.favorite_rounded,
                              size: 24,
                              color: Color(0xFF059669),
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
                'Buka aplikasi m-Banking atau e-Wallet (BSI, BCA, Livin, GoPay, OVO, Dana) lalu scan QRIS di atas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor rekening $label ($text) berhasil disalin'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih santri terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih minimal 1 bulan tagihan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian && _proofBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan unggah bukti transfer/pembayaran'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final selectedBills = _bills
        .where(
          (b) =>
              b.periodYear == _selectedYear &&
              _selectedMonths.contains(b.periodMonth) &&
              b.id.isNotEmpty,
        )
        .toList();
    final List<String> billIds = selectedBills.map((b) => b.id).toList();

    if (billIds.isEmpty || billIds.length != _selectedMonths.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tagihan Infak Kesantrian untuk sebagian periode yang dipilih belum diterbitkan.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final num total = selectedBills.fold<num>(
      0,
      (sum, b) => sum + b.amountBilled,
    );

    final messenger = ScaffoldMessenger.of(context);
    final infaqRepo = RepositoryProvider.of<InfaqRepository>(context);
    final navigator = Navigator.of(context);
    final parentContext = navigator.context;
    final guardianName =
        context.read<AuthBloc>().state.user?.name ?? 'Wali Santri';

    ApiResult<String> result;
    if (!isGuardian && _selectedPaymentMethod == 'CASH') {
      result = await infaqRepo.payDirect(
        studentId: _selectedStudentId!,
        billIds: billIds,
        totalAmount: total,
      );
    } else {
      result = await infaqRepo.submitTransferPayment(
        studentId: _selectedStudentId!,
        billIds: billIds,
        totalAmount: total,
        proofBytes: _proofBytes ?? [],
        proofFilename: _proofFilename ?? 'proof.jpg',
      );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (result is ApiSuccess<String>) {
      final paymentId = result.data;
      await _showSuccessAnimation();
      navigator.pop(); // Close pay modal

      if (!parentContext.mounted) return;

      if (paymentId.isNotEmpty) {
        final receiptResult = await infaqRepo.getReceipt(paymentId);
        if (!parentContext.mounted) return;
        if (receiptResult is ApiSuccess<InfaqReceiptModel>) {
          ReceiptPreviewModal.show(
            parentContext,
            receiptResult.data.toSppReceiptModel(),
          );
          return;
        }
      }

      // Fallback preview
      final num rate = _bills.isNotEmpty ? _bills.first.amountBilled : 350000;
      final fallbackReceipt = SppReceiptModel(
        receiptNumber:
            'KW-INF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        paymentId: paymentId,
        paymentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentTime: DateFormat('HH:mm:ss').format(DateTime.now()),
        totalPaidAmount: total,
        paymentMethod: isGuardian ? 'TRANSFER' : _selectedPaymentMethod,
        status: isGuardian ? 'PENDING' : 'APPROVED',
        studentName: _selectedStudentName,
        studentNis: 'NIS-2026',
        studentClass: 'Kelas Santri',
        guardianName: guardianName,
        bills: _selectedMonths
            .map(
              (m) => SppReceiptBillItem(
                month: m,
                monthName: _monthNamesShort[m - 1],
                year: _selectedYear,
                amount: rate,
              ),
            )
            .toList(),
      );
      ReceiptPreviewModal.show(parentContext, fallbackReceipt);
    } else {
      final errorMsg = result is ApiFailure
          ? (result as ApiFailure).message
          : 'Gagal memproses pembayaran';
      messenger.showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _showSuccessAnimation() async {
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
                'Pembayaran Berhasil!',
                style: AppTypography.itemTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kwitansi pembayaran sedang diproses...',
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

  @override
  Widget build(BuildContext context) {
    final userRole =
        context.watch<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');
    final dashboardStudents = context
        .watch<DashboardBloc>()
        .state
        .metrics
        .students;

    if (_selectedStudentId == null &&
        dashboardStudents.isNotEmpty &&
        isGuardian) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedStudentId == null) {
          _selectStudent(
            dashboardStudents.first.id,
            dashboardStudents.first.name,
          );
        }
      });
    }

    final num rate = _bills.isNotEmpty ? _bills.first.amountBilled : 350000;
    final num totalAmount = _selectedMonths.length * rate;

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayar Infak Kesantrian',
                        style: AppTypography.headerTitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pembayaran Infak Kesantrian bulanan santri',
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

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Pemilihan Nama Santri
                      Row(
                        children: [
                          Text(
                            'Nama Santri',
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
                              'Belum ada santri terhubung dengan akun Anda',
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
                                  mainAxisExtent: 64,
                                ),
                            itemBuilder: (context, index) {
                              final st = dashboardStudents[index];
                              final isSelected = _selectedStudentId == st.id;

                              return InkWell(
                                onTap: () => _selectStudent(st.id, st.name),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFECFDF5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFE2E8F0),
                                      width: isSelected ? 1.6 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF059669)
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
                                      const SizedBox(width: 8),
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
                                                    ? const Color(0xFF065F46)
                                                    : const Color(0xFF334155),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              st.grade,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isSelected
                                                    ? const Color(0xFF059669)
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
                                            color: Color(0xFF059669),
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
                        // Bendahara Search
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau NIS santri...',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF059669),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: _searchGlobalStudents,
                        ),
                        if (_searchedStudents.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 180),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchedStudents.length,
                              separatorBuilder: (_, index) => const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              itemBuilder: (context, idx) {
                                final st = _searchedStudents[idx];
                                return ListTile(
                                  dense: true,
                                  leading: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Color(0xFFECFDF5),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                  title: Text(
                                    st.name,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'NIS: ${st.nis} • ${st.grade}',
                                    style: const TextStyle(fontSize: 10.5),
                                  ),
                                  onTap: () => _selectStudent(st.id, st.name),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 18),

                      // 2. Pemilihan Tahun & Periode Bulan (FIFO 12 Bulan)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pilih Periode Bulan',
                            style: AppTypography.itemTitle.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedYear,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                                items: _availableYears.map((yr) {
                                  return DropdownMenuItem<int>(
                                    value: yr,
                                    child: Text('Tahun $yr'),
                                  );
                                }).toList(),
                                onChanged: (newYr) {
                                  if (newYr != null && newYr != _selectedYear) {
                                    setState(() {
                                      _selectedYear = newYr;
                                      _selectedMonths.clear();
                                    });
                                    if (_selectedStudentId != null) {
                                      _loadBillsForStudent(
                                        _selectedStudentId!,
                                        year: newYr,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Grid 12 Bulan
                      if (_isLoadingBills)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 12,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.25,
                              ),
                          itemBuilder: (context, index) {
                            final monthNum = index + 1;
                            final monthLabel = _monthNamesShort[index];

                            final bill = _bills.firstWhere(
                              (b) =>
                                  b.periodYear == _selectedYear &&
                                  b.periodMonth == monthNum,
                              orElse: () => InfaqBillModel(
                                id: '',
                                studentId: _selectedStudentId ?? 0,
                                periodMonth: monthNum,
                                periodYear: _selectedYear,
                                amountBilled: 350000,
                                status: 'UNPAID',
                              ),
                            );

                            final isPaid = bill.isPaid;
                            final isPending = bill.isPending;
                            final isSelected = _selectedMonths.contains(monthNum);

                            Color bgColor = Colors.white;
                            Color borderColor = const Color(0xFFE2E8F0);
                            Color textColor = const Color(0xFF334155);

                            if (isPaid) {
                              bgColor = const Color(0xFFF1F5F9);
                              borderColor = const Color(0xFFE2E8F0);
                              textColor = const Color(0xFF94A3B8);
                            } else if (isPending) {
                              bgColor = const Color(0xFFFEF3C7);
                              borderColor = const Color(0xFFF59E0B);
                              textColor = const Color(0xFFB45309);
                            } else if (isSelected) {
                              bgColor = const Color(0xFFECFDF5);
                              borderColor = const Color(0xFF059669);
                              textColor = const Color(0xFF065F46);
                            }

                            return InkWell(
                              onTap: isPaid || isPending
                                  ? null
                                  : () => _onMonthTapped(monthNum),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor,
                                    width: isSelected ? 1.6 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      monthLabel,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected || isPaid
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isPaid
                                          ? 'LUNAS'
                                          : isPending
                                              ? 'MENUNGGU'
                                              : isSelected
                                                  ? 'DIPILIH'
                                                  : 'BELUM',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isPaid
                                            ? const Color(0xFF10B981)
                                            : isPending
                                                ? const Color(0xFFD97706)
                                                : isSelected
                                                    ? const Color(0xFF059669)
                                                    : const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 18),

                      // 3. Ringkasan & Total
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Tagihan Infak',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_selectedMonths.length} Bulan Terpilih',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.format(totalAmount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4. Metode Pembayaran & Rekening
                      if (!isGuardian) ...[
                        Row(
                          children: [
                            Text(
                              'Metode Pembayaran',
                              style: AppTypography.itemTitle.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () => _selectedPaymentMethod = 'CASH',
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentMethod == 'CASH'
                                        ? const Color(0xFFECFDF5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedPaymentMethod == 'CASH'
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Bayar Kasir (Cash)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedPaymentMethod == 'CASH'
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () => _selectedPaymentMethod = 'TRANSFER',
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentMethod == 'TRANSFER'
                                        ? const Color(0xFFECFDF5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _selectedPaymentMethod == 'TRANSFER'
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Transfer Bank',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _selectedPaymentMethod == 'TRANSFER'
                                              ? const Color(0xFF065F46)
                                              : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Jika Transfer: Daftar Rekening & Upload Bukti
                      if (isGuardian || _selectedPaymentMethod == 'TRANSFER') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pilihan Rekening Pembayaran',
                              style: AppTypography.itemTitle.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            InkWell(
                              onTap: _showQrisDialog,
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 16,
                                    color: Color(0xFF059669),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Bayar QRIS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ...bankAccounts.map((acc) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        acc.bankName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          acc.accountNumber,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          'a.n. ${acc.accountHolder}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                    color: Color(0xFF059669),
                                  ),
                                  onPressed: () => _copyToClipboard(
                                    acc.accountNumber,
                                    acc.bankName,
                                  ),
                                  tooltip: 'Salin Rekening',
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),

                        // Upload Bukti Struk
                        Row(
                          children: [
                            Text(
                              'Unggah Bukti Pembayaran',
                              style: AppTypography.itemTitle.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            if (isGuardian)
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

                        InkWell(
                          onTap: _showImagePickerOptions,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _proofBytes != null
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFCBD5E1),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _proofBytes == null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.upload_file_rounded,
                                        color: Color(0xFF059669),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Pilih foto bukti struk / nota transfer',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          _proofBytes!,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _proofFilename ?? 'bukti.jpg',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Siap diunggah',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF059669),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _proofBytes = null;
                                            _proofFilename = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedMonths.isEmpty
                      ? null
                      : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedPaymentMethod == 'CASH' && !isGuardian
                              ? 'Konfirmasi Pembayaran Kasir'
                              : 'Kirim Bukti Pembayaran Infak',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
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
