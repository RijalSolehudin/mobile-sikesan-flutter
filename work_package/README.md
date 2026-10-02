# Work Package: Architectural Audit & Production Concerns

Dokumen ini berisi daftar paket pekerjaan (*work packages*) hasil *code audit* kritis arsitektur, keamanan, keandalan, native platform, dan UX aplikasi mobile **SIKESAN (Sistem Keuangan Santri)**.

Seluruh tugas diurutkan berdasarkan tingkat urgensi dan dampak risiko (*Criticality Order*):

| No | Task ID | File Dokumen | Prioritas | Area / Kategori | Estimasi Dampak |
|:---:|---|---|:---:|---|---|
| **1** | `TASK-CONC-01` | [Task-concern-01-ephemeral-cloudflare-url-dan-environment.md](./Task-concern-01-ephemeral-cloudflare-url-dan-environment.md) | **P0 (Critical)** | Infrastruktur, Network, DevOps | **Selesai (Completed)**: Multi-environment config & `--dart-define` terpasang. |
| **2** | `TASK-CONC-07` | [Task-concern-07-ios-permissions-camera-gallery.md](./Task-concern-07-ios-permissions-camera-gallery.md) | **P0 (Critical)** | Native iOS, Privacy & Compliance | **Selesai (Completed)**: Deklarasi izin kamera & galeri di `Info.plist` terpasang. |
| **3** | `TASK-CONC-12` | [Task-concern-12-app-id-and-bundle-identifier-store-blocker.md](./Task-concern-12-app-id-and-bundle-identifier-store-blocker.md) | **P0 (Critical)** | Native Android/iOS, Store Compliance | **Selesai (Completed)**: Identifier resmi `id.ponpes.sikesan` terpasang di Android & iOS. |
| **4** | `TASK-CONC-13` | [Task-concern-13-global-error-boundary-and-crash-observability.md](./Task-concern-13-global-error-boundary-and-crash-observability.md) | **P0 (Critical)** | Architecture & Production Stability | **Selesai (Completed)**: Global Error Boundary & `AppCrashFallbackScreen` terpasang. |
| **5** | `TASK-CONC-02` | [Task-concern-02-god-modals-dan-arsitektur-state-management.md](./Task-concern-02-god-modals-dan-arsitektur-state-management.md) | **P1 (High)** | UI Modularization & State Management | **Selesai (Completed)**: Dekomposisi sub-widget SPP (`spp_*`) & `SppFifoHelper`. |
| **6** | `TASK-CONC-03` | [Task-concern-03-security-session-dan-token-refresh.md](./Task-concern-03-security-session-dan-token-refresh.md) | **P1 (High)** | Security & Keandalan Transaksi | **Selesai (Completed)**: `QueuedInterceptorsWrapper`, silent refresh, & timeout background. |
| **7** | `TASK-CONC-08` | [Task-concern-08-image-compression-optimization.md](./Task-concern-08-image-compression-optimization.md) | **P1 (High)** | Performance & Network Optimization | **Selesai (Completed)**: Kompresi gambar 1440px & `ImageUploadHelper` batas 2MB. |
| **8** | `TASK-CONC-09` | [Task-concern-09-android-manifest-security-and-branding.md](./Task-concern-09-android-manifest-security-and-branding.md) | **P1 (High)** | Native Android Security & Branding | **Selesai (Completed)**: Label SIKESAN & proteksi `allowBackup="false"`. |
| **9** | `TASK-CONC-14` | [Task-concern-14-dio-send-timeout-and-network-hang.md](./Task-concern-14-dio-send-timeout-and-network-hang.md) | **P1 (High)** | Network Resilience & UX | **Selesai (Completed)**: `sendTimeout: 30s` & penanganan error humanis. |
| **10** | `TASK-CONC-15` | [Task-concern-15-biometric-and-transaction-pin-security.md](./Task-concern-15-biometric-and-transaction-pin-security.md) | **P1 (High)** | Financial Security & Fraud Prevention | **Selesai (Completed)**: Otentikasi Biometrik & 6-digit PIN pada seluruh mutasi dana. |
| **11** | `TASK-CONC-04` | [Task-concern-04-accessibility-text-scaling-dan-layout-overflow.md](./Task-concern-04-accessibility-text-scaling-dan-layout-overflow.md) | **P2 (Medium)** | UI Accessibility & Layout Stability | **Selesai (Completed)**: TextScaler clamp (0.85–1.20) & slider responsif. |
| **12** | `TASK-CONC-05` | [Task-concern-05-testing-coverage-dan-reliability.md](./Task-concern-05-testing-coverage-dan-reliability.md) | **P2 (Medium)** | QA, Test Automation, & CI | **Selesai (Completed)**: Widget test modal checkout, unit test FIFO SPP, & status code (52 test lulus). |
| **13** | `TASK-CONC-10` | [Task-concern-10-pdf-generation-background-isolate.md](./Task-concern-10-pdf-generation-background-isolate.md) | **P2 (Medium)** | Performance & Background Isolate | **Selesai (Completed)**: Background isolate `compute()` pada rendering PDF kuitansi. |
| **14** | `TASK-CONC-11` | [Task-concern-11-auth-cold-start-sync-and-rbac.md](./Task-concern-11-auth-cold-start-sync-and-rbac.md) | **P2 (Medium)** | Security & RBAC Profile Sync | **Selesai (Completed)**: Optimistic auth & background profile sync saat cold start. |
| **15** | `TASK-CONC-16` | [Task-concern-16-secure-storage-android-keystore-resilience.md](./Task-concern-16-secure-storage-android-keystore-resilience.md) | **P2 (Medium)** | Android KeyStore & Crash Resilience | **Selesai (Completed)**: Enkripsi KeyStore & graceful recovery `resetOnError: true`. |
| **16** | `TASK-CONC-06` | [Task-concern-06-network-resilience-dan-dependency-injection.md](./Task-concern-06-network-resilience-dan-dependency-injection.md) | **P3 (Moderate)** | Architecture & Offline Experience | **Selesai (Completed)**: `InjectionContainer` terpusat & retry policy request GET. |

---

## Petunjuk Eksekusi Tim Berdasarkan Fase Rilis

### Fase 1: Pra-Rilis & Kepatuhan Toko Aplikasi (P0 - Blocker)
1. `TASK-CONC-01`: Migrasi dari ephemeral tunnel Cloudflare ke domain backend staging/prod tetap.
2. `TASK-CONC-07`: Tambahkan permission kamera & galeri di `Info.plist` agar iOS tidak crash seketika.
3. `TASK-CONC-12`: Ubah Application ID dan Bundle ID dari `com.example.*` ke domain resmi pesantren.
4. `TASK-CONC-13`: Pasang Global Error Boundary & penanganan crash di `main.dart`.

### Fase 2: Stabilitas Jaringan & Keamanan Transaksi Finansial (P1 - High)
1. `TASK-CONC-08`: Terapkan batas dimensi `maxWidth`/`maxHeight` pada upload foto bukti bayar.
2. `TASK-CONC-09`: Perbaiki `android:label="SIKESAN"` dan matikan `allowBackup="false"`.
3. `TASK-CONC-14`: Pasang `sendTimeout` di `DioClient` untuk mencegah proses upload menggantung.
4. `TASK-CONC-15`: Pasang verifikasi Biometrik / PIN sebelum mutasi dana dan penarikan saldo.
5. `TASK-CONC-02` & `TASK-CONC-03`: Modularisasi modal pembayaran ribuan baris dan perbaiki alur token refresh.

### Fase 3: Optimasi UX, Performa & Ketahanan Perangkat (P2 & P3)
1. `TASK-CONC-16`: Perkuat `SecureStorageService` terhadap error Android KeyStore.
2. `TASK-CONC-10`: Pindahkan generasi file PDF kuitansi ke background isolate (`compute()`).
3. `TASK-CONC-11`: Sinkronisasi profil latar belakang saat cold start.
4. `TASK-CONC-04`, `TASK-CONC-05`, dan `TASK-CONC-06`: Audit aksesibilitas, unit test checkout, dan offline caching.
