# Task-concern-01: Ephemeral Cloudflare Tunnel & Ketiadaan Multi-Environment Config

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-01` |
| **Prioritas** | **P0 - Critical (Blocker)** |
| **Kategori** | Infrastruktur, Network, DevOps |
| **Komponen Terkait** | `lib/core/constants/api_endpoints.dart`, `lib/core/network/dio_client.dart` |
| **Status** | **Resolved / Completed** |

---

## 1. Deskripsi Masalah (Problem Statement)
Di dalam [api_endpoints.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/constants/api_endpoints.dart#L6-L8), URL API staging di-hardcode ke endpoint Cloudflare Quick Tunnel:
```dart
static const String defaultStagingUrl =
    'https://ears-very-solaris-affecting.trycloudflare.com/api/v1';
```

Domain `*.trycloudflare.com` adalah layanan *ephemeral tunnel* tanpa autentikasi Cloudflare Zero Trust berbayar/permanen. Karakteristik tunnel ini:
1. **Masa aktif acak**: URL akan langsung hangus dan berganti nama begitu sesi tunnel di server/laptop backend di-restart atau terputus koneksi.
2. **Ketiadaan Fallback**: Ketika URL mati, aplikasi langsung mengalami crash fungsional (`DioExceptionType.connectionError`, `502 Bad Gateway`, atau `404 Not Found`) untuk seluruh fitur tanpa ada indikasi yang jelas ke pengguna.
3. **Ketiadaan Build Flavors**: Tidak ada pemisahan lingkungan antara `development` (Localhost/LAN/Docker), `staging` (Server QA), dan `production` (Server Live Pesantren).

---

## 2. Dampak Risiko (Impact Analysis)
- **High Availability Breakdown**: Setiap kali backend server melakukan deploy/restart tunnel, seluruh tim QA, penguji, dan stakeholder tidak bisa mengakses aplikasi.
- **Risk of Production Leak**: Berisiko tinggi URL sementara ini terbawa hingga tahap *build release* APK/AAB Google Play Store atau iOS TestFlight.
- **Security & Compliance**: Layanan keuangan santri tidak boleh bergantung pada domain publik acak yang kepemilikannya tidak terverifikasi DNS-nya.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Migrasi ke Named Tunnel / Domain Resmi
Backend harus menggunakan **Cloudflare Named Tunnel** dengan DNS tetap yang diarahkan ke domain resmi pesantren, contoh:
- Development: `http://10.0.2.2:8000/api/v1` (Android Emulator) / `http://localhost:8000/api/v1`
- Staging: `https://api-staging.sikesan.ponpes.id/api/v1`
- Production: `https://api.sikesan.ponpes.id/api/v1`

### Langkah 2: Implementasi Environment Configuration via `--dart-define`
Ubah [api_endpoints.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/constants/api_endpoints.dart) agar sepenuhnya digerakkan oleh *compile-time environment variables*:

```dart
enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'staging');
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static AppEnvironment get environment {
    switch (_env.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      default:
        return AppEnvironment.staging;
    }
  }

  static String get baseUrl {
    if (_apiBaseUrl.isNotEmpty) {
      return _apiBaseUrl;
    }
    switch (environment) {
      case AppEnvironment.dev:
        return 'http://10.0.2.2:8000/api/v1';
      case AppEnvironment.staging:
        return 'https://api-staging.sikesan.ponpes.id/api/v1';
      case AppEnvironment.prod:
        return 'https://api.sikesan.ponpes.id/api/v1';
    }
  }
}
```

### Langkah 3: Konfigurasi File Env (`.env.staging.json`, `.env.prod.json`)
Buat file konfigurasi terpisah yang tidak di-*commit* secara publik jika ada kredensial sensitif:
```json
// env/staging.json
{
  "ENV": "staging",
  "API_BASE_URL": "https://api-staging.sikesan.ponpes.id/api/v1",
  "ENABLE_LOGGING": true
}
```
Jalankan aplikasi dengan:
```bash
flutter run --dart-define-from-file=env/staging.json
flutter build apk --dart-define-from-file=env/prod.json
```

---

## 4. Kriteria Penerimaan (Acceptance Criteria)
- [x] Tidak ada lagi string `trycloudflare.com` yang tertinggal di basis kode `lib/`.
- [x] Base URL dapat berganti secara otomatis sesuai flag compile `--dart-define-from-file`.
- [x] Koneksi ke staging menggunakan domain SSL terverifikasi (bukan ephemeral tunnel).
- [x] Dokumentasi cara menjalankan aplikasi di environment dev, staging, dan prod ditambahkan ke `README.md`.
