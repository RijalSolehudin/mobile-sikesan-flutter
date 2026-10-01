import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/spp_models.dart';
import '../models/top_up_models.dart';
import '../models/withdraw_models.dart';

class WalletRepository {
  final DioClient dioClient;

  WalletRepository(this.dioClient);

  /// Withdraw / debit balance from student wallet
  Future<ApiResult<WithdrawReceiptModel>> withdrawWallet({
    required int studentId,
    required int amount,
    String? description,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? const Uuid().v4();
      final response = await dioClient.dio.post(
        ApiEndpoints.walletWithdraw,
        data: {
          'student_id': studentId,
          'amount': amount,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
        options: Options(
          headers: {'Idempotency-Key': key},
        ),
      );

      final dynamic dataField = response.data['data'];
      if (dataField is Map<String, dynamic> && dataField['receipt'] != null) {
        final receipt = WithdrawReceiptModel.fromJson(
          dataField['receipt'] as Map<String, dynamic>,
        );
        return ApiSuccess(
          receipt,
          message: response.data['message']?.toString() ??
              'Penarikan saldo berhasil diproses',
        );
      }

      return ApiFailure('Format respon tidak sesuai');
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memproses penarikan saldo',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Submit top-up request to backend
  Future<ApiResult<TopUpRequestModel>> submitTopUpRequest({
    required int studentId,
    required int amount,
    required String paymentMethod, // 'TRANSFER' or 'CASH'
    List<int>? proofBytes,
    String? proofFilename,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? const Uuid().v4();
      final mapData = <String, dynamic>{
        'student_id': studentId,
        'requested_amount': amount,
        'payment_method': paymentMethod,
      };

      if (proofBytes != null && proofBytes.isNotEmpty) {
        mapData['proof'] = MultipartFile.fromBytes(
          proofBytes,
          filename: proofFilename ?? 'proof.jpg',
        );
      }

      final formData = FormData.fromMap(mapData);

      final response = await dioClient.dio.post(
        ApiEndpoints.topUps,
        data: formData,
        options: Options(
          headers: {'Idempotency-Key': key},
        ),
      );

      final dynamic dataField = response.data['data'];
      if (dataField is Map<String, dynamic>) {
        final topUp = TopUpRequestModel.fromJson(dataField);
        return ApiSuccess(
          topUp,
          message: response.data['message']?.toString() ??
              'Permintaan top-up berhasil diajukan',
        );
      }

      return ApiFailure('Format respon tidak sesuai');
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal mengajukan top up saldo',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Approve top up request (Admin / Bendahara / Kasir direct counter payment)
  Future<ApiResult<void>> approveTopUp(String topUpId) async {
    try {
      final response = await dioClient.dio.post(
        '${ApiEndpoints.topUps}/$topUpId/approve',
      );

      return ApiSuccess(
        null,
        message: response.data['message']?.toString() ??
            'Top up saldo berhasil disetujui',
      );
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal menyetujui top up saldo',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Search students for Admin / Bendahara / Kasir
  Future<ApiResult<List<StudentLookupModel>>> getStudents({
    String? search,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.students,
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
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
}
