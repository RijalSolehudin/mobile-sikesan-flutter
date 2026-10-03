import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_upload_helper.dart';
import '../../../core/widgets/dashed_upload_box.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/models/infaq_models.dart';
import '../../../data/repositories/infaq_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../spp/widget/receipt_preview_modal.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/transaction_security_sheet.dart';

class PayInfaqModal extends StatefulWidget {
  const PayInfaqModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
  final int _selectedYear = DateTime.now().year;
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
      AppSnackBar.showError(context, msg);
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
          amountBilled: 50000,
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
      useRootNavigator: true,
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
                color: Color(0xFFF59E0B),
              ),
              title: Text(
                'Ambil Foto dari Kamera',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFFF59E0B),
              ),
              title: Text(
                'Pilih dari Galeri',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
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
      useRootNavigator: true,
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
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 150,
                      color: Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NMID: ID102003920192',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pondok Pesantren SIKESAN',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mendukung semua aplikasi bank & e-wallet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
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

  Future<void> _handlePayment() async {
    if (_selectedStudentId == null) {
      AppSnackBar.showError(context, 'Silakan pilih santri terlebih dahulu');
      return;
    }

    if (_selectedMonths.isEmpty) {
      AppSnackBar.showError(context, 'Silakan pilih minimal 1 bulan tagihan');
      return;
    }

    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian &&
        _selectedPaymentMethod == 'TRANSFER' &&
        _proofBytes == null) {
      AppSnackBar.showError(
        context,
        'Silakan unggah bukti transfer/pembayaran',
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
      AppSnackBar.showError(
        context,
        'Tagihan Infak Kesantrian untuk sebagian periode yang dipilih belum diterbitkan.',
      );
      return;
    }

    final num total = selectedBills.fold<num>(
      0,
      (sum, b) => sum + b.amountBilled,
    );

    final isAuthorized = await TransactionSecurityHelper.authorizeTransaction(
      context: context,
      actionTitle: 'Bayar Infak Santri',
      formattedAmount: CurrencyFormatter.formatRupiah(total),
      subtitle: 'Santri: $_selectedStudentName (${selectedBills.length} Bulan)',
    );

    if (!isAuthorized) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Otorisasi keamanan transaksi dibatalkan.',
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    if (!mounted) return;
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
      final num rate = _bills.isNotEmpty ? _bills.first.amountBilled : 50000;
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
      AppSnackBar.showError(null, errorMsg);
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
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kwitansi pembayaran sedang diproses...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
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

    final num rate = _bills.isNotEmpty ? _bills.first.amountBilled : 50000;
    final num totalAmount = _selectedMonths.length * rate;
    final bankAccounts = BankAccountModel.defaultAccounts();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.94,
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
              // Header matching design
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Infak Kesantrian',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pembayaran infak bulanan santri',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
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
                      // 1. Kolom Paling Atas: Search Bar untuk Bendahara / Card Santri untuk Wali Santri
                      if (!isGuardian) ...[
                        // Bendahara Search Bar
                        TextField(
                          controller: _searchController,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau NIS santri...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
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
                                : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 16,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _selectedStudentId = null;
                                        _selectedStudentName = '';
                                        _searchedStudents.clear();
                                        _bills.clear();
                                        _selectedMonths.clear();
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
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
                                color: Color(0xFFF59E0B),
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
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
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
                                    backgroundColor: Color(0xFFFEF3C7),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                  title: Text(
                                    st.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'NIS: ${st.nis} • ${st.grade}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  onTap: () => _selectStudent(st.id, st.name),
                                );
                              },
                            ),
                          ),
                        ],
                        if (_selectedStudentId != null &&
                            _selectedStudentName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Santri: $_selectedStudentName',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ] else ...[
                        // Wali Santri: Container / Card berisi anak-anaknya
                        if (dashboardStudents.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people_alt_rounded,
                                      size: 16,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pilih Santri (Anak)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: dashboardStudents.map((st) {
                                    final isSelected =
                                        _selectedStudentId == st.id;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: InkWell(
                                          onTap: () =>
                                              _selectStudent(st.id, st.name),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFFFFFBEB)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFFF59E0B)
                                                    : const Color(0xFFCBD5E1),
                                                width: isSelected ? 1.6 : 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: isSelected
                                                      ? const Color(0xFFF59E0B)
                                                      : const Color(0xFFE2E8F0),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 16,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF64748B,
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        st.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  isSelected
                                                                  ? FontWeight
                                                                        .w800
                                                                  : FontWeight
                                                                        .w600,
                                                              color: isSelected
                                                                  ? const Color(
                                                                      0xFFB45309,
                                                                    )
                                                                  : const Color(
                                                                      0xFF1E293B,
                                                                    ),
                                                            ),
                                                      ),
                                                      Text(
                                                        st.grade,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 10,
                                                              color:
                                                                  const Color(
                                                                    0xFF64748B,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (isSelected)
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 16,
                                                    color: Color(0xFFF59E0B),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      // 2. Bulan Selector Grid (3 columns x 4 rows)
                      if (_isLoadingBills)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 12,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
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
                                amountBilled: 50000,
                                status: 'UNPAID',
                              ),
                            );

                            final isPaid = bill.isPaid;
                            final isPending = bill.isPending;
                            final isSelected = _selectedMonths.contains(
                              monthNum,
                            );

                            Color bgColor = Colors.white;
                            Color borderColor = const Color(0xFFE2E8F0);
                            Color textColor = const Color(0xFF1E293B);

                            if (isPaid) {
                              bgColor = const Color(0xFFF0FDF4);
                              borderColor = const Color(0xFFBBF7D0);
                              textColor = const Color(0xFF15803D);
                            } else if (isPending) {
                              bgColor = const Color(0xFFFEF3C7);
                              borderColor = const Color(0xFFFDE68A);
                              textColor = const Color(0xFFB45309);
                            } else if (isSelected) {
                              bgColor = const Color(0xFFFFFBEB);
                              borderColor = const Color(0xFFF59E0B);
                              textColor = const Color(0xFFB45309);
                            }

                            return InkWell(
                              onTap: isPaid || isPending
                                  ? null
                                  : () => _onMonthTapped(monthNum),
                              borderRadius: BorderRadius.circular(24),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: borderColor,
                                    width: isSelected ? 1.6 : 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isPaid) ...[
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 15,
                                        color: Color(0xFF15803D),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      monthLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: isSelected || isPaid
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 10),

                      // Caption: Pilih satu atau lebih bulan. Bulan dengan centang hijau sudah lunas.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1.5),
                            child: Icon(
                              Icons.info_rounded,
                              size: 14,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pilih satu atau lebih bulan. Bulan dengan centang hijau sudah lunas.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 3. Card Total Tagihan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFEF08A),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Tagihan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_selectedMonths.length} bulan x ${CurrencyFormatter.format(rate)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.format(totalAmount),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4. Metode Pembayaran *
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Metode Pembayaran ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(
                                () => _selectedPaymentMethod = 'TRANSFER',
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 'TRANSFER'
                                      ? const Color(0xFFFFFDF5)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 'TRANSFER'
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFE2E8F0),
                                    width: _selectedPaymentMethod == 'TRANSFER'
                                        ? 1.5
                                        : 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      size: 18,
                                      color:
                                          _selectedPaymentMethod == 'TRANSFER'
                                          ? const Color(0xFFB45309)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Transfer',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            _selectedPaymentMethod == 'TRANSFER'
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(
                                () => _selectedPaymentMethod = 'CASH',
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 'CASH'
                                      ? const Color(0xFFFFFDF5)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 'CASH'
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFE2E8F0),
                                    width: _selectedPaymentMethod == 'CASH'
                                        ? 1.5
                                        : 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_atm_rounded,
                                      size: 18,
                                      color: _selectedPaymentMethod == 'CASH'
                                          ? const Color(0xFFB45309)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tunai',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: _selectedPaymentMethod == 'CASH'
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Daftar Rekening Transfer & QRIS
                      if (_selectedPaymentMethod == 'TRANSFER') ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pilihan Rekening Transfer',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            InkWell(
                              onTap: _showQrisDialog,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_2,
                                    size: 15,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bayar QRIS',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF59E0B),
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
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
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
                                        horizontal: 6,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        acc.bankName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10.5,
                                          color: const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      acc.accountNumber,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => _copyToClipboard(
                                    acc.accountNumber,
                                    acc.bankName,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.copy_rounded,
                                      size: 15,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      // 5. Upload Bukti Transfer (Boleh kosong untuk Admin)
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Upload Bukti Transfer',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isGuardian
                                ? '(Wajib untuk Wali Santri)'
                                : '(Boleh kosong untuk Admin)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Reusable Dashed Upload Box Widget
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Button: Bayar Rp...
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ||
                          _selectedStudentId == null ||
                          _selectedMonths.isEmpty
                      ? null
                      : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A524),
                    disabledBackgroundColor: const Color(
                      0xFFFCD34D,
                    ).withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
                          'Bayar ${CurrencyFormatter.format(totalAmount)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
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
