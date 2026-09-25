import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Staging Container Gateway (sikesan-staging-gateway mapped to port 8080)
  static const String stagingLocalPort = '8080';
  static const String stagingTunnelUrl =
      'https://ears-very-solaris-affecting.trycloudflare.com/api/v1';

  // Custom override if needed
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (kIsWeb) {
      return '/api/v1';
    }
    return stagingTunnelUrl;
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
