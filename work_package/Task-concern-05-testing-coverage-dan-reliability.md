# Task-concern-05: Test Coverage, Widget Testing, & Reliability Pipeline

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-05` |
| **Prioritas** | **P2 - Medium (Quality Assurance & Regression Shield)** |
| **Kategori** | Testing, CI/CD, Quality Engineering |
| **Komponen Terkait** | Folder `test/`, `test/widget_test.dart`, Modal Pembayaran SPP/Infaq |
| **Status** | Completed / Verified |

---

## 1. Deskripsi Masalah (Problem Statement)
Saat ini proyek mencatat hasil pengujian:
```text
00:02 +28: All tests passed!
```
Meskipun seluruh 28 test lulus, pengujian tersebut memberikan **False Sense of Security (rasa aman semu)**:

1. **Ketiadaan Widget Tests pada Alur Transaksi**:
   - Hampir 100% test yang ada adalah *Unit Test* untuk BLoC (`auth_bloc_test.dart`, `dashboard_bloc_test.dart`, `spp_payment_bloc_test.dart`) dan formatting mata uang.
   - Tidak ada satupun *Widget Test* yang memverifikasi form interaktif di dalam modal transaksi (SPP, Infaq, Top Up, Tarik Tunai) yang menampung ribuan baris kode interaktif.
2. **Ketiadaan Test Validasi Form & Error State**:
   - Tidak ada pengujian bahwa tombol "Bayar SPP" harus berstatus *disabled* jika belum ada santri atau bulan yang dipilih.
   - Tidak ada pengujian respon UI ketika backend mengembalikan validasi error HTTP `422 Unprocessable Entity` (misal: "Tagihan bulan tersebut telah dibayar oleh wali santri lain").
3. **Smoke Test Minimal**:
   - `widget_test.dart` hanya menjalankan satu kali `pumpWidget(SikesanMobileApp)` tanpa menguji interaksi navigasi atau perpindahan halaman sama sekali.

---

## 2. Dampak Risiko (Impact Analysis)
- **Regression Bugs**: Refactoring kode UI atau perubahan style dapat secara tidak sengaja mematahkan alur checkout pembayaran tanpa terdeteksi oleh CI test suite saat ini.
- **Edge-Case Failure**: Masalah seperti input nominal negatif, karakter khusus pada kolom pencarian, atau file gambar bukti transfer yang corrupt baru ditemukan saat sudah digunakan oleh pengguna riil di lapangan.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Buat Widget Test untuk Form Pembayaran SPP (`test/features/spp/pay_spp_modal_test.dart`)
Uji skenario-skenario kritis:
1. Modal terbuka dengan benar dan menampilkan daftar santri asuhan wali.
2. Memilih bulan ke-10 (Oktober) otomatis memilih bulan ke-8 dan ke-9 jika belum lunas (Aturan FIFO).
3. Tombol "Konfirmasi & Bayar" dinonaktifkan jika belum ada bulan yang dipilih.
4. Muncul SnackBar error jika API mengembalikan `ApiFailure`.

```dart
testWidgets('PaySppModal disables submit button when no month is selected', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PaySppModalContent(...),
      ),
    ),
  );

  final submitBtn = find.widgetWithText(ElevatedButton, 'Konfirmasi & Bayar');
  expect(tester.widget<ElevatedButton>(submitBtn).enabled, isFalse);
});
```

### Langkah 2: Mock Dio HTTP Adapter untuk Repository Testing
Gunakan `http_mock_adapter` atau Mockito untuk menguji repository terhadap berbagai variasi respon server:
- Skenario sukses: `200 OK` dengan payload JSON valid.
- Skenario validasi gagal: `422 Unprocessable Entity` dengan rincian `errors`.
- Skenario server down: `500 Internal Server Error` & `Connection Timeout`.

### Langkah 3: Integrasikan ke GitHub Actions CI Pipeline
Pastikan file `.github/workflows/ci.yml` menjalankan `flutter test --coverage` dan menggagalkan merge pull request jika coverage menurun.

---

## 4. Kriteria Penerimaan (Acceptance Criteria)
- [x] Test coverage mencakup skenario UI form transaksi utama (SPP submit button disabled/enabled/loading & summary card).
- [x] Terdapat pengujian otomatis untuk aturan bisnis FIFO pembayaran SPP (`SppFifoHelper`).
- [x] Repository memiliki unit test untuk handling status code `200`, `401`, `422`, dan `500` (`spp_repository_test.dart`).
- [x] Seluruh test dapat dijalankan di CI environment secara headless tanpa error (`52 tests passed`).
