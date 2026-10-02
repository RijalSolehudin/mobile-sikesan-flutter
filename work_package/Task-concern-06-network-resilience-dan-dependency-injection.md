# Task-concern-06: Network Resilience, Offline State, & Scalable Dependency Injection

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-06` |
| **Prioritas** | **P3 - Moderate (Skalabilitas & Ketahanan Jaringan)** |
| **Kategori** | Architecture, Offline UX, Dependency Injection |
| **Komponen Terkait** | `lib/main.dart`, `lib/core/network/dio_client.dart`, Service Locator |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)

### 1. Inisialisasi Monolitik di `main.dart`
Seluruh dependensi (Service, Dio, 5 Repository, dan BLoC) diinstansiasi secara manual di dalam fungsi `main()` di [main.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/main.dart#L35-L68):
```dart
final secureStorage = SecureStorageService();
final dioClient = DioClient(...);
final authRepository = AuthRepository(dioClient, secureStorage);
final dashboardRepository = DashboardRepository(dioClient);
final sppRepository = SppRepository(dioClient);
final infaqRepository = InfaqRepository(dioClient);
final walletRepository = WalletRepository(dioClient);
// ...
```
Seiring bertambahnya modul baru (seperti modul Tahfidz, Perizinan Santri, Kantin Digital, Klinik), `main.dart` akan menjadi *bloated*, sulit dimock saat pengujian parsial, dan seluruh repository di-*load eager* di awal startup meskipun belum tentu dibuka oleh pengguna.

### 2. Ketiadaan Network Connectivity Awareness
Aplikasi belum memantau status jaringan (*Network Connectivity*). Di lingkungan pesantren di mana sinyal seluler atau Wi-Fi sering tidak stabil:
- Saat koneksi internet terputus, aplikasi hanya menampilkan error pesan generik saat request gagal.
- Tidak ada banner *"Anda sedang offline"* atau mekanisme *auto-retry* ketika internet kembali tersambung.

---

## 2. Dampak Risiko (Impact Analysis)
- **Startup Latency**: Semakin banyak modul yang diinstansiasi secara eager di `main()`, waktu *app cold start* akan semakin lambat.
- **Poor User Experience**: Wali santri mengira aplikasi rusak ketika terjadi gangguan sinyal internet di area pesantren.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Terapkan Service Locator Terstruktur (`get_it` / `injector.dart`)
Pindahkan inisialisasi dependensi ke file konfigurasi DI khusus (`lib/core/di/injection.dart`):
```dart
final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Core Services
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<DioClient>(() => DioClient(secureStorage: getIt()));

  // Repositories (Lazy Singleton - hanya dibuat saat pertama kali dipanggil)
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt(), getIt()));
  getIt.registerLazySingleton<SppRepository>(() => SppRepository(getIt()));
  getIt.registerLazySingleton<DashboardRepository>(() => DashboardRepository(getIt()));
  // ...
}
```
Dengan demikian, `main.dart` kembali ramping dan fokus pada konfigurasi root widget.

### Langkah 2: Global Connectivity Watcher
Tambahkan listener jaringan (`connectivity_plus`) di root builder `MaterialApp`:
- Tampilkan *subtle offline bar* di bagian atas layar ketika koneksi terputus.
- Berikan tombol *“Coba Lagi”* otomatis begitu sinyal pulih.

### Langkah 3: Retry Policy untuk Idempotent GET Requests
Konfigurasikan Dio interceptor untuk otomatis mengulang request `GET` yang gagal akibat *temporary network glitch* (maksimal 2x retry dengan exponential backoff).

---

## 4. Kriteria Penerimaan (Acceptance Criteria)
- [x] Inisialisasi dependensi diisolasi ke dalam container terpusat `InjectionContainer` (`lib/core/di/injection_container.dart`).
- [x] Request HTTP `GET` yang bersifat idempotent memiliki mekanisme auto-retry pada fluktuasi sinyal internet di `DioClient`.
- [x] Penanganan status offline dan kegagalan jaringan terintegrasi secara elegan via formatDioError dan error boundary.
