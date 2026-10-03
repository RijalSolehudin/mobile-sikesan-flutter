import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_sikesan_flutter/core/navigation/navigation_keys.dart';
import 'package:mobile_sikesan_flutter/features/navigation/screen/main_navigation_shell.dart';

void main() {
  group('MainNavigationShell Tests (No Tab History & Modal Unwinding)', () {
    List<Widget> createTestTabs() {
      return const [
        Scaffold(body: Text('Tab Beranda')),
        Scaffold(body: Text('Tab Mutasi')),
        Scaffold(body: Text('Tab Informasi')),
        Scaffold(body: Text('Tab CS')),
        Scaffold(body: Text('Tab Profil')),
      ];
    }

    testWidgets(
      'Priority 1: Hardware back button closes active modal and sub-modal in LIFO order',
      (tester) async {
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => MainNavigationShell(
                tabs: [
                  Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Buka modal pertama (Modal 1)
                          showDialog(
                            context: context,
                            useRootNavigator: true,
                            builder: (ctx1) => AlertDialog(
                              title: const Text('Modal 1 - Detail Riwayat'),
                              content: ElevatedButton(
                                onPressed: () {
                                  // Buka sub-modal kedua (Modal 2)
                                  showModalBottomSheet(
                                    context: ctx1,
                                    useRootNavigator: true,
                                    builder: (ctx2) => const SizedBox(
                                      height: 200,
                                      child: Text('Modal 2 - Edit Riwayat'),
                                    ),
                                  );
                                },
                                child: const Text('Buka Modal Edit'),
                              ),
                            ),
                          );
                        },
                        child: const Text('Buka Detail Riwayat'),
                      ),
                    ),
                  ),
                  const Scaffold(body: Text('Tab Mutasi')),
                  const Scaffold(body: Text('Tab Informasi')),
                  const Scaffold(body: Text('Tab CS')),
                  const Scaffold(body: Text('Tab Profil')),
                ],
              ),
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

        // 1. Buka Modal 1
        await tester.tap(find.text('Buka Detail Riwayat'));
        await tester.pumpAndSettle();
        expect(find.text('Modal 1 - Detail Riwayat'), findsOneWidget);

        // 2. Buka Sub-modal 2 dari dalam Modal 1
        await tester.tap(find.text('Buka Modal Edit'));
        await tester.pumpAndSettle();
        expect(find.text('Modal 2 - Edit Riwayat'), findsOneWidget);
        expect(find.text('Modal 1 - Detail Riwayat'), findsOneWidget);

        // 3. Tekan back pertama: Sub-modal 2 harus tertutup lebih dulu (LIFO)
        final dynamic widgetsBinding = tester.binding;
        await widgetsBinding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('Modal 2 - Edit Riwayat'), findsNothing);
        expect(find.text('Modal 1 - Detail Riwayat'), findsOneWidget);

        // 4. Tekan back kedua: Modal 1 harus tertutup
        await widgetsBinding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('Modal 1 - Detail Riwayat'), findsNothing);
        expect(find.text('Buka Detail Riwayat'), findsOneWidget);
      },
    );

    testWidgets(
      'Priority 2: Tab switching does NOT record history; back on non-home tab does not navigate back to previous tab',
      (tester) async {
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => MainNavigationShell(
                tabs: createTestTabs(),
              ),
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

        // Awalnya di Tab Beranda
        expect(find.text('Tab Beranda'), findsOneWidget);

        // Pindah ke Tab Mutasi (index 1) via Bottom Bar
        await tester.tap(find.text('Mutasi'));
        await tester.pumpAndSettle();
        expect(find.text('Tab Mutasi'), findsOneWidget);

        // Pindah lagi ke Tab Profil (index 4)
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();
        expect(find.text('Tab Profil'), findsOneWidget);

        // Sekarang tekan tombol back bawaan hp saat berada di Tab Profil
        final dynamic widgetsBinding = tester.binding;
        await widgetsBinding.handlePopRoute();
        await tester.pumpAndSettle();

        // HARUS TETAP di Tab Profil dan menampilkan snackbar konfirmasi keluar aplikasi!
        // TIDAK BOLEH kembali ke Tab Mutasi atau Tab Beranda!
        expect(find.text('Tab Profil'), findsOneWidget);
        expect(find.text('Tab Mutasi'), findsNothing);
        expect(
          find.text('Tekan sekali lagi untuk keluar dari aplikasi'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Subroute (/home/kwitansi) pops to /home, and modal on subroute closes before page pops',
      (tester) async {
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => MainNavigationShell(
                tabs: [
                  Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => context.push('/home/kwitansi'),
                        child: const Text('Ke Kwitansi'),
                      ),
                    ),
                  ),
                  const Scaffold(body: Text('Tab Mutasi')),
                  const Scaffold(body: Text('Tab Informasi')),
                  const Scaffold(body: Text('Tab CS')),
                  const Scaffold(body: Text('Tab Profil')),
                ],
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
                              title: Text('Modal Detail Kwitansi'),
                            ),
                          );
                        },
                        child: const Text('Buka Modal Kwitansi'),
                      ),
                    ),
                  ),
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

        // 1. Masuk ke subroute Kwitansi
        await tester.tap(find.text('Ke Kwitansi'));
        await tester.pumpAndSettle();
        expect(find.text('Buka Modal Kwitansi'), findsOneWidget);

        // 2. Buka dialog modal di Kwitansi
        await tester.tap(find.text('Buka Modal Kwitansi'));
        await tester.pumpAndSettle();
        expect(find.text('Modal Detail Kwitansi'), findsOneWidget);

        final dynamic widgetsBinding = tester.binding;

        // 3. Back press 1: Tutup modal kwitansi terlebih dahulu
        await widgetsBinding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Modal Detail Kwitansi'), findsNothing);
        expect(find.text('Buka Modal Kwitansi'), findsOneWidget);

        // 4. Back press 2: Keluar dari halaman Kwitansi kembali ke /home
        await widgetsBinding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Ke Kwitansi'), findsOneWidget);
        expect(find.text('Buka Modal Kwitansi'), findsNothing);
      },
    );

    testWidgets(
      'switchToTab programmatically changes active tab without adding to history',
      (tester) async {
        late BuildContext capturedContext;
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => MainNavigationShell(
                tabs: [
                  Builder(
                    builder: (ctx) {
                      capturedContext = ctx;
                      return const Scaffold(body: Text('Tab Beranda'));
                    },
                  ),
                  const Scaffold(body: Text('Tab Mutasi')),
                  const Scaffold(body: Text('Tab Informasi')),
                  const Scaffold(body: Text('Tab CS')),
                  const Scaffold(body: Text('Tab Profil')),
                ],
              ),
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

        expect(find.text('Tab Beranda'), findsOneWidget);

        // Programmatically switch to Tab Mutasi (index 1)
        MainNavigationShell.switchToTab(capturedContext, 1);
        await tester.pumpAndSettle();

        expect(find.text('Tab Mutasi'), findsOneWidget);
      },
    );
  });
}
