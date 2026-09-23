# Design Tokens & UI Slicing Guide - SIKESAN Mobile

Dokumen ini mendefinisikan secara pasti seluruh token visual hasil ekstraksi dari 5 screenshot acuan klien.

---

## 1. Palet Warna (Color Palette)

| Nama Token | Nilai Hex / Color | Kegunaan |
| :--- | :--- | :--- |
| **`primaryGreen`** | `#16A34A` / `#10B981` | Warna utama, Header app, Active Tab icon & pill |
| **`primaryGreenDark`**| `#059669` | Gradient header, badge gelap ("Semua Santri") |
| **`primaryGreenLight`**| `#D1FAE5` | Background badge pemasukan |
| **`expenseRed`** | `#EF4444` | Nominal pengeluaran, Tombol logout |
| **`expenseRedLight`** | `#FEE2E2` | Background badge pengeluaran / ikon panah merah |
| **`incomeGreen`** | `#10B981` | Nominal pemasukan (+ Rp) |
| **`darkSlate`** | `#1E293B` | Header teks informasi, filter status terpilih ("Dipublikasikan") |
| **`scaffoldBackground`**| `#F8FAFC` | Latar belakang halaman aplikasi |
| **`cardBackground`** | `#FFFFFF` | Latar belakang seluruh kartu komponen |
| **`textPrimary`** | `#0F172A` | Judul, nama santri, nominal utama |
| **`textSecondary`** | `#64748B` | Subtitle, keterangan kelas, tanggal |
| **`textMuted`** | `#94A3B8` | Placeholder form pencarian |
| **`borderLight`** | `#E2E8F0` | Garis border kartu dan text field |

---

## 2. Tipografi & Skala Font
* **Font Family:** `Plus Jakarta Sans` / `Poppins` (Google Fonts)
* **Header Big:** `22sp`, Bold (700) - Contoh: "Pusat Informasi", "Laporan Uang Saku"
* **Section Title:** `16sp`, Bold (700) - Contoh: "Menu Utama", "Riwayat Transaksi"
* **Card Value:** `18sp` - `24sp`, Extra Bold (800) - Contoh: "Rp 1.230.500"
* **Body / Title Item:** `14sp`, SemiBold (600) - Contoh: "Diki Rafsanjani", "Top Up Saldo"
* **Caption / Subtitle:** `12sp`, Regular (400) / Medium (500) - Contoh: "Wali Santri · Kelas 11"
* **Small Pill:** `11sp`, Medium (500) - Contoh: "Semua Kelas", "Draft"

---

## 3. Komponen Kunci UI (Key Visual Components)

### A. Custom Curved Bottom Navigation Bar
- **Latar:** Hijau solid (`#16A34A`) dengan sudut melengkung `top: Radius.circular(24)`.
- **Item Tidak Aktif:** Icon putih/putih transparan dengan teks label di bawahnya.
- **Item Aktif:** Dikelilingi lingkaran putih mengambang (*circular white container*), icon berwarna hijau di dalamnya, dengan label hijau tebal.

### B. Saldo Carousel Card (Beranda)
- **Container:** Rounded rectangle (`16dp`), latar hijau gradient, border halus semi-transparan.
- **Inner Badge:** Pill hijau tua (*Semua Santri*).
- **Indikator:** Dots pagination horizontal di bagian bawah carousel.

### C. Menu Grid (Beranda)
- **Grid:** 4 kolom dengan icon bulat/kotak bersudut melengkung, warna icon pastel lembut (Hijau, Biru, Oranye, Ungu, Merah).
- **Aksi Expand:** "Lihat Lebih Sedikit ^" / "Lihat Semua v".

### D. Filter Chips (Horizontal Scroll)
- **Bentuk:** `StadiumBorder` (Pill lonjong penuh).
- **State Aktif:** Solid hijau (`#16A34A`) atau Solid Hitam (`#1E293B`) dengan teks putih.
- **State Inaktif:** Background putih / abu-abu terang dengan teks gelap.
