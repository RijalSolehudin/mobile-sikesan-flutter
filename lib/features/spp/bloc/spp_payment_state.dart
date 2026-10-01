part of 'spp_payment_bloc.dart';

@freezed
class SppPaymentState with _$SppPaymentState {
  const SppPaymentState._();

  const factory SppPaymentState.initial() = SppPaymentInitial;
  const factory SppPaymentState.submitting() = SppPaymentSubmitting;
  const factory SppPaymentState.success({
    required String paymentId,
    String? message,
  }) = SppPaymentSuccess;
  const factory SppPaymentState.failure(String message) = SppPaymentFailure;

  bool get isSubmitting => this is SppPaymentSubmitting;
}
