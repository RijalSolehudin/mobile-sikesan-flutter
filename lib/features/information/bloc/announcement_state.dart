import 'package:equatable/equatable.dart';
import '../../../data/models/announcement_model.dart';

enum AnnouncementStatus { initial, loading, loaded, error }

class AnnouncementState extends Equatable {
  final AnnouncementStatus status;
  final List<AnnouncementModel> announcements;
  final List<AnnouncementModel> filteredAnnouncements;
  final int selectedCategoryIndex;
  final int selectedStatusIndex;
  final String searchQuery;
  final String? errorMessage;

  // Metrik yang dihitung dari data
  final int totalCount;
  final int publishedCount;
  final int draftCount;
  final int importantCount;

  const AnnouncementState({
    this.status = AnnouncementStatus.initial,
    this.announcements = const [],
    this.filteredAnnouncements = const [],
    this.selectedCategoryIndex = 0,
    this.selectedStatusIndex = 0,
    this.searchQuery = '',
    this.errorMessage,
    this.totalCount = 0,
    this.publishedCount = 0,
    this.draftCount = 0,
    this.importantCount = 0,
  });

  AnnouncementState copyWith({
    AnnouncementStatus? status,
    List<AnnouncementModel>? announcements,
    List<AnnouncementModel>? filteredAnnouncements,
    int? selectedCategoryIndex,
    int? selectedStatusIndex,
    String? searchQuery,
    String? errorMessage,
    int? totalCount,
    int? publishedCount,
    int? draftCount,
    int? importantCount,
  }) {
    return AnnouncementState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      filteredAnnouncements:
          filteredAnnouncements ?? this.filteredAnnouncements,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedStatusIndex: selectedStatusIndex ?? this.selectedStatusIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      totalCount: totalCount ?? this.totalCount,
      publishedCount: publishedCount ?? this.publishedCount,
      draftCount: draftCount ?? this.draftCount,
      importantCount: importantCount ?? this.importantCount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    announcements,
    filteredAnnouncements,
    selectedCategoryIndex,
    selectedStatusIndex,
    searchQuery,
    errorMessage,
    totalCount,
    publishedCount,
    draftCount,
    importantCount,
  ];
}
