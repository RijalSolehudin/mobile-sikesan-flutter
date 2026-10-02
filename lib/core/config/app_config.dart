import 'package:flutter/foundation.dart' show kIsWeb;

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'staging');
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  static String? customBaseUrl;

  static AppEnvironment get environment {
    switch (_env.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'dev':
      case 'development':
      case 'local':
        return AppEnvironment.dev;
      default:
        return AppEnvironment.staging;
    }
  }

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (_apiBaseUrl.isNotEmpty) {
      return _apiBaseUrl;
    }
    if (kIsWeb) {
      return '/api/v1';
    }
    switch (environment) {
      case AppEnvironment.dev:
        return 'http://10.0.2.2:8000/api/v1';
      case AppEnvironment.staging:
        return 'https://api-staging.sikesan.ponpes.id/api/v1';
      case AppEnvironment.prod:
        return 'https://api.sikesan.ponpes.id/api/v1';
    }
  }
}
