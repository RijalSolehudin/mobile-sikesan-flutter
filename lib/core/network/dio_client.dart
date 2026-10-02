import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
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
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final isAuthEndpoint =
                path.contains('/auth/login') || path.contains('/auth/refresh');

            if (!isAuthEndpoint) {
              final refreshToken = await secureStorage.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final newAccessToken =
                    await _performSilentTokenRefresh(refreshToken);
                if (newAccessToken != null && newAccessToken.isNotEmpty) {
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';
                  try {
                    final response = await dio.fetch(options);
                    return handler.resolve(response);
                  } catch (e) {
                    if (e is DioException) {
                      return handler.next(e);
                    }
                  }
                }
              }
            }

            await secureStorage.clearAuth();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
      if (kDebugMode && AppConfig.enableLogging)
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

  Future<String?> _performSilentTokenRefresh(String refreshToken) async {
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final dynamic raw = response.data;
        final dynamic data = raw['data'] ?? raw;
        final newAccessToken = data['token'] ?? data['access_token'];
        final newRefreshToken = data['refresh_token'];
        if (newAccessToken != null) {
          await secureStorage.saveToken(newAccessToken.toString());
          if (newRefreshToken != null) {
            await secureStorage.saveRefreshToken(newRefreshToken.toString());
          }
          return newAccessToken.toString();
        }
      }
    } catch (e) {
      if (kDebugMode && AppConfig.enableLogging) {
        debugPrint('[SILENT REFRESH] Gagal memperbarui token: $e');
      }
      return null;
    }
    return null;
  }

  static Map<String, dynamic> _maskSensitiveMap(Map<String, dynamic> map) {
    const sensitiveKeys = {
      'password',
      'password_confirmation',
      'token',
      'access_token',
      'refresh_token',
      'secret',
      'secret_key',
      'pin',
      'old_password',
      'new_password',
      'cvv',
      'security_code',
      'card_number',
      'no_rekening',
      'account_number',
      'nik',
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

  /// Helper untuk memformat pesan kesalahan jaringan Dio secara ramah dan informatif bagi pengguna
  static String formatDioError(
    DioException e, {
    String fallback = 'Terjadi kesalahan jaringan',
  }) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi ke server terputus (waktu habis). Periksa koneksi internet Anda.';
      case DioExceptionType.sendTimeout:
        return 'Waktu pengunggahan data habis. Periksa koneksi internet Anda dan coba lagi.';
      case DioExceptionType.receiveTimeout:
        return 'Respon server melebihi batas waktu tunggu. Silakan coba beberapa saat lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Pastikan perangkat Anda terhubung ke internet.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        final dynamic data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
        return fallback;
    }
  }
}
