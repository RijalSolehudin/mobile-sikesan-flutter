# Task-feature-02: Integrasi Layanan Customer Service & Pengaduan Wali Santri

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-02` |
| **Prioritas** | **P1 - High** |
| **Epic / Modul** | Customer Service & Helpdesk Santri |
| **Komponen Terkait** | `lib/features/cs_sikesan/`, `CsScreen`, `CsHeader`, `CsEmptyState` |
| **Status** | Backlog / Belum Terintegrasi |

---

## 1. Latar Belakang & Masalah Saat Ini
Layar CS di [CsScreen](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/cs_sikesan/screen/cs_screen.dart) saat ini hanya berupa tampilan kosong statis ([CsEmptyState](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/cs_sikesan/widget/cs_empty_state.dart)) dengan chip filter kelas tanpa aksi.
Wali santri tidak dapat mengirim pesan kendala (misal: bukti bayar belum terverifikasi, salah nominal transfer, atau uang saku anak belum masuk), dan tidak ada kontak cepat ke WhatsApp Helpdesk pesantren.

---

## 2. User Story
- **Sebagai Wali Santri**, saya ingin mengirimkan tiket aduan atau pesan bantuan keuangan santri dan memantau status penyelesaiannya oleh admin.
- **Sebagai Wali Santri**, saya ingin tombol cepat langsung ke nomor resmi WhatsApp Helpdesk Keuangan Pesantren jika memerlukan respon instan.
- **Sebagai Bendahara / Admin CS**, saya ingin melihat daftar pesan masuk dari wali santri berdasarkan kelas dan memberikan balasan/solusi.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Quick Action Card (WhatsApp Helpdesk)**:
   - Banner kontak admin pesantren dengan tombol *"Chat WhatsApp CS Keuangan"* menggunakan `url_launcher` (`https://wa.me/<nomor_cs>?text=...`).
2. **Daftar Tiket Aduan / Percakapan**:
   - List tiket dengan status badge (*Menunggu Review*, *Sedang Diproses*, *Selesai*), nomor tiket, tanggal, dan judul kendala.
3. **Form Pembuatan Tiket Aduan Baru (`CreateTicketModal`)**:
   - Pilihan kategori aduan (Kendala SPP, Masalah Uang Saku, Verifikasi Transfer, Lainnya).
   - Input judul masalah dan deskripsi rinci.
   - Upload lampiran screenshot/foto struk kendala.
4. **Detail Tiket & Riwayat Chat**:
   - Tampilan riwayat tanggapan antara wali santri dan petugas CS.

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/support/tickets` (List tiket pengguna)
- `POST /api/v1/support/tickets` (Submit tiket baru beserta lampiran file)
- `GET /api/v1/support/tickets/{id}` (Detail percakapan dan status tiket)
- `POST /api/v1/support/tickets/{id}/replies` (Kirim balasan chat)

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Tombol WhatsApp CS langsung membuka aplikasi WhatsApp dengan template pesan pembuka yang menyertakan Nama Santri & ID Wali.
- [ ] Wali santri dapat membuat tiket aduan baru dan mengunggah foto kendala.
- [ ] Riwayat tiket tersimpan dan ter-update statusnya saat di-resolve oleh pihak keuangan pesantren.
