import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/navigation/navigation_keys.dart';
import '../core/navigation/snackbar_cleanup_observer.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/screen/login_screen.dart';
import '../features/auth/screen/role_selection_screen.dart';
import '../features/splash/screen/splash_screen.dart';
import '../features/kwitansi/screen/kwitansi_screen.dart';
import '../features/navigation/screen/main_navigation_shell.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      observers: [SnackBarCleanupObserver()],
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        final isSplash = loc == '/splash' || loc == '/';
        final isRoleSelection = loc == '/role-selection';
        final isLogin = loc == '/login';

        final isLoggedIn = authState.isAuthenticated;

        // If user is ALREADY logged in and attempts to access splash screen (e.g. via back button),
        // redirect immediately to /home so splash screen is NEVER shown again!
        if (isLoggedIn && isSplash) {
          return '/home';
        }

        // While on splash during cold start, let SplashScreen perform branding delay and transition
        if (isSplash) {
          return null;
        }

        // Global Splash check: while checking token or during app startup, stay on /splash
        if (authState is AuthInitial) {
          return '/splash';
        }

        // If not logged in and not on login or role-selection page, redirect to role-selection
        if (!isLoggedIn && !isLogin && !isRoleSelection) {
          return '/role-selection';
        }

        // If logged in and on login/role-selection, redirect to home
        if (isLoggedIn && (isLogin || isRoleSelection)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        ),
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final initialRole = state.extra as String?;
            return LoginScreen(initialRole: initialRole);
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final tabParam = state.uri.queryParameters['tab'];
            final initialIndex = int.tryParse(tabParam ?? '') ?? 0;
            return MainNavigationShell(initialIndex: initialIndex);
          },
          routes: [
            GoRoute(
              path: 'kwitansi',
              builder: (context, state) => const KwitansiScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/kwitansi',
          redirect: (context, state) => '/home/kwitansi',
        ),
        GoRoute(
          path: '/mutation',
          redirect: (context, state) => '/home?tab=1',
        ),
        GoRoute(
          path: '/information',
          redirect: (context, state) => '/home?tab=2',
        ),
        GoRoute(
          path: '/cs',
          redirect: (context, state) => '/home?tab=3',
        ),
        GoRoute(
          path: '/profile',
          redirect: (context, state) => '/home?tab=4',
        ),
      ],
    );

    router.routerDelegate.addListener(() {
      rootScaffoldMessengerKey.currentState?.clearSnackBars();
    });

    return router;
  }
}
