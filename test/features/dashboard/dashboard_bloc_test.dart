import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/core/network/api_result.dart';
import 'package:mobile_sikesan_flutter/core/network/dio_client.dart';
import 'package:mobile_sikesan_flutter/data/local/secure_storage_service.dart';
import 'package:mobile_sikesan_flutter/data/models/dashboard_metric_model.dart';
import 'package:mobile_sikesan_flutter/data/models/menu_item_model.dart';
import 'package:mobile_sikesan_flutter/data/models/transaction_item_model.dart';
import 'package:mobile_sikesan_flutter/data/repositories/dashboard_repository.dart';
import 'package:mobile_sikesan_flutter/features/dashboard/bloc/dashboard_bloc.dart';

class MockDashboardRepository extends DashboardRepository {
  ApiResult<DashboardMetricModel>? metricResult;
  ApiResult<List<TransactionItemModel>>? txResult;

  MockDashboardRepository()
      : super(DioClient(secureStorage: SecureStorageService()));

  @override
  Future<ApiResult<DashboardMetricModel>> getDashboardMetrics({String role = 'Wali Santri'}) async {
    return metricResult ??
        const ApiSuccess(
          DashboardMetricModel(
            totalBalance: 500000,
            totalIncome: 100000,
            totalExpense: 50000,
            totalUnpaidSpp: 250000,
            monthlyBill: 250000,
            unpaidStatus: 'Belum Lunas',
          ),
        );
  }

  @override
  Future<ApiResult<List<TransactionItemModel>>> getRecentTransactions({int perPage = 5}) async {
    return txResult ??
        ApiSuccess([
          TransactionItemModel(
            id: '1',
            title: 'Top Up Tunai',
            category: 'Top Up',
            amount: 100000,
            isIncome: true,
            date: DateTime(2026, 9, 20),
            studentName: 'Ahmad',
          ),
        ]);
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsForRole(String role) async {
    return MenuItemModel.defaultMenus().where((m) => m.isVisibleForRole(role)).toList();
  }
}

void main() {
  group('DashboardBloc Unit Tests', () {
    late MockDashboardRepository mockRepo;
    late DashboardBloc dashboardBloc;

    setUp(() {
      mockRepo = MockDashboardRepository();
      dashboardBloc = DashboardBloc(dashboardRepository: mockRepo);
    });

    tearDown(() {
      dashboardBloc.close();
    });

    test('Initial state is correct', () {
      expect(dashboardBloc.state.status, DashboardStatus.initial);
      expect(dashboardBloc.state.carouselIndex, 0);
      expect(dashboardBloc.state.isMenuExpanded, true);
    });

    test('DashboardCarouselChanged updates carouselIndex', () {
      dashboardBloc.add(const DashboardCarouselChanged(1));
      expect(dashboardBloc.stream, emits(predicate<DashboardState>((state) => state.carouselIndex == 1)));
    });

    test('DashboardToggleMenuExpanded toggles isMenuExpanded', () {
      dashboardBloc.add(const DashboardToggleMenuExpanded());
      expect(dashboardBloc.stream, emits(predicate<DashboardState>((state) => state.isMenuExpanded == false)));
    });

    test('DashboardFetchRequested loads metrics, transactions, and menus', () async {
      dashboardBloc.add(const DashboardFetchRequested(role: 'Wali Santri'));

      await expectLater(
        dashboardBloc.stream,
        emitsInOrder([
          predicate<DashboardState>((s) => s.status == DashboardStatus.loading),
          predicate<DashboardState>((s) {
            return s.status == DashboardStatus.loaded &&
                s.metrics.totalBalance == 500000 &&
                s.transactions.length == 1 &&
                s.menuItems.isNotEmpty;
          }),
        ]),
      );
    });
  });
}
