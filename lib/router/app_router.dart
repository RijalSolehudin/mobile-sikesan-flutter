import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/screen/login_screen.dart';
import '../features/auth/screen/role_selection_screen.dart';
import '../features/splash/screen/splash_screen.dart';
import '../features/dashboard/screen/home_screen.dart';
import '../features/mutation/screen/mutation_screen.dart';
import '../features/information/screen/information_screen.dart';
import '../features/cs_sikesan/screen/cs_screen.dart';
import '../features/profile/screen/profile_screen.dart';
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        final isSplash = loc == '/splash';
        final isRoleSelection = loc == '/role-selection';
        final isLogin = loc == '/login';

        // While on splash, let SplashScreen perform branding delay and transition
        if (isSplash) {
          return null;
        }

        // Global Splash check: while checking token or during app startup, stay on /splash
        if (authState is AuthInitial) {
          if (!isSplash) return '/splash';
          return null;
        }

        final isLoggedIn = authState.isAuthenticated;

        // If not logged in and not on login or role-selection page, redirect to role-selection
        if (!isLoggedIn && !isLogin && !isRoleSelection) {
          return '/role-selection';
        }

        // If logged in and on login/role-selection/splash, redirect to home
        if (isLoggedIn && (isLogin || isRoleSelection || isSplash)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/mutation',
                  builder: (context, state) => const MutationScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/information',
                  builder: (context, state) => const InformationScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/cs',
                  builder: (context, state) => const CsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
