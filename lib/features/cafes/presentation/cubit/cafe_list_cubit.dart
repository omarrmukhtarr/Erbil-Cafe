import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';

enum ListStatus { initial, loading, loadingMore, success, failure }

class CafeListState extends Equatable {
  const CafeListState({
    this.status = ListStatus.initial,
    this.cafes = const [],
    this.query = const CafeQuery(),
    this.areas = const [],
    this.nextCursor,
    this.hasMore = false,
    this.failure,
  });

  final ListStatus status;
  final List<Cafe> cafes;
  final CafeQuery query;
  final List<AreaCount> areas;
  final String? nextCursor;
  final bool hasMore;
  final Failure? failure;

  bool get isEmpty => status == ListStatus.success && cafes.isEmpty;

  CafeListState copyWith({
    ListStatus? status,
    List<Cafe>? cafes,
    CafeQuery? query,
    List<AreaCount>? areas,
    String? nextCursor,
    bool? hasMore,
    Failure? failure,
  }) =>
      CafeListState(
        status: status ?? this.status,
        cafes: cafes ?? this.cafes,
        query: query ?? this.query,
        areas: areas ?? this.areas,
        nextCursor: nextCursor,
        hasMore: hasMore ?? this.hasMore,
        failure: failure,
      );

  @override
  List<Object?> get props =>
      [status, cafes, query, areas, nextCursor, hasMore, failure];
}

class CafeListCubit extends Cubit<CafeListState> {
  CafeListCubit(this._repository) : super(const CafeListState());

  final CafeRepository _repository;
  Timer? _debounce;

  /// Guards against a slow earlier request overwriting a newer one's results.
  int _requestId = 0;

  Future<void> load({CafeQuery? query}) async {
    final effective = query ?? state.query;
    final id = ++_requestId;

    emit(state.copyWith(status: ListStatus.loading, query: effective));

    try {
      final page = await _repository.list(effective);
      if (id != _requestId) return;

      emit(state.copyWith(
        status: ListStatus.success,
        cafes: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ));
    } on Failure catch (f) {
      if (id != _requestId) return;
      emit(state.copyWith(status: ListStatus.failure, failure: f));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ListStatus.loadingMore) return;

    emit(state.copyWith(status: ListStatus.loadingMore, nextCursor: state.nextCursor));

    try {
      final page = await _repository.list(
        state.query.copyWith(cursor: state.nextCursor),
      );
      emit(state.copyWith(
        status: ListStatus.success,
        cafes: [...state.cafes, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(status: ListStatus.failure, failure: f));
    }
  }

  /// Debounced so a query does not fire on every keystroke.
  void search(String term) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      load(query: state.query.copyWith(search: term, cursor: null));
    });
  }

  void setArea(String? area) =>
      load(query: state.query.copyWith(area: area, cursor: null));

  void setPriceRange(PriceRange? price) =>
      load(query: state.query.copyWith(priceRange: price, cursor: null));

  void setAmenities(List<String> amenities) =>
      load(query: state.query.copyWith(amenities: amenities, cursor: null));

  void setMinRating(double? rating) =>
      load(query: state.query.copyWith(minRating: rating, cursor: null));

  void setOpenNow(bool? openNow) =>
      load(query: state.query.copyWith(openNow: openNow, cursor: null));

  void setSort(String sort) =>
      load(query: state.query.copyWith(sort: sort, cursor: null));

  void clearFilters() => load(query: const CafeQuery());

  Future<void> loadAreas() async {
    try {
      emit(state.copyWith(areas: await _repository.areas()));
    } on Failure {
      // Filter chips are a nicety; their absence must not break the listing.
    }
  }

  /// Reflects a favourite toggled elsewhere without refetching the page.
  void applyFavorite(String cafeId, {required bool isFavorited}) {
    emit(state.copyWith(
      cafes: state.cafes
          .map((c) => c.id == cafeId ? c.copyWith(isFavorited: isFavorited) : c)
          .toList(),
      nextCursor: state.nextCursor,
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
