import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/config/app_config.dart';
import 'package:mobile_sikesan_flutter/core/constants/api_endpoints.dart';

void main() {
  group('AppConfig & ApiEndpoints Tests', () {
    tearDown(() {
      AppConfig.customBaseUrl = null;
    });

    test('default environment resolves correctly', () {
      expect(AppConfig.environment, isA<AppEnvironment>());
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(AppConfig.baseUrl.contains('trycloudflare.com'), isFalse);
    });

    test('customBaseUrl override takes precedence when set', () {
      AppConfig.customBaseUrl = 'https://custom.api.sikesan.id/api/v1';
      expect(AppConfig.baseUrl, equals('https://custom.api.sikesan.id/api/v1'));
      expect(ApiEndpoints.baseUrl, equals('https://custom.api.sikesan.id/api/v1'));

      ApiEndpoints.customBaseUrl = 'https://another.api.sikesan.id/api/v1';
      expect(AppConfig.baseUrl, equals('https://another.api.sikesan.id/api/v1'));
      expect(ApiEndpoints.baseUrl, equals('https://another.api.sikesan.id/api/v1'));
    });

    test('ApiEndpoints routes are correctly formed without trailing slash', () {
      expect(ApiEndpoints.login, equals('/auth/login'));
      expect(ApiEndpoints.guardianDashboard, equals('/dashboard/guardian'));
      expect(ApiEndpoints.treasurerDashboard, equals('/dashboard/treasurer'));
      expect(ApiEndpoints.students, equals('/students'));
      expect(ApiEndpoints.walletTransactions, equals('/transactions/wallet'));
      expect(ApiEndpoints.walletWithdraw, equals('/wallet/withdraw'));
    });
  });
}
