# Feature Task Backlog: Integrasi & Implementasi Fitur Baru

Folder ini berisi daftar paket pekerjaan (*backlog task*) untuk seluruh fitur aplikasi mobile **SIKESAN (Sistem Keuangan Santri)** yang **belum diintegrasikan ke backend** atau **belum diimplementasikan / masih berupa UI statis / mock**:

---

## Master Index Backlog Fitur

| No | Task ID | File Dokumen | Prioritas | Modul / Epic | Status Saat Ini di Mobile |
|:---:|:---:|---|:---:|---|---|
| **1** | `TASK-FEAT-01` | [Task-feature-01-informasi-dan-pengumuman-pesantren.md](./Task-feature-01-informasi-dan-pengumuman-pesantren.md) | **P1 (High)** | Informasi & Berita Pesantren | **UI Mock**: Metrik statis nol, empty state selalu muncul, SnackBar *"segera hadir"*. |
| **2** | `TASK-FEAT-02` | [Task-feature-02-customer-service-dan-helpdesk-pengaduan.md](./Task-feature-02-customer-service-dan-helpdesk-pengaduan.md) | **P1 (High)** | CS & Helpdesk Wali Santri | **UI Mock**: Tampilan kosong tanpa fungsi chat, tiket aduan, atau tombol WhatsApp CS. |
| **3** | `TASK-FEAT-03` | [Task-feature-03-manajemen-profil-dan-ubah-password.md](./Task-feature-03-manajemen-profil-dan-ubah-password.md) | **P1 (High)** | Akun, Ubah Password, Dark Mode | **Belum Terintegrasi**: Menu ubah password hanya SnackBar, dark mode belum global. |
| **4** | `TASK-FEAT-04` | [Task-feature-04-direktori-dan-detail-data-santri.md](./Task-feature-04-direktori-dan-detail-data-santri.md) | **P1 (High)** | Kesiswaan & Kartu Digital Santri | **Belum Ada Screen**: Menu `data_santri` di dashboard belum memiliki halaman / rute. |
| **5** | `TASK-FEAT-05` | [Task-feature-05-arsip-dan-riwayat-kwitansi-digital.md](./Task-feature-05-arsip-dan-riwayat-kwitansi-digital.md) | **P1 (High)** | Arsip & Pencarian Kuitansi Digital | **Belum Ada Screen**: Menu `kwitansi` di dashboard belum memiliki halaman arsip kuitansi. |
| **6** | `TASK-FEAT-06` | [Task-feature-06-sistem-kasir-dan-pos-koperasi-santri.md](./Task-feature-06-sistem-kasir-dan-pos-koperasi-santri.md) | **P2 (Medium)** | Point of Sale (POS) & Kantin | **Belum Ada Screen**: Menu `sistem_kasir` untuk role Kasir belum memiliki UI / scanner. |
| **7** | `TASK-FEAT-07` | [Task-feature-07-buku-kas-rekening-asrama-dan-kesantrian.md](./Task-feature-07-buku-kas-rekening-asrama-dan-kesantrian.md) | **P2 (Medium)** | Kas Operasional Asrama & Jurnal | **Belum Ada Screen**: Menu `rek_wali_asrama` & `rek_kesantrian` belum memiliki halaman. |
| **8** | `TASK-FEAT-08` | [Task-feature-08-detail-transaksi-dan-export-laporan-mutasi.md](./Task-feature-08-detail-transaksi-dan-export-laporan-mutasi.md) | **P2 (Medium)** | Mutasi, Detail & Export Laporan | **Belum Ada Aksi**: Baris mutasi tidak bisa di-klik & belum ada fitur export PDF/Excel. |

---

## Petunjuk Pengembangan Bagi Tim Developer
1. **Fase Prioritas 1 (Core Wali Santri Experience)**:
   - Selesaikan `TASK-FEAT-01` (Pengumuman Pesantren), `TASK-FEAT-02` (Helpdesk/CS), dan `TASK-FEAT-03` (Ubah Password & Akun) agar fitur dasar wali santri lengkap.
   - Selesaikan `TASK-FEAT-04` (Direktori Santri) dan `TASK-FEAT-05` (Arsip Kuitansi Digital).
2. **Fase Prioritas 2 (Staff & Operasional Pesantren)**:
   - Implementasikan `TASK-FEAT-06` (Sistem Kasir POS), `TASK-FEAT-07` (Buku Kas Asrama), dan `TASK-FEAT-08` (Export Laporan Mutasi).
