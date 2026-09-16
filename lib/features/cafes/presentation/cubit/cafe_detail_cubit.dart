import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../favorites/data/favorite_sync.dart';
import '../../../reviews/data/models/review.dart';
import '../../../reviews/data/repositories/review_repository.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';

enum DetailStatus { loading, success, failure }

class CafeDetailState extends Equatable {
  const CafeDetailState({
    this.status = DetailStatus.loading,
    this.preview,
    this.detail,
    this.reviews = const [],
    this.summary = const RatingSummary.empty(),
    this.reviewsLoaded = false,
    this.failure,
  });

  final DetailStatus status;

  /// The café as the card that opened this page knew it.
  ///
  /// The page used to be a blank spinner until the detail request returned,
  /// even though the card that was tapped already held the name, photo,
  /// rating and hours-status. Worse, the Hero flight had no destination to
  /// land on, so the photo that should have grown into the header simply
  /// vanished. With this the header, title and actions are there on the
  /// first frame and the rest fills in beneath them.
  final Cafe? preview;

  final CafeDetail? detail;
  final List<Review> reviews;
  final RatingSummary summary;

  /// Distinguishes "no reviews" from "reviews not back yet", so the page can
  /// show a placeholder rather than claim nobody has reviewed the café.
  final bool reviewsLoaded;

  final Failure? failure;

  /// The best café data available right now: the full detail once it has
  /// arrived, the card's copy until then.
  Cafe? get cafe => detail?.cafe ?? preview;

  CafeDetailState copyWith({
    DetailStatus? status,
    CafeDetail? detail,
    List<Review>? reviews,
    RatingSummary? summary,
    bool? reviewsLoaded,
    Failure? failure,
  }) =>
      CafeDetailState(
        status: status ?? this.status,
        preview: preview,
        detail: detail ?? this.detail,
        reviews: reviews ?? this.reviews,
        summary: summary ?? this.summary,
        reviewsLoaded: reviewsLoaded ?? this.reviewsLoaded,
        failure: failure,
      );

  @override
  List<Object?> get props =>
      [status, preview, detail, reviews, summary, reviewsLoaded, failure];
}

class CafeDetailCubit extends Cubit<CafeDetailState> {
  CafeDetailCubit({
    required CafeRepository cafes,
    required ReviewRepository reviews,
    Cafe? preview,
  })  : _cafes = cafes,
        _reviews = reviews,
        super(CafeDetailState(preview: preview)) {
    _favorites = FavoriteSync.instance.changes.listen((change) {
      if (change.cafeId == state.cafe?.id) {
        applyFavorite(isFavorited: change.isFavorited);
      }
    });
  }

  final CafeRepository _cafes;
  final ReviewRepository _reviews;
  late final StreamSubscription<FavoriteChange> _favorites;

  Future<void> load(String idOrSlug) async {
    emit(CafeDetailState(preview: state.preview));

    // Reviews are keyed on the café's id. When the card handed one over they
    // start at the same moment as the café itself instead of after it.
    final knownId = state.preview?.id;
    final reviews = knownId == null ? null : _loadReviews(knownId);

    try {
      // The café itself must succeed; reviews are secondary, so a café whose
      // reviews fail still renders rather than showing an error page.
      //
      // The menu used to be fetched here as well and was never shown — the
      // menu screen loads its own.
      final detail = await _cafes.detail(idOrSlug);
      if (isClosed) return;

      emit(state.copyWith(status: DetailStatus.success, detail: detail));

      await (reviews ?? _loadReviews(detail.cafe.id));
    } on Failure catch (f) {
      if (isClosed) return;
      emit(state.copyWith(status: DetailStatus.failure, failure: f));
    }
  }

  Future<void> _loadReviews(String cafeId) async {
    ReviewPage? page;
    try {
      page = await _reviews.forCafe(cafeId);
    } on Failure {
      // Shown as "no reviews" rather than failing the page.
    }
    if (isClosed) return;

    emit(state.copyWith(
      reviews: page?.page.items,
      summary: page?.summary,
      reviewsLoaded: true,
      failure: state.failure,
    ));
  }

  /// Re-reads reviews after the user rates the café, so their review, the
  /// breakdown and the headline average all move together — without the page
  /// blanking back to a spinner.
  ///
  /// The café itself is re-read too: `ratingAvg` on the header comes from the
  /// café row, not from the review summary, and leaving it stale made a rating
  /// look like it had not counted.
  Future<void> reloadReviews() async {
    final cafeId = state.detail?.cafe.id;
    if (cafeId == null) return;

    try {
      final page = await _reviews.forCafe(cafeId);
      if (isClosed) return;
      emit(state.copyWith(reviews: page.page.items, summary: page.summary));
    } on Failure {
      // Leave the existing list in place.
    }

    try {
      final detail = await _cafes.detail(cafeId);
      if (isClosed) return;
      emit(state.copyWith(detail: detail));
    } on Failure {
      // The headline average stays as it was; the breakdown above is already
      // correct, so this is cosmetic.
    }
  }

  void applyFavorite({required bool isFavorited}) {
    if (isClosed) return;
    final detail = state.detail;
    if (detail == null) return;
    if (detail.cafe.isFavorited == isFavorited) return;

    emit(state.copyWith(
      detail: CafeDetail(
        cafe: detail.cafe.copyWith(isFavorited: isFavorited),
        images: detail.images,
        openingHours: detail.openingHours,
        capacity: detail.capacity,
        phone: detail.phone,
        whatsapp: detail.whatsapp,
        instagram: detail.instagram,
        facebook: detail.facebook,
        website: detail.website,
      ),
    ));
  }

  @override
  Future<void> close() {
    _favorites.cancel();
    return super.close();
  }
}
