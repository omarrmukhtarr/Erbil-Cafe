import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../cafes/data/models/cafe.dart';
import 'favorites_repository.dart';

/// A café's saved state changed — optimistically, confirmed, or rolled back.
@immutable
class FavoriteChange {
  const FavoriteChange({
    required this.cafeId,
    required this.isFavorited,
    this.cafe,
  });

  final String cafeId;
  final bool isFavorited;

  /// The café itself when the caller had it, so the Saved tab can insert a
  /// newly saved café without refetching its whole list.
  final Cafe? cafe;
}

/// Makes the heart instant, and keeps every screen that shows it in step.
///
/// Before this, tapping a heart waited for the round trip before anything
/// moved — on a phone in Erbil that is regularly most of a second of a button
/// that looks broken. Each screen also patched only its *own* list, so saving
/// a café on its page left Home's carousel, Explore and the Saved tab (which
/// is kept alive by the tab shell and never reloaded) all showing the old
/// state.
///
/// Now the change is broadcast the moment the finger lifts, the request runs
/// behind it, and the server's answer is broadcast again. If the request
/// fails, the original state is broadcast and the error rethrown, so the
/// heart springs back rather than lying.
///
/// Deliberately not part of [FavoritesRepository]: tests mock the repository,
/// and a stream on a mock is null.
class FavoriteSync {
  FavoriteSync._();

  static final instance = FavoriteSync._();

  final _changes = StreamController<FavoriteChange>.broadcast();

  Stream<FavoriteChange> get changes => _changes.stream;

  /// Per café, the last toggle still in flight. A second tap waits for the
  /// first rather than racing it, so responses cannot land out of order.
  final _pending = <String, Future<void>>{};

  /// Flips [cafe]'s saved state and returns the state the server settled on.
  Future<bool> toggle(Cafe cafe, FavoritesRepository repository) {
    final wanted = !cafe.isFavorited;
    _changes.add(
      FavoriteChange(cafeId: cafe.id, isFavorited: wanted, cafe: cafe),
    );

    final previous = _pending[cafe.id] ?? Future<void>.value();
    final completer = Completer<bool>();

    final run = previous.then((_) async {
      try {
        final result = await repository.toggle(cafe.id);
        _changes.add(
          FavoriteChange(cafeId: cafe.id, isFavorited: result, cafe: cafe),
        );
        completer.complete(result);
      } on Failure catch (failure) {
        _changes.add(
          FavoriteChange(
            cafeId: cafe.id,
            isFavorited: cafe.isFavorited,
            cafe: cafe,
          ),
        );
        completer.completeError(failure);
      }
    });

    _pending[cafe.id] = run;
    run.whenComplete(() {
      if (identical(_pending[cafe.id], run)) _pending.remove(cafe.id);
    });

    return completer.future;
  }
}
