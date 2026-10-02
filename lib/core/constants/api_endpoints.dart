import '../config/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.baseUrl;

  static String? get customBaseUrl => AppConfig.customBaseUrl;
  static set customBaseUrl(String? url) {
    AppConfig.customBaseUrl = url;
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
  static const String walletWithdraw = '/wallet/withdraw';
  static const String ledgerReports = '/reports/ledger';
  static const String topUps = '/top-ups';
  static const String sppPayments = '/spp/payments';
  static const String infaqKesantrianPayments = '/infaq-kesantrian/payments';
  static const String infaqKesantrianSubmit =
      '/infaq-kesantrian/submit-payment';
  static String infaqBills(dynamic studentId) =>
      '/students/$studentId/infaq-bills';
  static String infaqReceipt(dynamic paymentId) =>
      '/infaq-kesantrian/payments/$paymentId/receipt';
  static const String infaqs = '/infaqs';
}
