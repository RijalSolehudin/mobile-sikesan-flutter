import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/models/user_model.dart';

/// Fake in-memory implementation of FlutterSecureStorage for testing
class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};
  bool shouldThrowOnRead = false;
  bool shouldThrowOnWrite = false;

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowOnWrite) {
      throw Exception('Simulated KeyStore write failure');
    }
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowOnRead) {
      throw Exception('Simulated Android KeyStore BadPaddingException');
    }
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  late FakeFlutterSecureStorage fakeStorage;
  late SecureStorageService storageService;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    storageService = SecureStorageService(storage: fakeStorage);
  });

  group('SecureStorageService Resilience Tests', () {
    test('saveToken and getToken roundtrip successfully', () async {
      await storageService.saveToken('test_jwt_token_123');
      final token = await storageService.getToken();
      expect(token, 'test_jwt_token_123');
    });

    test(
      'getToken handles corrupted KeyStore gracefully without throwing fatal exception',
      () async {
        await storageService.saveToken('valid_token');
        fakeStorage.shouldThrowOnRead = true;

        // Must not throw exception
        final token = await storageService.getToken();
        expect(token, isNull);
      },
    );

    test('saveUser and getUser serializes UserModel properly', () async {
      const user = UserModel(
        id: 1,
        name: 'Ahmad Santri',
        email: 'ahmad@example.com',
        username: 'ahmadsantri',
        role: 'Santri',
      );

      await storageService.saveUser(user);
      final retrievedUser = await storageService.getUser();

      expect(retrievedUser, isNotNull);
      expect(retrievedUser?.name, 'Ahmad Santri');
      expect(retrievedUser?.role, 'Santri');
    });

    test('clearAuth removes all session keys safely', () async {
      await storageService.saveToken('token_abc');
      await storageService.saveRefreshToken('refresh_xyz');

      await storageService.clearAuth();

      final token = await storageService.getToken();
      final refreshToken = await storageService.getRefreshToken();
      expect(token, isNull);
      expect(refreshToken, isNull);
    });
  });
}
