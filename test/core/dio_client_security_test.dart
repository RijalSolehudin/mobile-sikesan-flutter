import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';

void main() {
  group('DioClient Security & Resilience Tests', () {
    test('formatDioError returns correct friendly messages for timeout types', () {
      final sendTimeoutEx = DioException(
        requestOptions: RequestOptions(path: '/spp/payments'),
        type: DioExceptionType.sendTimeout,
      );
      expect(
        DioClient.formatDioError(sendTimeoutEx),
        contains('Waktu pengunggahan data habis'),
      );

      final connTimeoutEx = DioException(
        requestOptions: RequestOptions(path: '/spp/payments'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        DioClient.formatDioError(connTimeoutEx),
        contains('Koneksi ke server terputus'),
      );

      final serverErrorEx = DioException(
        requestOptions: RequestOptions(path: '/spp/payments'),
        response: Response(
          requestOptions: RequestOptions(path: '/spp/payments'),
          statusCode: 422,
          data: {'message': 'Bulan tagihan sudah lunas'},
        ),
      );
      expect(
        DioClient.formatDioError(serverErrorEx),
        'Bulan tagihan sudah lunas',
      );
    });

    test('DioClient initializes with QueuedInterceptorsWrapper and 30s sendTimeout', () {
      final storage = SecureStorageService();
      final client = DioClient(secureStorage: storage);

      expect(client.dio.options.sendTimeout, const Duration(seconds: 30));
      expect(client.dio.options.connectTimeout, const Duration(seconds: 15));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 15));

      // Must have QueuedInterceptorsWrapper registered
      final hasQueuedInterceptor = client.dio.interceptors.any(
        (interceptor) => interceptor is QueuedInterceptorsWrapper,
      );
      expect(hasQueuedInterceptor, isTrue);
    });
  });
}
