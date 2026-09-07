import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';

/// The category row under the greeting.
///
/// People arrive at a café app with a shape in mind — somewhere with shisha,
/// somewhere to work, somewhere open at midnight — long before they have a
/// name. This turns that shape into one tap, handing off to Explore with the
/// filter already applied.
///
/// The categories are the amenities the catalogue actually has, fetched with
/// counts, so an empty category can never be offered and the labels arrive
/// already translated.
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    required this.categories,
    required this.onCategory,
    required this.onOpenNow,
    this.loading = false,
    super.key,
  });

  final List<AmenityCount> categories;
  final void Function(String key) onCategory;
  final VoidCallback onOpenNow;
  final bool loading;

  static const height = 118.0;
  static const _tile = 62.0;
  static const _width = 76.0;

  /// The Material icon behind each amenity key.
  ///
  /// Keyed on `key`, not the seed's `icon` string: Flutter tree-shakes icons,
  /// so a name looked up at runtime cannot resolve to a glyph. A key the API
  /// grows later still renders — it just gets the cup.
  static IconData iconFor(String key) => switch (key) {
        'wifi' => Icons.wifi_rounded,
        'shisha' => Icons.smoking_rooms_rounded,
        'outdoor' => Icons.deck_rounded,
        'parking' => Icons.local_parking_rounded,
        'family' => Icons.family_restroom_rounded,
        'delivery' => Icons.delivery_dining_rounded,
        'breakfast' => Icons.bakery_dining_rounded,
        'desserts' => Icons.cake_rounded,
        'workspace' => Icons.laptop_mac_rounded,
        'live_music' => Icons.music_note_rounded,
        'city_view' => Icons.landscape_rounded,
        'card_payment' => Icons.credit_card_rounded,
        _ => Icons.local_cafe_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (loading) {
      return const SizedBox(height: height, child: _CategorySkeleton());
    }
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xl,
          AppSpacing.page,
          0,
        ),
        // Open-now leads: it is the one filter whose answer changes hour to
        // hour, and the one most likely to be what a person means by "café".
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const HGap.md(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Category(
              label: l10n.openNow,
              icon: Icons.schedule_rounded,
              onTap: onOpenNow,
              highlighted: true,
            );
          }

          final category = categories[index - 1];
          return _Category(
            label: category.name,
            icon: iconFor(category.key),
            onTap: () => onCategory(category.key),
          );
        },
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Drawn in the accent rather than the card ink, to lead the row.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: CategoryStrip._width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: highlighted ? AppColors.accent : AppColors.cardDark,
              borderRadius: AppRadius.cardR,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: CategoryStrip._tile,
                  height: CategoryStrip._tile,
                  child: Icon(
                    icon,
                    size: 26,
                    color: highlighted ? AppColors.onCream : AppColors.accent,
                  ),
                ),
              ),
            ),
            const Gap(6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onCreamMuted,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        0,
      ),
      itemCount: 5,
      separatorBuilder: (_, __) => const HGap.md(),
      itemBuilder: (context, _) => const SizedBox(
        width: CategoryStrip._width,
        child: Column(
          children: [
            AppSkeleton(
              height: CategoryStrip._tile,
              width: CategoryStrip._tile,
              radius: AppRadius.card,
            ),
            Gap(6),
            AppSkeleton(height: 10, width: 48),
          ],
        ),
      ),
    );
  }
}
