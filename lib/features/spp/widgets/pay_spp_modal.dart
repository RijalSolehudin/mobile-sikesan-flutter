import 'dart:io';
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
import '../../../data/repositories/spp_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import 'receipt_preview_modal.dart';

class PaySppModal extends StatefulWidget {
  const PaySppModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaySppModal(),
    );
  }

  @override
  State<PaySppModal> createState() => _PaySppModalState();
}

class _PaySppModalState extends State<PaySppModal> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  int? _selectedStudentId;
  String _selectedStudentName = '';
  int _selectedYear = DateTime.now().year;
  final Set<int> _selectedMonths = {};
  String _selectedPaymentMethod = 'TRANSFER'; // 'TRANSFER' or 'CASH'

  File? _proofFile;
  bool _isLoadingBills = false;
  bool _isSubmitting = false;
  List<SppBillModel> _bills = [];

  // For Treasurer Global Student Search
  final TextEditingController _searchController = TextEditingController();
  List<StudentLookupModel> _searchedStudents = [];
  bool _isSearchingStudent = false;

  final List<String> _monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
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
    final sppRepo = RepositoryProvider.of<SppRepository>(context);
    final result = await sppRepo.getStudentBills(studentId, year: year ?? _selectedYear);

    if (!mounted) return;

    if (result is ApiSuccess<List<SppBillModel>>) {
      setState(() {
        _bills = result.data;
        _isLoadingBills = false;
      });
    } else {
      final msg = result is ApiFailure ? (result as ApiFailure).message : 'Gagal memuat tagihan SPP';
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
        orElse: () => SppBillModel(
          id: '',
          studentId: _selectedStudentId ?? 0,
          periodMonth: m,
          periodYear: _selectedYear,
          amountBilled: 750000,
          status: 'UNPAID',
        ),
      );
      if (!bill.isPaid) {
        unpaidMonths.add(m);
      }
    }

    if (!unpaidMonths.contains(monthNumber)) return; // Bulan sudah lunas, tidak dapat dipilih

    setState(() {
      final maxSelected = _selectedMonths.isEmpty ? 0 : _selectedMonths.reduce((a, b) => a > b ? a : b);

      if (_selectedMonths.contains(monthNumber)) {
        if (monthNumber == maxSelected) {
          // Klik pada bulan tertinggi yang sedang terpilih -> batalkan bulan ini
          _selectedMonths.remove(monthNumber);
        } else {
          // Klik pada bulan terpilih yang lebih rendah -> pangkas pemilihan di atas bulan ini
          _selectedMonths.removeWhere((m) => m > monthNumber);
        }
      } else {
        // Klik pada bulan yang belum terpilih:
        // Terapkan prinsip FIFO: otomatis pilih semua bulan tertua yang belum lunas sampai bulan ini
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
    final sppRepo = RepositoryProvider.of<SppRepository>(context);
    final result = await sppRepo.getStudents(search: query);

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
        setState(() {
          _proofFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
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
                    'QRIS Pondok Pesantren',
                    style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    // Visual QR Code Placeholder
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
                          Icon(Icons.qr_code_2_rounded, size: 180, color: Colors.grey.shade800),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.school_rounded, size: 24, color: Color(0xFF5B58EB)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pondok Pesantren SIKESAN',
                      style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
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
                'Buka aplikasi BCA Mobile, Livin, GoPay, OVO, Dana, atau ShopeePay lalu scan QRIS di atas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B58EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        const SnackBar(content: Text('Silakan pilih santri terlebih dahulu'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih minimal 1 bulan tagihan'), backgroundColor: AppColors.error),
      );
      return;
    }

    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian && _proofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah bukti transfer/pembayaran'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Map selected months to actual bill IDs from database
    final selectedBills = _bills
        .where((b) => b.periodYear == _selectedYear && _selectedMonths.contains(b.periodMonth) && b.id.isNotEmpty)
        .toList();
    final List<String> billIds = selectedBills.map((b) => b.id).toList();

    if (billIds.isEmpty || billIds.length != _selectedMonths.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan SPP untuk sebagian/seluruh periode yang dipilih belum diterbitkan oleh pesantren.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final sppRepo = RepositoryProvider.of<SppRepository>(context);
    final num rate = selectedBills.isNotEmpty ? selectedBills.first.amountBilled : 750000;
    final num total = selectedBills.fold<num>(0, (sum, b) => sum + b.amountBilled);

    ApiResult<String> result;
    if (!isGuardian && _selectedPaymentMethod == 'CASH') {
      result = await sppRepo.payDirect(
        studentId: _selectedStudentId!,
        billIds: billIds,
        totalAmount: total,
      );
    } else {
      result = await sppRepo.submitTransferPayment(
        studentId: _selectedStudentId!,
        billIds: billIds,
        totalAmount: total,
        proofFile: _proofFile ?? File(''),
      );
    }

    if (!mounted) return;

    if (result is ApiSuccess<String>) {
      final paymentId = result.data;

      // Show success animation dialog
      await _showSuccessAnimation();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close pay modal

      // Fetch receipt data and show preview modal
      final receiptResult = await sppRepo.getReceipt(paymentId);
      if (mounted) {
        if (receiptResult is ApiSuccess<SppReceiptModel>) {
          ReceiptPreviewModal.show(context, receiptResult.data);
        } else {
          // Fallback receipt preview
          final fallbackReceipt = SppReceiptModel(
            receiptNumber: 'KW-SPP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
            paymentId: paymentId,
            paymentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            paymentTime: DateFormat('HH:mm:ss').format(DateTime.now()),
            totalPaidAmount: total,
            paymentMethod: isGuardian ? 'TRANSFER' : _selectedPaymentMethod,
            status: isGuardian ? 'PENDING' : 'APPROVED',
            studentName: _selectedStudentName,
            studentNis: 'NIS-2026',
            studentClass: 'Kelas Santri',
            guardianName: context.read<AuthBloc>().state.user?.name ?? 'Wali Santri',
            bills: _selectedMonths.map((m) => SppReceiptBillItem(
              month: m,
              monthName: _monthNamesShort[m - 1],
              year: _selectedYear,
              amount: rate,
            )).toList(),
          );
          ReceiptPreviewModal.show(context, fallbackReceipt);
        }
      }
    } else {
      setState(() => _isSubmitting = false);
      final msg = (result as ApiFailure<String>).message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
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
                style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
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
    ).timeout(const Duration(milliseconds: 1400), onTimeout: () {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');
    final dashboardStudents = context.watch<DashboardBloc>().state.metrics.students;

    final num rate = _bills.isNotEmpty ? _bills.first.amountBilled : 750000;
    final num totalAmount = _selectedMonths.length * rate;

    final bankAccounts = BankAccountModel.defaultAccounts();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Column(
        children: [
          // Header (Title, Subtitle, Close Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bayar SPP',
                    style: AppTypography.headerTitle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pembayaran SPP bulanan santri',
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
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
                        style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (isGuardian) ...[
                    // Wali Santri: Tags / Chips Santri Asuhan
                    if (dashboardStudents.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text('Belum ada santri terhubung dengan akun Anda', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dashboardStudents.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: dashboardStudents.length == 1 ? 1 : 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 64,
                        ),
                        itemBuilder: (context, index) {
                          final st = dashboardStudents[index];
                          final isSelected = _selectedStudentId == st.id;

                          return InkWell(
                            onTap: () {
                              _selectStudent(st.id, st.name);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF5F5FE) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF5B58EB) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.6 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF5B58EB).withValues(alpha: 0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar Icon
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF5B58EB) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
                                      size: 18,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Nama & Jenjang
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          st.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF334155),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          st.grade,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? const Color(0xFF5B58EB) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Indikator Pilihan (Ceklis saat terpilih)
                                  if (isSelected)
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5B58EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ] else ...[
                    // Bendahara / Admin: Input Pencarian Santri Global
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau NIS santri...',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8)),
                        suffixIcon: _isSearchingStudent
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          borderSide: const BorderSide(color: Color(0xFF5B58EB), width: 1.5),
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
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchedStudents.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final st = _searchedStudents[index];
                            return ListTile(
                              dense: true,
                              title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${st.nis} • ${st.grade}', style: const TextStyle(fontSize: 11)),
                              onTap: () => _selectStudent(st.id, st.name),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),

                  // 2. Tahun Tagihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Tahun', style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedYear,
                                isDense: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                                items: _availableYears.map((y) {
                                  return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)));
                                }).toList(),
                                onChanged: (newYear) {
                                  if (newYear != null && newYear != _selectedYear) {
                                    setState(() {
                                      _selectedYear = newYear;
                                      _selectedMonths.clear();
                                    });
                                    if (_selectedStudentId != null) {
                                      _loadBillsForStudent(_selectedStudentId!, year: newYear);
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Grid Pilihan 12 Bulan (3 kolom x 4 baris)
                  Row(
                    children: [
                      Text('Pilihan Bulan', style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                      const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Prinsip FIFO (Berurutan)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ),
                      if (_isLoadingBills) ...[
                        const SizedBox(width: 10),
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.6,
                    ),
                    itemBuilder: (context, index) {
                      final monthNumber = index + 1;
                      final monthName = _monthNamesShort[index];

                      // Check if already paid
                      final bill = _bills.firstWhere(
                        (b) => b.periodYear == _selectedYear && b.periodMonth == monthNumber,
                        orElse: () => SppBillModel(
                          id: '',
                          studentId: _selectedStudentId ?? 0,
                          periodMonth: monthNumber,
                          periodYear: _selectedYear,
                          amountBilled: 750000,
                          status: 'UNPAID',
                        ),
                      );

                      final isPaid = bill.isPaid;
                      final isSelected = _selectedMonths.contains(monthNumber);

                      if (isPaid) {
                        // Bulan Lunas: Hijau muda, border hijau, centang hijau, disabled
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                monthName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF047857),
                                ),
                              ),
                              const Positioned(
                                right: 8,
                                child: Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                              ),
                            ],
                          ),
                        );
                      }

                      // Bulan Belum Lunas: Bisa dipilih dengan prinsip FIFO
                      return GestureDetector(
                        onTap: () => _onMonthTapped(monthNumber),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF5B58EB) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF5B58EB) : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF5B58EB).withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Keterangan Info Biru
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pilih satu atau lebih bulan. Bulan dengan centang hijau sudah lunas.',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade700, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Card Total Tagihan
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F1FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E3FD)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Tagihan',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedMonths.isEmpty
                                  ? 'Belum ada bulan dipilih'
                                  : '${_selectedMonths.length} bulan x ${CurrencyFormatter.format(rate)}',
                              style: TextStyle(fontSize: 11, color: Colors.indigo.shade600),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF5B58EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Bagian Metode Pembayaran
                  Row(
                    children: [
                      Text('Metode Pembayaran', style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                      const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (isGuardian) ...[
                    // KHUSUS WALI SANTRI:
                    // A. Grid 3 Card Rekening Bank
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bankAccounts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final acc = bankAccounts[index];
                        return GestureDetector(
                          onTap: () => _copyToClipboard(acc.accountNumber, acc.bankName),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B58EB).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    acc.bankName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: Color(0xFF5B58EB),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  acc.accountNumber,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  acc.accountHolder,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.copy_rounded, size: 10, color: Color(0xFF5B58EB)),
                                    SizedBox(width: 2),
                                    Text('Salin', style: TextStyle(fontSize: 8.5, color: Color(0xFF5B58EB), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Garis Pemisah (Divider)
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('atau bayar via QRIS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // B. Card Layout Grid 1 (QRIS)
                    GestureDetector(
                      onTap: _showQrisDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: const Icon(Icons.qr_code_scanner_rounded, size: 24, color: Color(0xFFDC2626)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'QRIS Pesantren SIKESAN',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Klik untuk scan barcode dari BCA, Mandiri, GoPay, Dana, dll.',
                                    style: TextStyle(fontSize: 10.5, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // C. Upload Bukti Pembayaran
                    Row(
                      children: [
                        Text('Bukti Pembayaran', style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                        const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _proofFile != null ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _proofFile != null
                            ? Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(_proofFile!, width: 48, height: 48, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Bukti Foto Terpilih', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _proofFile!.path.split('/').last,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF5B58EB)),
                                    onPressed: _showImagePickerOptions,
                                  ),
                                ],
                              )
                            : Column(
                                children: const [
                                  Icon(Icons.cloud_upload_outlined, size: 30, color: Color(0xFF5B58EB)),
                                  SizedBox(height: 6),
                                  Text(
                                    'Unggah Bukti Transfer / Struk',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Format JPG, PNG, atau Screenshot (Maks. 5MB)',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ] else ...[
                    // Role Bendahara / Staf Kasir: Toggle Tunai & Transfer
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPaymentMethod = 'TRANSFER'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedPaymentMethod == 'TRANSFER' ? const Color(0xFFF0F1FE) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedPaymentMethod == 'TRANSFER' ? const Color(0xFF5B58EB) : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 18,
                                    color: _selectedPaymentMethod == 'TRANSFER' ? const Color(0xFF5B58EB) : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Transfer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _selectedPaymentMethod == 'TRANSFER' ? const Color(0xFF5B58EB) : Colors.grey.shade700,
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
                            onTap: () => setState(() => _selectedPaymentMethod = 'CASH'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedPaymentMethod == 'CASH' ? const Color(0xFFF0F1FE) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedPaymentMethod == 'CASH' ? const Color(0xFF5B58EB) : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.point_of_sale_rounded,
                                    size: 18,
                                    color: _selectedPaymentMethod == 'CASH' ? const Color(0xFF5B58EB) : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tunai',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _selectedPaymentMethod == 'CASH' ? const Color(0xFF5B58EB) : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 6. Tombol Submit Bayar (Rounded Full-Width)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedMonths.isEmpty ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B58EB),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _selectedMonths.isEmpty ? 'Pilih Bulan Tagihan' : 'Bayar ${CurrencyFormatter.format(totalAmount)}',
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
    );
  }
}
