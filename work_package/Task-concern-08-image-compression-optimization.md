# Task-concern-08: Ketiadaan Pembatasan Dimensi & Kompresi Gambar Upload Bukti Transfer

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-08` |
| **Prioritas** | **P1 - High** |
| **Kategori** | Performance, Network Optimization, Reliability |
| **Komponen Terkait** | `lib/features/spp/widget/pay_spp_modal.dart`, `lib/features/infaq/widget/pay_infaq_modal.dart`, `lib/features/wallet/widget/top_up_modal.dart` |
| **Status** | **Selesai (Resolved / Completed)** |

---

## 1. Deskripsi Masalah (Problem Statement)
Pada seluruh modal pembayaran manual yang memerlukan upload struk/bukti transfer, pemanggilan `image_picker` saat ini hanya mengandalkan:
```dart
final XFile? image = await _picker.pickImage(
  source: source,
  imageQuality: 80,
);
```

Parameter `maxWidth` dan `maxHeight` tidak didefinisikan sama sekali, serta tidak ada validasi ukuran berkas (*file size limit*) sebelum berkas dikirimkan via multipart HTTP.

---

## 2. Dampak Risiko (Impact Analysis)
1. **Out-of-Memory (OOM) Crash di Perangkat Low-End**:
   Kamera smartphone modern (48 MP – 200 MP) menghasilkan foto berdimensi 6000x8000+ pixel. Mengolah dan me-render bitmap resolusi tinggi ini tanpa scaling akan memakan lonjakan alokasi memori puluhan hingga ratusan megabyte di heap memory Android/iOS, memicu Force Close (OOM).
2. **Lonjakan Konsumsi Bandwidth & Request Timeout**:
   Ukuran file foto mentah tetap berkisar antara 4 MB hingga 12 MB meskipun kualitas diatur 80. Di area lingkungan pesantren atau daerah sub-urban dengan penetrasi sinyal 3G/4G atau Wi-Fi yang padat, upload file sebesar ini memakan waktu sangat lama dan rentan mengalami `DioExceptionType.sendTimeout`.
3. **Beban Storage & IO Backend**:
   Menyimpan file multi-megabyte untuk sekadar struk bukti transfer memboroskan kuota storage server backend dan memperlambat waktu muat dashboard admin/bendahara santri.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Batasi Resolusi pada Saat Pengambilan Gambar
Tambahkan batasan `maxWidth` dan `maxHeight` standar dokumen (maksimal 1440x1440 pixel sudah sangat jelas untuk membaca nomor rekening, tanggal, dan nominal pada struk):

```dart
final XFile? image = await _picker.pickImage(
  source: source,
  maxWidth: 1440,
  maxHeight: 1440,
  imageQuality: 75,
);
```

### Langkah 2: Buat Helper Validasi Ukuran File (Client-side Guard)
Buat utilitas `ImagePickerHelper` terpusat untuk memvalidasi batas maksimum berkas sebelum di-upload ke backend (misalnya maksimal 2 MB):

```dart
class ImageUploadHelper {
  static const int maxFileSizeBytes = 2 * 1024 * 1024; // 2 MB

  static Future<bool> validateFileSize(XFile file) async {
    final int length = await file.length();
    return length <= maxFileSizeBytes;
  }
}
```

Jika melebihi kuota, beri feedback `SnackBar` edukatif: *"Ukuran gambar bukti transfer terlalu besar (maksimal 2MB). Harap ambil ulang atau pilih foto lain."*

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [x] Semua pemanggilan `pickImage` di SPP, Infaq, dan Wallet menyertakan `maxWidth: 1440`, `maxHeight: 1440`, dan `imageQuality: 75` melalui `ImageUploadHelper.pickImageWithCompression()`.
- [x] Helper validasi ukuran file `ImageUploadHelper.validateFileSize()` terpasang untuk mencegah pengiriman file melebihi batas 2MB.
- [x] SnackBar peringatan edukatif muncul jika pengguna memilih file yang melebihi batas 2MB sebelum proses upload dimulai.
- [x] Unit test untuk `ImageUploadHelper` terpasang di `test/core/image_upload_helper_test.dart`.
