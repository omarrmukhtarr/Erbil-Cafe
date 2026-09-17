import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/location/location_service.dart';
import '../../../favorites/data/favorite_sync.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';

enum ListStatus { initial, loading, loadingMore, success, failure }

class CafeListState extends Equatable {
  const CafeListState({
    this.status = ListStatus.initial,
    this.cafes = const [],
    this.query = const CafeQuery(),
    this.areas = const [],
    this.amenityOptions = const [],
    this.nextCursor,
    this.hasMore = false,
    this.failure,
  });

  final ListStatus status;
  final List<Cafe> cafes;
  final CafeQuery query;
  final List<AreaCount> areas;

  /// Every amenity at least one café offers, most common first. Drives the
  /// amenity chips in the filter bar.
  final List<AmenityCount> amenityOptions;
  final String? nextCursor;
  final bool hasMore;
  final Failure? failure;

  bool get isEmpty => status == ListStatus.success && cafes.isEmpty;

  /// Loading with nothing on screen yet — the only time a skeleton is right.
  ///
  /// A filter change or a pull-to-refresh used to blank the list back to
  /// skeletons, which read as the app starting over. The old results now stay
  /// put (dimmed) until the new ones land.
  bool get isFirstLoad => status == ListStatus.loading && cafes.isEmpty;

  /// Loading while the previous results are still showing.
  bool get isReloading => status == ListStatus.loading && cafes.isNotEmpty;

  CafeListState copyWith({
    ListStatus? status,
    List<Cafe>? cafes,
    CafeQuery? query,
    List<AreaCount>? areas,
    List<AmenityCount>? amenityOptions,
    String? nextCursor,
    bool? hasMore,
    Failure? failure,
  }) =>
      CafeListState(
        status: status ?? this.status,
        cafes: cafes ?? this.cafes,
        query: query ?? this.query,
        areas: areas ?? this.areas,
        amenityOptions: amenityOptions ?? this.amenityOptions,
        nextCursor: nextCursor,
        hasMore: hasMore ?? this.hasMore,
        failure: failure,
      );

  @override
  List<Object?> get props =>
      [status, cafes, query, areas, amenityOptions, nextCursor, hasMore, failure];
}

class CafeListCubit extends Cubit<CafeListState> {
  CafeListCubit(this._repository) : super(const CafeListState()) {
    _favorites = FavoriteSync.instance.changes.listen(
      (change) => applyFavorite(change.cafeId, isFavorited: change.isFavorited),
    );
  }

  final CafeRepository _repository;
  Timer? _debounce;
  late final StreamSubscription<FavoriteChange> _favorites;

  /// When the last page request failed. The scroll listener asks for the next
  /// page on every pixel near the bottom, so without a pause a dropped
  /// connection turned into a request per frame.
  DateTime? _loadMoreFailedAt;

  /// Guards against a slow earlier request overwriting a newer one's results.
  int _requestId = 0;

  Future<void> load({CafeQuery? query}) async {
    final effective = query ?? state.query;
    final id = ++_requestId;

    emit(state.copyWith(status: ListStatus.loading, query: effective));

    try {
      final page = await _repository.list(effective);
      if (id != _requestId || isClosed) return;

      emit(state.copyWith(
        status: ListStatus.success,
        cafes: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ));
    } on Failure catch (f) {
      if (id != _requestId || isClosed) return;
      emit(state.copyWith(status: ListStatus.failure, failure: f));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == ListStatus.loadingMore ||
        state.status == ListStatus.loading) {
      return;
    }

    final failedAt = _loadMoreFailedAt;
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < const Duration(seconds: 4)) {
      return;
    }

    // A filter applied while this page is in the air starts a new request
    // id; the page that comes back belongs to the old query and must not be
    // appended to the new results.
    final id = _requestId;

    emit(state.copyWith(status: ListStatus.loadingMore, nextCursor: state.nextCursor));

    try {
      final page = await _repository.list(
        state.query.copyWith(cursor: state.nextCursor),
      );
      if (id != _requestId || isClosed) return;

      _loadMoreFailedAt = null;
      emit(state.copyWith(
        status: ListStatus.success,
        cafes: [...state.cafes, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ));
    } on Failure {
      if (id != _requestId || isClosed) return;

      // The page already on screen is still good, so this is not a failure of
      // the list — just stop asking for a moment.
      _loadMoreFailedAt = DateTime.now();
      emit(state.copyWith(
        status: ListStatus.success,
        nextCursor: state.nextCursor,
      ));
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

  /// Adds [key] if it is not applied, removes it if it is.
  ///
  /// Every chip in the filter bar is a toggle: the same tap that applies a
  /// filter takes it off again. Before this, tapping an applied area chip did
  /// nothing and the only way back was a separate "all areas" chip, which
  /// people read as a seventh area rather than as "clear".
  void toggleAmenity(String key) {
    final next = [...state.query.amenities];
    if (!next.remove(key)) next.add(key);
    setAmenities(next);
  }

  void toggleArea(String area) =>
      setArea(state.query.area == area ? null : area);

  void togglePriceRange(PriceRange price) =>
      setPriceRange(state.query.priceRange == price ? null : price);

  void toggleOpenNow() => setOpenNow(state.query.openNow == true ? null : true);

  void setMinRating(double? rating) =>
      load(query: state.query.copyWith(minRating: rating, cursor: null));

  void setOpenNow(bool? openNow) =>
      load(query: state.query.copyWith(openNow: openNow, cursor: null));

  void setSort(String sort) =>
      load(query: state.query.copyWith(sort: sort, cursor: null));

  void clearFilters() => load(query: const CafeQuery());

  /// How far "Near me" looks. Erbil is about thirty kilometres across, so this
  /// takes in the whole city and simply puts the closest cafés first.
  static const nearMeRadiusKm = 40.0;

  /// Sorts by distance from [location], or back to top rated when null.
  void setNearMe(UserLocation? location) => load(
        query: location == null
            ? state.query.copyWith(
                lat: null,
                lng: null,
                radiusKm: null,
                sort: 'rating',
                cursor: null,
              )
            : state.query.copyWith(
                lat: location.lat,
                lng: location.lng,
                radiusKm: nearMeRadiusKm,
                sort: 'distance',
                cursor: null,
              ),
      );

  /// Loads the two lists the filter chips are built from, in one pass.
  ///
  /// Both are small, cacheable and independent of the current query, so they
  /// are fetched once when the screen opens and never again.
  Future<void> loadFilterOptions() async {
    try {
      final results = await Future.wait([
        _repository.areas(),
        _repository.amenities(),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        areas: results[0] as List<AreaCount>,
        amenityOptions: results[1] as List<AmenityCount>,
        nextCursor: state.nextCursor,
        // Kept: the chips can arrive after the list failed, and dropping the
        // failure here left the error view with nothing to show.
        failure: state.failure,
      ));
    } on Failure {
      // Filter chips are a nicety; their absence must not break the listing.
    }
  }

  /// Reflects a favourite toggled elsewhere without refetching the page.
  void applyFavorite(String cafeId, {required bool isFavorited}) {
    if (isClosed) return;
    final index = state.cafes.indexWhere((c) => c.id == cafeId);
    if (index == -1 || state.cafes[index].isFavorited == isFavorited) return;

    emit(state.copyWith(
      failure: state.failure,
      cafes: state.cafes
          .map((c) => c.id == cafeId ? c.copyWith(isFavorited: isFavorited) : c)
          .toList(),
      nextCursor: state.nextCursor,
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _favorites.cancel();
    return super.close();
  }
}
