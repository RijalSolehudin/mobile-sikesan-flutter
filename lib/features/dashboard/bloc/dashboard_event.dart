import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardFetchRequested extends DashboardEvent {
  final String role;

  const DashboardFetchRequested({this.role = 'Wali Santri'});

  @override
  List<Object?> get props => [role];
}

class DashboardRefreshRequested extends DashboardEvent {
  final String role;

  const DashboardRefreshRequested({this.role = 'Wali Santri'});

  @override
  List<Object?> get props => [role];
}

class DashboardCarouselChanged extends DashboardEvent {
  final int index;

  const DashboardCarouselChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class DashboardToggleMenuExpanded extends DashboardEvent {
  const DashboardToggleMenuExpanded();
}

class DashboardBillsLoadMoreRequested extends DashboardEvent {
  const DashboardBillsLoadMoreRequested();
}

class DashboardBillStatusFilterChanged extends DashboardEvent {
  final String status;

  const DashboardBillStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class DashboardHistoryTabChanged extends DashboardEvent {
  final int tabIndex;

  const DashboardHistoryTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
