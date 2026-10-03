import 'package:intl/intl.dart';

import '../../../core/utils/currency_formatter.dart';

num _toNum(dynamic value) => num.tryParse(value?.toString() ?? '') ?? 0;

String? _toNullableString(dynamic value) {
  final str = value?.toString().trim();
  return (str == null || str.isEmpty) ? null : str;
}

class KwitansiItemDetail {
  final String? id;
  final String description;
  final int qty;
  final num price;

  const KwitansiItemDetail({
    this.id,
    required this.description,
    this.qty = 1,
    required this.price,
  });

  num get total => qty * price;

  String get formattedTotal => CurrencyFormatter.format(total);

  factory KwitansiItemDetail.fromJson(Map<String, dynamic> json) {
    return KwitansiItemDetail(
      id: json['id']?.toString(),
      description: json['description']?.toString() ?? 'Item Pembayaran',
      qty: int.tryParse(json['qty']?.toString() ?? '') ?? 1,
      price: _toNum(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'qty': qty,
    'price': price,
  };
}

/// Akun (staf) yang memproses / menerbitkan kwitansi.
/// Namanya dipakai sebagai penandatangan & nomornya sebagai "Kontak Kami".
class KwitansiProcessor {
  final int? id;
  final String name;
  final String? phone;

  const KwitansiProcessor({this.id, required this.name, this.phone});

  factory KwitansiProcessor.fromJson(Map<String, dynamic> json) {
    return KwitansiProcessor(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['username']?.toString() ?? '-',
      phone: _toNullableString(json['phone']),
    );
  }
}

class KwitansiModel {
  static const String defaultSignerRole = 'Bendahara Yayasan';

  final String id;
  final String receiptNumber;
  final String recipientName;
  final int? studentId;
  final String category;
  final num amount;
  final DateTime? issuedAt;
  final String paymentMethod;
  final String status;
  final String? note;
  final String signerRole;
  final KwitansiProcessor? processedBy;
  final String? whatsappNumber;
  final String? email;
  final String? address;
  final String? attachmentUrl;
  final List<KwitansiItemDetail> items;

  const KwitansiModel({
    required this.id,
    required this.receiptNumber,
    required this.recipientName,
    this.studentId,
    required this.category,
    required this.amount,
    this.issuedAt,
    required this.paymentMethod,
    required this.status,
    this.note,
    this.signerRole = defaultSignerRole,
    this.processedBy,
    this.whatsappNumber,
    this.email,
    this.address,
    this.attachmentUrl,
    this.items = const [],
  });

  // ---------------------------------------------------------------------------
  // Derived / display getters
  // ---------------------------------------------------------------------------

  /// Nama penandatangan = nama akun yang memproses kwitansi.
  String get signerName => processedBy?.name ?? '-';

  /// Nomor kontak = nomor telepon akun yang memproses kwitansi.
  String? get contact => processedBy?.phone;

  String get formattedAmount => CurrencyFormatter.format(amount);

  /// Format tampilan `dd/MM/yyyy HH:mm` (dipakai kartu, detail & invoice).
  String get dateTime =>
      issuedAt == null ? '-' : DateFormat('dd/MM/yyyy HH:mm').format(issuedAt!);

  String get itemCountDescription =>
      '${items.isEmpty ? 1 : items.length} Item Pembayaran';

  String get displayItemDetail {
    if (items.isNotEmpty) {
      final first = items.first;
      final more = items.length > 1 ? ' +${items.length - 1} item' : '';
      return '${first.description} (${first.qty}x)$more';
    }
    return note != null && note!.isNotEmpty ? note! : category;
  }

  String get spelledAmount => numberToWords(amount);

  // ---------------------------------------------------------------------------
  // JSON mapping
  // ---------------------------------------------------------------------------

  static String _mapStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'active':
      case 'aktif':
      case '':
        return 'Aktif';
      case 'void':
      case 'cancelled':
      case 'canceled':
        return 'Dibatalkan';
      default:
        return raw!;
    }
  }

  factory KwitansiModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(KwitansiItemDetail.fromJson)
              .toList()
        : <KwitansiItemDetail>[];

    final itemsTotal = items.fold<num>(0, (sum, e) => sum + e.total);
    final total = json['total_amount'] ?? json['amount'];

    final processed = json['processed_by'] ?? json['processor'];

    return KwitansiModel(
      id: json['id']?.toString() ?? '',
      receiptNumber: json['receipt_number']?.toString() ?? '-',
      recipientName: json['recipient_name']?.toString() ?? '-',
      studentId: int.tryParse(json['student_id']?.toString() ?? ''),
      category: json['category']?.toString() ?? 'Pondok',
      amount: total != null ? _toNum(total) : itemsTotal,
      issuedAt: DateTime.tryParse(
        (json['issued_at'] ?? json['created_at'])?.toString() ?? '',
      )?.toLocal(),
      paymentMethod: json['payment_method']?.toString() ?? 'Transfer',
      status: _mapStatus(json['status']?.toString()),
      note: _toNullableString(json['note']),
      signerRole: _toNullableString(json['signer_role']) ?? defaultSignerRole,
      processedBy: processed is Map<String, dynamic>
          ? KwitansiProcessor.fromJson(processed)
          : null,
      whatsappNumber: _toNullableString(json['whatsapp_number']),
      email: _toNullableString(json['email']),
      address: _toNullableString(json['address']),
      attachmentUrl: _toNullableString(json['attachment_url']),
      items: items,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String numberToWords(num number) {
    final satuan = [
      '',
      'Satu',
      'Dua',
      'Tiga',
      'Empat',
      'Lima',
      'Enam',
      'Tujuh',
      'Delapan',
      'Sembilan',
      'Sepuluh',
      'Sebelas',
    ];
    int n = number.toInt();
    if (n == 0) return 'Nol Rupiah';

    String convert(int val) {
      if (val < 12) return satuan[val];
      if (val < 20) return '${convert(val - 10)} Belas';
      if (val < 100) {
        return '${convert(val ~/ 10)} Puluh ${satuan[val % 10]}'.trim();
      }
      if (val < 200) return 'Seratus ${convert(val - 100)}'.trim();
      if (val < 1000) {
        return '${convert(val ~/ 100)} Ratus ${convert(val % 100)}'.trim();
      }
      if (val < 2000) return 'Seribu ${convert(val - 1000)}'.trim();
      if (val < 1000000) {
        return '${convert(val ~/ 1000)} Ribu ${convert(val % 1000)}'.trim();
      }
      if (val < 1000000000) {
        return '${convert(val ~/ 1000000)} Juta ${convert(val % 1000000)}'
            .trim();
      }
      if (val < 1000000000000) {
        return '${convert(val ~/ 1000000000)} Miliar ${convert(val % 1000000000)}'
            .trim();
      }
      return '';
    }

    final result = convert(n).replaceAll(RegExp(r'\s+'), ' ').trim();
    return '$result Rupiah';
  }
}

/// Payload untuk membuat / memperbarui kwitansi.
///
/// Sengaja TIDAK memuat nama penandatangan maupun kontak: backend mengisinya
/// dari akun yang sedang login (`processed_by`).
class KwitansiRequest {
  final DateTime issuedAt;
  final String recipientName;
  final int? studentId;
  final String? whatsappNumber;
  final String? email;
  final String? address;
  final String category;
  final String paymentMethod;
  final List<KwitansiItemDetail> items;
  final String signerRole;
  final String? note;

  const KwitansiRequest({
    required this.issuedAt,
    required this.recipientName,
    this.studentId,
    this.whatsappNumber,
    this.email,
    this.address,
    required this.category,
    required this.paymentMethod,
    required this.items,
    required this.signerRole,
    this.note,
  });

  factory KwitansiRequest.fromModel(KwitansiModel m) => KwitansiRequest(
    issuedAt: m.issuedAt ?? DateTime.now(),
    recipientName: m.recipientName,
    studentId: m.studentId,
    whatsappNumber: m.whatsappNumber,
    email: m.email,
    address: m.address,
    category: m.category,
    paymentMethod: m.paymentMethod,
    items: m.items,
    signerRole: m.signerRole,
    note: m.note,
  );

  KwitansiRequest copyWith({
    String? recipientName,
    String? paymentMethod,
    List<KwitansiItemDetail>? items,
  }) => KwitansiRequest(
    issuedAt: issuedAt,
    recipientName: recipientName ?? this.recipientName,
    studentId: studentId,
    whatsappNumber: whatsappNumber,
    email: email,
    address: address,
    category: category,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    items: items ?? this.items,
    signerRole: signerRole,
    note: note,
  );

  Map<String, dynamic> toJson() {
    String? clean(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    return {
      'issued_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(issuedAt),
      'recipient_name': recipientName.trim(),
      'student_id': studentId,
      'whatsapp_number': clean(whatsappNumber),
      'email': clean(email),
      'address': clean(address),
      'category': category.trim(),
      'payment_method': paymentMethod,
      'signer_role': signerRole.trim(),
      'note': clean(note),
      'items': items.map((e) => e.toJson()).toList(),
    }..removeWhere((_, v) => v == null);
  }
}

/// Hasil list kwitansi (dengan metadata paginasi Laravel).
class KwitansiPage {
  final List<KwitansiModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const KwitansiPage({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  bool get hasMore => currentPage < lastPage;
}
