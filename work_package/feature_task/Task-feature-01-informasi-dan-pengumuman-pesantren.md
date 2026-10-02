# Task-feature-01: Integrasi Modul Pengumuman & Informasi Pesantren

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-01` |
| **Prioritas** | **P1 - High** |
| **Epic / Modul** | Informasi & Pengumuman Pesantren |
| **Komponen Terkait** | `lib/features/information/`, `InformationScreen`, `InformationMetricCards`, `InformationFilterBar` |
| **Status** | Backlog / Belum Terintegrasi |

---

## 1. Latar Belakang & Masalah Saat Ini
Saat ini antarmuka [InformationScreen](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/information/screen/information_screen.dart) berstatus **UI statis / mock**:
- Kartu metrik [InformationMetricCards](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/information/widget/information_metric_cards.dart) menampilkan angka statis nol tanpa sumber data.
- Daftar pengumuman selalu menampilkan [InformationEmptyState](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/information/widget/information_empty_state.dart).
- Tombol aksi *"Tambah Pengumuman"* hanya memunculkan notifikasi `SnackBar('Form pengumuman segera hadir.')`.
- Belum ada BLoC, Repository, Model, ataupun koneksi endpoint API ke backend.

---

## 2. User Story
- **Sebagai Wali Santri**, saya ingin membaca maklumat dan berita keuangan resmi dari pesantren (edaran SPP, infaq renovasi, jadwal libur santri) agar saya mendapatkan kabar terkini yang valid langsung dari ponsel saya.
- **Sebagai Pengurus Pesantren / Bendahara**, saya ingin membuat dan mempublikasikan pengumuman baru dengan target kategori tertentu (Wali Santri, Santri, Semua).

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Daftar Berita & Pengumuman**:
   - Menampilkan kartu artikel pengumuman dengan foto banner/thumbnail, tanggal terbit, badge kategori (SPP, Infak, Uang Saku, Umum), dan ringkasan isi.
   - Fitur *Pull to Refresh* dan *Pagination (Infinite Scroll)*.
   - Filter aktif berdasarkan kategori dan status pengumuman.
2. **Halaman Detail Pengumuman (`AnnouncementDetailScreen`)**:
   - Menampilkan judul lengkap, nama penulis (Humas/Bendahara), teks isi pengumuman berformat rich-text/markdown, lampiran PDF berkas edaran jika ada, dan tombol bagikan (*Share to WhatsApp*).
3. **Form Tambah Pengumuman (Khusus Admin/Staff)**:
   - Input judul, pilihan kategori, upload foto banner, status (Draft/Publish), dan teks isi.

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/announcements`
  - Query params: `page`, `per_page`, `category`, `status`, `search`
- `GET /api/v1/announcements/{id}`
  - Response detail dan lampiran berkas PDF.
- `POST /api/v1/announcements` (Khusus Admin)
  - Payload multipart: `title`, `category`, `content`, `banner_image`, `is_published`

---

## 5. Rencana Arsitektur & State Management
- **Model**: `AnnouncementModel` (`id`, `title`, `content`, `category`, `bannerUrl`, `publishedAt`, `authorName`, `attachmentUrl`).
- **Repository**: `AnnouncementRepository` (metode `getAnnouncements`, `getAnnouncementDetail`, `createAnnouncement`).
- **BLoC**: `AnnouncementBloc` dengan event `AnnouncementFetchRequested`, `AnnouncementFilterChanged`, dan state `initial`, `loading`, `loaded(List<AnnouncementModel>)`, `error(message)`.

---

## 6. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Kartu metrik menampilkan jumlah rilis pengumuman riil dari backend.
- [ ] Daftar pengumuman termuat dari API dengan indikator loading shimmer.
- [ ] Wali santri dapat mengklik pengumuman dan membaca detail isi lengkap beserta berkas edaran.
- [ ] Filter tab (Semua, Infak, SPP, Uang Saku) menyaring data secara dinamis dari API.
