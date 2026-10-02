# Task-feature-05: Implementasi Layanan Arsip & Pencarian Kwitansi Digital

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-05` |
| **Prioritas** | **P1 - High** |
| **Epic / Modul** | Pembukuan & Bukti Transaksi Resmi |
| **Komponen Terkait** | Dashboard menu `kwitansi`, `ReceiptPdfService`, `ApiEndpoints.infaqReceipt` |
| **Status** | Backlog / Belum Diimplementasikan |

---

## 1. Latar Belakang & Masalah Saat Ini
Aplikasi SIKESAN telah memiliki mesin pembuat PDF yang sangat kuat di [ReceiptPdfService](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/services/receipt_pdf_service.dart), dan terdapat menu **"Kwitansi Digital"** (`id: 'kwitansi'`) di grid menu utama dashboard.
Namun saat ini:
- PDF kuitansi hanya dapat dilihat sesaat setelah pengguna menyelesaikan checkout pembayaran via modal pratinjau.
- **Tidak ada halaman arsip kuitansi** untuk mencari dan mengunduh ulang kuitansi pembayaran bulan-bulan sebelumnya.
- Mengetuk menu "Kwitansi Digital" di dashboard tidak merespon apa pun (*no-op*).
- Wali santri yang membutuhkan bukti pembayaran untuk klaim tunjangan kantor atau arsip keluarga kesulitan mencetak ulang bukti bayar lama.

---

## 2. User Story
- **Sebagai Wali Santri**, saya ingin membuka riwayat arsip kuitansi, mencari bukti pembayaran berdasarkan bulan/kategori (SPP, Infak, Top Up), serta mengunduh atau membagikan file PDF kuitansi resmi bertanda tangan digital pesantren.
- **Sebagai Kasir / Bendahara**, saya ingin mencetak ulang kuitansi pembayaran santri kapan pun diperlukan dengan nomor resi resmi.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Layar Arsip Kwitansi (`ReceiptArchiveScreen`)**:
   - Filter Tabs: *Semua*, *SPP Santri*, *Infak Kesantrian*, *Top Up Dompet*.
   - Filter Rentang Tanggal / Bulan & Tahun ajaran.
   - Kartu Kuitansi: Nomor Referensi Kuitansi (e.g. `RCP-2026-00123`), Nama Santri, Tanggal Lunas, Nominal, dan Metode Bayar (Transfer/Tunai/Saldo).
2. **Aksi Cepat Tiap Kuitansi**:
   - Tombol *"Lihat PDF"* (membuka pratinjau dokumen via `Printing.layoutPdf`).
   - Tombol *"Bagikan PDF"* (mengirim berkas PDF langsung ke WhatsApp / Email).
   - Tombol *"Cetak"* (mengirim perintah cetak langsung ke printer Bluetooth thermal atau printer Wi-Fi).

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/receipts`
  - Query: `category`, `student_id`, `start_date`, `end_date`, `page`, `per_page`
  - Response: Daftar metadata kuitansi resmi.
- `GET /api/v1/receipts/{receipt_number}/data`
  - Response: Objek data lengkap untuk di-render oleh `ReceiptPdfService`.

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Mengetuk menu "Kwitansi Digital" membuka layar `ReceiptArchiveScreen`.
- [ ] Pengguna dapat memfilter kuitansi berdasarkan bulan dan jenis transaksi.
- [ ] Mengetuk tombol kuitansi menghasilkan file PDF yang rapi dan dapat di-share / di-print tanpa error.
