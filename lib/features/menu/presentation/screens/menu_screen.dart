import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/menu.dart';
import '../../data/repositories/menu_repository.dart';

/// A café's menu.
///
/// This one screen replaces v1's three hand-written menu files — 419 lines
/// each, byte-identical apart from the class name — and works for every café.
class MenuScreen extends StatefulWidget {
  const MenuScreen({required this.slug, super.key});

  final String slug;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<Menu> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<MenuRepository>().forCafe(widget.slug);
  }

  void _reload() {
    setState(() => _future = sl<MenuRepository>().forCafe(widget.slug));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menu)),
      body: FutureBuilder<Menu>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (_, __) =>
                  const AppSkeleton(height: 88, radius: AppRadius.card),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorView(
              failure: error is Failure
                  ? error
                  : const ServerFailure('Could not load the menu'),
              onRetry: _reload,
            );
          }

          final menu = snapshot.data!;
          if (menu.isEmpty) {
            return EmptyView(
              icon: Icons.menu_book_outlined,
              title: l10n.noMenuYet,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              for (final category in menu.categories) ...[
                if (category.items.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Divider(
                            color: AppColors.tan.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final item in category.items)
                    _MenuItemTile(item: item, currency: l10n.currencyIqd),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item, required this.currency});

  final MenuItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Opacity(
      // Unavailable items stay visible but clearly muted, so the menu still
      // reads as complete.
      opacity: item.isAvailable ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.cardR,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.chipR,
              child: SizedBox(
                width: 64,
                height: 64,
                child: item.thumbUrl == null
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.local_cafe_outlined,
                            color: AppColors.textDisabled),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.thumbUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, _) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, _, __) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isPopular) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.accent),
                      ],
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.isAvailable
                        ? Formatters.price(item.priceIqd, currency)
                        : l10n.unavailable,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: item.isAvailable
                          ? AppColors.accent
                          : AppColors.textDisabled,
                    ),
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
