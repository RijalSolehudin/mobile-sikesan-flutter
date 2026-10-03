/// Enum Global untuk Metode Pembayaran SPP dan Transaksi Keuangan
enum SppPaymentMethod {
  transfer,
  cash,
  qris;

  String get apiValue {
    switch (this) {
      case SppPaymentMethod.transfer:
        return 'TRANSFER';
      case SppPaymentMethod.cash:
        return 'CASH';
      case SppPaymentMethod.qris:
        return 'QRIS';
    }
  }

  static SppPaymentMethod fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CASH':
        return SppPaymentMethod.cash;
      case 'QRIS':
        return SppPaymentMethod.qris;
      case 'TRANSFER':
      default:
        return SppPaymentMethod.transfer;
    }
  }
}

/// Enum Global untuk Status Tagihan SPP Santri
enum SppBillStatus {
  unpaid,
  partial,
  paid,
  pending;

  bool get isPaid => this == SppBillStatus.paid;
  bool get isPending => this == SppBillStatus.pending;
  bool get isUnpaid => this == SppBillStatus.unpaid;

  String get apiValue {
    switch (this) {
      case SppBillStatus.paid:
        return 'PAID';
      case SppBillStatus.partial:
        return 'PARTIAL';
      case SppBillStatus.pending:
        return 'PENDING';
      case SppBillStatus.unpaid:
        return 'UNPAID';
    }
  }

  static SppBillStatus fromString(String? value) {
    final normalized = value?.trim().toUpperCase();
    switch (normalized) {
      case 'PAID':
        return SppBillStatus.paid;
      case 'PARTIAL':
        return SppBillStatus.partial;
      case 'PENDING':
      case 'MENUNGGU':
      case 'MENUNGGU_VERIFIKASI':
        return SppBillStatus.pending;
      case 'UNPAID':
      default:
        return SppBillStatus.unpaid;
    }
  }
}
