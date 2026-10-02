# Task-concern-16: Ketahanan Hardware KeyStore Android pada `SecureStorageService`

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-16` |
| **Prioritas** | **P2 - Medium** |
| **Kategori** | Local Security, Android Native Stability, Crash Prevention |
| **Komponen Terkait** | `lib/data/local/secure_storage_service.dart` |
| **Status** | Open / Pending Action |

---

## 1. Deskripsi Masalah (Problem Statement)
Implementasi [secure_storage_service.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/data/local/secure_storage_service.dart#L9-L10) saat ini:

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
```

Kelemahan teknis:
1. `FlutterSecureStorage` diinisialisasi tanpa opsi Android `encryptedSharedPreferences: true`.
2. Method `getToken()`, `saveToken()`, dan `saveUser()` tidak memiliki blok penanganan `try-catch` terhadap `PlatformException`.

---

## 2. Dampak Risiko (Impact Analysis)
Pada perangkat Android (terutama Samsung Knox dan Xiaomi MIUI/HyperOS), saat perangkat melakukan update versi OS, restore dari Google Cloud Backup, atau saat lockscreen/keystore di-reset oleh pengguna, Master Key hardware KeyStore dapat menjadi *invalid* atau *desynchronized*.
Ketika hal ini terjadi, pemanggilan `_storage.read(...)` melempar `PlatformException` (seperti `BadPaddingException` atau `KeyStoreException`).
Karena tidak ada `try-catch` di `SecureStorageService`, aplikasi akan mengalami **fatal crash seketika pada saat cold start / splash screen**.

---

## 3. Rencana Solusi Teknis (Technical Solution)

Konfigurasikan opsi enkripsi tangguh dengan mekanisme pemulihan otomatis (*Graceful Reset Fallback*):

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
              resetOnError: true, // Otomatis reset cache jika KeyStore korup daripada memicu crash
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      // Jika KeyStore korup, bersihkan sesi secara aman
      await clearAuth();
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (_) {
      await clearAuth();
      await _storage.write(key: AppConstants.tokenKey, value: token);
    }
  }
}
```

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [ ] `AndroidOptions(encryptedSharedPreferences: true, resetOnError: true)` aktif secara default.
- [ ] Seluruh pembacaan storage dibungkus `try-catch` pelindung agar tidak melempar `PlatformException` fatal ke UI thread.
- [ ] Pengujian simulasi invalid key berhasil me-reset storage ke state unauthenticated tanpa force close.
