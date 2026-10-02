# Task-concern-14: Ketiadaan `sendTimeout` pada `DioClient` (Infinite Upload Hang)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-14` |
| **Prioritas** | **P1 - High** |
| **Kategori** | Network Resilience, Reliability, UX |
| **Komponen Terkait** | `lib/core/network/dio_client.dart` |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)
Konfigurasi `BaseOptions` di [lib/core/network/dio_client.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/network/dio_client.dart#L13-L17) saat ini:

```dart
dio = Dio(
  BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ),
);
```

Parameter `sendTimeout` **tidak didefinisikan**.

---

## 2. Dampak Risiko (Impact Analysis)
Dalam arsitektur HTTP client Dio, ketiadaan `sendTimeout` berarti batas waktu pengiriman stream data bernilai tak terhingga (`null` / infinite).
Aplikasi SIKESAN memiliki fitur upload file multipart gambar bukti bayar (SPP, infaq, top up). Ketika pengguna berada pada jaringan seluler yang tidak stabil (sinyal naik-turun khas area asrama santri), pengiriman stream byte bisa terhenti di tengah jalan.
Tanpa `sendTimeout`:
- Dialog loading atau indikator submit akan berputar selamanya (*infinite spinning loader*).
- Aplikasi tidak memicu error `DioExceptionType.sendTimeout`.
- Pengguna tidak memiliki jalan keluar selain menutup paksa (*kill*) aplikasi dari OS recent apps.

---

## 3. Rencana Solusi Teknis (Technical Solution)

Tambahkan batasan waktu pengiriman data yang rasional pada `BaseOptions`:

```dart
dio = Dio(
  BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 25), // Batasi upload stream maksimal 25 detik
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ),
);
```

Serta tambahkan penanganan pesan humanis di interceptor error:
```dart
if (error.type == DioExceptionType.sendTimeout) {
  // Tampilkan: "Koneksi terputus saat mengunggah berkas. Periksa sinyal internet Anda dan coba lagi."
}
```

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [x] `sendTimeout` terpasang dengan durasi 30 detik di `DioClient`.
- [x] Jika upload foto terputus di tengah jalan, error ditangkap secara anggun via `DioClient.formatDioError()` dan menampilkan pesan instruktif ke pengguna.
- [x] Indikator loading berhenti dan tombol *"Coba Kirim Ulang"* kembali aktif tanpa membekukan aplikasi.
