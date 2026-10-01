import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/network/api_result.dart';
import '../../../data/repositories/spp_repository.dart';

part 'spp_payment_event.dart';
part 'spp_payment_state.dart';
part 'spp_payment_bloc.freezed.dart';

class SppPaymentBloc extends Bloc<SppPaymentEvent, SppPaymentState> {
  final SppRepository _sppRepository;

  SppPaymentBloc({required SppRepository sppRepository})
    : _sppRepository = sppRepository,
      super(const SppPaymentState.initial()) {
    on<SppPaymentSubmitTransfer>(_onSubmitTransfer);
    on<SppPaymentSubmitCash>(_onSubmitCash);
    on<SppPaymentReset>(_onReset);

    _log('SppPaymentBloc initialized');
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'SppPaymentBloc',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _onSubmitTransfer(
    SppPaymentSubmitTransfer event,
    Emitter<SppPaymentState> emit,
  ) async {
    _log('Submitting transfer payment for student ${event.studentId}, total: ${event.totalAmount}');
    emit(const SppPaymentState.submitting());

    final result = await _sppRepository.submitTransferPayment(
      studentId: event.studentId,
      billIds: event.billIds,
      totalAmount: event.totalAmount,
      proofBytes: event.proofBytes,
      proofFilename: event.proofFilename,
      bankName: event.bankName,
      accountHolder: event.accountHolder,
    );

    if (result is ApiSuccess<String>) {
      _log('Transfer payment submitted successfully: ${result.data}');
      emit(SppPaymentState.success(paymentId: result.data, message: result.message));
    } else if (result is ApiFailure<String>) {
      _log('Transfer payment submission failed: ${result.message}');
      emit(SppPaymentState.failure(result.message));
    }
  }

  Future<void> _onSubmitCash(
    SppPaymentSubmitCash event,
    Emitter<SppPaymentState> emit,
  ) async {
    _log('Submitting cash payment for student ${event.studentId}, total: ${event.totalAmount}');
    emit(const SppPaymentState.submitting());

    final result = await _sppRepository.payDirect(
      studentId: event.studentId,
      billIds: event.billIds,
      totalAmount: event.totalAmount,
    );

    if (result is ApiSuccess<String>) {
      _log('Cash payment successful: ${result.data}');
      emit(SppPaymentState.success(paymentId: result.data, message: result.message));
    } else if (result is ApiFailure<String>) {
      _log('Cash payment failed: ${result.message}');
      emit(SppPaymentState.failure(result.message));
    }
  }

  void _onReset(
    SppPaymentReset event,
    Emitter<SppPaymentState> emit,
  ) {
    _log('Reset payment state');
    emit(const SppPaymentState.initial());
  }
}
