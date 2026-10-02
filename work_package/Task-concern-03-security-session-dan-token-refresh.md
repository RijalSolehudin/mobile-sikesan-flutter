# Task-concern-03: Security Session, Silent Token Refresh, & Idempotency Key Handling

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-03` |
| **Prioritas** | **P1 - High (Keamanan & Keandalan Transaksi)** |
| **Kategori** | Security, Network Interceptor, Auth Session |
| **Komponen Terkait** | `lib/core/network/dio_client.dart`, `lib/core/services/session_timeout_listener.dart`, `lib/data/repositories/` |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)

### 1. Ketiadaan Silent Token Refresh (Abrupt Logout)
Di dalam [dio_client.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/network/dio_client.dart#L33-L39):
```dart
onError: (DioException error, handler) async {
  if (error.response?.statusCode == 401) {
    await secureStorage.clearAuth();
    onUnauthorized?.call();
  }
  return handler.next(error);
}
```
Ketika Access Token kedaluwarsa (misalnya setelah 24 jam atau 7 hari):
- Jika seorang wali santri sedang menyelesaikan form pembayaran SPP atau melihat rincian tagihan, request berikutnya langsung menghasilkan HTTP `401`.
- Interceptor langsung menghapus sesi dan menendang pengguna ke halaman Login secara tiba-tiba tanpa mencoba memperbarui token via Refresh Token (`POST /auth/refresh`).

### 2. Keterbatasan `SessionTimeoutListener`
[session_timeout_listener.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/services/session_timeout_listener.dart) saat ini memantau interaksi sentuhan layar (`PointerDownEvent`). Namun:
- Belum memantau perubahan status siklus hidup aplikasi (`AppLifecycleState.paused / resumed`).
- Jika bendahara membuka aplikasi, lalu meminimize aplikasi ke background selama 2 jam, saat aplikasi dibuka kembali sesinya belum terverifikasi secara instan apakah batas inaktivitas telah terlewati.

### 3. Masking Data Sensitif pada Logging
Di `DioClient._maskSensitiveMap`, masking hanya memeriksa beberapa key tertentu (`password`, `token`, `access_token`). Pada transaksi perbankan/pesantren, parameter seperti `pin`, `security_code`, `nominal`, atau `no_rekening` berpotensi terekspos di log debug konsol.

### 4. Idempotency Key Management pada Retry
Pada operasi mutasi finansial (`POST /transactions/spp`, `POST /transactions/top-up`), Idempotency Key (`uuid.v4()`) digenerate di level method repository. Jika terjadi *network drop / retry* di level interceptor, UUID berisiko digenerate ulang sehingga berpotensi menyebabkan *double charge / double mutation* di backend.

---

## 2. Dampak Risiko (Impact Analysis)
- **Bad User Experience**: Pengguna merasa frustrasi karena sering "ter-logout sendiri" saat sesi token habis.
- **Financial Inconsistency**: Duplikasi transaksi mutasi jika idempotency key tidak di-*lock* per satu transaksi pengguna yang sama.
- **Compliance & Security**: Risiko kebocoran data sensitif ke log perangkat atau APM logging tools.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Implementasi QueuedInterceptor untuk Silent Token Refresh
Gunakan `QueuedInterceptorsWrapper` pada Dio untuk menahan request saat token sedang di-refresh:
```dart
dio.interceptors.add(
  QueuedInterceptorsWrapper(
    onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401) {
        final refreshToken = await secureStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            // Lakukan pembaruan token secara hening (silent refresh)
            final newAccessToken = await _performSilentTokenRefresh(refreshToken);
            
            // Retry request awal dengan token yang baru
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (_) {
            // Jika refresh token juga gagal/expired, barulah lakukan logout
            await secureStorage.clearAuth();
            onUnauthorized?.call();
          }
        } else {
          await secureStorage.clearAuth();
          onUnauthorized?.call();
        }
      }
      return handler.next(error);
    },
  ),
);
```

### Langkah 2: Audit Lifecycle pada `SessionTimeoutListener`
Tambahkan `WidgetsBindingObserver` pada `SessionTimeoutListener` untuk mencatat timestamp saat aplikasi masuk ke background (`didChangeAppLifecycleState`):
```dart
if (state == AppLifecycleState.resumed) {
  final elapsed = DateTime.now().difference(_lastBackgroundTimestamp);
  if (elapsed >= timeoutDuration) {
    _triggerTimeout();
  }
}
```

### Langkah 3: Bind Idempotency Key ke Objek Transaksi
Simpan `idempotencyKey` di dalam State form pembayaran (bukan digenerate ad-hoc saat mengirim request) sehingga tombol kirim ulang / retry akan mengirimkan Idempotency Key yang identik.

---

## 4. Kriteria Penerimaan (Acceptance Criteria)
- [x] Pengguna tidak ter-logout saat token access expired jika refresh token masih berlaku (*silent refresh* berhasil via `_performSilentTokenRefresh`).
- [x] Multiple request paralel saat token expired tidak memicu pemanggilan endpoint refresh berulang (ditangani oleh `QueuedInterceptorsWrapper`).
- [x] Sesi bendahara otomatis berakhir jika aplikasi ditinggal di background melebihi batas waktu 30 menit (diperiksa via `WidgetsBindingObserver` di `SessionTimeoutListener`).
- [x] Masking data sensitif (`pin`, `security_code`, `no_rekening`, `card_number`, `nik`) terpasang pada network logging `DioClient`.
- [x] Unit test `test/core/dio_client_security_test.dart` mengonfirmasi konfigurasi `QueuedInterceptorsWrapper` dan network error formatting.
