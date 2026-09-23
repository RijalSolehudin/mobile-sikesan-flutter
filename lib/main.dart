import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'data/local/secure_storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/spp_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set System UI Overlay Style for smooth status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize Core Services
  final secureStorage = SecureStorageService();
  
  late final AuthBloc authBloc;
  final dioClient = DioClient(
    secureStorage: secureStorage,
    onUnauthorized: () {
      authBloc.add(const AuthLogoutRequested());
    },
  );

  final authRepository = AuthRepository(dioClient, secureStorage);
  final dashboardRepository = DashboardRepository(dioClient);
  final sppRepository = SppRepository(dioClient);

  authBloc = AuthBloc(authRepository: authRepository)..add(const AuthCheckRequested());
  final dashboardBloc = DashboardBloc(dashboardRepository: dashboardRepository);

  final router = AppRouter.createRouter(authBloc);

  runApp(
    SikesanMobileApp(
      authRepository: authRepository,
      dashboardRepository: dashboardRepository,
      sppRepository: sppRepository,
      authBloc: authBloc,
      dashboardBloc: dashboardBloc,
      router: router,
    ),
  );
}

class SikesanMobileApp extends StatelessWidget {
  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;
  final SppRepository sppRepository;
  final AuthBloc authBloc;
  final DashboardBloc dashboardBloc;
  final GoRouter router;

  const SikesanMobileApp({
    super.key,
    required this.authRepository,
    required this.dashboardRepository,
    required this.sppRepository,
    required this.authBloc,
    required this.dashboardBloc,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<DashboardRepository>.value(value: dashboardRepository),
        RepositoryProvider<SppRepository>.value(value: sppRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<DashboardBloc>.value(value: dashboardBloc),
        ],
        child: MaterialApp.router(
          title: 'SIKESAN Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
