# Task-feature-08: Implementasi Detail Transaksi & Export Laporan Mutasi (PDF/Excel)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-08` |
| **Prioritas** | **P2 - Medium** |
| **Epic / Modul** | Mutasi & Laporan Keuangan |
| **Komponen Terkait** | `lib/features/mutation/`, `MutationScreen`, `MutationItemTile`, `ReceiptPdfService` |
| **Status** | Backlog / Belum Diimplementasikan |

---

## 1. Latar Belakang & Masalah Saat Ini
Pada layar [MutationScreen](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/mutation/screen/mutation_screen.dart):
- Seluruh baris transaksi ([MutationItemTile](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/mutation/widget/mutation_item_tile.dart)) saat ini **tidak dapat diklik / tidak ada gesture interaction**.
- Pengguna tidak dapat melihat nomor referensi bank, jam transaksi terperinci, nama kasir pemproses, rincian biaya admin, atau status verifikasi.
- Tidak ada fitur **Export Laporan Mutasi** (PDF / Excel / CSV) untuk mengekspor rekap mutasi keuangan santri berdasarkan rentang bulan/semester.

---

## 2. User Story
- **Sebagai Wali Santri**, saya ingin mengetuk baris mutasi untuk melihat lembar detail transaksi lengkap dan langsung mengunduh bukti tanda terima transaksinya.
- **Sebagai Wali Santri & Bendahara**, saya ingin mengekspor seluruh catatan transaksi mutasi dalam format PDF atau Excel untuk arsip laporan keuangan keluarga atau audit yayasan pesantren.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Modal Lembar Detail Transaksi (`TransactionDetailSheet`)**:
   - Ditampilkan saat item mutasi di-tap.
   - Status Badge (*Berhasil / Terverifikasi*, *Pending*, *Dibatalkan*).
   - Rincian: No. Transaksi, Jenis (SPP/Uang Saku/Infak), Tanggal & Jam, Metode Bayar, Nama Santri & NIS, Nama Petugas Pemroses, Catatan/Berita Acara.
   - Tombol Aksi: *"Unduh Bukti Transaksi"* (memanggil generator PDF).
2. **Tombol & Dialog Export Laporan (`ExportMutationDialog`)**:
   - Tombol ikon *"Download / Export"* pada header `MutationScreen`.
   - Dialog pemilihan periode: Bulan Ini, 3 Bulan Terakhir, atau Custom Range (Tanggal Awal - Tanggal Akhir).
   - Format: *PDF Laporan Rekapitulasi* atau *Spreadsheet Excel (.xlsx)*.

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/transactions/{id}/detail`
- `GET /api/v1/reports/mutation/export`
  - Query: `start_date`, `end_date`, `type`, `format` (pdf/xlsx)
  - Mengembalikan file stream atau download URL.

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Mengetuk baris transaksi mutasi membuka lembar modal detail dengan informasi lengkap.
- [ ] Tombol cetak bukti bayar di lembar detail berhasil men-download PDF tanda terima.
- [ ] Fitur export menghasilkan dokumen rekapitulasi mutasi yang sesuai dengan filter yang dipilih.
