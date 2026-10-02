# Task-feature-03: Integrasi Manajemen Akun, Ubah Password & Preferensi Tema

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-FEAT-03` |
| **Prioritas** | **P1 - High** |
| **Epic / Modul** | Profil Pengguna & Keamanan Kredensial |
| **Komponen Terkait** | `lib/features/profile/`, `ProfileScreen`, `ProfileMenuTile`, `ProfileThemeToggle` |
| **Status** | Backlog / Belum Terintegrasi |

---

## 1. Latar Belakang & Masalah Saat Ini
Pada [ProfileScreen](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/profile/screen/profile_screen.dart#L54-L93):
- Menu *"Informasi Akun"*, *"Ubah Password"*, dan *"Bantuan"* hanya me-render `SnackBar('... segera hadir.')`.
- Pengguna tidak memiliki cara untuk mengganti password mereka sendiri dari dalam aplikasi, yang menjadi risiko keamanan jika kredensial default dari admin belum diganti.
- Toggle *Mode Gelap / Terang* hanya mengubah variabel lokal `bool _isDarkMode` tanpa merubah `ThemeMode` aplikasi global atau menyimpannya di preferensi lokal perangkat.

---

## 2. User Story
- **Sebagai Pengguna (Wali Santri / Staff)**, saya ingin melihat dan memperbarui informasi nomor telepon dan email akun saya.
- **Sebagai Pengguna**, saya ingin mengganti password akun secara mandiri dengan memasukkan password lama dan konfirmasi password baru.
- **Sebagai Pengguna**, saya ingin preferensi tema (Dark Mode / Light Mode / Ikuti Sistem) tersimpan permanen di perangkat.

---

## 3. Spesifikasi UI & Alur Interaksi
1. **Layar Informasi Akun (`AccountInfoScreen`)**:
   - Menampilkan Nama Lengkap, Nomor HP/WhatsApp, Email, Role, Tanggal Terdaftar, dan Daftar Santri yang terafiliasi dengan akun wali santri.
   - Form ubah nomor telepon & email dengan tombol simpan.
2. **Layar Ubah Password (`ChangePasswordScreen`)**:
   - Field: Password Lama, Password Baru (dengan indikator kekuatan password: min 8 karakter), Konfirmasi Password Baru.
   - Tombol toggle show/hide password (ikon mata).
   - Validasi kecocokan password sebelum submit.
3. **Global Theme Toggle**:
   - Hubungkan toggle di profil dengan `ThemeCubit` / `AppThemeBloc` yang mengubah `ThemeMode` pada root `MaterialApp` dan menyimpannya di `SharedPreferences`.

---

## 4. Rencana Kontrak API Backend
- `GET /api/v1/auth/profile`
- `PUT /api/v1/auth/profile` (Update telepon/email)
- `POST /api/v1/auth/change-password`
  - Body: `current_password`, `new_password`, `new_password_confirmation`

---

## 5. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Pengguna dapat mengganti password dengan validasi keamanan yang ketat.
- [ ] Pesan error validasi (misal password lama salah) ditampilkan jelas dari backend.
- [ ] Pengguna dapat melihat daftar data santri yang terhubung dengan akun mereka.
- [ ] Preferensi Dark Mode bekerja secara instan di seluruh layar dan tetap tersimpan saat aplikasi dibuka kembali.
