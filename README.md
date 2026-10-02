# SIKESAN Mobile (Flutter)

Aplikasi Mobile Keuangan Santri (SIKESAN) untuk Pondok Pesantren berbasis Flutter.

---

## 🌍 Multi-Environment Configuration

Aplikasi mendukung konfigurasi multi-environment menggunakan compile-time environment variables (`--dart-define` atau `--dart-define-from-file`).

### Konfigurasi Environment File (`env/`):

1. **Development (`env/dev.json`)**:
   ```json
   {
     "ENV": "dev",
     "API_BASE_URL": "http://10.0.2.2:8000/api/v1",
     "ENABLE_LOGGING": true
   }
   ```
   *Catatan: Gunakan `http://localhost:8000/api/v1` untuk iOS Simulator / macOS / Web, atau `http://10.0.2.2:8000/api/v1` untuk Android Emulator.*

2. **Staging (`env/staging.json`)**:
   ```json
   {
     "ENV": "staging",
     "API_BASE_URL": "https://api-staging.sikesan.ponpes.id/api/v1",
     "ENABLE_LOGGING": true
   }
   ```

3. **Production (`env/prod.json`)**:
   ```json
   {
     "ENV": "prod",
     "API_BASE_URL": "https://api.sikesan.ponpes.id/api/v1",
     "ENABLE_LOGGING": false
   }
   ```

---

## 🚀 Menjalankan Aplikasi

### 1. Menjalankan di Local / Development:
```bash
# Menggunakan file config dev
flutter run --dart-define-from-file=env/dev.json

# Atau dengan parameter langsung
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

### 2. Menjalankan di Staging:
```bash
flutter run --dart-define-from-file=env/staging.json
```

### 3. Menjalankan di Production:
```bash
flutter run --dart-define-from-file=env/prod.json
```

---

## 📦 Build Release

### Build Android APK:
```bash
# Staging APK
flutter build apk --release --dart-define-from-file=env/staging.json

# Production APK
flutter build apk --release --dart-define-from-file=env/prod.json
```

### Build Android App Bundle (AAB untuk Google Play Store):
```bash
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

### Build Web (PWA):
```bash
# Staging Web
flutter build web --release --base-href "/m/" --dart-define-from-file=env/staging.json

# Production Web
flutter build web --release --base-href "/m/" --dart-define-from-file=env/prod.json
```

---

## 🧪 Testing

Jalankan seluruh unit dan widget test:
```bash
flutter test
```

Analisis linting:
```bash
flutter analyze
```
