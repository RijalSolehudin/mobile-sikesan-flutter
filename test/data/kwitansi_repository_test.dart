import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/repositories/kwitansi_repository.dart';
import 'package:mobile_sikesan_flutter/features/kwitansi/models/kwitansi_model.dart';

void main() {
  group('KwitansiModel.fromJson', () {
    test('maps backend contract incl. processed_by as signer & contact', () {
      final m = KwitansiModel.fromJson({
        'id': 12,
        'receipt_number': 'INV/PONDOK/2026/09/01/017',
        'issued_at': '2026-09-01T17:36:00',
        'recipient_name': 'M Nazri Fatih altaf',
        'category': 'Pondok',
        'payment_method': 'Transfer',
        'status': 'active',
        'total_amount': '500000.00',
        'signer_role': 'Bendahara Yayasan',
        'items': [
          {'description': 'SPP Bulan September 2026', 'qty': 1, 'price': 500000},
        ],
        'processed_by': {'id': 7, 'name': 'Risda Nur Fajar Purnama,SE', 'phone': '0812'},
      });

      expect(m.id, '12');
      expect(m.amount, 500000);
      expect(m.dateTime, '01/09/2026 17:36');
      expect(m.status, 'Aktif');
      expect(m.signerName, 'Risda Nur Fajar Purnama,SE');
      expect(m.contact, '0812');
      expect(m.items.single.total, 500000);
    });

    test('falls back to items total and safe defaults', () {
      final m = KwitansiModel.fromJson({
        'id': 1,
        'items': [
          {'description': 'A', 'qty': 2, 'price': 1000},
          {'description': 'B', 'qty': 1, 'price': 500},
        ],
      });
      expect(m.amount, 2500);
      expect(m.signerName, '-');
      expect(m.contact, isNull);
      expect(m.signerRole, KwitansiModel.defaultSignerRole);
      expect(m.itemCountDescription, '2 Item Pembayaran');
    });
  });

  test('KwitansiRequest.toJson never sends signer name/contact', () {
    final json = KwitansiRequest(
      issuedAt: DateTime(2026, 9, 1, 17, 36),
      recipientName: ' Budi ',
      email: '  ',
      category: 'Pondok',
      paymentMethod: 'Tunai',
      items: const [KwitansiItemDetail(description: 'X', qty: 2, price: 100)],
      signerRole: 'Bendahara Yayasan',
    ).toJson();

    expect(json['issued_at'], '2026-09-01 17:36:00');
    expect(json['recipient_name'], 'Budi');
    expect(json.containsKey('email'), isFalse);
    expect(json.containsKey('signer_name'), isFalse);
    expect(json.containsKey('contact'), isFalse);
    expect(json['items'], [
      {'description': 'X', 'qty': 2, 'price': 100},
    ]);
  });

  group('KwitansiRepository', () {
    late Dio dio;
    late KwitansiRepository repo;

    setUp(() {
      dio = Dio();
      repo = KwitansiRepository(
        DioClient.withDio(dio, secureStorage: SecureStorageService()),
      );
    });

    test('parses Laravel paginator and sends filters', () async {
      RequestOptions? captured;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            captured = o;
            h.resolve(
              Response(
                requestOptions: o,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      {'id': 1, 'receipt_number': 'INV/1', 'total_amount': 10},
                    ],
                    'current_page': 1,
                    'last_page': 3,
                    'total': 41,
                  },
                },
              ),
            );
          },
        ),
      );

      final result = await repo.getKwitansi(
        search: 'nazri',
        category: 'Pondok',
        date: DateTime(2026, 9, 1),
      );

      expect(captured!.path, '/kwitansi');
      expect(captured!.queryParameters['search'], 'nazri');
      expect(captured!.queryParameters['category'], 'Pondok');
      expect(captured!.queryParameters['date'], '2026-09-01');
      final page = (result as ApiSuccess<KwitansiPage>).data;
      expect(page.items.single.receiptNumber, 'INV/1');
      expect(page.total, 41);
      expect(page.hasMore, isTrue);
    });

    test('surfaces first 422 validation message', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) => h.reject(
            DioException(
              requestOptions: o,
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: o,
                statusCode: 422,
                data: {
                  'message': 'The given data was invalid.',
                  'errors': {
                    'recipient_name': ['Nama penerima wajib diisi.'],
                  },
                },
              ),
            ),
          ),
        ),
      );

      final result = await repo.create(
        KwitansiRequest(
          issuedAt: DateTime(2026),
          recipientName: '',
          category: 'Pondok',
          paymentMethod: 'Tunai',
          items: const [],
          signerRole: 'Bendahara Yayasan',
        ),
      );

      expect(result, isA<ApiFailure<KwitansiModel>>());
      final failure = result as ApiFailure<KwitansiModel>;
      expect(failure.statusCode, 422);
      expect(failure.message, 'Nama penerima wajib diisi.');
    });
  });
}
