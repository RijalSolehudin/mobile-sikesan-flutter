import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard_metric_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/transaction_item_model.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardMetricModel metrics;
  final List<TransactionItemModel> transactions;
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
    this.menuItems = const [],
    this.carouselIndex = 0,
    this.isMenuExpanded = true,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardMetricModel? metrics,
    List<TransactionItemModel>? transactions,
    List<MenuItemModel>? menuItems,
    int? carouselIndex,
    bool? isMenuExpanded,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      transactions: transactions ?? this.transactions,
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
    menuItems,
    carouselIndex,
    isMenuExpanded,
    errorMessage,
  ];
}
