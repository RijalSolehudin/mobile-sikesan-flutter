# Task-concern-12: Penggantian ID Aplikasi Default `com.example.*` (Store Submission Blocker)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-12` |
| **Prioritas** | **P0 - Critical (Blocker)** |
| **Kategori** | Native Android, Native iOS, DevOps & Release Management |
| **Komponen Terkait** | `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj` |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)
Kedua platform native Android dan iOS masih menggunakan identifier bawaan generator Flutter:
- Android: `applicationId = "com.example.mobile_sikesan_flutter"` pada [build.gradle.kts](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/android/app/build.gradle.kts#L24)
- iOS: `PRODUCT_BUNDLE_IDENTIFIER = com.example.mobileSikesanFlutter` pada [project.pbxproj](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/ios/Runner.xcodeproj/project.pbxproj#L480)

---

## 2. Dampak Risiko (Impact Analysis)
1. **Penolakan Keras oleh Google Play Console & Apple App Store**:
   Kedua portal pengembang mewajibkan Application ID yang unik secara global dan secara eksplisit menolak pendaftaran aplikasi dengan domain contoh (`com.example.*`).
2. **Keterputusan Data jika Diubah Pasca Rilis**:
   Application ID adalah identitas permanen aplikasi di sistem operasi Android dan iOS. Jika aplikasi sempat didistribusikan ke pengguna lalu Application ID diubah, OS akan memperlakukannya sebagai dua aplikasi berbeda (pengguna lama tidak akan menerima auto-update dan data lokal akan hilang).

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Tetapkan Nomenklatur Bundle ID Resmi Pesantren
Gunakan domain resmi instansi / pesantren yang berformat *Reverse Domain Name*, contoh:
- Android: `id.ponpes.sikesan` atau `id.or.sikesan.mobile`
- iOS: `id.ponpes.sikesan` atau `id.or.sikesan.mobile`

### Langkah 2: Pembaruan Konfigurasi Android
Perbarui [android/app/build.gradle.kts](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/android/app/build.gradle.kts):
```kotlin
android {
    namespace = "id.ponpes.sikesan"
    // ...
    defaultConfig {
        applicationId = "id.ponpes.sikesan"
        // ...
    }
}
```

### Langkah 3: Pembaruan Konfigurasi iOS
Perbarui semua referensi `PRODUCT_BUNDLE_IDENTIFIER` di [ios/Runner.xcodeproj/project.pbxproj](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/ios/Runner.xcodeproj/project.pbxproj) menjadi `id.ponpes.sikesan`.

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [x] Tidak ada lagi string `com.example` di dalam folder `android/` maupun `ios/`.
- [x] Namespace dan Application ID Android diperbarui menjadi `id.ponpes.sikesan`, serta file `MainActivity.kt` telah dipindahkan ke direktori `android/app/src/main/kotlin/id/ponpes/sikesan/`.
- [x] iOS `PRODUCT_BUNDLE_IDENTIFIER` (Runner & RunnerTests) diperbarui menjadi `id.ponpes.sikesan` dan `id.ponpes.sikesan.RunnerTests`.
- [x] Paket aplikasi siap didaftarkan di Google Play Console dan Apple Developer Console tanpa resiko penolakan identifier contoh.
