# PRD - SIKESAN Mobile Application (Flutter)

## 1. Ringkasan Produk
**SIKESAN Mobile** adalah aplikasi sistem manajemen keuangan santri dan operasional kesantrian berbasis mobile (Flutter) yang terintegrasi langsung dengan backend Laravel SIKESAN. Aplikasi ini dirancang untuk multi-role (Wali Santri, Kasir, Bendahara, Staff Kesantrian, dan Admin) dengan tampilan antarmuka yang dinamis sesuai hak akses peran pengguna.

---

## 2. Target Pengguna & Persona

| Role | Kebutuhan Utama | Menu yang Dapat Diakses |
| :--- | :--- | :--- |
| **Wali Santri** | Melihat saldo santri, request top-up, cek tagihan SPP, bayar infak, lihat riwayat mutasi anak | Beranda (Saldo anak), Bayar SPP, Top Up Saldo, Infak Kesantrian, Kwitansi, Riwayat Transaksi |
| **Kasir** | Mencatat transaksi POS/uang keluar santri, menerima top up tunai | Beranda (Ringkasan Kasir), Sistem Kasir, Top Up Saldo, Riwayat Transaksi |
| **Staff Kesantrian** | Monitoring data santri, membuat pengumuman/informasi asrama | Data Santri, Rekening Wali Asrama, Rekening Kesantrian, Pusat Informasi |
| **Bendahara / Admin**| Monitoring keuangan global pesantren, approval top up, manajemen tagihan SPP | Semua Menu Utama, Approval Top Up, Laporan Keuangan Ledger, Rekening Kesantrian, Settings |

---

## 3. Modul & Fitur Utama

### A. Autentikasi (Auth)
- **Metode Login:** Username dan Password via Laravel Sanctum (`POST /api/v1/auth/login`).
- **Token Handling:** Token Bearer disimpan aman di `FlutterSecureStorage`.
- **Auto Logout:** Jika API mengembalikan status `401 Unauthorized`, token dihapus dan diarahkan kembali ke Login.

### B. Beranda (Dashboard)
- **Header:** Salam personalisasi, nama user, role badge, tombol filter, dan icon notifikasi.
- **Kartu Metrik Keuangan (Carousel):**
  - Untuk Wali: Total Tabungan Santri, Tagihan Belum Lunas, Total Pemasukan & Pengeluaran.
  - Untuk Bendahara/Admin: Saldo Global Santri, Total Pembayaran SPP Pesantren, Tagihan Perbulan.
- **Menu Utama (Grid 4 Kolom):**
  - Dynamic Grid berdasarkan role dengan tombol *Expand / Collapse* ("Lihat Lebih Sedikit / Lihat Semua").
  - Menu: *Top Up Saldo, Rekening Wali Asrama, Infak Kesantrian, Rekening Kesantrian, Uang Keluar, Data Santri, Sistem Kasir, Kwitansi Digital, Bayar SPP, Akun Staff, Settings*.
- **Riwayat Transaksi Terbaru:**
  - Card transaksi dengan indikator jenis transaksi (Pemasukan: Hijau panah naik / Pengeluaran: Merah panah turun), nama santri, kategori, nominal, dan waktu.

### C. Mutasi / Laporan Keuangan
- **Segmented Control:** Tab Uang Saku, Pembayaran SPP, dan Infak Kesantrian.
- **Pencarian & Filter:** Search bar nama santri/ID, filter tanggal, dan horizontal filter chips kelas (*Semua Kelas, Kelas 7, Kelas 8...*).
- **Ringkasan Transaksi:** Total Masuk (+ Rp) & Total Keluar (- Rp).
- **Grafik Statistik (Spline Area Chart):** Visualisasi tren pengeluaran/pemasukan berkala (Harian, Mingguan, Bulanan).
- **Daftar Transaksi Lengkap:** Filter status (*Semua, Pemasukan, Pengeluaran*) dan jumlah total item.

### D. Pusat Informasi
- **4 Metrik Ringkasan:** Total Informasi, Belum Dibaca, Sudah Dibaca, Informasi Sangat Penting.
- **Pencarian & Multi-Filter:**
  - Kategori: *Semua, Infak Kesantrian, Keuangan SPP, Uang Saku*.
  - Status: *Semua, Draft, Terjadwal, Dipublikasikan, Expired, Arsip*.
- **Tombol Aksi:** "+ Pengumuman" untuk Staff Kesantrian / Admin.

### E. CS SIKESAN (Status: Placeholder)
- Menampilkan tab di navigasi bawah dan header sesuai desain acuan.
- Konten utama menampilkan ilustrasi & pesan placeholder: *"Fitur CS SIKESAN Sedang Dalam Pengembangan"*.

### F. Profil Saya
- **Header Profil:** Foto avatar dengan badge kamera/edit, nama pengguna, dan pill badge role.
- **Menu Navigasi:**
  - Informasi Akun
  - Ubah Password
  - Bantuan & Panduan
  - Switch Mode Tampilan (Terang / Gelap)
  - Tombol Logout Merah (Clear session & redirect)

---

## 4. Kebutuhan Non-Fungsional & Ketahanan Sistem
1. **Network Failure Handling:** Menangani timeout dan kehilangan koneksi internet tanpa membuat aplikasi crash.
2. **Double-Submit Prevention:** Tombol transaksi otomatis disabled saat request sedang berjalan (`BlocInProgress`).
3. **Idempotency Support:** Request top-up dan pembayaran SPP menyertakan UUID `Idempotency-Key` di header.
4. **Visual Accuracy (Pixel-Perfect):** 100% konsisten dengan desain acuan (warna `#10B981`, custom curved bottom nav bar, rounded cards, micro-animations).
