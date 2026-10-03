import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final DioClient dioClient;

  AnnouncementRepository(this.dioClient);

  /// Mengambil daftar pengumuman dari API backend.
  /// Jika endpoint belum tersedia (404), gunakan mock data.
  Future<ApiResult<List<AnnouncementModel>>> getAnnouncements({
    int page = 1,
    int perPage = 15,
    String? category,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};
      if (category != null && category != 'Semua') {
        queryParams['category'] = category;
      }
      if (status != null && status != 'Semua') {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dioClient.dio.get(
        '/announcements',
        queryParameters: queryParams,
      );

      final dynamic responseData = response.data;
      List<dynamic> items = [];

      if (responseData is Map<String, dynamic>) {
        final dataField = responseData['data'];
        if (dataField is Map<String, dynamic> && dataField['data'] is List) {
          items = dataField['data'] as List<dynamic>;
        } else if (dataField is List) {
          items = dataField;
        }
      } else if (responseData is List) {
        items = responseData;
      }

      final announcements = items
          .whereType<Map<String, dynamic>>()
          .map((item) => AnnouncementModel.fromJson(item))
          .toList();

      return ApiSuccess(announcements);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const ApiFailure(
          'Fitur pengumuman belum terintegrasi dengan data backend.',
          statusCode: 404,
        );
      }
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat pengumuman',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Mengambil detail pengumuman berdasarkan ID.
  Future<ApiResult<AnnouncementModel>> getAnnouncementDetail(String id) async {
    try {
      final response = await dioClient.dio.get('/announcements/$id');
      final dynamic responseData = response.data;

      Map<String, dynamic> item = {};
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is Map<String, dynamic>) {
          item = responseData['data'] as Map<String, dynamic>;
        } else {
          item = responseData;
        }
      }

      return ApiSuccess(AnnouncementModel.fromJson(item));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const ApiFailure(
          'Detail pengumuman belum terintegrasi dengan data backend.',
          statusCode: 404,
        );
      }
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat detail pengumuman',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
