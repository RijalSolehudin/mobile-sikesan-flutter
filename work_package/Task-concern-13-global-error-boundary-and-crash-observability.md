# Task-concern-13: Ketiadaan Global Error Boundary & Crash Observability di Produksi

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-13` |
| **Prioritas** | **P0 - Critical** |
| **Kategori** | Architecture, Error Handling, Production Observability |
| **Komponen Terkait** | `lib/main.dart`, `lib/core/widgets/` |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)
Fungsi `main()` di [lib/main.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/main.dart#L22) langsung memanggil `runApp()` tanpa memasang penanganan kesalahan tingkat root runtime:
- Belum ada implementasi `FlutterError.onError` (penanganan error rendering widget).
- Belum ada implementasi `PlatformDispatcher.instance.onError` (penanganan async error di luar widget tree).
- Belum ada `ErrorWidget.builder` custom untuk menggantikan layar merah (debug) atau layar abu-abu/blank (release).
- Tidak ada SDK pemantauan crash jarak jauh (remote APM) seperti Firebase Crashlytics atau Sentry.

---

## 2. Dampak Risiko (Impact Analysis)
1. **Layar Beku / Abu-abu (Grey Screen of Death)**:
   Jika terjadi bug tak terduga (misal data null dari API atau parsing desimal gagal), layar aplikasi langsung membeku menjadi abu-abu tanpa opsi apapun bagi pengguna selain mematikan paksa aplikasi.
2. **Ketiadaan Visibilitas Error Produksi (Blind Debugging)**:
   Ketika wali santri di lapangan mengalami crash, tim teknis tidak memiliki log stack trace, spesifikasi perangkat, maupun konteks network untuk melakukan reproduksi dan perbaikan bug.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Pasang Global Exception Hooks di `main.dart`
Perbarui inisialisasi di `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tangkap semua error rendering UI Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Kirim stack trace ke remote crash reporter di release mode:
    // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Tangkap semua error asynchronous di luar widget tree
  PlatformDispatcher.instance.onError = (error, stack) {
    // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Kustomisasi Error Widget agar ramah bagi pengguna
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return AppCrashFallbackScreen(errorDetails: errorDetails);
  };

  // ... jalankan runApp
}
```

### Langkah 2: Buat `AppCrashFallbackScreen` yang Ramah
Buat widget di `core/widgets/app_crash_fallback_screen.dart` yang menampilkan:
- Ilustrasi ramah & teks informatif: *"Mohon Maaf, Terjadi Kendala Teknis Pada Sistem"*
- Tombol *"Muat Ulang Halaman"* yang mereset state navigasi.
- Tombol *"Hubungi CS SIKESAN"* yang mengarahkan ke WhatsApp Helpdesk pesantren.

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [x] Error async tak tertangani tidak lagi menyebabkan aplikasi langsung keluar tanpa jejak (dilindungi `PlatformDispatcher.instance.onError`).
- [x] Layar crash menampilkan UI fallback yang sopan dengan tombol recovery (`AppCrashFallbackScreen` via `ErrorWidget.builder`).
- [x] Siap dihubungkan ke Crashlytics / Sentry begitu konfigurasi cloud disiapkan (hook logging telah terpasang di `main.dart`).
- [x] Pengujian unit/widget test untuk fallback screen berhasil diimplementasikan (`test/core/app_crash_fallback_screen_test.dart`).
