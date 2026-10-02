# Task-concern-04: Accessibility, Dynamic Text Scaling, & Layout Overflow Prevention

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-04` |
| **Prioritas** | **P2 - Medium (UI Reliability & Inklusivitas)** |
| **Kategori** | UI/UX, Accessibility, Responsive Layout |
| **Komponen Terkait** | `lib/main.dart`, `student_wallet_slider.dart`, `dashboard_menu_grid.dart`, grid bulan SPP |
| **Status** | Open / Pending Action |

---

## 1. Deskripsi Masalah (Problem Statement)
Aplikasi SIKESAN digunakan oleh berbagai kalangan, termasuk orang tua / wali santri senior yang umumnya mengatur ukuran font perangkat mereka ke **Besar / Extra Large (130%–150%)** melalui pengaturan aksesibilitas sistem operasi iOS atau Android.

Di beberapa bagian antarmuka aplikasi, terdapat penggunaan ukuran dimensi kaku (*hardcoded height* & *fixed aspect ratio*):
1. **Student Wallet Slider**:
   ```dart
   SizedBox(
     height: 76,
     child: ListView.separated(...),
   )
   ```
   Di dalamnya terdapat tiga baris teks (Nama santri, Kelas, Nominal saldo). Ketika font membesar 1.3x, teks akan terpotong atau memicu **RenderFlex Overflowed by X pixels** (garis belang hitam-kuning).
2. **Grid Bulan SPP**:
   ```dart
   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
     crossAxisCount: 3,
     childAspectRatio: 2.6,
   )
   ```
   Rasio lebar-tinggi yang kaku ini menyebabkan nama bulan bertabrakan dengan ikon centang status ketika font diperbesar.
3. **Small Touch Targets**:
   Beberapa ikon aksi (seperti tombol centang pemilihan atau badge role) memiliki ukuran di bawah standar aksesibilitas minimum (48 x 48 dp menurut pedoman Material Design / WCAG).

---

## 2. Dampak Risiko (Impact Analysis)
- **Tampilan Rusak di HP Wali Santri**: Keluhan dari wali santri bahwa teks "menumpuk", "terpotong", atau muncul peringatan overflow visual di layar perangkat mereka.
- **Aksesibilitas Buruk**: Wali santri lanjut usia kesulitan membaca saldo dan rincian tagihan pesantren.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Terapkan TextScaler Clamping Global pada Root MaterialApp
Di [main.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/main.dart), batasi rasio scaling font sistem agar tetap terbaca jelas namun tidak merusak layout desain:

```dart
MaterialApp.router(
  builder: (context, child) {
    final mediaQuery = MediaQuery.of(context);
    final clampedTextScaler = mediaQuery.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.18, // Mencegah teks membesar hingga merusak kartu fixed
    );

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: clampedTextScaler),
      child: KeyboardDismissWatcher(
        child: child!,
      ),
    );
  },
  // ...
)
```

### Langkah 2: Ganti Hardcoded Height dengan Padding Dinamis / Intrinsic Sizing
Ubah widget kartu yang memiliki tinggi tetap menjadi berbasis padding vertikal atau `ConstrainedBox(minHeight: ...)`:
- Pada kartu santri: Ganti `height: 76` menjadi `constraints: const BoxConstraints(minHeight: 80, maxHeight: 100)`.
- Pada GridView: Gunakan `mainAxisExtent` yang dinamis atau `Wrap` fleksibel jika item teks berpotensi membengkak.

### Langkah 3: Perlebar Touch Target Area
Pastikan setiap elemen interaktif (tombol centang, ikon kalender, filter pill) memiliki `HitTestBehavior.opaque` dan padding minimal `44x44 dp` untuk kenyamanan sentuhan jari.

---

## 4. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Dilakukan pengujian di emulator/device fisik dengan *Font Size = Largest / 140%* di pengaturan sistem.
- [ ] Nol (0) error *RenderFlex overflow* di seluruh layar (Home, SPP Modal, Infaq Modal, Mutasi, Profil).
- [ ] Teks tetap terbaca proporsional dan tidak ada teks penting yang terpotong secara tidak wajar.
