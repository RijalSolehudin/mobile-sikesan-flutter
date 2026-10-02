# Task-concern-15: Ketiadaan Otentikasi Lapis Kedua untuk Mutasi Finansial (PIN / Biometrik)

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-15` |
| **Prioritas** | **P1 - High** |
| **Kategori** | Financial Security, Fraud Prevention, Compliance |
| **Komponen Terkait** | `withdraw_modal.dart`, `pay_spp_modal.dart`, `top_up_modal.dart`, paket `local_auth` |
| **Status** | Open / Pending Action |

---

## 1. Deskripsi Masalah (Problem Statement)
Fitur-fitur transaksi sensitif seperti penarikan saldo tabungan santri (`withdraw_modal.dart`), pembayaran SPP santri (`pay_spp_modal.dart`), dan transfer dompet saat ini dapat langsung dieksekusi begitu pengguna mengisi form dan menekan tombol *"Konfirmasi Bayar"*.

Tidak ada mekanisme tantangan otentikasi lapis kedua (*Step-Up Authentication* / 2FA) berupa:
- Masukan 6-digit PIN Transaksi Finansial.
- Sensor Biometrik (Fingerprint / Touch ID / Face ID) bawaan perangkat.

---

## 2. Dampak Risiko (Impact Analysis)
1. **Risiko Akses Tak Sah (Unattended Phone Fraud)**:
   Smartphone wali santri sering kali dipinjam oleh anak-anak atau diletakkan di meja tanpa kunci layar aktif. Siapa pun yang memegang smartphone dapat melakukan mutasi dana, penarikan saldo, atau pembayaran tanpa sepengetahuan wali santri.
2. **Kepatuhan Regulasi Dompet Digital / Fintech**:
   Standar keamanan perbankan dan fintech (seperti aturan BI/OJK untuk e-money) mewajibkan otorisasi faktor kedua (PIN/Biometrik) sebelum memindahkan atau mendebit dana pengguna.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Tambahkan Dependensi `local_auth`
Tambahkan paket resmi di `pubspec.yaml`:
```yaml
dependencies:
  local_auth: ^2.3.0
```

### Langkah 2: Buat `BiometricAuthService`
```dart
class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticateTransaction({required String reason}) async {
    final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canCheck) return true; // Fallback ke PIN jika perangkat tidak support biometrik

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
```

### Langkah 3: Sisipkan Verifikasi Sebelum Request API Finansial
Sebelum memanggil repository transaksi di modal pembayaran/penarikan, panggil dialog biometrik/PIN. Jika verifikasi gagal atau dibatalkan, hentikan proses pembayaran.

---

## 4. Checklist Penerimaan (Acceptance Criteria)
- [ ] Pengguna diminta memindai sidik jari / Face ID atau memasukkan PIN sebelum saldo dompet/tabungan santri didebit.
- [ ] Tersedia fallback ke PIN transaksi jika biometrik perangkat tidak aktif/tidak tersedia.
- [ ] Tidak ada mutasi dana yang dapat diproses tanpa lolos verifikasi lapis kedua.
