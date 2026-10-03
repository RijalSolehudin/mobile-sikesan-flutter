import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_crash_fallback_screen.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/spp_repository.dart';
import 'data/repositories/infaq_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/announcement_repository.dart';
import 'core/navigation/navigation_keys.dart';
import 'core/widgets/app_snackbar.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/spp/bloc/spp_payment_bloc.dart';
import 'core/services/session_timeout_listener.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tangkap error rendering Flutter UI
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Remote observability hook (Crashlytics/Sentry) siap diintegrasikan di sini
  };

  // Tangkap uncaught async errors di luar widget tree
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught Asynchronous Error: $error\n$stack');
    return true;
  };

  // Tampilkan screen fallback yang ramah pengganti grey screen of death
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return AppCrashFallbackScreen(errorDetails: errorDetails);
  };

  // Set System UI Overlay Style for smooth status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Pada Web / PWA, gunakan single-entry history agar perpindahan tab bottom bar
  // tidak menumpuk riwayat browser history tak berujung (pola standar mobile app)
  if (kIsWeb) {
    SystemNavigator.selectSingleEntryHistory();
  }

  // Initialize Core Services via InjectionContainer (TASK-CONC-06)
  late final AuthBloc authBloc;
  InjectionContainer.init(
    onUnauthorized: () {
      authBloc.add(const AuthLogoutRequested());
    },
  );

  authBloc = AuthBloc(authRepository: InjectionContainer.authRepository)
    ..add(const AuthCheckRequested());
  final dashboardBloc = DashboardBloc(
    dashboardRepository: InjectionContainer.dashboardRepository,
  );

  final router = AppRouter.createRouter(authBloc);

  runApp(
    SikesanMobileApp(
      authRepository: InjectionContainer.authRepository,
      dashboardRepository: InjectionContainer.dashboardRepository,
      sppRepository: InjectionContainer.sppRepository,
      infaqRepository: InjectionContainer.infaqRepository,
      walletRepository: InjectionContainer.walletRepository,
      announcementRepository: InjectionContainer.announcementRepository,
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
  final AnnouncementRepository announcementRepository;
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
    required this.announcementRepository,
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
        RepositoryProvider<AnnouncementRepository>.value(
          value: announcementRepository,
        ),
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
            final mediaQuery = MediaQuery.of(context);
            final clampedTextScaler = mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.20,
            );

            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: clampedTextScaler),
              child: KeyboardDismissWatcher(
                child: SessionTimeoutListener(
                  authBloc: authBloc,
                  timeoutDuration: const Duration(minutes: 30),
                  onTimeout: () {
                    AppSnackBar.showWarning(
                      context,
                      'Sesi Bendahara berakhir otomatis setelah 30 menit tidak ada aktivitas demi keamanan.',
                      duration: const Duration(seconds: 4),
                    );
                  },
                  child: child ?? const SizedBox.shrink(),
                ),
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
