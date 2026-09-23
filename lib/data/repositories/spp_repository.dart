import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/spp_models.dart';

class SppRepository {
  final DioClient dioClient;

  SppRepository(this.dioClient);

  Future<ApiResult<List<StudentLookupModel>>> getStudents({String? search}) async {
    try {
      final response = await dioClient.dio.get(
        '/students',
        queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
      );

      final dynamic dataField = response.data['data'];
      List<dynamic> list = [];
      if (dataField is Map<String, dynamic> && dataField['data'] is List) {
        list = dataField['data'] as List<dynamic>;
      } else if (dataField is List) {
        list = dataField;
      }

      final students = list
          .whereType<Map<String, dynamic>>()
          .map((item) => StudentLookupModel.fromJson(item))
          .toList();

      return ApiSuccess(students);
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat data santri',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<List<SppBillModel>>> getStudentBills(int studentId) async {
    try {
      final response = await dioClient.dio.get('/students/$studentId/bills');
      final dynamic rawList = response.data['data'];
      List<dynamic> list = [];
      if (rawList is List) {
        list = rawList;
      }

      final bills = list
          .whereType<Map<String, dynamic>>()
          .map((item) => SppBillModel.fromJson(item))
          .toList();

      return ApiSuccess(bills);
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat tagihan SPP',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<String>> payDirect({
    required int studentId,
    required List<String> billIds,
    required num totalAmount,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/spp/payments',
        data: {
          'student_id': studentId,
          'bill_ids': billIds,
          'total_amount': totalAmount.toInt(),
          'payment_method': 'CASH',
        },
      );

      final paymentData = response.data['data'];
      final paymentId = paymentData?['id']?.toString() ?? '';
      return ApiSuccess(paymentId, message: response.data['message']?.toString());
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memproses pembayaran kasir',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<String>> submitTransferPayment({
    required int studentId,
    required List<String> billIds,
    required num totalAmount,
    required File proofFile,
    String? bankName,
    String? accountHolder,
  }) async {
    try {
      final formData = FormData.fromMap({
        'student_id': studentId,
        'total_amount': totalAmount.toInt(),
        'sender_bank_name': bankName ?? 'Transfer Bank',
        'sender_account_holder': accountHolder ?? 'Wali Santri',
        'proof': await MultipartFile.fromFile(
          proofFile.path,
          filename: proofFile.path.split('/').last,
        ),
      });

      for (int i = 0; i < billIds.length; i++) {
        formData.fields.add(MapEntry('bill_ids[$i]', billIds[i]));
      }

      final response = await dioClient.dio.post(
        '/spp/submit-payment',
        data: formData,
      );

      final paymentData = response.data['data'];
      final paymentId = paymentData?['id']?.toString() ?? '';
      return ApiSuccess(paymentId, message: response.data['message']?.toString());
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal mengirim pembayaran transfer',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<SppReceiptModel>> getReceipt(String paymentId) async {
    try {
      final response = await dioClient.dio.get('/spp/payments/$paymentId/receipt');
      final dynamic raw = response.data['data'];
      if (raw is Map<String, dynamic>) {
        return ApiSuccess(SppReceiptModel.fromJson(raw));
      }
      return ApiFailure('Data kwitansi tidak valid');
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat kwitansi',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
