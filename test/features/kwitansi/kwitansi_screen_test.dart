import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/models/user_model.dart';
import 'package:mobile_sikesan_flutter/data/repositories/auth_repository.dart';
import 'package:mobile_sikesan_flutter/data/repositories/infaq_repository.dart';
import 'package:mobile_sikesan_flutter/data/repositories/kwitansi_repository.dart';
import 'package:mobile_sikesan_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/screen/kwitansi_screen.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_header.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_summary_card.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_card.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/kwitansi_detail_modal.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/widget/create_kwitansi_modal.dart';

const _processor = {
  'id': 7,
  'name': 'Risda Nur Fajar Purnama,SE',
  'phone': '088218712525',
};

const _loggedInUser = UserModel(
  id: 7,
  name: 'Risda Nur Fajar Purnama,SE',
  username: 'risda',
  email: 'risda@example.com',
  role: 'Bendahara',
  phone: '088218712525',
);

Map<String, dynamic> _kwitansiJson({
  required int id,
  required String number,
  required String name,
  required num price,
  String issuedAt = '2026-09-01T17:36:00',
  String? whatsapp,
}) => {
  'id': id,
  'receipt_number': number,
  'issued_at': issuedAt,
  'recipient_name': name,
  'category': 'Pondok',
  'payment_method': 'Transfer',
  'status': 'active',
  'whatsapp_number': whatsapp,
  'signer_role': 'Bendahara Yayasan',
  'total_amount': price,
  'items': [
    {'id': id * 10, 'description': 'SPP Bulan September 2026', 'qty': 1, 'price': price},
  ],
  'processed_by': _processor,
};

/// Backend palsu in-memory yang mengikuti kontrak `/kwitansi`.
class _FakeKwitansiBackend {
  final List<Map<String, dynamic>> store = [
    _kwitansiJson(
      id: 1,
      number: 'INV/PONDOK/2026/09/01/017',
      name: 'M Nazri Fatih altaf',
      price: 500000,
    ),
    _kwitansiJson(
      id: 2,
      number: 'INV/PONDOK/2026/09/02/018',
      name: 'Muhammad Rais Al Fatih',
      price: 750000,
      issuedAt: '2026-09-02T17:24:00',
    ),
  ];
  Map<String, dynamic>? lastCreatePayload;

  void handle(RequestOptions options, RequestInterceptorHandler handler) {
    Response ok(dynamic data, [int code = 200]) =>
        Response(requestOptions: options, statusCode: code, data: data);

    final path = options.path;
    final detail = RegExp(r'^/kwitansi/(\d+)$').firstMatch(path);

    if (path == '/students') {
      return handler.resolve(ok({'data': <dynamic>[]}));
    }
    if (path == '/kwitansi/categories') {
      return handler.resolve(ok({'data': ['Pondok']}));
    }
    if (path == '/kwitansi' && options.method == 'GET') {
      final q = (options.queryParameters['search'] ?? '').toString().toLowerCase();
      final list = store
          .where((e) => q.isEmpty || e['recipient_name'].toString().toLowerCase().contains(q))
          .toList();
      return handler.resolve(ok({
        'data': {'data': list, 'current_page': 1, 'last_page': 1, 'total': list.length},
      }));
    }
    if (path == '/kwitansi' && options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      lastCreatePayload = body;
      final items = (body['items'] as List).cast<Map<String, dynamic>>();
      final total = items.fold<num>(0, (s, e) => s + (e['qty'] as int) * (e['price'] as num));
      final created = {
        ...body,
        'id': 99,
        'receipt_number': 'INV/PONDOK/2026/09/03/099',
        'status': 'active',
        'total_amount': total,
        // Backend mengisi penandatangan dari akun yang login
        'processed_by': _processor,
      };
      store.insert(0, created);
      return handler.resolve(ok({'data': created, 'message': 'Kwitansi dibuat'}, 201));
    }
    if (detail != null) {
      final id = int.parse(detail.group(1)!);
      final idx = store.indexWhere((e) => e['id'] == id);
      if (idx == -1) return handler.resolve(ok({'message': 'Not found'}, 404));
      if (options.method == 'DELETE') {
        store.removeAt(idx);
        return handler.resolve(ok({'message': 'Dihapus'}));
      }
      return handler.resolve(ok({'data': store[idx]}));
    }
    handler.resolve(ok({'message': 'Unhandled $path'}, 404));
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository()
    : super(DioClient(secureStorage: SecureStorageService()), SecureStorageService());

  @override
  Future<ApiResult<UserModel>> login({
    required String username,
    required String password,
  }) async => const ApiSuccess(_loggedInUser);
}

void main() {
  late _FakeKwitansiBackend backend;
  late Dio dio;
  late DioClient dioClient;
  late AuthBloc authBloc;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    backend = _FakeKwitansiBackend();
    dio = Dio();
    dioClient = DioClient.withDio(dio, secureStorage: SecureStorageService());
    dio.interceptors.add(InterceptorsWrapper(onRequest: backend.handle));
    authBloc = AuthBloc(authRepository: _FakeAuthRepository())
      ..add(const AuthLoginRequested(username: 'risda', password: 'x'));
    await authBloc.stream.firstWhere((s) => s.user != null);
  });

  tearDown(() => authBloc.close());

  Widget buildApp() => MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (_) => KwitansiRepository(dioClient)),
      RepositoryProvider(create: (_) => InfaqRepository(dioClient)),
    ],
    child: BlocProvider.value(
      value: authBloc,
      child: const MaterialApp(home: KwitansiScreen()),
    ),
  );

  testWidgets('KwitansiScreen loads receipts from backend and searches server-side', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(KwitansiHeader), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pondok'), findsWidgets);
    expect(find.byType(KwitansiSummaryCard), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(KwitansiCard), findsNWidgets(2));
    expect(find.text('M Nazri Fatih altaf'), findsOneWidget);
    expect(find.text('INV/PONDOK/2026/09/01/017'), findsOneWidget);
    expect(find.text('Rp 500.000'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nazri');
    await tester.pump(const Duration(milliseconds: 500)); // debounce
    await tester.pumpAndSettle();

    expect(find.byType(KwitansiCard), findsOneWidget);
    expect(find.text('Muhammad Rais Al Fatih'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Detail shows signer from processed_by account', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('M Nazri Fatih altaf'));
    await tester.pumpAndSettle();

    expect(find.byType(KwitansiDetailModal), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(KwitansiDetailModal),
        matching: find.text('01/09/2026 17:36'),
      ),
      findsOneWidget,
    );
    expect(find.text('Lima Ratus Ribu Rupiah'), findsOneWidget);
    expect(find.text('Risda Nur Fajar Purnama,SE'), findsOneWidget);
    expect(find.text('Bendahara Yayasan'), findsOneWidget);
    expect(find.text('Unduh PDF'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });

  testWidgets('Delete calls backend and removes the card', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('M Nazri Fatih altaf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
    await tester.pumpAndSettle();

    expect(find.byType(KwitansiDetailModal), findsNothing);
    expect(backend.store.any((e) => e['id'] == 1), isFalse);
    expect(find.text('M Nazri Fatih altaf'), findsNothing);
    expect(find.byType(KwitansiCard), findsOneWidget);
  });

  testWidgets(
    'Create posts to backend without signer name; signer comes from logged-in account',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(CreateKwitansiModal), findsOneWidget);

      // Penandatangan read-only dari akun yang login
      expect(find.text('Risda Nur Fajar Purnama,SE'), findsOneWidget);
      expect(find.text('Nama penandatangan'), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ketik nama atau pilih dari database..'),
        'das',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '08xxxxxxxxxx'),
        '081234567890',
      );
      await tester.enterText(find.widgetWithText(TextFormField, '0'), '1');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi Item'),
        'das',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan Invoice'));
      await tester.tap(find.text('Simpan Invoice'));
      await tester.pumpAndSettle();

      final payload = backend.lastCreatePayload!;
      expect(payload['recipient_name'], 'das');
      expect(payload['whatsapp_number'], '081234567890');
      expect(payload.containsKey('signer_name'), isFalse);
      expect(payload.containsKey('contact'), isFalse);
      expect((payload['items'] as List).single['price'], 1);

      expect(find.byType(KwitansiDetailModal), findsOneWidget);
      expect(find.text('Satu Rupiah'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(KwitansiCard), findsNWidgets(3));
    },
  );
}
