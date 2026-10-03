import '../../../core/utils/currency_formatter.dart';

class KwitansiItemDetail {
  final String description;
  final int qty;
  final num price;

  const KwitansiItemDetail({
    required this.description,
    this.qty = 1,
    required this.price,
  });

  num get total => qty * price;

  String get formattedTotal => CurrencyFormatter.format(total);
}

class KwitansiModel {
  final String id;
  final String receiptNumber;
  final String recipientName;
  final String category;
  final String itemCountDescription;
  final num amount;
  final String dateTime;
  final String paymentMethod;
  final String status;
  final String? note;
  final String? studentNis;
  final String? studentClass;
  final String? itemDetailTitle;
  final String signerName;
  final String signerRole;
  final String? whatsappNumber;
  final String? email;
  final String? address;
  final String? contact;
  final String? attachmentPath;
  final List<KwitansiItemDetail> items;

  const KwitansiModel({
    required this.id,
    required this.receiptNumber,
    required this.recipientName,
    required this.category,
    required this.itemCountDescription,
    required this.amount,
    required this.dateTime,
    required this.paymentMethod,
    required this.status,
    this.note,
    this.studentNis,
    this.studentClass,
    this.itemDetailTitle,
    this.signerName = 'Risda Nur Fajar Purnama',
    this.signerRole = 'Bendahara Yayasan',
    this.whatsappNumber,
    this.email,
    this.address,
    this.contact,
    this.attachmentPath,
    this.items = const [],
  });

  String get formattedAmount => CurrencyFormatter.format(amount);

  String get displayItemDetail {
    if (items.isNotEmpty) {
      final first = items.first;
      return '${first.description} (${first.qty}x)';
    }
    return itemDetailTitle ??
        (note != null && note!.isNotEmpty
            ? note!
            : '$itemCountDescription ($category)');
  }

  String get spelledAmount => numberToWords(amount);

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

  KwitansiModel copyWith({
    String? id,
    String? receiptNumber,
    String? recipientName,
    String? category,
    String? itemCountDescription,
    num? amount,
    String? dateTime,
    String? paymentMethod,
    String? status,
    String? note,
    String? studentNis,
    String? studentClass,
    String? itemDetailTitle,
    String? signerName,
    String? signerRole,
    String? whatsappNumber,
    String? email,
    String? address,
    String? contact,
    String? attachmentPath,
    List<KwitansiItemDetail>? items,
  }) {
    return KwitansiModel(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      recipientName: recipientName ?? this.recipientName,
      category: category ?? this.category,
      itemCountDescription: itemCountDescription ?? this.itemCountDescription,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      note: note ?? this.note,
      studentNis: studentNis ?? this.studentNis,
      studentClass: studentClass ?? this.studentClass,
      itemDetailTitle: itemDetailTitle ?? this.itemDetailTitle,
      signerName: signerName ?? this.signerName,
      signerRole: signerRole ?? this.signerRole,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      items: items ?? this.items,
    );
  }

  static List<KwitansiModel> get initialData => [
    const KwitansiModel(
      id: '1',
      receiptNumber: 'INV/PONDOK/2026/09/01/017',
      recipientName: 'M Nazri Fatih altaf',
      category: 'Pondok',
      itemCountDescription: '1 Item Pembayaran',
      amount: 500000,
      dateTime: '01/09/2026 17:36',
      paymentMethod: 'Transfer',
      status: 'Aktif',
      studentNis: '202609001',
      studentClass: 'Kelas 7A',
      itemDetailTitle: 'SPP Bulan Agustus 2026 (1x)',
      note: 'Pembayaran Iuran Bulanan Pondok',
    ),
    const KwitansiModel(
      id: '2',
      receiptNumber: 'INV/PONDOK/2026/09/02/018',
      recipientName: 'Muhammad Rais Al Fatih',
      category: 'Pondok',
      itemCountDescription: '1 Item Pembayaran',
      amount: 750000,
      dateTime: '02/09/2026 17:24',
      paymentMethod: 'Transfer',
      status: 'Aktif',
      studentNis: '202609002',
      studentClass: 'Kelas 8B',
      itemDetailTitle: 'Uang Kegiatan & Fasilitas Santri',
      note: 'Pembayaran Kegiatan Santri',
    ),
    const KwitansiModel(
      id: '3',
      receiptNumber: 'INV/PONDOK/2026/09/02/015',
      recipientName: 'Ahmad Zaky Mubarak',
      category: 'Pondok',
      itemCountDescription: '1 Item Pembayaran',
      amount: 350000,
      dateTime: '02/09/2026 17:17',
      paymentMethod: 'Tunai',
      status: 'Aktif',
      studentNis: '202609003',
      studentClass: 'Kelas 7B',
      itemDetailTitle: 'Seragam & Kitab Pesantren',
      note: 'Pembayaran Seragam & Kitab',
    ),
    const KwitansiModel(
      id: '4',
      receiptNumber: 'INV/PONDOK/2026/08/28/012',
      recipientName: 'Fathir Rahman Hakim',
      category: 'Pondok',
      itemCountDescription: '2 Item Pembayaran',
      amount: 1200000,
      dateTime: '28/08/2026 10:15',
      paymentMethod: 'Transfer',
      status: 'Aktif',
      studentNis: '202608012',
      studentClass: 'Kelas 9A',
      itemDetailTitle: 'SPP & Ekstrakurikuler (2x)',
      note: 'Pembayaran SPP & Ekstrakurikuler',
    ),
    const KwitansiModel(
      id: '5',
      receiptNumber: 'INV/PONDOK/2026/08/25/009',
      recipientName: 'Alifia Nurul Izzah',
      category: 'Pondok',
      itemCountDescription: '1 Item Pembayaran',
      amount: 450000,
      dateTime: '25/08/2026 14:02',
      paymentMethod: 'Transfer',
      status: 'Aktif',
      studentNis: '202608009',
      studentClass: 'Kelas 7C',
      itemDetailTitle: 'Iuran Sarana & Uang Saku',
      note: 'Pembayaran Uang Saku & Fasilitas',
    ),
  ];
}
