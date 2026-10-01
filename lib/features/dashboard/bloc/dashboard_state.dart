import 'package:equatable/equatable.dart';
import '../../../data/models/bill_history_model.dart';
import '../../../data/models/dashboard_metric_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/transaction_item_model.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardMetricModel metrics;
  final List<TransactionItemModel> transactions;
  final List<BillHistoryModel> bills;
  final int billsPage;
  final bool billsHasMore;
  final bool isLoadingMoreBills;
  final String billStatusFilter; // 'all', 'unpaid', 'paid', 'pending'
  final int selectedHistoryTab; // 0: Riwayat Tagihan, 1: Riwayat Transaksi
  final List<MenuItemModel> menuItems;
  final int carouselIndex;
  final bool isMenuExpanded;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.metrics = const DashboardMetricModel(
      totalBalance: 0,
      totalIncome: 0,
      totalExpense: 0,
      totalUnpaidSpp: 0,
      monthlyBill: 0,
      unpaidStatus: '-',
    ),
    this.transactions = const [],
    this.bills = const [],
    this.billsPage = 1,
    this.billsHasMore = true,
    this.isLoadingMoreBills = false,
    this.billStatusFilter = 'all',
    this.selectedHistoryTab = 0,
    this.menuItems = const [],
    this.carouselIndex = 0,
    this.isMenuExpanded = true,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardMetricModel? metrics,
    List<TransactionItemModel>? transactions,
    List<BillHistoryModel>? bills,
    int? billsPage,
    bool? billsHasMore,
    bool? isLoadingMoreBills,
    String? billStatusFilter,
    int? selectedHistoryTab,
    List<MenuItemModel>? menuItems,
    int? carouselIndex,
    bool? isMenuExpanded,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      transactions: transactions ?? this.transactions,
      bills: bills ?? this.bills,
      billsPage: billsPage ?? this.billsPage,
      billsHasMore: billsHasMore ?? this.billsHasMore,
      isLoadingMoreBills: isLoadingMoreBills ?? this.isLoadingMoreBills,
      billStatusFilter: billStatusFilter ?? this.billStatusFilter,
      selectedHistoryTab: selectedHistoryTab ?? this.selectedHistoryTab,
      menuItems: menuItems ?? this.menuItems,
      carouselIndex: carouselIndex ?? this.carouselIndex,
      isMenuExpanded: isMenuExpanded ?? this.isMenuExpanded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == DashboardStatus.loading;
  bool get isLoaded => status == DashboardStatus.loaded;

  @override
  List<Object?> get props => [
    status,
    metrics,
    transactions,
    bills,
    billsPage,
    billsHasMore,
    isLoadingMoreBills,
    billStatusFilter,
    selectedHistoryTab,
    menuItems,
    carouselIndex,
    isMenuExpanded,
    errorMessage,
  ];
}
