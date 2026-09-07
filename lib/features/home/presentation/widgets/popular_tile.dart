import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../menu/data/models/menu.dart';

/// A popular menu item — v1's coffee tile: dark surface, image on top, the
/// price in copper with the currency label before the amount.
///
/// The price now sits on the photo instead of under the café's name. Three
/// stacked lines of small text all looked like the same kind of information;
/// on the photo the price is the first thing read, which is what it is for.
/// The café's own rating comes along, so an item is never recommended without
/// a hint of whether the place serving it is any good.
class PopularTile extends StatelessWidget {
  const PopularTile({required this.item, super.key});

  final PopularItem item;

  static const width = 164.0;
  static const imageHeight = 136.0;
  static const height = 202.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: width,
      child: AppCard(
        onTap: () => context.push(Routes.menu(item.cafeSlug)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ItemImage(url: item.item.thumbUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.imageScrim),
                  ),
                  // The two chips sit in opposite corners rather than in one
                  // row: on a 164pt tile a long price and a long "unavailable"
                  // label do not fit side by side in every language.
                  Positioned(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: _PricePill(
                      label: Formatters.price(
                        item.item.priceIqd,
                        l10n.currencyIqd,
                      ),
                    ),
                  ),
                  if (!item.item.isAvailable)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: _Chip(
                          label: l10n.unavailable,
                          color: AppColors.onCardMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.item.name,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: AppColors.onCard),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap.xs(),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.cafeName,
                          style: const TextStyle(
                            color: AppColors.onCardMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.cafeRating > 0) ...[
                        const HGap(6),
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppColors.accent),
                        const HGap(2),
                        Text(
                          item.cafeRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.onCardMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) return const _NoImage();

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => const ColoredBox(color: AppColors.cardDarkAlt),
      errorWidget: (context, _, __) => const _NoImage(),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: AppColors.cardDarkAlt,
        child: Icon(
          Icons.local_cafe_outlined,
          color: AppColors.onCardDisabled,
        ),
      );
}

/// The price, in copper on the badge tone, over the photo.
class _PricePill extends StatelessWidget {
  const _PricePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.badge.withValues(alpha: 0.92),
        borderRadius: AppRadius.pillR,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        maxLines: 1,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badge.withValues(alpha: 0.92),
        borderRadius: AppRadius.pillR,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
