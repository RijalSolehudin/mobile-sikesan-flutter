import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/modal_scaffold_wrapper.dart';
import '../../../data/models/spp_models.dart';
import '../../../data/models/transaction_item_model.dart';
import '../../spp/widget/receipt_preview_modal.dart';

class TransactionDetailModal extends StatelessWidget {
  final TransactionItemModel tx;

  const TransactionDetailModal({super.key, required this.tx});

  static Future<void> show(BuildContext context, TransactionItemModel tx) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalScaffoldWrapper(
        child: TransactionDetailModal(tx: tx),
      ),
    );
  }

  void _handleCopyId(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.showSuccess(context, 'Nomor transaksi berhasil disalin');
  }

  void _handlePreviewReceipt(BuildContext context) {
    if (tx.receipt != null) {
      ReceiptPreviewModal.show(context, tx.receipt!);
      return;
    }

    // Bangun receipt model dari data transaksi
    final receipt = SppReceiptModel(
      receiptNumber: tx.transactionNumber ?? 'KW-${tx.id.substring(0, tx.id.length > 8 ? 8 : tx.id.length)}',
      paymentId: tx.id,
      paymentDate: DateFormatter.formatDateOnly(tx.date),
      paymentTime: DateFormatter.formatTimeOnly(tx.date),
      totalPaidAmount: tx.amount,
      paymentMethod: tx.paymentMethod ?? (tx.category.contains('Transfer') ? 'TRANSFER' : 'CASH'),
      status: 'APPROVED',
      studentName: tx.studentName ?? 'Santri',
      studentNis: tx.studentNis ?? '-',
      studentClass: tx.studentClass ?? '-',
      guardianName: 'Wali Santri',
      bills: [
        SppReceiptBillItem(
          month: tx.date.month,
          monthName: const [
            'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
            'Juni',
            'Juli',
            'Agustus',
            'September',
            'Oktober',
            'November',
            'Desember',
          ][(tx.date.month - 1).clamp(0, 11)],
          year: tx.date.year,
          amount: tx.amount,
        ),
      ],
    );

    ReceiptPreviewModal.show(context, receipt);
  }

  void _showProofImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ModalScaffoldWrapper(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bukti Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 450),
                  child: InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text(
                          'Gagal memuat gambar bukti',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = tx.isPending;
    final isPaid = tx.isPaidOrSuccess;
    final isRejected = tx.isRejectedOrFailed;

    // Status colors
    final Color statusBg = isPending
        ? const Color(0xFFFEF3C7)
        : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7));
    final Color statusFg = isPending
        ? const Color(0xFFD97706)
        : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF16A34A));
    final IconData statusIcon = isPending
        ? Icons.hourglass_top_rounded
        : (isRejected ? Icons.cancel_rounded : Icons.check_circle_rounded);

    final txNum = tx.transactionNumber ?? tx.id;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Handle & Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detail Transaksi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Material(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Card (Nominal & Status)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 14, color: statusFg),
                                  const SizedBox(width: 6),
                                  Text(
                                    tx.statusLabel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: statusFg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Amount
                            Text(
                              CurrencyFormatter.formatRupiah(tx.amount),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: tx.isIncome
                                    ? AppColors.primary
                                    : const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // UTC+7 Formatted Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormatter.formatFull(tx.date),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Information Grid Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              label: 'No. Transaksi',
                              customValueWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      txNum,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _handleCopyId(context, txNum),
                                    borderRadius: BorderRadius.circular(4),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 18, color: Color(0xFFF1F5F9)),
                            _buildInfoRow(
                              context,
                              label: 'Jenis Transaksi',
                              value: tx.title,
                              valueColor: const Color(0xFF1E293B),
                              isBold: true,
                            ),
                            const Divider(height: 18, color: Color(0xFFF1F5F9)),
                            _buildInfoRow(
                              context,
                              label: 'Kategori / Tipe',
                              value: tx.category,
                            ),
                            if (tx.studentName != null) ...[
                              const Divider(
                                height: 18,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildInfoRow(
                                context,
                                label: 'Nama Santri',
                                value: tx.studentName!,
                                isBold: true,
                              ),
                            ],
                            if (tx.studentNis != null ||
                                (tx.studentClass != null &&
                                    tx.studentClass!.isNotEmpty)) ...[
                              const Divider(
                                height: 18,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildInfoRow(
                                context,
                                label: 'NIS / Kelas',
                                value:
                                    '${tx.studentNis ?? '-'} · ${tx.studentClass ?? '-'}',
                              ),
                            ],
                            const Divider(height: 18, color: Color(0xFFF1F5F9)),
                            _buildInfoRow(
                              context,
                              label: 'Metode Pembayaran',
                              value: tx.paymentMethod ??
                                  (tx.category.contains('Transfer')
                                      ? 'TRANSFER BANK'
                                      : 'KASIR / TUNAI'),
                            ),
                            if (tx.senderBankName != null) ...[
                              const Divider(
                                height: 18,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildInfoRow(
                                context,
                                label: 'Bank Pengirim',
                                value: tx.senderBankName!,
                              ),
                            ],
                            if (tx.senderAccountHolder != null) ...[
                              const Divider(
                                height: 18,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildInfoRow(
                                context,
                                label: 'Atas Nama',
                                value: tx.senderAccountHolder!,
                              ),
                            ],
                            if (tx.description != null &&
                                tx.description!.isNotEmpty &&
                                tx.description != tx.title) ...[
                              const Divider(
                                height: 18,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildInfoRow(
                                context,
                                label: 'Keterangan',
                                value: tx.description!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Bukti Pembayaran / Transfer jika ada foto
                      if (tx.proofUrl != null && tx.proofUrl!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Bukti Pembayaran',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => _showProofImageDialog(
                                      context,
                                      tx.proofUrl!,
                                    ),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'Perbesar',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showProofImageDialog(
                                  context,
                                  tx.proofUrl!,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    tx.proofUrl!,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 80,
                                      color: const Color(0xFFF1F5F9),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Foto bukti tidak dapat dimuat',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // 3. Struk Preview Button (Jika sudah diverifikasi dan lunas)
                      if (isPaid) ...[
                        ElevatedButton.icon(
                          onPressed: () => _handlePreviewReceipt(context),
                          icon: const Icon(Icons.receipt_long_rounded, size: 18),
                          label: Text(
                            'Lihat Struk / Bukti Transaksi',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ] else if (isPending) ...[
                        // Notice banner untuk transaksi yang menunggu verifikasi
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Transaksi ini sedang menunggu verifikasi oleh pihak Bendahara. Struk digital resmi akan otomatis tersedia setelah pembayaran diverifikasi dan disetujui.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF92400E),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    String? value,
    Widget? customValueWidget,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        if (customValueWidget != null)
          Flexible(child: customValueWidget)
        else
          Flexible(
            child: Text(
              value ?? '-',
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? const Color(0xFF1E293B),
              ),
            ),
          ),
      ],
    );
  }
}
