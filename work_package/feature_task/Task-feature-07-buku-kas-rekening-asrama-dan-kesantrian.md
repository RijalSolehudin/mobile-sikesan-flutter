# Task-feature-07: Implementasi Modul Buku Kas Rekening Asrama & Kesantrian

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-07` |
| **Prioritas** | **P2 - Medium** |
| **Epic / Modul** | Manajemen Kas Asrama & Operasional Kesantrian |
| **Komponen Terkait** | Dashboard menu `rek_wali_asrama`, `rek_kesantrian`, `ApiEndpoints.ledgerReports` |
| **Status** | Backlog / Belum Diimplementasikan |

---

## 1. Latar Belakang & Masalah Saat Ini
Pada dashboard menu grid, terdapat dua menu penting untuk Staff Kesantrian dan Bendahara:
1. **"Rekening Wali Asrama"** (`id: 'rek_wali_asrama'`)
2. **"Rekening Kesantrian"** (`id: 'rek_kesantrian'`)

Meskipun backend memiliki endpoint pembukuan di `ApiEndpoints.ledgerReports` (`/reports/ledger`), di aplikasi mobile saat ini:
- Tidak ada halaman atau navigasi saat menu-menu tersebut diklik (*no-op*).
- Wali asrama tidak dapat mencatat uang kas operasional kamar/asrama santri, uang titipan berobat santri, atau pengeluaran kegiatan ekstrakulikuler.

---

## 2. User Story
- **Sebagai Wali Asrama / Pengurus Kamar**, saya ingin melihat saldo kas asrama yang saya kelola, mencatat pengeluaran harian asrama (misal kebutuhan kebersihan, obat santri sakit), dan mengajukan klaim *reimbursement* ke Bendahara Pusat.
- **Sebagai Bendahara Pusat**, saya ingin memantau buku kas seluruh asrama dan menyetujui laporan pertanggungjawaban kas asrama secara digital.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Layar Buku Kas Asrama (`DormitoryLedgerScreen`)**:
   - Saldo Kas Aktif Asrama / Kesantrian.
   - Ringkasan Kas Masuk & Kas Keluar bulan berjalan.
   - Filter transaksi berdasarkan kategori keperluan (Kesehatan, Kebersihan, Konsumsi, Darurat).
   - Daftar jurnal pembukuan harian.
2. **Modal Input Pengeluaran Kas (`AddExpenseRecordModal`)**:
   - Form nominal pengeluaran, tanggal, pos anggaran, deskripsi, dan foto bukti nota/struk belanja fisik.
3. **Status Verifikasi Bendahara**:
   - Badge status: *Menunggu Verifikasi Bendahara*, *Disetujui*, *Ditolak*.

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/dormitory/ledgers` (List saldo dan transaksi kas asrama)
- `POST /api/v1/dormitory/ledgers/entry` (Catat pengeluaran/pemasukan baru)
- `POST /api/v1/dormitory/ledgers/{id}/approve` (Khusus Bendahara)

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Mengetuk menu "Rekening Wali Asrama" atau "Rekening Kesantrian" membuka buku kas yang sesuai dengan asrama yang diampu pengguna.
- [ ] Staff dapat mencatat pengeluaran kas dengan mengunggah foto nota fisik.
- [ ] Riwayat kas ter-update seketika dan mempengaruhi saldo buku besar.
