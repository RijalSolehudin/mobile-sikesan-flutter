part of 'spp_payment_bloc.dart';

@freezed
class SppPaymentEvent with _$SppPaymentEvent {
  const factory SppPaymentEvent.submitTransfer({
    required int studentId,
    required List<String> billIds,
    required num totalAmount,
    required List<int> proofBytes,
    required String proofFilename,
    String? bankName,
    String? accountHolder,
  }) = SppPaymentSubmitTransfer;

  const factory SppPaymentEvent.submitCash({
    required int studentId,
    required List<String> billIds,
    required num totalAmount,
  }) = SppPaymentSubmitCash;

  const factory SppPaymentEvent.reset() = SppPaymentReset;
}
