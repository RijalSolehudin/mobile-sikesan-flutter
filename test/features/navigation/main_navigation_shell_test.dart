import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_sikesan_flutter/core/navigation/navigation_keys.dart';
import 'package:mobile_sikesan_flutter/features/navigation/screen/main_navigation_shell.dart';

void main() {
  group('MainNavigationShell Back Button Tests (Option C)', () {
    testWidgets('Priority 1: back button closes active modal first', (
      tester,
    ) async {
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainNavigationShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => Scaffold(
                      body: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              builder: (ctx) => const SizedBox(
                                height: 200,
                                child: Text('Modal Aktif SPP'),
                              ),
                            );
                          },
                          child: const Text('Buka Modal'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/mutation',
                    builder: (context, state) => const Scaffold(
                      body: Text('Halaman Mutasi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Buka Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Aktif SPP'), findsOneWidget);
      expect(rootNavigatorKey.currentState?.canPop(), isTrue);

      // Simulate system back button via WidgetsBinding
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // Modal should now be closed!
      expect(find.text('Modal Aktif SPP'), findsNothing);
      expect(find.text('Buka Modal'), findsOneWidget);
    });

    testWidgets('Priority 2: back button from non-home tab returns to Home tab', (
      tester,
    ) async {
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/mutation',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainNavigationShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const Scaffold(
                      body: Text('Halaman Beranda'),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/mutation',
                    builder: (context, state) => const Scaffold(
                      body: Text('Halaman Mutasi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Mutasi tab
      expect(find.text('Halaman Mutasi'), findsOneWidget);

      // Simulate back press
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // Should now switch to Home tab
      expect(find.text('Halaman Beranda'), findsOneWidget);
    });

    testWidgets('Priority 3: back button on Home tab shows exit warning snackbar', (
      tester,
    ) async {
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainNavigationShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const Scaffold(
                      body: Text('Halaman Beranda'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        ),
      );
      await tester.pumpAndSettle();

      // Simulate back press on Home tab
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // SnackBar should appear
      expect(
        find.text('Tekan sekali lagi untuk keluar dari aplikasi'),
        findsOneWidget,
      );
    });

    testWidgets('Subroute in branch (/home/kwitansi) pops on back and returns to /home', (
      tester,
    ) async {
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainNavigationShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => Scaffold(
                      body: Center(
                        child: ElevatedButton(
                          onPressed: () => context.push('/home/kwitansi'),
                          child: const Text('Buka Kwitansi'),
                        ),
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'kwitansi',
                        builder: (context, state) => const Scaffold(
                          body: Text('Halaman Kwitansi Digital'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        ),
      );
      await tester.pumpAndSettle();

      // Open Kwitansi
      await tester.tap(find.text('Buka Kwitansi'));
      await tester.pumpAndSettle();

      expect(find.text('Halaman Kwitansi Digital'), findsOneWidget);

      // Simulate system back button
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // Subroute popped and user is back on /home
      expect(find.text('Halaman Kwitansi Digital'), findsNothing);
      expect(find.text('Buka Kwitansi'), findsOneWidget);
    });

    testWidgets(
        'Dialog on subroute (/home/kwitansi) dismisses on back and stays on /home/kwitansi',
        (tester) async {
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/home/kwitansi',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainNavigationShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const Scaffold(
                      body: Text('Halaman Beranda'),
                    ),
                    routes: [
                      GoRoute(
                        path: 'kwitansi',
                        builder: (context, state) => Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (ctx) => const AlertDialog(
                                    title: Text('Modal Tambah Kwitansi'),
                                  ),
                                );
                              },
                              child: const Text('Tambah Kwitansi'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        ),
      );
      await tester.pumpAndSettle();

      // Ensure we are on kwitansi page
      expect(find.text('Tambah Kwitansi'), findsOneWidget);

      // Open create modal
      await tester.tap(find.text('Tambah Kwitansi'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Tambah Kwitansi'), findsOneWidget);

      // Simulate system back press
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // Modal is dismissed, user is STILL on kwitansi page
      expect(find.text('Modal Tambah Kwitansi'), findsNothing);
      expect(find.text('Tambah Kwitansi'), findsOneWidget);
      expect(find.text('Halaman Beranda'), findsNothing);
    });
  });
}
