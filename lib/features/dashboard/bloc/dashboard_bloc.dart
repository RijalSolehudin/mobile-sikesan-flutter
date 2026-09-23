import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/dashboard_metric_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/transaction_item_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository,
        super(const DashboardState()) {
    on<DashboardFetchRequested>(_onDashboardFetchRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<DashboardCarouselChanged>(_onDashboardCarouselChanged);
    on<DashboardToggleMenuExpanded>(_onDashboardToggleMenuExpanded);
  }

  Future<void> _onDashboardFetchRequested(
    DashboardFetchRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await _loadDashboardData(event.role, emit);
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(event.role, emit);
  }

  void _onDashboardCarouselChanged(
    DashboardCarouselChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(carouselIndex: event.index));
  }

  void _onDashboardToggleMenuExpanded(
    DashboardToggleMenuExpanded event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(isMenuExpanded: !state.isMenuExpanded));
  }

  Future<void> _loadDashboardData(String role, Emitter<DashboardState> emit) async {
    try {
      final results = await Future.wait([
        _dashboardRepository.getDashboardMetrics(role: role),
        _dashboardRepository.getRecentTransactions(),
        _dashboardRepository.getMenuItemsForRole(role),
      ]);

      final metricsResult = results[0] as ApiResult<DashboardMetricModel>;
      final transactionsResult = results[1] as ApiResult<List<TransactionItemModel>>;
      final menuItems = results[2] as List<MenuItemModel>;

      DashboardMetricModel metrics = DashboardMetricModel.dummy();
      if (metricsResult is ApiSuccess<DashboardMetricModel>) {
        metrics = metricsResult.data;
      }

      List<TransactionItemModel> transactions = [];
      if (transactionsResult is ApiSuccess<List<TransactionItemModel>>) {
        transactions = transactionsResult.data;
      }

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          metrics: metrics,
          transactions: transactions,
          menuItems: menuItems,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Gagal memuat data dashboard: ${e.toString()}',
        ),
      );
    }
  }
}
