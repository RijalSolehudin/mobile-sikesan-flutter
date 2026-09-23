import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:uuid/uuid.dart';
import '../constants/api_endpoints.dart';
import '../../data/local/secure_storage_service.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageService secureStorage;
  final void Function()? onUnauthorized;

  DioClient({
    required this.secureStorage,
    this.onUnauthorized,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (options.method == 'POST') {
            options.headers['Idempotency-Key'] = const Uuid().v4();
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await secureStorage.clearAuth();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);
  }
}
