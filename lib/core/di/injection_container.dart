import '../network/dio_client.dart';
import '../../data/local/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/spp_repository.dart';
import '../../data/repositories/infaq_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../data/repositories/kwitansi_repository.dart';

import '../services/biometric_auth_service.dart';

/// Container Dependency Injection terpusat untuk modularitas dan kesiapan pengujian (TASK-CONC-06)
class InjectionContainer {
  static late final SecureStorageService secureStorage;
  static late final BiometricAuthService biometricAuth;
  static late final DioClient dioClient;
  static late final AuthRepository authRepository;
  static late final DashboardRepository dashboardRepository;
  static late final SppRepository sppRepository;
  static late final InfaqRepository infaqRepository;
  static late final WalletRepository walletRepository;
  static late final AnnouncementRepository announcementRepository;
  static late final KwitansiRepository kwitansiRepository;

  /// Menginisialisasi semua dependensi inti aplikasi
  static void init({required void Function() onUnauthorized}) {
    secureStorage = SecureStorageService();
    biometricAuth = BiometricAuthService();
    dioClient = DioClient(
      secureStorage: secureStorage,
      onUnauthorized: onUnauthorized,
    );
    authRepository = AuthRepository(dioClient, secureStorage);
    dashboardRepository = DashboardRepository(dioClient);
    sppRepository = SppRepository(dioClient);
    infaqRepository = InfaqRepository(dioClient);
    walletRepository = WalletRepository(dioClient);
    announcementRepository = AnnouncementRepository(dioClient);
    kwitansiRepository = KwitansiRepository(dioClient);
  }
}
