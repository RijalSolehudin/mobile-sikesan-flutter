import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_upload_helper.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/transaction_security_sheet.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/repositories/spp_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../bloc/spp_payment_bloc.dart';
import '../utils/spp_fifo_helper.dart';
import 'receipt_preview_modal.dart';
import 'spp_bill_summary_card.dart';
import 'spp_month_grid_selector.dart';
import 'spp_payment_method_section.dart';
import 'spp_student_selector.dart';
import 'spp_submit_button.dart';
import 'spp_year_selector.dart';

/// Modal Transaksi Pembayaran SPP Bulanan Santri
/// Telah direfaktor modular sesuai TASK-CONC-02 (dekomposisi god modal & arsitektur BLoC)
class PaySppModal extends StatefulWidget {
  const PaySppModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaySppModal(),
    );
  }

  @override
  State<PaySppModal> createState() => _PaySppModalState();
}

class _PaySppModalState extends State<PaySppModal> {
  int? _selectedStudentId;
  String _selectedStudentName = '';
  int _selectedYear = DateTime.now().year;
  final List<int> _availableYears = [
    DateTime.now().year - 1,
    DateTime.now().year,
    DateTime.now().year + 1,
  ];

  final Set<int> _selectedMonths = {};
  List<SppBillModel> _bills = [];
  bool _isLoadingBills = false;
  bool _isSubmitting = false;

  String _selectedPaymentMethod = 'TRANSFER';
  Uint8List? _proofBytes;
  String? _proofFilename;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearchingStudent = false;
  List<StudentLookupModel> _searchedStudents = [];
  Timer? _searchDebounce;

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
        final firstStudent = dashboardStudents.first;
        _selectStudent(firstStudent.id, firstStudent.name);
      }
    }
  }

  void _selectStudent(int studentId, String studentName) {
    setState(() {
      _selectedStudentId = studentId;
      _selectedStudentName = studentName;
      _selectedMonths.clear();
      _searchedStudents.clear();
      _searchController.text = studentName;
    });
    _loadBillsForStudent(studentId, year: _selectedYear);
  }

  Future<void> _loadBillsForStudent(int studentId, {int? year}) async {
    setState(() => _isLoadingBills = true);
    final sppRepo = RepositoryProvider.of<SppRepository>(context);
    final result = await sppRepo.getStudentBills(
      studentId,
      year: year ?? _selectedYear,
    );

    if (!mounted) return;
    setState(() {
      _isLoadingBills = false;
      if (result is ApiSuccess<List<SppBillModel>>) {
        _bills = result.data;
      } else {
        _bills = [];
      }
    });
  }

  void _onMonthTapped(int monthNumber) {
    final unpaidMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].where((m) {
      final b = _bills.firstWhere(
        (bill) => bill.periodMonth == m && bill.periodYear == _selectedYear,
        orElse: () => SppBillModel(
          id: '',
          studentId: _selectedStudentId ?? 0,
          periodMonth: m,
          periodYear: _selectedYear,
          amountBilled: 750000,
          status: 'UNPAID',
        ),
      );
      return !b.isPaid;
    }).toList();

    setState(() {
      final updated = SppFifoHelper.computeFifoSelection(
        currentSelection: _selectedMonths,
        tappedMonth: monthNumber,
        unpaidMonthsSorted: unpaidMonths,
      );
      _selectedMonths.clear();
      _selectedMonths.addAll(updated);
    });
  }

  void _searchGlobalStudents(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchedStudents = []);
      return;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isSearchingStudent = true);
      final sppRepo = RepositoryProvider.of<SppRepository>(context);
      final result = await sppRepo.getStudents(search: query.trim());
      if (!mounted) return;
      setState(() {
        _isSearchingStudent = false;
        if (result is ApiSuccess<List<StudentLookupModel>>) {
          _searchedStudents = result.data;
        }
      });
    });
  }

  void _copyToClipboard(String text, String bankName) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.showSuccess(
      context,
      'Nomor rekening $bankName berhasil disalin',
    );
  }

  void _showQrisDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'QRIS Pesantren SIKESAN',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 200,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pindai QRIS ini melalui aplikasi BCA, Mandiri, GoPay, OVO, atau ShopeePay.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Ambil Foto Kamera'),
              onTap: () {
                Navigator.pop(ctx);
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
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await ImageUploadHelper.pickImageWithCompression(
      ImagePicker(),
      source: source,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final filename = file.name;
      setState(() {
        _proofBytes = bytes;
        _proofFilename = filename;
      });
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedStudentId == null) {
      _showError('Pilih santri terlebih dahulu.');
      return;
    }
    if (_selectedMonths.isEmpty) {
      _showError('Pilih setidaknya satu bulan tagihan.');
      return;
    }

    final userRole = context.read<AuthBloc>().state.user?.role ?? 'Wali Santri';
    final isGuardian = userRole.toLowerCase().contains('wali');

    if (isGuardian && _proofBytes == null) {
      _showError('Harap unggah bukti transfer pembayaran terlebih dahulu.');
      return;
    }

    final selectedBills = _bills
        .where((b) => _selectedMonths.contains(b.periodMonth))
        .toList();
    final billIds = selectedBills.map((b) => b.id).toList();

    if (billIds.isEmpty || billIds.length != _selectedMonths.length) {
      _showError(
        'Tagihan SPP untuk periode yang dipilih belum diterbitkan oleh pesantren.',
      );
      return;
    }

    final num total = selectedBills.fold<num>(
      0,
      (sum, b) => sum + b.amountBilled,
    );

    // Otentikasi Lapis Kedua (TASK-CONC-15)
    final isAuthorized = await TransactionSecurityHelper.authorizeTransaction(
      context: context,
      actionTitle: 'Bayar Tagihan SPP',
      formattedAmount: CurrencyFormatter.formatRupiah(total),
      subtitle: 'Santri: $_selectedStudentName (${selectedBills.length} Bulan)',
    );

    if (!isAuthorized) {
      if (mounted) {
        _showError('Otorisasi keamanan transaksi dibatalkan.');
      }
      return;
    }

    setState(() => _isSubmitting = true);

    if (!mounted) return;
    final paymentBloc = context.read<SppPaymentBloc>();
    if (!isGuardian && _selectedPaymentMethod == 'CASH') {
      paymentBloc.add(
        SppPaymentEvent.submitCash(
          studentId: _selectedStudentId!,
          billIds: billIds,
          totalAmount: total,
        ),
      );
    } else {
      paymentBloc.add(
        SppPaymentEvent.submitTransfer(
          studentId: _selectedStudentId!,
          billIds: billIds,
          totalAmount: total,
          proofBytes: _proofBytes ?? [],
          proofFilename: _proofFilename ?? 'proof.jpg',
        ),
      );
    }
  }

  void _showError(String msg) {
    AppSnackBar.showError(context, msg);
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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

    final num rate = _bills.isNotEmpty ? _bills.first.amountBilled : 750000;
    final num totalAmount = _selectedMonths.length * rate;
    final bankAccounts = BankAccountModel.defaultAccounts();

    return BlocListener<SppPaymentBloc, SppPaymentState>(
      listener: (context, paymentState) {
        paymentState.whenOrNull(
          success: (paymentId, message) async {
            setState(() => _isSubmitting = false);
            final navigator = Navigator.of(context);
            final parentContext = navigator.context;
            final sppRepo = RepositoryProvider.of<SppRepository>(context);
            final sppPaymentBloc = context.read<SppPaymentBloc>();
            final dashboardBloc = context.read<DashboardBloc>();

            // Refresh dashboard metrics
            dashboardBloc.add(DashboardRefreshRequested(role: userRole));

            await _showSuccessAnimation();
            navigator.pop();

            // Reset payment state for future transactions
            sppPaymentBloc.add(const SppPaymentEvent.reset());

            final receiptResult = await sppRepo.getReceipt(paymentId);
            if (!parentContext.mounted) return;

            if (receiptResult is ApiSuccess<SppReceiptModel>) {
              ReceiptPreviewModal.show(parentContext, receiptResult.data);
            }
          },
          failure: (message) {
            setState(() => _isSubmitting = false);
            _showError(message);
          },
        );
      },
      child: Center(
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
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SppStudentSelector(
                          isGuardian: isGuardian,
                          dashboardStudents: dashboardStudents,
                          selectedStudentId: _selectedStudentId,
                          onSelectGuardianStudent: (st) =>
                              _selectStudent(st.id, st.name),
                          searchController: _searchController,
                          isSearchingStudent: _isSearchingStudent,
                          searchedStudents: _searchedStudents,
                          onSearchChanged: _searchGlobalStudents,
                          onSelectLookupStudent: (st) =>
                              _selectStudent(st.id, st.name),
                        ),
                        const SizedBox(height: 16),

                        SppYearSelector(
                          selectedYear: _selectedYear,
                          availableYears: _availableYears,
                          onYearChanged: (newYear) {
                            setState(() {
                              _selectedYear = newYear;
                              _selectedMonths.clear();
                            });
                            if (_selectedStudentId != null) {
                              _loadBillsForStudent(
                                _selectedStudentId!,
                                year: newYear,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        SppMonthGridSelector(
                          selectedYear: _selectedYear,
                          selectedStudentId: _selectedStudentId,
                          selectedMonths: _selectedMonths,
                          bills: _bills,
                          isLoadingBills: _isLoadingBills,
                          onMonthTapped: _onMonthTapped,
                        ),
                        const SizedBox(height: 14),

                        SppBillSummaryCard(
                          selectedMonthsCount: _selectedMonths.length,
                          rate: rate,
                          totalAmount: totalAmount,
                        ),
                        const SizedBox(height: 16),

                        SppPaymentMethodSection(
                          isGuardian: isGuardian,
                          selectedPaymentMethod: _selectedPaymentMethod,
                          onPaymentMethodChanged: (method) =>
                              setState(() => _selectedPaymentMethod = method),
                          bankAccounts: bankAccounts,
                          proofBytes: _proofBytes,
                          proofFilename: _proofFilename,
                          onCopyAccount: _copyToClipboard,
                          onShowQris: _showQrisDialog,
                          onPickProof: _showImagePickerOptions,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Submit Button
                SppSubmitButton(
                  isSubmitting: _isSubmitting,
                  isEnabled: _selectedMonths.isNotEmpty,
                  totalAmount: totalAmount,
                  onSubmit: _handlePayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
