# SSOT (Single Source of Truth) - SIKESAN Flutter Architecture

## 1. Konsep Dasar & Arsitektur Folder (Layered Architecture)
Proyek diorganisasi ke dalam 4 folder root di dalam `lib/`:

```text
lib/
├── core/                       # Reusable logic, configurations, design tokens, & generic widgets
│   ├── constants/              # ApiEndpoints, AppConstants, AssetPaths
│   ├── network/                # DioClient, AuthInterceptor, ErrorInterceptor, ApiResult
│   ├── theme/                  # AppColors, AppTypography, AppShadows, AppTheme
│   ├── utils/                  # CurrencyFormatter, DateFormatter, Validators
│   └── widgets/                # Reusable UI components (Buttons, Inputs, Cards, Badges)
│
├── data/                       # Data layer (Contracts, Models, Repositories, Services)
│   ├── local/                  # SecureStorageService, SharedPrefService
│   ├── models/                 # Request & Response DTOs (@freezed + @JsonSerializable)
│   ├── repositories/           # Repositories (Menggabungkan Remote & Local source)
│   └── services/               # Remote Api Services (Dio HTTP calls)
│
├── features/                   # Screen UI & Feature Logic (BLoC)
│   ├── auth/                   # screen/, widget/, bloc/ (AuthBloc)
│   ├── dashboard/              # screen/, widget/, bloc/ (DashboardBloc)
│   ├── mutation/               # screen/, widget/
│   ├── information/            # screen/, widget/
│   ├── cs_sikesan/             # screen/, widget/
│   ├── profile/                # screen/, widget/
│   ├── navigation/             # screen/, widget/
│   ├── spp/                    # widget/, bloc/ (SppPaymentBloc)
│   ├── infaq/                  # widget/
│   └── wallet/                 # widget/
│
├── router/                     # Routing System
│   ├── app_router.dart         # GoRouter with StatefulShellRoute
│   └── auth_guard.dart         # Guard logic (Redirect unauthenticated/authenticated)
│
└── main.dart                   # Entry point, dependency injection / MultiRepositoryProvider / MultiBlocProvider
```

---

## 2. State Management Standard: BLoC + Freezed
Setiap BLoC memiliki 3 elemen:
1. **Event (`@freezed`):** Mendefinisikan aksi pengguna (contoh: `DashboardEvent.fetchMetrics()`, `DashboardEvent.changeCarouselIndex(int index)`).
2. **State (`@freezed`):** Mendefinisikan state UI (`initial`, `loading`, `loaded(data)`, `error(message)`).
3. **Bloc:** Menghubungkan Event dengan Repository dan memancarkan State baru.

---

## 3. Network & API Handling: Dio + Sanctum Interceptor
- **Base URL:** Diatur di `ApiEndpoints.baseUrl`.
- **AuthInterceptor:**
  - Menambahkan `Authorization: Bearer <token>` secara otomatis jika token tersedia di `SecureStorageService`.
  - Menambahkan `Accept: application/json`.
  - Menambahkan header `Idempotency-Key` (UUID v4) untuk aksi mutasi (`POST`).
- **ErrorInterceptor:**
  - `401 Unauthorized`: Memanggil `AuthRepository.logout()` dan redirect ke `/login`.
  - `422 Unprocessable Entity`: Mengurai objek `errors` Laravel menjadi pesan validasi spesifik.
  - `500 / Network Error`: Mengembalikan pesan ramah pengguna.

---

## 4. Local Storage Strategy
- **`FlutterSecureStorage`:** Khusus data sensitif (`access_token`, user credentials).
- **`SharedPreferences`:** Konfigurasi UI (Dark/Light mode, caching dynamic role menu config).

---

## 5. Acuan Arsitektur & Modularitas (SOT Panduan AI & Developer)
1. **Komponen Global & Reusable (Tempatkan di folder `core/` atau `data/`):**
   - Jika suatu elemen digunakan berulang kali di berbagai fitur (cross-feature), wajib dibuat secara generik dan diletakkan di `core/` (misal: `core/constants/` untuk enum dan konstanta, `core/utils/` untuk helper/formatter, `core/widgets/` untuk modal/snackbar/dialog/button generik, `core/services/` untuk service global) atau `data/` (models, repositories).
2. **Komponen Spesifik Fitur (Cegah God File):**
   - Jika suatu elemen spesifik untuk satu fitur saja (tidak reusable), pisahkan ke dalam file/class tersendiri di dalam fitur tersebut (`features/<feature_name>/widget/`, `screen/`, `bloc/`). Dilarang mencampur semua logika ke dalam satu file besar (god file).
3. **Standar Penggunaan Enum:**
   - Himpunan data terbatas (metode pembayaran, status tagihan, status transaksi, peran pengguna) wajib menggunakan `enum` type-safe, bukan magic string.

---

## 6. Larangan Data Dummy, Statis, & Hardcoded
- Dilarang keras menyematkan data dummy, statis, atau hardcoded di dalam source code tanpa integrasi data backend yang riil (misal rekening bank statis, tarif SPP fiktif, mock berita).
- Jika ada fitur atau bagian UI yang belum tersedia atau belum selesai terhubung dengan API backend, wajib ditandai secara eksplisit dengan placeholder:
  `"belum terintegrasi dengan data backend"`

