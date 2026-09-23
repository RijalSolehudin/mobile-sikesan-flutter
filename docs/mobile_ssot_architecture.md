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
│   ├── auth/                   # login_screen, bloc (AuthBloc)
│   ├── dashboard/              # home_screen, widgets, bloc (DashboardBloc)
│   ├── mutation/               # mutation_screen, widgets, bloc (MutationBloc)
│   ├── information/            # info_screen, widgets, bloc (InformationBloc)
│   ├── cs_sikesan/             # cs_screen (placeholder), bloc
│   ├── profile/                # profile_screen, change_password_screen, bloc
│   └── navigation/             # main_navigation_shell, custom_curved_bottom_bar
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
