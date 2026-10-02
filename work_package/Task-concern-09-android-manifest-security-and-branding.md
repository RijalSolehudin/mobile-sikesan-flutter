# Task-concern-09: Android Manifest Security Hardening & App Launcher Branding

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-09` |
| **Prioritas** | **P1 - High** |
| **Kategori** | Native Android, Mobile Security, Branding |
| **Komponen Terkait** | `android/app/src/main/AndroidManifest.xml` |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)
Di dalam [android/app/src/main/AndroidManifest.xml](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/android/app/src/main/AndroidManifest.xml), terdapat beberapa konfigurasi bawaan boilerplate Flutter yang belum disesuaikan untuk standar aplikasi finansial produksi:

1. **Branding Aplikasi**:
   ```xml
   android:label="mobile_sikesan_flutter"
   ```
   Nama yang tampil di bawah ikon launcher di perangkat pengguna adalah nama package repository teknis, bukan nama produk formal (`SIKESAN`).
2. **Ketiadaan Proteksi Backup ADB (`allowBackup`)**:
   Secara default, jika atribut `android:allowBackup` tidak diset `false`, sistem Android mengizinkan tools debug seperti Android Debug Bridge (ADB) mengekspor data *shared_preferences*, database lokal, dan file cache aplikasi ke komputer eksternal.
3. **Ketiadaan Kebijakan Lalu Lintas Jaringan Jelas (`usesCleartextTraffic`)**:
   Tidak ada deklarasi penolakan traffic HTTP biasa tanpa enkripsi SSL.

---

## 2. Dampak Risiko (Impact Analysis)
- **Kredibilitas Produk / User Experience**: Tampilan nama `mobile_sikesan_flutter` di layar beranda HP wali santri terlihat tidak profesional dan menimbulkan keraguan keamanan pengguna.
- **Kebocoran Data Finansial (ADB Sandbox Leak)**: Jika HP santri/wali santri dipinjam atau dihubungkan ke komputer melalui mode USB Debugging, data cache sesi finansial dapat di-dump melalui perintah `adb backup`.
- **Man-in-the-Middle (MitM) Vulnerability**: Membiarkan cleartext traffic berpotensi membuka celah sniffing data pada jaringan Wi-Fi publik tanpa proteksi TLS/HTTPS.

---

## 3. Rencana Solusi Teknis (Technical Solution)

Perbarui tag `<application>` di [android/app/src/main/AndroidManifest.xml](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/android/app/src/main/AndroidManifest.xml):

```xml
    <application
        android:label="SIKESAN"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:fullBackupContent="false"
        android:usesCleartextTraffic="false">
```

> [!NOTE]
> Jika selama masa pengujian lokal emulator diperlukan koneksi ke backend HTTP lokal (`http://10.0.2.2:8000`), gunakan konfigurasi terpisah pada `android/app/src/debug/AndroidManifest.xml` dengan `network_security_config` khusus, bukan membuka celah cleartext di production manifest.

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [x] Nama label aplikasi di Android terpasang menjadi `"SIKESAN"` pada launcher OS.
- [x] `android:allowBackup="false"` dan `android:fullBackupContent="false"` telah terpasang untuk mencegah backup sandbox data keuangan via ADB.
- [x] Proteksi keamanan manifest native Android siap dan aman untuk rilis produksi.
