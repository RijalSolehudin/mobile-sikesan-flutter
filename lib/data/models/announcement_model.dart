/// Model data pengumuman pesantren.
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category; // 'SPP', 'Infak', 'Uang Saku', 'Umum'
  final String status; // 'draft', 'scheduled', 'published', 'expired', 'archived'
  final String? bannerUrl;
  final String? attachmentUrl;
  final String authorName;
  final DateTime publishedAt;
  final DateTime createdAt;
  final bool isImportant;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.status,
    this.bannerUrl,
    this.attachmentUrl,
    required this.authorName,
    required this.publishedAt,
    required this.createdAt,
    this.isImportant = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'published',
      bannerUrl: json['banner_url']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      authorName: json['author_name']?.toString() ?? 'Admin',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isImportant: json['is_important'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'status': status,
      'banner_url': bannerUrl,
      'attachment_url': attachmentUrl,
      'author_name': authorName,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_important': isImportant,
    };
  }

  /// Data mock untuk pengembangan sebelum API backend tersedia.
  static List<AnnouncementModel> mockAnnouncements() {
    final now = DateTime.now();
    return [
      AnnouncementModel(
        id: 'ann-001',
        title: 'Jadwal Pembayaran SPP Semester Genap 2026/2027',
        content:
            'Assalamualaikum Wr. Wb.\n\n'
            'Dengan ini kami sampaikan bahwa pembayaran SPP semester genap tahun ajaran 2026/2027 '
            'telah dibuka mulai tanggal 1 Oktober 2026. Batas akhir pembayaran adalah tanggal 15 Oktober 2026.\n\n'
            '**Rincian Biaya:**\n'
            '- SPP Bulanan: Rp 750.000\n'
            '- Uang Makan: Rp 350.000\n'
            '- Uang Kegiatan: Rp 150.000\n\n'
            'Pembayaran dapat dilakukan melalui:\n'
            '1. Transfer Bank ke rekening pesantren\n'
            '2. Pembayaran tunai di kantor bendahara\n'
            '3. Melalui aplikasi SIKESAN (menu Top Up → Bayar SPP)\n\n'
            'Bagi wali santri yang mengalami kesulitan pembayaran, silakan menghubungi kantor bendahara '
            'untuk pengajuan keringanan.\n\n'
            'Jazakallahu Khairan.\n\n'
            'Wassalamualaikum Wr. Wb.\n'
            'Bendahara Pesantren',
        category: 'SPP',
        status: 'published',
        authorName: 'Ust. Ahmad Fauzi',
        publishedAt: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(hours: 3)),
        isImportant: true,
      ),
      AnnouncementModel(
        id: 'ann-002',
        title: 'Pengumpulan Infak Renovasi Masjid Pesantren',
        content:
            'Bismillahirrahmanirrahim.\n\n'
            'Dalam rangka renovasi masjid pesantren yang sudah mulai menunjukkan kerusakan, '
            'kami mengadakan program infak renovasi masjid.\n\n'
            'Target pengumpulan: Rp 150.000.000\n'
            'Terkumpul saat ini: Rp 47.500.000\n\n'
            'Setiap kontribusi berapapun sangat berarti. Infak dapat disalurkan melalui menu '
            'Infak Kesantrian di aplikasi SIKESAN.\n\n'
            'Semoga Allah membalas kebaikan Bapak/Ibu sekalian.',
        category: 'Infak',
        status: 'published',
        authorName: 'Ust. Hasan Basri',
        publishedAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isImportant: true,
      ),
      AnnouncementModel(
        id: 'ann-003',
        title: 'Kebijakan Baru Uang Saku Santri',
        content:
            'Kepada Yth. Seluruh Wali Santri,\n\n'
            'Mulai bulan November 2026, kami memberlakukan kebijakan baru terkait uang saku santri:\n\n'
            '1. Batas maksimal top up uang saku per bulan: Rp 500.000\n'
            '2. Batas penarikan harian: Rp 50.000\n'
            '3. Seluruh transaksi akan tercatat di aplikasi SIKESAN\n\n'
            'Kebijakan ini bertujuan untuk mendidik santri dalam mengelola keuangan secara bijak.\n\n'
            'Terima kasih atas perhatian dan kerjasamanya.',
        category: 'Uang Saku',
        status: 'published',
        authorName: 'Ust. Ridwan',
        publishedAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 3)),
        isImportant: false,
      ),
      AnnouncementModel(
        id: 'ann-004',
        title: 'Libur Maulid Nabi Muhammad SAW 1448 H',
        content:
            'Assalamualaikum Wr. Wb.\n\n'
            'Sehubungan dengan peringatan Maulid Nabi Muhammad SAW 1448 H, '
            'pesantren akan libur pada:\n\n'
            'Tanggal: 27 - 29 Oktober 2026\n'
            'Santri dapat dijemput mulai: 26 Oktober 2026 pukul 14:00 WIB\n'
            'Santri kembali: 30 Oktober 2026 pukul 08:00 WIB\n\n'
            'Mohon penjemputan dan pengantaran santri dilakukan tepat waktu.\n\n'
            'Wassalamualaikum Wr. Wb.',
        category: 'Umum',
        status: 'published',
        authorName: 'Sekretariat Pesantren',
        publishedAt: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
        isImportant: false,
      ),
      AnnouncementModel(
        id: 'ann-005',
        title: 'Jadwal Ujian Akhir Semester Ganjil 2026',
        content:
            'Kepada seluruh santri dan wali santri,\n\n'
            'Ujian Akhir Semester Ganjil akan dilaksanakan pada:\n'
            'Tanggal: 10 - 17 Desember 2026\n\n'
            'Pastikan seluruh administrasi keuangan (SPP, Infak) sudah lunas '
            'sebelum pelaksanaan ujian.\n\n'
            'Santri yang belum melunasi administrasi tidak diperkenankan mengikuti ujian.',
        category: 'Umum',
        status: 'scheduled',
        authorName: 'Kepala Madrasah',
        publishedAt: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 1)),
        isImportant: true,
      ),
      AnnouncementModel(
        id: 'ann-006',
        title: 'Perubahan Tarif SPP Tahun Ajaran Baru',
        content:
            'Informasi mengenai penyesuaian tarif SPP untuk tahun ajaran 2027/2028 '
            'akan diumumkan setelah rapat pengurus pesantren.',
        category: 'SPP',
        status: 'draft',
        authorName: 'Bendahara',
        publishedAt: now,
        createdAt: now.subtract(const Duration(hours: 5)),
        isImportant: false,
      ),
    ];
  }
}
