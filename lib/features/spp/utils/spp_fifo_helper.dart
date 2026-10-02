/// Helper algoritma pemilihan bulan berurutan (First-In First-Out / FIFO) untuk tagihan SPP
/// Memenuhi TASK-CONC-02 agar business logic tidak tercampur dalam widget.
class SppFifoHelper {
  /// Menghitung set bulan yang harus dipilih sesuai prinsip FIFO
  static Set<int> computeFifoSelection({
    required Set<int> currentSelection,
    required int tappedMonth,
    required List<int> unpaidMonthsSorted,
  }) {
    if (!unpaidMonthsSorted.contains(tappedMonth)) {
      return currentSelection;
    }

    final newSelection = Set<int>.from(currentSelection);
    final maxSelected = currentSelection.isEmpty
        ? 0
        : currentSelection.reduce((a, b) => a > b ? a : b);

    if (currentSelection.contains(tappedMonth)) {
      if (tappedMonth == maxSelected) {
        // Klik pada bulan tertinggi yang sedang terpilih -> batalkan bulan ini
        newSelection.remove(tappedMonth);
      } else {
        // Klik pada bulan terpilih yang lebih rendah -> pangkas pemilihan di atas bulan ini
        newSelection.removeWhere((m) => m > tappedMonth);
      }
    } else {
      // Klik pada bulan yang belum terpilih:
      // Terapkan prinsip FIFO: otomatis pilih semua bulan tertua yang belum lunas sampai bulan ini
      newSelection.clear();
      for (final m in unpaidMonthsSorted) {
        if (m <= tappedMonth) {
          newSelection.add(m);
        }
      }
    }

    return newSelection;
  }
}
