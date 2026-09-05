import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../data/favorites_repository.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<Paginated<Cafe>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<FavoritesRepository>().list();
  }

  Future<void> _reload() async {
    setState(() => _future = sl<FavoritesRepository>().list());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedCafes)),
      body: FutureBuilder<Paginated<Cafe>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xl),
              itemBuilder: (_, __) => const CafeCardSkeleton(),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorView(
              failure: error is Failure
                  ? error
                  : const ServerFailure('Could not load your saved cafés'),
              onRetry: _reload,
            );
          }

          final cafes = snapshot.data!.items;

          if (cafes.isEmpty) {
            return EmptyView(
              icon: Icons.favorite_border,
              title: l10n.noFavorites,
              message: l10n.noFavoritesBody,
              action: FilledButton(
                onPressed: () => context.go(Routes.explore),
                child: Text(l10n.explore),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: cafes.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xl),
              itemBuilder: (context, index) {
                final cafe = cafes[index];
                return CafeCard(
                  cafe: cafe,
                  onTap: () => context.push(Routes.cafe(cafe.slug)),
                  onFavoriteTap: () async {
                    await sl<FavoritesRepository>().toggle(cafe.id);
                    // Unsaving removes it from this list, so refetch rather
                    // than leaving a card that is no longer a favourite.
                    await _reload();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
