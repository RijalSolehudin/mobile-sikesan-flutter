import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/navigation/navigation_keys.dart';
import 'package:mobile_sikesan_flutter/core/navigation/snackbar_cleanup_observer.dart';
import 'package:mobile_sikesan_flutter/core/widgets/app_snackbar.dart';

void main() {
  group('AppSnackBar and SnackBarCleanupObserver Tests', () {
    testWidgets('AppSnackBar clears previous snackbar before showing a new one', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      AppSnackBar.showError(context, 'Pesan Pertama');
                    },
                    child: const Text('Show Error'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AppSnackBar.showSuccess(context, 'Pesan Kedua');
                    },
                    child: const Text('Show Success'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Tap first button 3 times rapidly
      await tester.tap(find.text('Show Error'));
      await tester.tap(find.text('Show Error'));
      await tester.tap(find.text('Show Error'));
      await tester.pump();

      // Only ONE SnackBar is in widget tree, not 3 queued
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Pesan Pertama'), findsOneWidget);

      // Tap second button once
      await tester.tap(find.text('Show Success'));
      await tester.pump();

      // The first message is immediately cleared, and replaced by the second
      expect(find.text('Pesan Pertama'), findsNothing);
      expect(find.text('Pesan Kedua'), findsOneWidget);
    });

    testWidgets('SnackBarCleanupObserver clears snackbars on route navigation', (
      tester,
    ) async {
      final observer = SnackBarCleanupObserver();

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          navigatorObservers: [observer],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppSnackBar.showInfo(context, 'Pesan di Halaman 1');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const Scaffold(
                        body: Text('Halaman 2'),
                      ),
                    ),
                  );
                },
                child: const Text('Go to Page 2'),
              ),
            ),
          ),
        ),
      );

      // Show snackbar and navigate
      await tester.tap(find.text('Go to Page 2'));
      await tester.pumpAndSettle();

      // Page 2 is visible
      expect(find.text('Halaman 2'), findsOneWidget);
      // SnackBar from page 1 must NOT exist
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
