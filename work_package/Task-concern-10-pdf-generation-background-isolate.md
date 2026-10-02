# Task-concern-10: Generasi PDF Bukti Transaksi Memblokir Main UI Thread (Isolate Jank)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-10` |
| **Prioritas** | **P2 - Medium** |
| **Kategori** | Performance, Concurrency / Threading, UX Responsiveness |
| **Komponen Terkait** | `lib/core/services/receipt_pdf_service.dart` |
| **Status** | Open / Pending Action |

---

## 1. Deskripsi Masalah (Problem Statement)
Service [receipt_pdf_service.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/core/services/receipt_pdf_service.dart) adalah modul komprehensif (>1.000 baris kode) yang bertugas menyusun tanda terima resmi pembayaran (SPP, infaq, tagihan, dan dompet santri), merender tabel rincian, barcode/QR kode, logo pesantren, dan menghasilkan raw byte dokumen melalui `pdf.save()`.

Saat ini, seluruh proses kalkulasi layout PDF dan rendering byte dokumen dieksekusi langsung secara synchronous di dalam **Main UI Isolate** (thread utama Flutter yang juga bertanggung jawab merender 60/120 FPS animasi antarmuka).

---

## 2. Dampak Risiko (Impact Analysis)
1. **UI Freezing / Dropped Frames (Jank)**:
   Saat pengguna menekan tombol *"Unduh Bukti Transaksi"* atau *"Cetak Kuitansi"*, indikator loading (`CircularProgressIndicator`) akan berhenti berputar dan UI membeku selama 300 ms hingga 2 detik (tergantung spesifikasi prosesor HP santri).
2. **Keterbatasan Font Non-Latin**:
   Standar font bawaan paket `pdf` (`PdfFontFamily.helvetica`) tidak mendukung rendering karakter khusus/glif Arab/Pegon yang sangat umum dalam lingkungan pesantren (misal nama santri dalam bahasa Arab atau doa di header struk).

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Pindahkan Operasi `pdf.save()` ke Background Isolate Menggunakan `compute()`
Pisahkan fungsi penyusun data PDF menjadi *top-level function* atau *static function* yang dapat dijalankan di worker isolate:

```dart
Future<Uint8List> generateReceiptPdfInBackground(ReceiptData data) async {
  return await compute(_buildAndSavePdf, data);
}

// Dijalankan di isolate terpisah tanpa membebani Main UI Thread
Uint8List _buildAndSavePdf(ReceiptData data) {
  final pdf = pw.Document();
  // ... susun widget PDF ...
  return pdf.save();
}
```

Dengan pola ini, animasi progress loading di layar tetap berputar mulus 60 FPS tanpa jeda freeze.

### Langkah 2: Bundling Custom Unicode TTF Font
Muat font Google Fonts (seperti `Roboto` atau `NotoSansArabic`) dari assets atau memori agar teks Arab dan simbol rupiah selalu dirender dengan sempurna di dokumen kuitansi.

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [ ] Proses rendering dan encoding PDF dieksekusi di background isolate via `compute()`.
- [ ] Animasi loading UI tetap berjalan mulus (tanpa frame drop terdeteksi di Flutter DevTools Performance Overlay).
- [ ] Pengujian cetak kuitansi dengan teks panjang dan karakter khusus berhasil tanpa crash memori.
