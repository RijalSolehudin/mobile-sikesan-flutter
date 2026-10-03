import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/screen/kwitansi_screen.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_header.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_summary_card.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_card.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_detail_modal.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/create_kwitansi_modal.dart';

void main() {
  testWidgets(
    'KwitansiScreen renders header, summary card, and receipt items correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: KwitansiScreen()));
      await tester.pumpAndSettle();

      // Check Header
      expect(find.byType(KwitansiHeader), findsOneWidget);
      expect(find.text('Kwitansi Digital'), findsOneWidget);
      expect(find.text('Kelola & Buat Kwitansi'), findsOneWidget);

      // Check Search & Calendar
      expect(find.text('Cari Nama Penerima'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);

      // Check Filter Chips
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pondok'), findsWidgets);

      // Check Summary Card
      expect(find.byType(KwitansiSummaryCard), findsOneWidget);
      expect(find.text('Total Kwitansi'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Periode & Kategori Terpilih'), findsOneWidget);

      // Check Section Title
      expect(find.text('Riwayat Kwitansi'), findsOneWidget);

      // Check Receipt Cards
      expect(find.byType(KwitansiCard), findsNWidgets(5));
      expect(find.text('M Nazri Fatih altaf'), findsOneWidget);
      expect(find.text('Muhammad Rais Al Fatih'), findsOneWidget);
      expect(find.text('INV/PONDOK/2026/09/01/017'), findsOneWidget);
      expect(find.text('Rp 500.000'), findsOneWidget);
      expect(find.text('Rp 750.000'), findsOneWidget);

      // Check FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Test Search filtering
      await tester.enterText(find.byType(TextField), 'Nazri');
      await tester.pumpAndSettle();

      expect(find.byType(KwitansiCard), findsOneWidget);
      expect(find.text('M Nazri Fatih altaf'), findsOneWidget);
      expect(find.text('Muhammad Rais Al Fatih'), findsNothing);
      expect(find.text('1'), findsOneWidget); // summary card updated to 1
    },
  );

  testWidgets(
    'Tapping a KwitansiCard opens KwitansiDetailModal with exact visual layout',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: KwitansiScreen()));
      await tester.pumpAndSettle();

      // Tap on the first receipt card
      await tester.tap(find.text('M Nazri Fatih altaf'));
      await tester.pumpAndSettle();

      // Verify KwitansiDetailModal is open
      expect(find.byType(KwitansiDetailModal), findsOneWidget);

      // Verify modal header and invoice number
      expect(
        find.descendant(
          of: find.byType(KwitansiDetailModal),
          matching: find.text('INV/PONDOK/2026/09/01/017'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KwitansiDetailModal),
          matching: find.text('01/09/2026 17:36'),
        ),
        findsOneWidget,
      );

      // Verify Total Kwitansi card
      expect(find.text('TOTAL KWITANSI'), findsOneWidget);

      // Verify details
      expect(find.text('Terima Dari'), findsOneWidget);
      expect(find.text('Uang Sebesar'), findsOneWidget);
      expect(find.text('Lima Ratus Ribu Rupiah'), findsOneWidget);
      expect(find.text('Detail Item'), findsOneWidget);
      expect(find.text('Metode Pembayaran'), findsOneWidget);
      expect(find.text('Hormat Kami'), findsOneWidget);
      expect(find.text('Risda Nur Fajar Purnama'), findsOneWidget);
      expect(find.text('Bendahara Yayasan'), findsOneWidget);

      // Verify 4 action buttons
      expect(find.text('Unduh PDF'), findsOneWidget);
      expect(find.text('Print'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(KwitansiDetailModal), findsNothing);
    },
  );

  testWidgets(
    'Tapping + opens CreateKwitansiModal, submits, and opens KwitansiDetailModal with WhatsApp button',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: KwitansiScreen()));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify CreateKwitansiModal is open
      expect(find.byType(CreateKwitansiModal), findsOneWidget);
      expect(find.text('Buat Invoice Digital'), findsOneWidget);
      expect(
        find.text('Isi detail invoice / kwitansi digital'),
        findsOneWidget,
      );

      // Verify form fields
      expect(
        find.text('Ketik nama atau pilih dari database..'),
        findsOneWidget,
      );
      expect(find.text('Simpan Invoice'), findsOneWidget);
      expect(find.text('Grand Total'), findsOneWidget);

      // Fill in Nama Tujuan
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Ketik nama atau pilih dari database..',
        ),
        'das',
      );
      await tester.pumpAndSettle();

      // Fill in No WhatsApp
      await tester.enterText(
        find.widgetWithText(TextFormField, '08xxxxxxxxxx'),
        '081234567890',
      );
      await tester.pumpAndSettle();

      // Fill in Email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'email@contoh.com'),
        'das@gmail.com',
      );
      await tester.pumpAndSettle();

      // Fill item price
      await tester.enterText(find.widgetWithText(TextFormField, '0'), '1');
      await tester.pumpAndSettle();

      // Fill item description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi Item'),
        'das',
      );
      await tester.pumpAndSettle();

      // Scroll down to submit button and tap
      await tester.ensureVisible(find.text('Simpan Invoice'));
      await tester.tap(find.text('Simpan Invoice'));
      await tester.pumpAndSettle();

      // Verify KwitansiDetailModal is opened immediately after submit (Screenshot 3)
      expect(find.byType(KwitansiDetailModal), findsOneWidget);
      expect(find.text('TOTAL KWITANSI'), findsOneWidget);
      expect(find.text('Rp 1'), findsWidgets);
      expect(find.text('Satu Rupiah'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Unduh PDF'), findsOneWidget);
      expect(find.text('Print'), findsOneWidget);

      // Close KwitansiDetailModal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(KwitansiDetailModal), findsNothing);
    },
  );
}
