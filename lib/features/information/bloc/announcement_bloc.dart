import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../data/repositories/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

export 'announcement_event.dart';
export 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository _repository;

  static const List<String> categories = [
    'Semua',
    'Infak',
    'SPP',
    'Uang Saku',
    'Umum',
  ];

  static const List<String> statuses = [
    'Semua',
    'Draft',
    'Terjadwal',
    'Dipublikasikan',
    'Expired',
    'Arsip',
  ];

  AnnouncementBloc({required AnnouncementRepository repository})
    : _repository = repository,
      super(const AnnouncementState()) {
    on<AnnouncementFetchRequested>(_onFetchRequested);
    on<AnnouncementRefreshRequested>(_onRefreshRequested);
    on<AnnouncementCategoryChanged>(_onCategoryChanged);
    on<AnnouncementStatusChanged>(_onStatusChanged);
    on<AnnouncementSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetchRequested(
    AnnouncementFetchRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(state.copyWith(status: AnnouncementStatus.loading));
    await _loadAnnouncements(emit);
  }

  Future<void> _onRefreshRequested(
    AnnouncementRefreshRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    await _loadAnnouncements(emit);
  }

  void _onCategoryChanged(
    AnnouncementCategoryChanged event,
    Emitter<AnnouncementState> emit,
  ) {
    emit(state.copyWith(selectedCategoryIndex: event.categoryIndex));
    _applyFilters(emit);
  }

  void _onStatusChanged(
    AnnouncementStatusChanged event,
    Emitter<AnnouncementState> emit,
  ) {
    emit(state.copyWith(selectedStatusIndex: event.statusIndex));
    _applyFilters(emit);
  }

  void _onSearchChanged(
    AnnouncementSearchChanged event,
    Emitter<AnnouncementState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  Future<void> _loadAnnouncements(Emitter<AnnouncementState> emit) async {
    final result = await _repository.getAnnouncements();

    switch (result) {
      case ApiSuccess(data: final announcements):
        final totalCount = announcements.length;
        final publishedCount = announcements
            .where((a) => a.status == 'published')
            .length;
        final draftCount = announcements
            .where((a) => a.status == 'draft')
            .length;
        final importantCount = announcements.where((a) => a.isImportant).length;

        emit(
          state.copyWith(
            status: AnnouncementStatus.loaded,
            announcements: announcements,
            totalCount: totalCount,
            publishedCount: publishedCount,
            draftCount: draftCount,
            importantCount: importantCount,
          ),
        );
        _applyFilters(emit);

      case ApiFailure(message: final message):
        emit(
          state.copyWith(
            status: AnnouncementStatus.error,
            errorMessage: message,
          ),
        );
    }
  }

  void _applyFilters(Emitter<AnnouncementState> emit) {
    var filtered = List.of(state.announcements);

    // Filter kategori
    if (state.selectedCategoryIndex > 0 &&
        state.selectedCategoryIndex < categories.length) {
      final category = categories[state.selectedCategoryIndex];
      filtered = filtered.where((a) => a.category == category).toList();
    }

    // Filter status
    if (state.selectedStatusIndex > 0 &&
        state.selectedStatusIndex < statuses.length) {
      final statusLabel = statuses[state.selectedStatusIndex];
      final statusMap = {
        'Draft': 'draft',
        'Terjadwal': 'scheduled',
        'Dipublikasikan': 'published',
        'Expired': 'expired',
        'Arsip': 'archived',
      };
      final statusKey = statusMap[statusLabel] ?? statusLabel.toLowerCase();
      filtered = filtered.where((a) => a.status == statusKey).toList();
    }

    // Filter search
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (a) =>
                a.title.toLowerCase().contains(query) ||
                a.content.toLowerCase().contains(query),
          )
          .toList();
    }

    emit(state.copyWith(filteredAnnouncements: filtered));
  }
}
