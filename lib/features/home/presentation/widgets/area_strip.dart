import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';

/// Erbil by neighbourhood — Ainkawa, the Citadel, 40m, 60m, 100m.
///
/// Locals navigate the city by these names far more than by street address, so
/// this is the last thing on the home page: not a recommendation, a way to say
/// "show me what is near where I already am".
class AreaStrip extends StatelessWidget {
  const AreaStrip({required this.areas, required this.onTap, super.key});

  final List<AreaCount> areas;
  final void Function(String area) onTap;

  static const height = 78.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: areas.length,
        separatorBuilder: (_, __) => const HGap.md(),
        itemBuilder: (context, index) {
          final area = areas[index];

          return SizedBox(
            width: 168,
            child: AppCard(
              onTap: () => onTap(area.area),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.cardDarkAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ),
                  const HGap.md(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          area.area,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: AppColors.onCard),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          l10n.cafeCount(area.count),
                          style: const TextStyle(
                            color: AppColors.onCardMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
