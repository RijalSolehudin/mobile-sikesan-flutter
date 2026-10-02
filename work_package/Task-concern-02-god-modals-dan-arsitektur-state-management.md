# Task-concern-02: Refactoring "God Modals" & Anti-Pattern State Management pada Transaksi

| Metadata | Keterangan |
|---|---|
| **Task ID** | `TASK-CONC-02` |
| **Prioritas** | **P1 - High (Arsitektur & Maintainability)** |
| **Kategori** | Arsitektur Kode, UI Modularization, State Management |
| **Komponen Terkait** | `lib/features/spp/widget/pay_spp_modal.dart`, `lib/features/infaq/widget/pay_infaq_modal.dart`, `lib/features/wallet/widget/top_up_modal.dart`, `lib/features/wallet/widget/withdraw_modal.dart` |
| **Status** | Open / Pending Action |

---

## 1. Deskripsi Masalah (Problem Statement)
Empat file modal transaksi inti menampung total hampir **5.800 baris kode**:
1. `pay_spp_modal.dart` (**1.856 baris**)
2. `pay_infaq_modal.dart` (**1.555 baris**)
3. `top_up_modal.dart` (**1.432 baris**)
4. `withdraw_modal.dart` (**949 baris**)

### Anti-Pattern: "State Management Schizophrenia"
Meskipun proyek sudah memiliki pattern arsitektur BLoC (`SppPaymentBloc`), di dalam modal-modal tersebut terjadi pencampuran tiga paradigma sekaligus:
1. **Direct Repository Access di UI**:
   ```dart
   final sppRepo = RepositoryProvider.of<SppRepository>(context);
   final result = await sppRepo.getStudentBills(studentId, year: year);
   ```
   Widget memanggil API langsung tanpa melalui BLoC Event/State.
2. **Local State Overload (`setState`)**:
   Puluhan variabel lokal (`_selectedStudentId`, `_selectedMonths`, `_isLoadingBills`, `_searchController`, `_searchedStudents`, `_proofImage`, `_selectedPaymentMethod`, dll.) dikelola manual menggunakan `setState()`.
3. **Bisnis Logic Tertanam di Widget**:
   Algoritma pemilihan bulan berurutan (FIFO SPP), kalkulasi denda/diskon, manipulasi file picker gambar kompresi, dan mapping format rekening bank ditulis langsung di dalam `State<PaySppModal>`. BLoC hanya dipanggil di ujung akhir untuk aksi *submit*.

---

## 2. Dampak Risiko (Impact Analysis)
- **High Complexity & Fragility**: Mengubah satu baris logika (misal: syarat validasi bukti transfer) rentan merusak UI rendering atau state kalkulasi bulan lainnya.
- **Untestable Code**: File sebesar 1.800 baris yang mencampurkan UI layout, HTTP call, dan form state hampir mustahil diuji dengan *Unit Test* maupun *Widget Test*.
- **Memory Leak & State Loss**: Ketika layar berotasi atau keyboard muncul, rebuild widget yang kompleks dapat memicu *race condition* atau re-fetching data yang tidak diinginkan.

---

## 3. Rencana Solusi Teknis (Technical Solution)

### Langkah 1: Pindahkan Seluruh State & Business Logic ke BLoC / Cubit
Perluas `SppPaymentBloc` (atau buat `SppPaymentFormCubit`) agar menaungi seluruh state form pembayaran:
```dart
@freezed
class SppPaymentFormState with _$SppPaymentFormState {
  const factory SppPaymentFormState({
    required int selectedYear,
    int? selectedStudentId,
    String? selectedStudentName,
    required List<SppBillModel> bills,
    required Set<int> selectedMonths,
    required PaymentMethod paymentMethod,
    File? transferProof,
    required bool isLoadingBills,
    required bool isSubmitting,
    String? errorMessage,
  }) = _SppPaymentFormState;
}
```

Semua logika pemilihan bulan FIFO dipindahkan menjadi method murni di BLoC:
```dart
void onMonthToggled(int month) {
  // Logic FIFO murni yang dapat di-unit test secara independen tanpa context Flutter
}
```

### Langkah 2: Modularisasi UI Menjadi Sub-Widgets di `spp/widget/`
Pecah [pay_spp_modal.dart](file:///Users/rijalsolehudin/Development/SIKESAN/mobile-sikesan-flutter/lib/features/spp/widget/pay_spp_modal.dart) menjadi komponen-komponen terpisah maksimal 150–200 baris per file:
```text
lib/features/spp/widget/
├── pay_spp_modal.dart                  # Modal shell / container utama (~100 baris)
├── spp_student_selector.dart           # Pemilihan santri (guardian chips & global search)
├── spp_year_dropdown.dart              # Dropdown pemilihan tahun tagihan
├── spp_month_grid_selector.dart        # Grid 12 bulan dengan visualisasi status lunas / FIFO
├── spp_payment_method_selector.dart    # Pilihan metode bayar (Tunai Kasir vs Transfer Bank)
├── spp_bank_account_info_card.dart     # Kartu nomor rekening tujuan transfer
└── spp_proof_uploader.dart             # Upload & preview bukti transfer
```

Lakukan modularisasi serupa pada:
- `features/infaq/widget/` (Infaq student picker, amount grid, proof uploader)
- `features/wallet/widget/` (Top-up quick amount buttons, withdrawal student limits)

---

## 4. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Ukuran file `pay_spp_modal.dart`, `pay_infaq_modal.dart`, `top_up_modal.dart`, dan `withdraw_modal.dart` masing-masing di bawah 300 baris kode.
- [ ] Tidak ada pemanggilan langsung `RepositoryProvider.of<T>(context).fetchSomething()` di dalam `build()` atau `initState()` modal; semua melalui BLoC / Cubit.
- [ ] Logika pemilihan bulan FIFO memiliki unit test dengan coverage > 90%.
- [ ] Seluruh sub-widget memiliki parameter input yang eksplisit dan reusable.
