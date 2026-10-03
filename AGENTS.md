# Panduan Arsitektur & Standar Koding AI (Single Source of Truth)

Dokumen ini adalah acuan baku dan aturan permanen untuk semua agen AI dan pengembang dalam memodifikasi serta memelihara kode di repositori **SIKESAN Mobile Flutter**.

---

## 1. Prinsip Utama Arsitektur (Clean & Modular Architecture)

### Aturan 1: Komponen Global & Reusable (Tempatkan di Folder `core/` atau `data/`)
- Jika suatu komponen bersifat **global** dan digunakan berulang kali di berbagai fitur (cross-feature), komponen tersebut **WAJIB** dibuat secara generik, reusable, dan ditempatkan di:
  - `lib/core/`:
    - `constants/`: Enum global, API endpoints, AppConstants, AssetPaths.
    - `network/`: Dio client, interceptors, ApiResult contract.
    - `theme/`: Design tokens (AppColors, AppTypography, AppShadows, AppTheme).
    - `utils/`: Formatter, validator, date/currency helper, image compression.
    - `widgets/`: Reusable buttons, inputs, modal wrapper, custom snackbars, global dialogs.
    - `services/`: Global services (misal: PDF generator service, notification service).
  - `lib/data/`:
    - `local/`: SecureStorageService, SharedPrefService.
    - `models/`: DTOs, domain models, entity enums.
    - `repositories/`: Repository implementations.
- **DILARANG** menduplikasi helper, formatter, konstanta, atau widget umum di dalam folder fitur lokal.

### Aturan 2: Komponen Spesifik Fitur (Cegah God File)
- Jika suatu komponen bersifat **spesifik** untuk satu fitur dan tidak dapat digunakan ulang oleh fitur lain:
  - **WAJIB** ditempatkan di dalam folder fiturnya masing-masing: `lib/features/<feature_name>/`.
  - Dekomposisi sub-widget ke file/class terpisah (di folder `widget/` pada fitur terkait) untuk mencegah munculnya **god file / god class** (file dengan ratusan atau ribuan baris yang menggabungkan banyak tanggung jawab).
  - Pisahkan business logic ke dalam **BLoC** (`bloc/`) dan hindari meletakkan logic berat langsung di dalam `StatefulWidget`.

---

## 2. Larangan Data Dummy, Statis, & Hardcoded

- **DILARANG KERAS** menyematkan data dummy, statis, atau mock (seperti nomor rekening palsu, tarif SPP fiktif, pengumuman tiruan) di dalam kode produksi tanpa integrasi backend yang sesungguhnya.
- **Kewajiban Placeholder Backend:**
  - Jika suatu fitur, endpoint, atau bagian UI belum memiliki API backend yang aktif atau belum terintegrasi, tampilkan penanda/placeholder yang jelas dan eksplisit:
    `"belum terintegrasi dengan data backend"`
  - Jangan menyembunyikan ketiadaan API dengan data tiruan (mock) yang tampak seolah-olah data riil dari sistem.

---

## 3. Standar Penggunaan Enum (Type-Safety)

- Nilai yang memiliki himpunan terbatas (metode pembayaran, status transaksi, status tagihan, peran pengguna) **WAJIB** menggunakan `enum` Dart, bukan *magic string* (`String`).
- Pengecekan status atau role dilarang menggunakan manipulasi string acak (misal `.toLowerCase().contains(...)` yang tersebar di banyak tempat). Buat enum atau getter terpusat pada model terkait.

---

## 4. Struktur Folder Standar `lib/`

```text
lib/
├── core/                       # Reusable global logic, tokens, & generic widgets
│   ├── constants/              # Enums, ApiEndpoints, AppConstants
│   ├── network/                # DioClient, Interceptors, ApiResult
│   ├── theme/                  # AppColors, AppTypography, AppTheme
│   ├── utils/                  # Helper, Formatter, Validator
│   ├── widgets/                # Reusable UI components
│   └── services/               # Cross-cutting application services
│
├── data/                       # Data layer
│   ├── local/                  # SecureStorage, SharedPreferences
│   ├── models/                 # Request/Response models & Enums
│   ├── repositories/           # Repositories (Remote & Local data orchestration)
│   └── services/               # Remote Dio services
│
├── features/                   # Feature modules
│   └── <feature_name>/
│       ├── bloc/               # State management (Bloc, Event, State)
│       ├── screen/             # Top-level screen views
│       └── widget/             # Decomposed, modular sub-widgets
│
└── router/                     # GoRouter routing & navigation guards
```
