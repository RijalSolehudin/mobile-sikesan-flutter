import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: AppConstants.userKey, value: userJson);
    await _storage.write(key: AppConstants.roleKey, value: user.role);
  }

  Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
    await _storage.delete(key: AppConstants.roleKey);
  }
}
