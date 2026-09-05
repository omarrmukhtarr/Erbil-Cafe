import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../menu/data/models/menu.dart';
import '../../../menu/data/repositories/menu_repository.dart';
import '../../../reviews/data/models/review.dart';
import '../../../reviews/data/repositories/review_repository.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';

enum DetailStatus { loading, success, failure }

class CafeDetailState extends Equatable {
  const CafeDetailState({
    this.status = DetailStatus.loading,
    this.detail,
    this.menu,
    this.reviews = const [],
    this.summary = const RatingSummary.empty(),
    this.failure,
  });

  final DetailStatus status;
  final CafeDetail? detail;
  final Menu? menu;
  final List<Review> reviews;
  final RatingSummary summary;
  final Failure? failure;

  CafeDetailState copyWith({
    DetailStatus? status,
    CafeDetail? detail,
    Menu? menu,
    List<Review>? reviews,
    RatingSummary? summary,
    Failure? failure,
  }) =>
      CafeDetailState(
        status: status ?? this.status,
        detail: detail ?? this.detail,
        menu: menu ?? this.menu,
        reviews: reviews ?? this.reviews,
        summary: summary ?? this.summary,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, detail, menu, reviews, summary, failure];
}

class CafeDetailCubit extends Cubit<CafeDetailState> {
  CafeDetailCubit({
    required CafeRepository cafes,
    required MenuRepository menus,
    required ReviewRepository reviews,
  })  : _cafes = cafes,
        _menus = menus,
        _reviews = reviews,
        super(const CafeDetailState());

  final CafeRepository _cafes;
  final MenuRepository _menus;
  final ReviewRepository _reviews;

  Future<void> load(String idOrSlug) async {
    emit(const CafeDetailState());

    try {
      // The café itself must succeed; the menu and reviews are secondary, so a
      // café with no menu still renders rather than showing an error page.
      final detail = await _cafes.detail(idOrSlug);

      emit(state.copyWith(status: DetailStatus.success, detail: detail));

      final results = await Future.wait([
        _menus.forCafe(detail.cafe.id).then<Object?>((m) => m).catchError((_) => null),
        _reviews.forCafe(detail.cafe.id).then<Object?>((r) => r).catchError((_) => null),
      ]);

      final menu = results[0] as Menu?;
      final reviewPage = results[1] as ReviewPage?;

      emit(state.copyWith(
        menu: menu,
        reviews: reviewPage?.page.items,
        summary: reviewPage?.summary,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(status: DetailStatus.failure, failure: f));
    }
  }

  /// Re-reads reviews after the user writes one, so their pending review and
  /// the updated breakdown appear without a full reload.
  Future<void> reloadReviews() async {
    final cafeId = state.detail?.cafe.id;
    if (cafeId == null) return;

    try {
      final page = await _reviews.forCafe(cafeId);
      emit(state.copyWith(reviews: page.page.items, summary: page.summary));
    } on Failure {
      // Leave the existing list in place.
    }
  }

  void applyFavorite({required bool isFavorited}) {
    final detail = state.detail;
    if (detail == null) return;

    emit(state.copyWith(
      detail: CafeDetail(
        cafe: detail.cafe.copyWith(isFavorited: isFavorited),
        images: detail.images,
        openingHours: detail.openingHours,
        capacity: detail.capacity,
        phone: detail.phone,
        whatsapp: detail.whatsapp,
        instagram: detail.instagram,
        website: detail.website,
      ),
    ));
  }
}
