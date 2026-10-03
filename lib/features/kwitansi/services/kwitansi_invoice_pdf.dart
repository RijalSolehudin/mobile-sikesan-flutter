import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/currency_formatter.dart';
import '../models/kwitansi_model.dart';

/// Generates the A4 "INVOICE" document for Kwitansi Digital.
///
/// Layout is positioned absolutely (A4 = 595 x 842 pt) so it matches the
/// reference design pixel-for-pixel: teal header block on the top-left,
/// SIKESAN wallet logo on the top-right, pill-shaped table header,
/// total section, signature, notes and the bottom-right teal accent.
class KwitansiInvoicePdf {
  KwitansiInvoicePdf._();

  static final PdfColor _teal = PdfColor.fromHex('#0E7E7A');
  static final PdfColor _textDark = PdfColor.fromHex('#1F1F1F');
  static final PdfColor _textNote = PdfColor.fromHex('#4A4A4A');

  static const String _tealHex = '#0E7E7A';
  static const String _defaultContact = '088218712525';
  static const String _noteText =
      'Kwitansi/invoice ini adalah bukti pembayaran yang sah diterbitkan '
      'oleh sistem administrasi Yayasan. Terima kasih atas kepercayaan Anda.';

  static const List<String> _months = [
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
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static String fileName(KwitansiModel item) =>
      'Invoice_${item.receiptNumber.replaceAll('/', '_')}';

  static Future<Uint8List> generate(KwitansiModel item) async {
    final doc = pw.Document(
      title: 'Invoice ${item.receiptNumber}',
      author: 'SIKESAN',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildPage(item),
      ),
    );

    return doc.save();
  }

  static Future<void> printInvoice(KwitansiModel item) async {
    final bytes = await generate(item);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: fileName(item),
      format: PdfPageFormat.a4,
    );
  }

  static Future<void> shareInvoice(KwitansiModel item) async {
    final bytes = await generate(item);
    await Printing.sharePdf(bytes: bytes, filename: '${fileName(item)}.pdf');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _rp(num value) =>
      'Rp${CurrencyFormatter.formatWithoutSymbol(value)}';

  static String _orDash(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  /// Converts `dd/MM/yyyy HH:mm` into `d MMMM yyyy` (Indonesian month name).
  static String _formatDate(String raw) {
    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(raw);
    if (match == null) return raw;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = match.group(3)!;
    if (month < 1 || month > 12) return raw;
    return '$day ${_months[month - 1]} $year';
  }

  static List<KwitansiItemDetail> _resolveItems(KwitansiModel item) {
    if (item.items.isNotEmpty) return item.items;
    final title = (item.note ?? item.category).trim();
    return [KwitansiItemDetail(description: title, qty: 1, price: item.amount)];
  }

  static pw.Widget _svgIcon(String path, {double size = 12}) {
    return pw.SvgImage(
      svg:
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path fill="$_tealHex" d="$path"/></svg>',
      width: size,
      height: size,
    );
  }

  static pw.Widget _at({
    required double left,
    required double top,
    required pw.Widget child,
    double? width,
  }) {
    return pw.Positioned(
      left: left,
      top: top,
      child: width != null ? pw.SizedBox(width: width, child: child) : child,
    );
  }

  /// Places [text] horizontally centred on [centerX].
  static pw.Widget _centered(
    double centerX,
    double top,
    String text,
    pw.TextStyle style, {
    double width = 90,
  }) {
    return _at(
      left: centerX - width / 2,
      top: top,
      width: width,
      child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
    );
  }

  // ---------------------------------------------------------------------------
  // Page
  // ---------------------------------------------------------------------------

  static pw.Widget _buildPage(KwitansiModel item) {
    final pageW = PdfPageFormat.a4.width;
    final pageH = PdfPageFormat.a4.height;
    final items = _resolveItems(item);
    final total = items.fold<num>(0, (sum, e) => sum + e.total);
    final grandTotal = total > 0 ? total : item.amount;

    final white = PdfColors.white;
    final rowStyle = pw.TextStyle(fontSize: 9.5, color: _textDark);
    final rowBold = rowStyle.copyWith(fontWeight: pw.FontWeight.bold);
    final headerCell = pw.TextStyle(
      fontSize: 9.5,
      fontWeight: pw.FontWeight.bold,
      color: white,
    );
    final sectionTitle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: _teal,
    );
    final infoLabel = pw.TextStyle(fontSize: 9.5, color: _textDark);

    // Table geometry
    const double colNo = 78;
    const double colDesc = 101;
    const double colQty = 334;
    const double colHarga = 405;
    const double colTotal = 495;
    const double firstRowTop = 397;
    const double rowHeight = 24;

    final tableRows = <pw.Widget>[];
    for (var i = 0; i < items.length; i++) {
      final e = items[i];
      final top = firstRowTop + i * rowHeight;
      tableRows.addAll([
        _centered(colNo, top, '${i + 1}', rowStyle, width: 30),
        _at(
          left: colDesc,
          top: top,
          width: 200,
          child: pw.Text(e.description, style: rowBold, maxLines: 2),
        ),
        _centered(colQty, top, '${e.qty}', rowStyle, width: 40),
        _centered(colHarga, top, _rp(e.price), rowStyle),
        _centered(colTotal, top, _rp(e.total), rowStyle),
      ]);
    }

    return pw.SizedBox(
      width: pageW,
      height: pageH,
      child: pw.Stack(
        children: [
          // ── Header teal block ────────────────────────────────────────────
          pw.Positioned(
            left: 0,
            top: 18,
            child: pw.Container(
              width: 347,
              height: 184,
              decoration: pw.BoxDecoration(
                color: _teal,
                borderRadius: const pw.BorderRadius.only(
                  bottomRight: pw.Radius.circular(66),
                ),
              ),
            ),
          ),
          _at(
            left: 35,
            top: 52,
            child: pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 40,
                fontWeight: pw.FontWeight.bold,
                color: white,
                letterSpacing: 1.6,
              ),
            ),
          ),
          _at(
            left: 35,
            top: 109,
            width: 300,
            child: pw.Text(
              'No. ${item.receiptNumber}',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: white,
              ),
            ),
          ),
          _at(
            left: 35,
            top: 129,
            width: 300,
            child: pw.Text(
              'Date. ${_formatDate(item.dateTime)}',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: white,
              ),
            ),
          ),
          _at(
            left: 35,
            top: 154,
            child: pw.Container(width: 27, height: 1.6, color: white),
          ),

          // ── Logo ─────────────────────────────────────────────────────────
          _at(left: 399, top: 57, child: _walletLogo()),
          _at(
            left: 454,
            top: 56,
            child: pw.Text(
              'SIKESAN',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
              ),
            ),
          ),
          _at(
            left: 455,
            top: 84,
            child: pw.Text(
              'Sistem   Keuangan   Santri',
              style: pw.TextStyle(fontSize: 8.5, color: _textDark),
            ),
          ),

          // ── Diberikan kepada ─────────────────────────────────────────────
          _at(
            left: 35,
            top: 227,
            child: pw.Text('Diberikan kepada:', style: sectionTitle),
          ),
          ..._infoRow(
            top: 257,
            icon: _Icons.person,
            label: 'Nama',
            value: item.recipientName,
            style: infoLabel,
          ),
          ..._infoRow(
            top: 279,
            icon: _Icons.whatsapp,
            label: 'WA',
            value: _orDash(item.whatsappNumber),
            style: infoLabel,
          ),
          ..._infoRow(
            top: 301,
            icon: _Icons.email,
            label: 'Alamat',
            value: _orDash(item.address),
            style: infoLabel,
          ),

          // ── Metode Pembayaran ────────────────────────────────────────────
          _at(
            left: 338,
            top: 227,
            child: pw.Text('Metode Pembayaran:', style: sectionTitle),
          ),
          _at(left: 339, top: 257, child: _svgIcon(_Icons.bank, size: 14)),
          _at(
            left: 366,
            top: 258,
            child: pw.Text(item.paymentMethod, style: infoLabel),
          ),

          // ── Table header (pill) ──────────────────────────────────────────
          pw.Positioned(
            left: 35,
            top: 342,
            child: pw.Container(
              width: 528,
              height: 34,
              decoration: pw.BoxDecoration(
                color: _teal,
                borderRadius: pw.BorderRadius.circular(17),
              ),
            ),
          ),
          _centered(colNo, 353, 'No.', headerCell, width: 40),
          _at(
            left: colDesc,
            top: 353,
            child: pw.Text('DESKRIPSI ITEM', style: headerCell),
          ),
          _centered(colQty, 353, 'QTY', headerCell, width: 40),
          _centered(colHarga, 353, 'HARGA', headerCell),
          _centered(colTotal, 353, 'TOTAL', headerCell),

          // ── Table rows ───────────────────────────────────────────────────
          ...tableRows,

          // ── Total ────────────────────────────────────────────────────────
          _at(
            left: 298,
            top: 544,
            child: pw.Container(width: 265, height: 1.5, color: _teal),
          ),
          _at(
            left: 321,
            top: 560,
            child: pw.Text(
              'Total Keseluruhan',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
              ),
            ),
          ),
          _at(
            left: 468,
            top: 558,
            width: 95,
            child: pw.Text(
              _rp(grandTotal),
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
              ),
            ),
          ),

          // ── Signature ────────────────────────────────────────────────────
          _at(
            left: 35,
            top: 606,
            child: pw.Text('Hormat Kami,', style: rowStyle),
          ),
          _at(
            left: 35,
            top: 624,
            child: pw.Text(
              item.signerRole,
              style: pw.TextStyle(
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
          ),
          _at(
            left: 35,
            top: 662,
            width: 230,
            child: pw.Text(
              item.signerName,
              style: pw.TextStyle(
                fontSize: 12.5,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
          ),
          _at(
            left: 35,
            top: 683,
            child: pw.Container(width: 178, height: 1, color: _textDark),
          ),

          // ── Kontak Kami ──────────────────────────────────────────────────
          _at(
            left: 35,
            top: 709,
            child: pw.Text(
              'Kontak Kami:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
              ),
            ),
          ),
          _at(left: 35, top: 730, child: _svgIcon(_Icons.whatsapp, size: 12)),
          _at(
            left: 54,
            top: 731,
            child: pw.Text(
              _orDash(item.contact) == '-'
                  ? _defaultContact
                  : item.contact!.trim(),
              style: rowBold,
            ),
          ),

          // ── Catatan ──────────────────────────────────────────────────────
          _at(
            left: 316,
            top: 585,
            child: pw.Text('Catatan :', style: sectionTitle),
          ),
          _at(
            left: 316,
            top: 635,
            width: 210,
            child: pw.Text(
              _noteText,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _textNote,
                lineSpacing: 6,
              ),
            ),
          ),

          // ── Terima Kasih ─────────────────────────────────────────────────
          pw.Positioned(
            left: 316,
            bottom: 70,
            child: pw.Text(
              'TERIMA KASIH',
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
                letterSpacing: 0.6,
              ),
            ),
          ),

          // ── Bottom-right accent ──────────────────────────────────────────
          pw.Positioned(
            right: 0,
            bottom: 0,
            child: pw.Container(
              width: 177,
              height: 45,
              decoration: pw.BoxDecoration(
                color: _teal,
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _infoRow({
    required double top,
    required String icon,
    required String label,
    required String value,
    required pw.TextStyle style,
  }) {
    return [
      _at(left: 35, top: top, child: _svgIcon(icon, size: 12)),
      _at(
        left: 57,
        top: top + 1,
        child: pw.Text(label, style: style),
      ),
      _at(
        left: 101,
        top: top + 1,
        width: 200,
        child: pw.Text(': $value', style: style, maxLines: 1),
      ),
    ];
  }

  /// Teal wallet with cards peeking out – mirrors the SIKESAN mark in the
  /// reference design.
  static pw.Widget _walletLogo() {
    const svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 42">
  <rect x="9" y="1" width="24" height="17" rx="2" fill="#9ED6CF"/>
  <rect x="15" y="3" width="24" height="15" rx="2" fill="#E3F3F0"/>
  <rect x="17.5" y="6" width="12" height="1.6" rx="0.8" fill="#9ED6CF"/>
  <rect x="1" y="10" width="44" height="31" rx="5" fill="#1B918D"/>
  <rect x="1" y="10" width="44" height="7" rx="3.5" fill="#0E7E7A"/>
  <rect x="31" y="20" width="16" height="12" rx="3" fill="#0F6765"/>
  <circle cx="37" cy="26" r="2.2" fill="#E3F3F0"/>
</svg>
''';
    return pw.SvgImage(svg: svg, width: 46, height: 40);
  }
}

/// Material / brand icon paths (24x24 viewBox).
class _Icons {
  static const person =
      'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z'
      'm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3z'
      'm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z';

  static const email =
      'M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6'
      'c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z';

  static const bank =
      'M4 10v7h3v-7H4zm6 0v7h3v-7h-3zM2 22h19v-3H2v3zm14-12v7h3v-7h-3z'
      'm-4.5-9L2 6v2h19V6l-9.5-5z';

  static const whatsapp =
      'M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15'
      '-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463'
      '-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606'
      '.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025'
      '-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008'
      '-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 '
      '0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 '
      '1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006'
      '-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z'
      'M12.051 21.785h-.004a9.87 9.87 0 0 1 -5.031 -1.378l-.361-.214-3.741.982'
      '.998-3.648-.235-.374a9.86 9.86 0 0 1 -1.51 -5.26c.001-5.45 4.436-9.884 '
      '9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994'
      'c-.003 5.45-4.437 9.884-9.885 9.884z'
      'M20.464 3.488A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892'
      'c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 '
      '5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0 '
      '-3.48 -8.413z';
}
