import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/spp_models.dart';

class ReceiptPdfService {
  static Future<Uint8List> generateReceiptPdf(SppReceiptModel receipt) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Pesantren
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PONDOK PESANTREN SIKESAN',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#10B981'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Sistem Keuangan Santri Terintegrasi',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Jl. Pesantren Luhur No. 1, Jawa Barat • Telp: (021) 8899-7711',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: receipt.status.toUpperCase() == 'APPROVED'
                          ? PdfColor.fromHex('#ECFDF5')
                          : PdfColor.fromHex('#FEF3C7'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(
                        color: receipt.status.toUpperCase() == 'APPROVED'
                            ? PdfColor.fromHex('#10B981')
                            : PdfColor.fromHex('#F59E0B'),
                      ),
                    ),
                    child: pw.Text(
                      receipt.status.toUpperCase() == 'APPROVED' ? 'LUNAS' : 'MENUNGGU VERIFIKASI',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: receipt.status.toUpperCase() == 'APPROVED'
                            ? PdfColor.fromHex('#047857')
                            : PdfColor.fromHex('#B45309'),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#10B981')),
              pw.SizedBox(height: 12),

              // Title Bukti Pembayaran
              pw.Center(
                child: pw.Text(
                  'KWITANSI PEMBAYARAN SPP',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, letterSpacing: 1.1),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  receipt.receiptNumber,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 20),

              // Informasi Pembayaran & Santri
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Nama Santri', receipt.studentName),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('NIS Santri', receipt.studentNis),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('Kelas / Tingkat', receipt.studentClass),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('Wali Santri', receipt.guardianName),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Tanggal Bayar', receipt.paymentDate),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('Waktu Transaksi', receipt.paymentTime),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('Metode Pembayaran', receipt.paymentMethod.toUpperCase()),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('ID Referensi', receipt.paymentId.isNotEmpty ? receipt.paymentId : '-'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Tabel Rincian Tagihan
              pw.Text(
                'Rincian Bulan Tagihan:',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Keterangan Tagihan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Periode', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Nominal', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  ...receipt.bills.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('SPP Santri - ${item.monthName}', style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('${item.monthName} ${item.year}', style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(currencyFormatter.format(item.amount), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 12),

              // Total Amount
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F0F1FE'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#C7D2FE')),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Bayar:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                          currencyFormatter.format(receipt.totalPaidAmount),
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#5B58EB'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Wali Santri,', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 45),
                      pw.Text('( ${receipt.guardianName} )', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Bendahara Pesantren,', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 45),
                      pw.Text('( Bagian Keuangan SIKESAN )', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Dokumen ini dicetak otomatis oleh Aplikasi Mobile SIKESAN dan diakui sah.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
        ),
        pw.Text(': ', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700)),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static Future<void> printReceipt(SppReceiptModel receipt) async {
    final pdfBytes = await generateReceiptPdf(receipt);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Kwitansi_SPP_${receipt.receiptNumber}',
    );
  }

  static Future<void> downloadReceipt(SppReceiptModel receipt) async {
    final pdfBytes = await generateReceiptPdf(receipt);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Kwitansi_SPP_${receipt.receiptNumber}.pdf',
    );
  }
}
