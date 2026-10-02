# Task-feature-06: Implementasi Modul Sistem Kasir & POS Koperasi Santri

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-06` |
| **Prioritas** | **P2 - Medium** |
| **Epic / Modul** | Point of Sale (POS) & Koperasi Pesantren |
| **Komponen Terkait** | Dashboard menu `sistem_kasir`, `WalletRepository`, Pemindaian Barcode/QR |
| **Status** | Backlog / Belum Diimplementasikan |

---

## 1. Latar Belakang & Masalah Saat Ini
Aplikasi SIKESAN memiliki role pengguna **"Kasir"** dan menu **"Sistem Kasir"** (`id: 'sistem_kasir'`) di dashboard.
Namun modul POS (Point of Sale) ini **belum diimplementasikan sama sekali**:
- Tidak ada layar kasir untuk memindai kartu santri atau barcode belanjaan.
- Kasir di kantin atau koperasi pesantren belum bisa memproses transaksi belanja harian santri langsung dari aplikasi mobile tablet/HP kasir.
- Mengetuk menu "Sistem Kasir" di dashboard tidak memberikan reaksi apa pun.

---

## 2. User Story
- **Sebagai Petugas Kasir / Koperasi Pesantren**, saya ingin memindai barcode kartu santri (atau mencari nama santri), memilih item belanja/memasukkan nominal belanja santri, dan langsung mendebit saldo dompet digital santri secara instan.
- **Sebagai Santri / Wali Santri**, saldo uang saku santri otomatis terpotong secara transparan dan tercatat di riwayat mutasi dengan rincian belanja koperasi.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Layar Transaksi Kasir (`PosCashierScreen`)**:
   - Header: Identitas santri yang sedang berbelanja (Nama, Foto, Saldo Aktif).
   - Tombol *"Scan Kartu Santri"* (mengaktifkan kamera scanner QR/Barcode kartu santri).
   - Katalog Item Belanja Cepat / Tombol Numpad Input Manual Nominal.
   - Ringkasan Keranjang Belanja: Daftar item, kuantiti, subtotal, dan total bayar.
2. **Konfirmasi & Pemotongan Saldo (`PosCheckoutSheet`)**:
   - Validasi saldo: Jika saldo santri kurang, tombol bayar dinonaktifkan dengan peringatan *"Saldo tidak mencukupi"*.
   - Eksekusi transaksi debit instan.
   - Tampilan sukses transaksi disertai tombol cetak struk via printer thermal Bluetooth (58mm/80mm).

---

## 4. Rencana Kontrak API Backend
- `POST /api/v1/pos/scan-card`
  - Body: `card_uid` atau `nis`
  - Response: Profil santri, batas belanja harian, dan saldo aktif.
- `POST /api/v1/pos/charge`
  - Body: `student_id`, `items`, `total_amount`, `cashier_notes`
  - Response: Status sukses, sisa saldo santri, nomor transaksi POS.

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Role Kasir dapat membuka antarmuka POS dari dashboard.
- [ ] Scan barcode kartu santri memuat data nama dan saldo santri yang valid.
- [ ] Transaksi sukses memotong saldo santri secara atomik dan mencatat mutasi di sistem secara real-time.
