# Task-concern-07: Ketiadaan Deklarasi Izin Kamera & Galeri di iOS (Fatal Crash on iOS)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-07` |
| **Prioritas** | **P0 - Critical (Blocker)** |
| **Kategori** | Native iOS, Compliance, Application Stability |
| **Komponen Terkait** | `ios/Runner/Info.plist`, modal upload bukti pembayaran (`pay_spp_modal.dart`, `pay_infaq_modal.dart`, `top_up_modal.dart`) |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)
Aplikasi menyediakan alur pembayaran manual dengan bukti transfer via upload kamera atau galeri foto di:
- [pay_spp_modal.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/spp/widget/pay_spp_modal.dart#L93)
- [pay_infaq_modal.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/infaq/widget/pay_infaq_modal.dart#L89)
- [top_up_modal.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/wallet/widget/top_up_modal.dart#L80)

Pada kode Dart, fungsi dipanggil menggunakan:
```dart
final XFile? image = await _picker.pickImage(
  source: source, // ImageSource.camera atau ImageSource.gallery
  imageQuality: 80,
);
```

Namun, di file manifest iOS [ios/Runner/Info.plist](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/ios/Runner/Info.plist), **tidak ada satupun entri permission Privacy Keys** yang dibutuhkan oleh Apple Framework.

---

## 2. Dampak Risiko (Impact Analysis)
1. **Crash Seketika (SIGABRT) di iOS**:
   Ketika pengguna iPhone/iPad menekan opsi *"Kamera"* atau *"Galeri"*, sistem iOS akan langsung menghentikan proses aplikasi seketika tanpa peringatan (*hard crash*) karena pelanggaran izin privasi OS (*This app has crashed because it attempted to access privacy-sensitive data without a usage description*).
2. **App Store Review Auto-Rejection**:
   Apple App Store Review Guidelines (Guideline 5.1.1 - Data Collection and Storage) mewajibkan pesan penggunaan privasi yang jelas. Binary yang dikirim ke TestFlight atau App Store Connect akan otomatis ditolak (*ITMS-90683: Missing Purpose String in Info.plist*).

---

## 3. Rencana Solusi Teknis (Technical Solution)

Tambahkan *key-value pair* privacy description berbahasa Indonesia yang sopan dan jelas ke dalam `<dict>` di [ios/Runner/Info.plist](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/ios/Runner/Info.plist):

```xml
	<key>NSCameraUsageDescription</key>
	<string>SIKESAN memerlukan izin akses kamera untuk mengambil foto bukti transfer pembayaran SPP, infaq, atau pengisian saldo.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>SIKESAN memerlukan izin akses galeri foto untuk memilih bukti transfer pembayaran yang tersimpan di perangkat Anda.</string>
```

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [x] Entri `NSCameraUsageDescription` dan `NSPhotoLibraryUsageDescription` telah terdaftar di `ios/Runner/Info.plist`.
- [x] Deskripsi izin kamera & galeri iOS menggunakan pesan bahasa Indonesia yang ramah, informatif, dan sesuai standar Apple Guideline 5.1.1.
- [x] Penanganan graceful jika permission ditolak atau dialog ditutup (`image == null` dan error exception aman di dalam try-catch block modal pembayaran).
