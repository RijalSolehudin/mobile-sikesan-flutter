import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/repositories/spp_repository.dart';
import 'package:mobile_sikesan_flutter/features/spp/bloc/spp_payment_bloc.dart';

class MockSppRepository extends SppRepository {
  ApiResult<String>? transferResult;
  ApiResult<String>? cashResult;

  MockSppRepository() : super(DioClient(secureStorage: SecureStorageService()));

  @override
  Future<ApiResult<String>> submitTransferPayment({
    required int studentId,
    required List<String> billIds,
    required num totalAmount,
    required List<int> proofBytes,
    required String proofFilename,
    String? bankName,
    String? accountHolder,
    String? idempotencyKey,
  }) async {
    return transferResult ??
        const ApiSuccess('PAY-TRF-001', message: 'Berhasil submit transfer');
  }

  @override
  Future<ApiResult<String>> payDirect({
    required int studentId,
    required List<String> billIds,
    required num totalAmount,
    String? idempotencyKey,
  }) async {
    return cashResult ??
        const ApiSuccess('PAY-CSH-001', message: 'Berhasil bayar kasir');
  }
}

void main() {
  group('SppPaymentBloc Unit Tests (Freezed Union)', () {
    late MockSppRepository mockRepo;
    late SppPaymentBloc paymentBloc;

    setUp(() {
      mockRepo = MockSppRepository();
      paymentBloc = SppPaymentBloc(sppRepository: mockRepo);
    });

    tearDown(() {
      paymentBloc.close();
    });

    test('Initial state is SppPaymentInitial', () {
      expect(paymentBloc.state, const SppPaymentState.initial());
      expect(paymentBloc.state.isSubmitting, false);
    });

    test(
      'SppPaymentSubmitTransfer emits [submitting, success] on success',
      () async {
        mockRepo.transferResult = const ApiSuccess(
          'PAY-TRF-123',
          message: 'Sukses',
        );

        paymentBloc.add(
          const SppPaymentEvent.submitTransfer(
            studentId: 1,
            billIds: ['BILL-1', 'BILL-2'],
            totalAmount: 1500000,
            proofBytes: [1, 2, 3],
            proofFilename: 'bukti.jpg',
          ),
        );

        await expectLater(
          paymentBloc.stream,
          emitsInOrder([
            const SppPaymentState.submitting(),
            const SppPaymentState.success(
              paymentId: 'PAY-TRF-123',
              message: 'Sukses',
            ),
          ]),
        );
      },
    );

    test(
      'SppPaymentSubmitTransfer emits [submitting, failure] on failure',
      () async {
        mockRepo.transferResult = const ApiFailure(
          'Bukti transfer tidak valid',
          statusCode: 422,
        );

        paymentBloc.add(
          const SppPaymentEvent.submitTransfer(
            studentId: 1,
            billIds: ['BILL-1'],
            totalAmount: 750000,
            proofBytes: [1, 2],
            proofFilename: 'bukti.jpg',
          ),
        );

        await expectLater(
          paymentBloc.stream,
          emitsInOrder([
            const SppPaymentState.submitting(),
            const SppPaymentState.failure('Bukti transfer tidak valid'),
          ]),
        );
      },
    );

    test(
      'SppPaymentSubmitCash emits [submitting, success] on direct cash payment',
      () async {
        mockRepo.cashResult = const ApiSuccess(
          'PAY-CASH-789',
          message: 'Lunas',
        );

        paymentBloc.add(
          const SppPaymentEvent.submitCash(
            studentId: 1,
            billIds: ['BILL-1'],
            totalAmount: 750000,
          ),
        );

        await expectLater(
          paymentBloc.stream,
          emitsInOrder([
            const SppPaymentState.submitting(),
            const SppPaymentState.success(
              paymentId: 'PAY-CASH-789',
              message: 'Lunas',
            ),
          ]),
        );
      },
    );

    test('SppPaymentReset emits initial state', () async {
      paymentBloc.add(const SppPaymentEvent.reset());

      await expectLater(
        paymentBloc.stream,
        emits(const SppPaymentState.initial()),
      );
    });
  });
}
