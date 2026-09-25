import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../local/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _secureStorage;

  AuthRepository(this._dioClient, this._secureStorage);

  Future<ApiResult<UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {'username': username.trim(), 'password': password},
      );

      final token = response.data['access_token'];
      if (token != null) {
        await _secureStorage.saveToken(token.toString());
      }

      final user = UserModel.fromJson(response.data['user'] ?? {});
      await _secureStorage.saveUser(user);
      return ApiSuccess(user);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const ApiFailure(
          'Tidak dapat terhubung ke server backend SIKESAN. Pastikan server lokal/API aktif di alamat yang ditentukan.',
        );
      }

      final dynamic responseData = e.response?.data;
      String errorMsg = 'Gagal masuk. Periksa username dan password Anda.';
      if (responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) {
          errorMsg = responseData['message'].toString();
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMsg = errors.values
              .map((v) => (v is List) ? v.join(', ') : v.toString())
              .join('\n');
        }
      }
      return ApiFailure(errorMsg, statusCode: e.response?.statusCode);
    } catch (e) {
      return ApiFailure('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }

  Future<UserModel?> getCachedUser() async {
    return await _secureStorage.getUser();
  }

  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      // Optional call to server logout endpoint if token exists
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        await _dioClient.dio.post('/auth/logout');
      }
    } catch (_) {
      // Ignore network errors on logout to ensure local session always clears
    } finally {
      await _secureStorage.clearAuth();
    }
  }
}
