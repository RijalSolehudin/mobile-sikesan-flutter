import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../../data/local/secure_storage_service.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageService secureStorage;
  final void Function()? onUnauthorized;

  DioClient({required this.secureStorage, this.onUnauthorized}) {
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
      if (kDebugMode)
        InterceptorsWrapper(
          onRequest: (options, handler) {
            _logSanitizedRequest(options);
            return handler.next(options);
          },
          onResponse: (response, handler) {
            _logSanitizedResponse(response);
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
              '[API ERROR] ${error.requestOptions.method} ${error.requestOptions.path} '
              '-> ${error.response?.statusCode} ${error.message}',
            );
            return handler.next(error);
          },
        ),
    ]);
  }

  static void _logSanitizedRequest(RequestOptions options) {
    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      sanitizedHeaders['Authorization'] = 'Bearer [REDACTED_TOKEN]';
    }

    dynamic sanitizedData = options.data;
    if (sanitizedData is Map<String, dynamic>) {
      sanitizedData = _maskSensitiveMap(sanitizedData);
    } else if (sanitizedData is FormData) {
      sanitizedData =
          '[FormData fields: ${sanitizedData.fields.map((e) => e.key).join(", ")}]';
    }

    debugPrint('[API REQ] ${options.method} ${options.uri}');
    debugPrint('  Headers: $sanitizedHeaders');
    if (sanitizedData != null) {
      debugPrint('  Body: $sanitizedData');
    }
  }

  static void _logSanitizedResponse(Response response) {
    debugPrint(
      '[API RESP] ${response.requestOptions.method} ${response.requestOptions.path} '
      '[${response.statusCode}]',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final sanitized = _maskSensitiveMap(data);
      debugPrint('  Data: $sanitized');
    }
  }

  static Map<String, dynamic> _maskSensitiveMap(Map<String, dynamic> map) {
    const sensitiveKeys = {
      'password',
      'password_confirmation',
      'token',
      'access_token',
      'refresh_token',
      'secret',
      'pin',
      'old_password',
      'new_password',
    };
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      if (sensitiveKeys.contains(entry.key.toLowerCase())) {
        result[entry.key] = '***REDACTED***';
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] =
            _maskSensitiveMap(entry.value as Map<String, dynamic>);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}
