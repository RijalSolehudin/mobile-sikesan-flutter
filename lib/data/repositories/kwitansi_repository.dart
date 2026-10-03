import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../../features/kwitansi/models/kwitansi_model.dart';

/// Repository Kwitansi Digital.
///
/// Kontrak API (lihat `docs/api_documentation.md` – Kwitansi Digital):
/// - `GET    /kwitansi`             list + filter (`search`, `category`, `date`, `page`, `per_page`)
/// - `GET    /kwitansi/categories`  daftar kategori unik
/// - `GET    /kwitansi/{id}`        detail
/// - `POST   /kwitansi`             buat (JSON / multipart jika ada lampiran)
/// - `PUT    /kwitansi/{id}`        ubah
/// - `DELETE /kwitansi/{id}`        hapus
///
/// Penandatangan (`processed_by`) diisi backend dari akun yang sedang login.
class KwitansiRepository {
  final DioClient dioClient;

  KwitansiRepository(this.dioClient);

  static const int defaultPerPage = 20;

  ApiFailure<T> _failure<T>(DioException e, String fallback) {
    final data = e.response?.data;
    Map<String, dynamic>? errors;
    if (data is Map && data['errors'] is Map) {
      errors = Map<String, dynamic>.from(data['errors'] as Map);
    }
    var message = DioClient.formatDioError(e, fallback: fallback);
    if (errors != null && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) message = first.first.toString();
    }
    return ApiFailure<T>(
      message,
      statusCode: e.response?.statusCode,
      errors: errors,
    );
  }

  KwitansiModel? _parseSingle(dynamic body) {
    final dynamic raw = body is Map ? (body['data'] ?? body) : null;
    return raw is Map<String, dynamic> ? KwitansiModel.fromJson(raw) : null;
  }

  Future<ApiResult<KwitansiPage>> getKwitansi({
    String? search,
    String? category,
    DateTime? date,
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.isNotEmpty && category != 'Semua')
          'category': category,
        if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      };

      final response = await dioClient.dio.get(
        ApiEndpoints.kwitansi,
        queryParameters: query,
      );

      final dynamic dataField = response.data is Map
          ? response.data['data']
          : response.data;

      List<dynamic> list = [];
      int currentPage = page;
      int lastPage = page;
      int total = 0;

      if (dataField is Map<String, dynamic> && dataField['data'] is List) {
        // Laravel paginator: { data: { data: [...], current_page, last_page, total } }
        list = dataField['data'] as List<dynamic>;
        currentPage =
            int.tryParse(dataField['current_page']?.toString() ?? '') ?? page;
        lastPage =
            int.tryParse(dataField['last_page']?.toString() ?? '') ??
            currentPage;
        total =
            int.tryParse(dataField['total']?.toString() ?? '') ?? list.length;
      } else if (dataField is List) {
        list = dataField;
        final meta = response.data is Map ? response.data['meta'] : null;
        if (meta is Map) {
          currentPage =
              int.tryParse(meta['current_page']?.toString() ?? '') ?? page;
          lastPage =
              int.tryParse(meta['last_page']?.toString() ?? '') ?? currentPage;
          total = int.tryParse(meta['total']?.toString() ?? '') ?? list.length;
        } else {
          total = list.length;
        }
      }

      final items = list
          .whereType<Map<String, dynamic>>()
          .map(KwitansiModel.fromJson)
          .toList();

      return ApiSuccess(
        KwitansiPage(
          items: items,
          currentPage: currentPage,
          lastPage: lastPage,
          total: total,
        ),
      );
    } on DioException catch (e) {
      return _failure(e, 'Gagal memuat data kwitansi');
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<List<String>>> getCategories() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.kwitansiCategories);
      final dynamic raw = response.data is Map
          ? response.data['data']
          : response.data;
      final categories = raw is List
          ? raw
                .map((e) => e is Map ? e['name']?.toString() : e?.toString())
                .whereType<String>()
                .where((e) => e.trim().isNotEmpty)
                .toList()
          : <String>[];
      return ApiSuccess(categories);
    } on DioException catch (e) {
      return _failure(e, 'Gagal memuat kategori kwitansi');
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<KwitansiModel>> getDetail(String id) async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.kwitansiDetail(id));
      final item = _parseSingle(response.data);
      if (item == null) return const ApiFailure('Data kwitansi tidak valid');
      return ApiSuccess(item);
    } on DioException catch (e) {
      return _failure(e, 'Gagal memuat detail kwitansi');
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<KwitansiModel>> create(
    KwitansiRequest request, {
    XFile? attachment,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? const Uuid().v4();
      final payload = request.toJson();

      Object body = payload;
      if (attachment != null) {
        final formData = FormData();
        payload.forEach((k, v) {
          if (k == 'items') return;
          formData.fields.add(MapEntry(k, v.toString()));
        });
        for (var i = 0; i < request.items.length; i++) {
          final it = request.items[i];
          formData.fields
            ..add(MapEntry('items[$i][description]', it.description))
            ..add(MapEntry('items[$i][qty]', it.qty.toString()))
            ..add(MapEntry('items[$i][price]', it.price.toString()));
        }
        formData.files.add(
          MapEntry(
            'attachment',
            MultipartFile.fromBytes(
              await attachment.readAsBytes(),
              filename: attachment.name,
            ),
          ),
        );
        body = formData;
      }

      final response = await dioClient.dio.post(
        ApiEndpoints.kwitansi,
        data: body,
        options: Options(headers: {'Idempotency-Key': key}),
      );

      final item = _parseSingle(response.data);
      if (item == null) return const ApiFailure('Respon server tidak valid');
      return ApiSuccess(item, message: response.data['message']?.toString());
    } on DioException catch (e) {
      return _failure(e, 'Gagal menyimpan kwitansi');
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<KwitansiModel>> update(
    String id,
    KwitansiRequest request,
  ) async {
    try {
      final response = await dioClient.dio.put(
        ApiEndpoints.kwitansiDetail(id),
        data: request.toJson(),
      );
      final item = _parseSingle(response.data);
      if (item == null) return const ApiFailure('Respon server tidak valid');
      return ApiSuccess(item, message: response.data['message']?.toString());
    } on DioException catch (e) {
      return _failure(e, 'Gagal memperbarui kwitansi');
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> delete(String id) async {
    try {
      final response = await dioClient.dio.delete(
        ApiEndpoints.kwitansiDetail(id),
      );
      return ApiSuccess(
        null,
        message: response.data is Map
            ? response.data['message']?.toString()
            : null,
      );
    } on DioException catch (e) {
      return _failure(e, 'Gagal menghapus kwitansi');
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
