import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
              resetOnError: true,
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (_) {
      // Jika terjadi anomali KeyStore, coba reset dan simpan ulang
      await clearAuth();
      try {
        await _storage.write(key: AppConstants.tokenKey, value: token);
      } catch (_) {}
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (_) {
      // KeyStore corrupt fallback: bersihkan sesi agar tidak memicu crash
      await clearAuth();
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.refreshTokenKey, value: token);
    } catch (_) {
      try {
        await _storage.write(key: AppConstants.refreshTokenKey, value: token);
      } catch (_) {}
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userKey, value: userJson);
      await _storage.write(key: AppConstants.roleKey, value: user.role);
    } catch (_) {
      await clearAuth();
      try {
        final userJson = jsonEncode(user.toJson());
        await _storage.write(key: AppConstants.userKey, value: userJson);
        await _storage.write(key: AppConstants.roleKey, value: user.role);
      } catch (_) {}
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userKey);
      if (userJson == null) return null;
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTransactionPin(String pin) async {
    try {
      await _storage.write(key: AppConstants.transactionPinKey, value: pin);
    } catch (_) {}
  }

  Future<String?> getTransactionPin() async {
    try {
      return await _storage.read(key: AppConstants.transactionPinKey);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasTransactionPin() async {
    final pin = await getTransactionPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userKey);
      await _storage.delete(key: AppConstants.roleKey);
    } catch (_) {
      // Best-effort deletion
    }
  }
}
