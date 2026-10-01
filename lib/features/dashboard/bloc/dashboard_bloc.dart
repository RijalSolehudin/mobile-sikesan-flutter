import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/bill_history_model.dart';
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
    on<DashboardBillsLoadMoreRequested>(_onDashboardBillsLoadMoreRequested);
    on<DashboardBillStatusFilterChanged>(_onDashboardBillStatusFilterChanged);
    on<DashboardHistoryTabChanged>(_onDashboardHistoryTabChanged);
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

  Future<void> _onDashboardBillsLoadMoreRequested(
    DashboardBillsLoadMoreRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.isLoadingMoreBills || !state.billsHasMore) return;

    emit(state.copyWith(isLoadingMoreBills: true));
    final nextPage = state.billsPage + 1;
    final result = await _dashboardRepository.getBillHistory(
      page: nextPage,
      perPage: 10,
      status: state.billStatusFilter,
    );

    if (result is ApiSuccess<List<BillHistoryModel>>) {
      final newBills = result.data;
      emit(
        state.copyWith(
          bills: [...state.bills, ...newBills],
          billsPage: nextPage,
          billsHasMore: newBills.length >= 10,
          isLoadingMoreBills: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoadingMoreBills: false));
    }
  }

  Future<void> _onDashboardBillStatusFilterChanged(
    DashboardBillStatusFilterChanged event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.billStatusFilter == event.status) return;

    emit(
      state.copyWith(
        billStatusFilter: event.status,
        status: DashboardStatus.loading,
      ),
    );

    final result = await _dashboardRepository.getBillHistory(
      page: 1,
      perPage: 10,
      status: event.status,
    );

    if (result is ApiSuccess<List<BillHistoryModel>>) {
      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          bills: result.data,
          billsPage: 1,
          billsHasMore: result.data.length >= 10,
        ),
      );
    } else {
      emit(state.copyWith(status: DashboardStatus.loaded));
    }
  }

  void _onDashboardHistoryTabChanged(
    DashboardHistoryTabChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedHistoryTab: event.tabIndex));
  }

  Future<void> _loadDashboardData(
    String role,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _dashboardRepository.getDashboardMetrics(role: role),
        _dashboardRepository.getRecentTransactions(),
        _dashboardRepository.getMenuItemsForRole(role),
        _dashboardRepository.getBillHistory(
          page: 1,
          perPage: 10,
          status: state.billStatusFilter,
        ),
      ]);

      final metricsResult = results[0] as ApiResult<DashboardMetricModel>;
      final transactionsResult =
          results[1] as ApiResult<List<TransactionItemModel>>;
      final menuItems = results[2] as List<MenuItemModel>;
      final billsResult = results[3] as ApiResult<List<BillHistoryModel>>;

      DashboardMetricModel metrics = DashboardMetricModel.empty(role: role);
      if (metricsResult is ApiSuccess<DashboardMetricModel>) {
        metrics = metricsResult.data;
      }

      List<TransactionItemModel> transactions = [];
      if (transactionsResult is ApiSuccess<List<TransactionItemModel>>) {
        transactions = transactionsResult.data;
      }

      List<BillHistoryModel> bills = [];
      if (billsResult is ApiSuccess<List<BillHistoryModel>>) {
        bills = billsResult.data;
      }

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          metrics: metrics,
          transactions: transactions,
          bills: bills,
          billsPage: 1,
          billsHasMore: bills.length >= 10,
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
