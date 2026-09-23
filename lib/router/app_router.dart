import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/home_screen.dart';
import '../features/mutation/mutation_screen.dart';
import '../features/information/information_screen.dart';
import '../features/cs_sikesan/cs_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/navigation/main_navigation_shell.dart';

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
      initialLocation: '/home',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final isLoggingIn = state.matchedLocation == '/login';

        // While checking token on initial launch, stay on current location
        if (authState.status == AuthStatus.initial) {
          return null;
        }

        final isLoggedIn = authState.isAuthenticated;

        // If not logged in and not on login page, redirect to login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // If logged in and on login page, redirect to home
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
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
