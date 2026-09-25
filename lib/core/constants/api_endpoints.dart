import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Staging Cloudflare Named Tunnel endpoint
  static const String envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String defaultStagingUrl =
      'https://ears-very-solaris-affecting.trycloudflare.com/api/v1';

  // Custom override if needed
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    if (kIsWeb) {
      return '/api/v1';
    }
    return defaultStagingUrl;
  }

  // Auth
  static const String login = '/auth/login';

  // Dashboard
  static const String guardianDashboard = '/dashboard/guardian';
  static const String treasurerDashboard = '/dashboard/treasurer';

  // Students
  static const String students = '/students';

  // Financial Transactions
  static const String walletTransactions = '/transactions/wallet';
  static const String ledgerReports = '/reports/ledger';
  static const String topUps = '/top-ups';
  static const String sppPayments = '/spp/payments';
  static const String infaqs = '/infaqs';
}
