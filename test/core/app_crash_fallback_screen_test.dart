import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/widgets/app_crash_fallback_screen.dart';

void main() {
  testWidgets('AppCrashFallbackScreen displays polite message and reload button', (
    WidgetTester tester,
  ) async {
    final details = FlutterErrorDetails(
      exception: Exception('Simulated test rendering exception'),
      stack: StackTrace.current,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppCrashFallbackScreen(errorDetails: details),
      ),
    );

    // Verify main informative text is rendered
    expect(find.text('Terjadi Kendala Teknis'), findsOneWidget);
    expect(
      find.textContaining('sistem mendeteksi kendala pada tampilan antarmuka'),
      findsOneWidget,
    );
    expect(find.text('Muat Ulang Halaman'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    // In test environment (kDebugMode = true), debug toggle should be present
    expect(find.text('Lihat Detail Error (Debug)'), findsOneWidget);

    // Tap toggle to reveal debug stack trace
    await tester.tap(find.text('Lihat Detail Error (Debug)'));
    await tester.pumpAndSettle();

    expect(find.text('Sembunyikan Detail Log'), findsOneWidget);
    expect(
      find.textContaining('Simulated test rendering exception'),
      findsOneWidget,
    );
  });
}
