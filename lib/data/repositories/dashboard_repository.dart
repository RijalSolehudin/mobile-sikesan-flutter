import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard_metric_model.dart';
import '../models/menu_item_model.dart';
import '../models/transaction_item_model.dart';

class DashboardRepository {
  final DioClient dioClient;

  DashboardRepository(this.dioClient);

  Future<ApiResult<DashboardMetricModel>> getDashboardMetrics({
    String role = 'Wali Santri',
  }) async {
    try {
      final normalizedRole = role.toLowerCase();
      final isGuardian = normalizedRole.contains('wali');
      final endpoint = isGuardian
          ? ApiEndpoints.guardianDashboard
          : ApiEndpoints.treasurerDashboard;

      final response = await dioClient.dio.get(endpoint);
      final dynamic rawData = response.data['data'] ?? response.data;

      if (rawData is Map<String, dynamic>) {
        if (isGuardian) {
          return ApiSuccess(DashboardMetricModel.fromGuardianJson(rawData));
        } else {
          return ApiSuccess(DashboardMetricModel.fromTreasurerJson(rawData));
        }
      }

      return ApiSuccess(DashboardMetricModel.empty(role: role));
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        // Fallback for roles that don't have dedicated dashboard metric
        return ApiSuccess(DashboardMetricModel.empty(role: role));
      }
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat metrik dashboard',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<List<TransactionItemModel>>> getRecentTransactions({
    int perPage = 5,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.walletTransactions,
        queryParameters: {'per_page': perPage},
      );

      final dynamic responseData = response.data;
      List<dynamic> items = [];

      if (responseData is Map<String, dynamic>) {
        final dataField = responseData['data'];
        if (dataField is Map<String, dynamic> && dataField['data'] is List) {
          // Laravel LengthAwarePaginator: { data: { data: [...] } }
          items = dataField['data'] as List<dynamic>;
        } else if (dataField is List) {
          items = dataField;
        }
      } else if (responseData is List) {
        items = responseData;
      }

      final transactions = items
          .whereType<Map<String, dynamic>>()
          .map((item) => TransactionItemModel.fromJson(item))
          .toList();

      return ApiSuccess(transactions);
    } on DioException catch (e) {
      return ApiFailure(
        e.response?.data?['message'] ?? 'Gagal memuat transaksi terbaru',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiFailure('Terjadi kesalahan memuat transaksi: ${e.toString()}');
    }
  }

  Future<ApiResult<List<TransactionItemModel>>> getSppTransactions({
    bool isGuardian = true,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/transactions/spp',
        queryParameters: {'per_page': 20},
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

      final transactions = items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) =>
                TransactionItemModel.fromSppJson(item, isGuardian: isGuardian),
          )
          .toList();

      return ApiSuccess(transactions);
    } catch (e) {
      return ApiFailure('Gagal memuat transaksi SPP: ${e.toString()}');
    }
  }

  Future<ApiResult<List<TransactionItemModel>>> getInfaqTransactions({
    bool isGuardian = true,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/transactions/infaq',
        queryParameters: {'per_page': 20},
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

      final transactions = items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => TransactionItemModel.fromInfaqJson(
              item,
              isGuardian: isGuardian,
            ),
          )
          .toList();

      return ApiSuccess(transactions);
    } catch (e) {
      return ApiFailure('Gagal memuat transaksi Infak: ${e.toString()}');
    }
  }

  Future<List<MenuItemModel>> getMenuItemsForRole(String role) async {
    try {
      // Check if remote menu config endpoint exists with role query
      final response = await dioClient.dio.get(
        '/mobile/menu-config',
        queryParameters: {'role': role},
      );
      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'];
        List<dynamic> remoteList = [];
        if (rawData is List) {
          remoteList = rawData;
        } else if (rawData is Map<String, dynamic> && rawData[role] is List) {
          remoteList = rawData[role] as List<dynamic>;
        }

        if (remoteList.isNotEmpty) {
          final defaultMap = {
            for (var m in MenuItemModel.defaultMenus()) m.id: m,
          };
          final List<MenuItemModel> result = [];

          for (var item in remoteList) {
            if (item is Map<String, dynamic>) {
              final id = item['id']?.toString() ?? '';
              final isEnabled = item['is_enabled'] ?? true;
              if (defaultMap.containsKey(id) && isEnabled) {
                // Dynamically enabled by administrator for this role
                result.add(defaultMap[id]!);
              }
            }
          }
          if (result.isNotEmpty) return result;
        }
      }
    } catch (_) {
      // Gracefully fall back to client-side default menus
    }

    // Default client-side role filtering
    return MenuItemModel.defaultMenus()
        .where((menu) => menu.isVisibleForRole(role))
        .toList();
  }
}
