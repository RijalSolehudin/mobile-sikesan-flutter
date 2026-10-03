import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/repositories/kwitansi_repository.dart';
import '../models/kwitansi_model.dart';

// -----------------------------------------------------------------------------
// Events
// -----------------------------------------------------------------------------

abstract class KwitansiEvent extends Equatable {
  const KwitansiEvent();

  @override
  List<Object?> get props => [];
}

class KwitansiStarted extends KwitansiEvent {
  const KwitansiStarted();
}

class KwitansiRefreshed extends KwitansiEvent {
  const KwitansiRefreshed();
}

class KwitansiLoadMoreRequested extends KwitansiEvent {
  const KwitansiLoadMoreRequested();
}

class KwitansiSearchChanged extends KwitansiEvent {
  final String query;
  const KwitansiSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class KwitansiCategoryChanged extends KwitansiEvent {
  final String category;
  const KwitansiCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class KwitansiDateChanged extends KwitansiEvent {
  final DateTime? date;
  const KwitansiDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Kwitansi baru dibuat / diperbarui di server → sinkronkan ke list lokal.
class KwitansiItemUpserted extends KwitansiEvent {
  final KwitansiModel item;
  const KwitansiItemUpserted(this.item);

  @override
  List<Object?> get props => [item.id, item];
}

class KwitansiItemRemoved extends KwitansiEvent {
  final String id;
  const KwitansiItemRemoved(this.id);

  @override
  List<Object?> get props => [id];
}

// -----------------------------------------------------------------------------
// State
// -----------------------------------------------------------------------------

enum KwitansiStatus { initial, loading, loaded, error }

class KwitansiState extends Equatable {
  static const String allCategory = 'Semua';

  final KwitansiStatus status;
  final List<KwitansiModel> items;
  final List<String> categories;
  final String searchQuery;
  final String selectedCategory;
  final DateTime? selectedDate;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;
  final String? errorMessage;

  const KwitansiState({
    this.status = KwitansiStatus.initial,
    this.items = const [],
    this.categories = const [allCategory],
    this.searchQuery = '',
    this.selectedCategory = allCategory,
    this.selectedDate,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.total = 0,
    this.errorMessage,
  });

  KwitansiState copyWith({
    KwitansiStatus? status,
    List<KwitansiModel>? items,
    List<String>? categories,
    String? searchQuery,
    String? selectedCategory,
    DateTime? Function()? selectedDate,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    int? total,
    String? errorMessage,
  }) {
    return KwitansiState(
      status: status ?? this.status,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: selectedDate != null ? selectedDate() : this.selectedDate,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    categories,
    searchQuery,
    selectedCategory,
    selectedDate,
    currentPage,
    hasMore,
    isLoadingMore,
    total,
    errorMessage,
  ];
}

// -----------------------------------------------------------------------------
// Bloc
// -----------------------------------------------------------------------------

class KwitansiBloc extends Bloc<KwitansiEvent, KwitansiState> {
  final KwitansiRepository _repository;

  KwitansiBloc({required KwitansiRepository repository})
    : _repository = repository,
      super(const KwitansiState()) {
    on<KwitansiStarted>(_onStarted);
    on<KwitansiRefreshed>(_onRefreshed);
    on<KwitansiLoadMoreRequested>(_onLoadMore);
    on<KwitansiSearchChanged>(_onSearchChanged);
    on<KwitansiCategoryChanged>(_onCategoryChanged);
    on<KwitansiDateChanged>(_onDateChanged);
    on<KwitansiItemUpserted>(_onItemUpserted);
    on<KwitansiItemRemoved>(_onItemRemoved);
  }

  Future<void> _onStarted(
    KwitansiStarted event,
    Emitter<KwitansiState> emit,
  ) async {
    emit(state.copyWith(status: KwitansiStatus.loading));
    await Future.wait([_loadCategories(emit), _loadFirstPage(emit)]);
  }

  Future<void> _onRefreshed(
    KwitansiRefreshed event,
    Emitter<KwitansiState> emit,
  ) async {
    await Future.wait([_loadCategories(emit), _loadFirstPage(emit)]);
  }

  Future<void> _onSearchChanged(
    KwitansiSearchChanged event,
    Emitter<KwitansiState> emit,
  ) async {
    if (event.query == state.searchQuery) return;
    emit(
      state.copyWith(searchQuery: event.query, status: KwitansiStatus.loading),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _onCategoryChanged(
    KwitansiCategoryChanged event,
    Emitter<KwitansiState> emit,
  ) async {
    if (event.category == state.selectedCategory) return;
    emit(
      state.copyWith(
        selectedCategory: event.category,
        status: KwitansiStatus.loading,
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _onDateChanged(
    KwitansiDateChanged event,
    Emitter<KwitansiState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedDate: () => event.date,
        status: KwitansiStatus.loading,
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _onLoadMore(
    KwitansiLoadMoreRequested event,
    Emitter<KwitansiState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _repository.getKwitansi(
      search: state.searchQuery,
      category: state.selectedCategory,
      date: state.selectedDate,
      page: state.currentPage + 1,
    );

    switch (result) {
      case ApiSuccess(data: final page):
        final existingIds = state.items.map((e) => e.id).toSet();
        emit(
          state.copyWith(
            items: [
              ...state.items,
              ...page.items.where((e) => !existingIds.contains(e.id)),
            ],
            currentPage: page.currentPage,
            hasMore: page.hasMore,
            total: page.total,
            isLoadingMore: false,
          ),
        );
      case ApiFailure(message: final message):
        emit(state.copyWith(isLoadingMore: false, errorMessage: message));
    }
  }

  void _onItemUpserted(
    KwitansiItemUpserted event,
    Emitter<KwitansiState> emit,
  ) {
    final items = List<KwitansiModel>.of(state.items);
    final idx = items.indexWhere((e) => e.id == event.item.id);
    var total = state.total;
    if (idx != -1) {
      items[idx] = event.item;
    } else {
      items.insert(0, event.item);
      total += 1;
    }

    final categories = List<String>.of(state.categories);
    if (!categories.contains(event.item.category)) {
      categories.add(event.item.category);
    }

    emit(
      state.copyWith(
        items: items,
        total: total,
        categories: categories,
        status: KwitansiStatus.loaded,
      ),
    );
  }

  void _onItemRemoved(KwitansiItemRemoved event, Emitter<KwitansiState> emit) {
    final before = state.items.length;
    final items = state.items.where((e) => e.id != event.id).toList();
    final removed = before - items.length;
    emit(
      state.copyWith(
        items: items,
        total: (state.total - removed).clamp(0, 1 << 31),
      ),
    );
  }

  Future<void> _loadFirstPage(Emitter<KwitansiState> emit) async {
    final result = await _repository.getKwitansi(
      search: state.searchQuery,
      category: state.selectedCategory,
      date: state.selectedDate,
      page: 1,
    );

    switch (result) {
      case ApiSuccess(data: final page):
        emit(
          state.copyWith(
            status: KwitansiStatus.loaded,
            items: page.items,
            currentPage: page.currentPage,
            hasMore: page.hasMore,
            total: page.total,
          ),
        );
      case ApiFailure(message: final message):
        emit(
          state.copyWith(status: KwitansiStatus.error, errorMessage: message),
        );
    }
  }

  Future<void> _loadCategories(Emitter<KwitansiState> emit) async {
    final result = await _repository.getCategories();
    if (result is ApiSuccess<List<String>>) {
      final merged = <String>{
        KwitansiState.allCategory,
        ...result.data,
        ...state.categories,
      }.toList();
      emit(state.copyWith(categories: merged, status: state.status));
    }
  }
}
