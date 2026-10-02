# Task-concern-11: Validasi Sesi & Re-sync Profil Pengguna Saat Cold Start (RBAC Sync)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-11` |
| **Prioritas** | **P2 - Medium** |
| **Kategori** | Authentication, Security, State Management |
| **Komponen Terkait** | `lib/features/auth/bloc/auth_bloc.dart`, `lib/features/auth/repository/auth_repository.dart` |
| **Status** | Open / Pending Action |

---

## 1. Deskripsi Masalah (Problem Statement)
Pada saat aplikasi pertama kali dibuka (*cold start*), penentuan status pengguna diatur di [auth_bloc.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/auth/bloc/auth_bloc.dart#L45-L49):

```dart
final token = await _secureStorageService.getToken();
final user = await _secureStorageService.getUser();

if (token != null && user != null) {
  emit(AuthState.authenticated(user));
} else {
  emit(const AuthState.unauthenticated());
}
```

Aplikasi langsung mengasumsikan pengguna valid hanya berdasarkan keberadaan token lokal tanpa melakukan pengecekan status server (*handshake validation*).

---

## 2. Dampak Risiko (Impact Analysis)
1. **Perubahan Hak Akses / Role (RBAC) Tidak Terpancar**:
   Jika seorang pengurus pesantren atau staf diturunkan hak aksesnya (misal dari Bendahara menjadi Wali Santri biasa) atau sebaliknya di sistem web pusat, aplikasi di HP-nya akan tetap merender menu bendahara berdasarkan cache profil lokal sampai pengguna melakukan logout manual.
2. **Akun Dinonaktifkan Tetap Menampilkan Data Sensitif**:
   Jika santri telah lulus atau akun disuspend oleh pihak pesantren, saat membuka aplikasi pengguna masih bisa melihat dashboard finansial dan data ringkasan tabungan lokal sebelum akhirnya terjadi error 401 saat mengklik transaksi baru.

---

## 3. Rencana Solusi Teknis (Technical Solution)

Terapkan strategi **Optimistic Authentication with Background Sync**:

1. **Fase 1 (Cepat / Non-blocking)**: Emit `AuthState.authenticated(cachedUser)` agar aplikasi langsung membuka layar utama tanpa loading lama.
2. **Fase 2 (Silent Verification)**: Secara asynchronous, panggil endpoint `GET /auth/me` di background:
   - Jika response sukses `200 OK`: Perbarui data profil lokal di `SecureStorageService` dan panggil `emit(AuthState.authenticated(freshUser))` jika ada perubahan role/nama/saldo.
   - Jika response `401 Unauthorized` atau akun dinonaktifkan: Bersihkan storage lokal dan panggil `emit(const AuthState.unauthenticated())` yang otomatis mengarahkan ke halaman login dengan pesan: *"Sesi Anda telah berakhir atau akun telah diperbarui. Silakan login kembali."*
   - Jika koneksi offline (`SocketException` / `DioExceptionType.connectionError`): Abaikan verifikasi latar belakang dan tetap izinkan akses offline mode read-only.

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [ ] Profil pengguna diverifikasi ke server di latar belakang saat aplikasi diluncurkan.
- [ ] Perubahan role di backend otomatis memperbarui menu dashboard tanpa mengharuskan pengguna login ulang manual.
- [ ] Pengguna dengan akun non-aktif langsung dialihkan ke login screen dengan notifikasi yang jelas.
