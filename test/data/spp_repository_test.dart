import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/repositories/spp_repository.dart';

void main() {
  group('SppRepository Status Code & Network Resilience Unit Tests', () {
    late Dio testDio;
    late DioClient dioClient;
    late SppRepository sppRepository;
    late SecureStorageService fakeStorage;

    setUp(() {
      testDio = Dio();
      fakeStorage = SecureStorageService();
      dioClient = DioClient.withDio(testDio, secureStorage: fakeStorage);
      sppRepository = SppRepository(dioClient);
    });

    test(
      'getStudentBills returns ApiSuccess when server responds 200 OK',
      () async {
        testDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': [
                      {
                        'id': 'bill-01',
                        'student_id': 1,
                        'period_month': 1,
                        'period_year': 2026,
                        'amount_billed': 500000,
                        'status': 'UNPAID',
                      },
                    ],
                  },
                ),
              );
            },
          ),
        );

        final result = await sppRepository.getStudentBills(1, year: 2026);
        expect(result, isA<ApiSuccess>());
        final bills = (result as ApiSuccess).data;
        expect(bills.length, 1);
        expect(bills.first.id, 'bill-01');
        expect(bills.first.amountBilled, 500000);
      },
    );

    test('getStudentBills returns ApiFailure on 401 Unauthorized', () async {
      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Unauthenticated.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final result = await sppRepository.getStudentBills(1);
      expect(result, isA<ApiFailure>());
      final failure = result as ApiFailure;
      expect(failure.statusCode, 401);
      expect(failure.message, 'Unauthenticated.');
    });

    test(
      'payDirect returns ApiFailure on 422 Unprocessable Entity (Validation Error)',
      () async {
        testDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 422,
                    data: {
                      'message':
                          'Tagihan SPP bulan ini sudah dibayar sebelumnya.',
                      'errors': {
                        'bill_ids': ['Tagihan tidak valid atau telah lunas.'],
                      },
                    },
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );

        final result = await sppRepository.payDirect(
          studentId: 1,
          billIds: ['bill-01'],
          totalAmount: 500000,
        );

        expect(result, isA<ApiFailure>());
        final failure = result as ApiFailure;
        expect(failure.statusCode, 422);
        expect(
          failure.message,
          'Tagihan SPP bulan ini sudah dibayar sebelumnya.',
        );
      },
    );

    test(
      'submitTransferPayment handles 500 Internal Server Error cleanly with humanized message',
      () async {
        testDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 500,
                    data: {'message': 'Internal Server Error'},
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );

        final result = await sppRepository.submitTransferPayment(
          studentId: 1,
          billIds: ['bill-01'],
          totalAmount: 500000,
          proofBytes: [1, 2, 3],
          proofFilename: 'test.jpg',
        );

        expect(result, isA<ApiFailure>());
        final failure = result as ApiFailure;
        expect(failure.statusCode, 500);
        expect(failure.message, contains('Server sedang mengalami kendala'));
      },
    );
  });
}
