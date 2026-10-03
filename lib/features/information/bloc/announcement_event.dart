import 'package:equatable/equatable.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk meminta fetch data pengumuman dari repository
class AnnouncementFetchRequested extends AnnouncementEvent {
  const AnnouncementFetchRequested();
}

/// Event untuk refresh data (pull-to-refresh)
class AnnouncementRefreshRequested extends AnnouncementEvent {
  const AnnouncementRefreshRequested();
}

/// Event ketika filter kategori berubah
class AnnouncementCategoryChanged extends AnnouncementEvent {
  final int categoryIndex;
  const AnnouncementCategoryChanged(this.categoryIndex);

  @override
  List<Object?> get props => [categoryIndex];
}

/// Event ketika filter status berubah
class AnnouncementStatusChanged extends AnnouncementEvent {
  final int statusIndex;
  const AnnouncementStatusChanged(this.statusIndex);

  @override
  List<Object?> get props => [statusIndex];
}

/// Event ketika search query berubah
class AnnouncementSearchChanged extends AnnouncementEvent {
  final String query;
  const AnnouncementSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
