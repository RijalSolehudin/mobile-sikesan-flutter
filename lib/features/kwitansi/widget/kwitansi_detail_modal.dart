import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/repositories/kwitansi_repository.dart';
import '../models/kwitansi_model.dart';
import '../services/kwitansi_invoice_pdf.dart';
import 'kwitansi_card.dart';
import '../../../core/widgets/modal_scaffold_wrapper.dart';

class KwitansiDetailModal extends StatefulWidget {
  final KwitansiModel item;
  final VoidCallback? onDeleted;
  final Function(KwitansiModel)? onUpdated;

  const KwitansiDetailModal({
    super.key,
    required this.item,
    this.onDeleted,
    this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required KwitansiModel item,
    VoidCallback? onDeleted,
    Function(KwitansiModel)? onUpdated,
  }) {
    return showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ModalScaffoldWrapper(
        child: KwitansiDetailModal(
          item: item,
          onDeleted: onDeleted,
          onUpdated: onUpdated,
        ),
      ),
    );
  }

  @override
  State<KwitansiDetailModal> createState() => _KwitansiDetailModalState();
}

class _KwitansiDetailModalState extends State<KwitansiDetailModal> {
  late KwitansiModel _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    // Ambil versi terbaru dari server (mis. data penandatangan terkini).
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDetail());
  }

  Future<void> _handlePrint(BuildContext context) async {
    try {
      await KwitansiInvoicePdf.printInvoice(_currentItem);
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Gagal mencetak invoice');
      }
    }
  }

  Future<void> _handleDownload() async {
    try {
      await KwitansiInvoicePdf.shareInvoice(_currentItem);
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(context, 'Gagal mengunduh invoice PDF');
      }
    }
  }

  Future<void> _handleWhatsApp() async {
    final rawPhone = _currentItem.whatsappNumber?.trim() ?? '';
    String phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }
    if (phone.isEmpty) {
      AppSnackBar.showError(context, 'Nomor WhatsApp tidak valid');
      return;
    }

    final message =
        '''Assalamualaikum Wr. Wb.
Berikut konfirmasi kwitansi pembayaran digital SIKESAN:

*No. Invoice:* ${_currentItem.receiptNumber}
*Tanggal:* ${_currentItem.dateTime}
*Nama Penerima:* ${_currentItem.recipientName}
*Total:* ${_currentItem.formattedAmount} (${_currentItem.spelledAmount})
*Kategori:* ${_currentItem.category}
*Metode:* ${_currentItem.paymentMethod}
*Status:* ${_currentItem.status}

Terima kasih atas pembayaran Anda.
Wassalamu'alaikum Wr. Wb.
_SIKESAN Digital_''';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppSnackBar.showInfo(context, 'Membuka WhatsApp ke $phone...');
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Pesan kwitansi berhasil disiapkan untuk $phone',
        );
      }
    }
  }

  Future<void> _refreshDetail() async {
    if (_currentItem.id.isEmpty) return;
    final result = await context.read<KwitansiRepository>().getDetail(
      _currentItem.id,
    );
    if (!mounted) return;
    if (result is ApiSuccess<KwitansiModel>) {
      setState(() => _currentItem = result.data);
    }
  }

  void _handleEdit() {
    final repository = context.read<KwitansiRepository>();
    final isSingleItem = _currentItem.items.length <= 1;
    final firstItem = _currentItem.items.isNotEmpty
        ? _currentItem.items.first
        : null;

    final nameCtrl = TextEditingController(text: _currentItem.recipientName);
    final amountCtrl = TextEditingController(
      text: CurrencyFormatter.formatWithoutSymbol(
        firstItem?.price ?? _currentItem.amount,
      ),
    );
    final detailCtrl = TextEditingController(
      text: firstItem?.description ?? _currentItem.displayItemDetail,
    );
    String selectedMethod = _currentItem.paymentMethod;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) => ModalScaffoldWrapper(
        child: StatefulBuilder(
          builder: (context, setModalState) {
          Future<void> save() async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) {
              AppSnackBar.showError(context, 'Nama penerima wajib diisi');
              return;
            }

            var items = _currentItem.items;
            if (isSingleItem) {
              final newPrice = CurrencyFormatter.parseClean(amountCtrl.text);
              if (newPrice <= 0) {
                AppSnackBar.showError(context, 'Nominal harus lebih dari 0');
                return;
              }
              items = [
                KwitansiItemDetail(
                  id: firstItem?.id,
                  description: detailCtrl.text.trim().isEmpty
                      ? 'Item Pembayaran'
                      : detailCtrl.text.trim(),
                  qty: firstItem?.qty ?? 1,
                  price: newPrice,
                ),
              ];
            }

            final request = KwitansiRequest.fromModel(_currentItem).copyWith(
              recipientName: name,
              paymentMethod: selectedMethod,
              items: items,
            );

            setModalState(() => isSaving = true);
            final result = await repository.update(_currentItem.id, request);
            if (!bContext.mounted) return;
            setModalState(() => isSaving = false);

            switch (result) {
              case ApiSuccess(data: final updated):
                if (mounted) setState(() => _currentItem = updated);
                widget.onUpdated?.call(updated);
                Navigator.of(bContext).pop();
                if (mounted) {
                  AppSnackBar.showSuccess(
                    this.context,
                    'Kwitansi berhasil diperbarui',
                  );
                }
              case ApiFailure(message: final message):
                AppSnackBar.showError(context, message);
            }
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      'Edit Kwitansi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Penerima',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isSingleItem) ...[
                      TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Nominal (Rp)',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: detailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Detail Item',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else ...[
                      Text(
                        'Kwitansi ini berisi ${_currentItem.items.length} item. '
                        'Nominal & detail item tidak dapat diubah dari sini.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: const InputDecoration(
                        labelText: 'Metode Pembayaran',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items:
                          {'Transfer', 'Tunai', 'Saldo Santri', selectedMethod}
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B074),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSaving ? null : save,
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Simpan Perubahan',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ));
  }

  void _handleDelete() {
    final repository = context.read<KwitansiRepository>();
    bool isDeleting = false;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dContext) => ModalScaffoldWrapper(
        child: StatefulBuilder(
          builder: (dContext, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Hapus Kwitansi?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          content: Text(
            'Apakah Anda yakin ingin menghapus kwitansi ${_currentItem.receiptNumber}? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.of(dContext).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      final result = await repository.delete(_currentItem.id);
                      if (!dContext.mounted) return;

                      switch (result) {
                        case ApiSuccess():
                          final receiptNumber = _currentItem.receiptNumber;
                          Navigator.of(dContext).pop(); // pop confirm dialog
                          if (mounted) {
                            Navigator.of(context).pop(); // pop detail modal
                            AppSnackBar.showSuccess(
                              context,
                              'Kwitansi $receiptNumber telah dihapus',
                            );
                          }
                          widget.onDeleted?.call();
                        case ApiFailure(message: final message):
                          setDialogState(() => isDeleting = false);
                          AppSnackBar.showError(dContext, message);
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Hapus',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390, maxHeight: 660),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Top Green Header Card
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B074),
                    borderRadius: BorderRadius.all(Radius.circular(26)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Close button on top-right
                      Align(
                        alignment: Alignment.topRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Center Header Content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Document/Receipt Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Invoice Number
                          Text(
                            _currentItem.receiptNumber,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Timestamp
                          Text(
                            _currentItem.dateTime,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Category Badge (e.g. Pondok)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _currentItem.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Scrollable Body Content
                Flexible(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 3.5,
                    radius: const Radius.circular(8),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Kwitansi Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'TOTAL KWITANSI',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _currentItem.formattedAmount,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF00895E),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Row: Terima Dari
                          _buildDetailRow(
                            'Terima Dari',
                            _currentItem.recipientName,
                            isBoldValue: true,
                          ),
                          const SizedBox(height: 10),
                          const DashedLineDivider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),

                          // Row: Uang Sebesar
                          _buildDetailRow(
                            'Uang Sebesar',
                            _currentItem.spelledAmount,
                            isItalicValue: true,
                          ),
                          const SizedBox(height: 10),
                          const DashedLineDivider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),

                          // Detail Item
                          Text(
                            'Detail Item',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _currentItem.displayItemDetail,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF334155),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _currentItem.formattedAmount,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_currentItem.email != null &&
                              _currentItem.email!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const DashedLineDivider(color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              'Email',
                              _currentItem.email!,
                              isBoldValue: true,
                            ),
                          ],
                          if (_currentItem.address != null &&
                              _currentItem.address!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const DashedLineDivider(color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 10),
                            _buildDetailRow('Alamat', _currentItem.address!),
                          ],
                          const SizedBox(height: 10),
                          const DashedLineDivider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),

                          // Metode Pembayaran
                          _buildDetailRow(
                            'Metode Pembayaran',
                            _currentItem.paymentMethod,
                            isBoldValue: true,
                          ),
                          const SizedBox(height: 10),
                          const DashedLineDivider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),

                          // Hormat Kami
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hormat Kami',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currentItem.signerName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentItem.signerRole,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const DashedLineDivider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 8),

                          // Signature Box Watermark
                          Center(
                            child: Container(
                              width: 66,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Icon(
                                Icons.verified_outlined,
                                size: 20,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Bottom Action Buttons (2x2 Grid or 3+2 with WhatsApp)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      // Row 1: Unduh PDF & Print (& WhatsApp if available)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: _handleDownload,
                                icon: const Icon(
                                  Icons.download_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Unduh PDF',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00B074),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: () => _handlePrint(context),
                                icon: const Icon(
                                  Icons.print_rounded,
                                  size: 15,
                                  color: Color(0xFF0F172A),
                                ),
                                label: Text(
                                  'Print',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_currentItem.whatsappNumber != null &&
                              _currentItem.whatsappNumber!
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: OutlinedButton.icon(
                                  onPressed: _handleWhatsApp,
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 15,
                                    color: Color(0xFF16A34A),
                                  ),
                                  label: Text(
                                    'WhatsApp',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF0FDF4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF86EFAC),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: Edit & Hapus
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: _handleEdit,
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Color(0xFF0F172A),
                                ),
                                label: Text(
                                  'Edit',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: _handleDelete,
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  size: 16,
                                  color: Color(0xFFEF4444),
                                ),
                                label: Text(
                                  'Hapus',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  side: const BorderSide(
                                    color: Color(0xFFFECACA),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBoldValue = false,
    bool isItalicValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isItalicValue ? 12 : 13,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
              fontStyle: isItalicValue ? FontStyle.italic : FontStyle.normal,
              color: isItalicValue
                  ? const Color(0xFF334155)
                  : (isBoldValue
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155)),
            ),
          ),
        ),
      ],
    );
  }
}
