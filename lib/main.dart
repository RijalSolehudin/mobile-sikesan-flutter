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
import 'data/repositories/infaq_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/spp/bloc/spp_payment_bloc.dart';
import 'core/services/session_timeout_listener.dart';
import 'router/app_router.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

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
  final infaqRepository = InfaqRepository(dioClient);
  final walletRepository = WalletRepository(dioClient);

  authBloc = AuthBloc(authRepository: authRepository)
    ..add(const AuthCheckRequested());
  final dashboardBloc = DashboardBloc(dashboardRepository: dashboardRepository);

  final router = AppRouter.createRouter(authBloc);

  runApp(
    SikesanMobileApp(
      authRepository: authRepository,
      dashboardRepository: dashboardRepository,
      sppRepository: sppRepository,
      infaqRepository: infaqRepository,
      walletRepository: walletRepository,
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
  final InfaqRepository infaqRepository;
  final WalletRepository walletRepository;
  final AuthBloc authBloc;
  final DashboardBloc dashboardBloc;
  final GoRouter router;

  const SikesanMobileApp({
    super.key,
    required this.authRepository,
    required this.dashboardRepository,
    required this.sppRepository,
    required this.infaqRepository,
    required this.walletRepository,
    required this.authBloc,
    required this.dashboardBloc,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<DashboardRepository>.value(
          value: dashboardRepository,
        ),
        RepositoryProvider<SppRepository>.value(value: sppRepository),
        RepositoryProvider<InfaqRepository>.value(value: infaqRepository),
        RepositoryProvider<WalletRepository>.value(value: walletRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<DashboardBloc>.value(value: dashboardBloc),
          BlocProvider<SppPaymentBloc>(
            create: (context) => SppPaymentBloc(sppRepository: sppRepository),
          ),
        ],
        child: MaterialApp.router(
          title: 'SIKESAN - Sistem Keuangan Santri',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          builder: (context, child) {
            return KeyboardDismissWatcher(
              child: SessionTimeoutListener(
                authBloc: authBloc,
                timeoutDuration: const Duration(minutes: 30),
                onTimeout: () {
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sesi Bendahara berakhir otomatis setelah 30 menit tidak ada aktivitas demi keamanan.',
                      ),
                      backgroundColor: Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 5),
                    ),
                  );
                },
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class KeyboardDismissWatcher extends StatefulWidget {
  final Widget child;

  const KeyboardDismissWatcher({super.key, required this.child});

  @override
  State<KeyboardDismissWatcher> createState() => _KeyboardDismissWatcherState();
}

class _KeyboardDismissWatcherState extends State<KeyboardDismissWatcher>
    with WidgetsBindingObserver {
  double _lastBottomInset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final view = View.of(context);
    final currentBottomInset = view.viewInsets.bottom;

    // When keyboard transitions from open to closed (e.g. back button pressed)
    if (_lastBottomInset > 0 && currentBottomInset == 0) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _lastBottomInset = currentBottomInset;
  }

  @override
  Future<bool> didPopRoute() async {
    // When back button is tapped, ensure active focus is dropped immediately
    final currentBottomInset = View.of(context).viewInsets.bottom;
    if (currentBottomInset > 0 || FocusManager.instance.primaryFocus != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    return super.didPopRoute();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

