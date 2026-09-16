import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/di/injector.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../l10n/app_localizations.dart';
import '../../cafes/data/models/cafe.dart';
import '../data/favorite_sync.dart';
import '../data/favorites_repository.dart';

/// The one way a heart button saves or unsaves a café.
///
/// Guests get the sign-in prompt; signed-in users get an instant heart, a
/// light tap of haptics, and — only if the request fails — the heart springing
/// back with the reason in a snackbar.
Future<void> toggleFavorite(BuildContext context, Cafe cafe) {
  final l10n = AppLocalizations.of(context);

  return requireAuth(
    context,
    reason: l10n.signInToFavorite,
    action: () async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      HapticFeedback.lightImpact();

      try {
        await FavoriteSync.instance.toggle(cafe, sl<FavoritesRepository>());
      } on Failure catch (failure) {
        messenger?.showSnackBar(SnackBar(content: Text(failure.message)));
      }
    },
  );
}
